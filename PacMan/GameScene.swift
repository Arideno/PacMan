//
//  GameScene.swift
//  PacMan
//
//  Created by Andrii Moisol on 05.09.2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var pacman: PacMan!
    private var gameField: SKShapeNode!
    
    private var lastUpdateTime: TimeInterval = 0
    private var dt: CGFloat = 0
    
    let level: Level
    
    init(size: CGSize, level: Level) {
        self.level = level
        super.init(size: size)
    }
    
    override func didMove(to view: SKView) {
        pacman = PacMan(size: CGSize(width: 40, height: 40))
        
        gameField = SKShapeNode(rectOf: CGSize(width: level.tileSize.width * CGFloat(level.map[0].count), height: level.tileSize.height * CGFloat(level.map.count)))
        gameField.fillColor = .black
        gameField.strokeColor = .clear
        gameField.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(gameField)
        
        physicsWorld.contactDelegate = self
        
        for (i, array) in level.map.reversed().enumerated() {
            for (j, element) in array.enumerated() {
                if element == 3 {
                    let obstacle = Obstacle(size: level.tileSize)
                    obstacle.position = .init(x: CGFloat(j) * level.tileSize.width + level.tileSize.width / 2 - gameField.frame.width / 2, y: CGFloat(i) * level.tileSize.height + level.tileSize.height / 2 - gameField.frame.height / 2)
                    gameField.addChild(obstacle)
                } else if element == 2 {
                    let food = Food(radius: 3)
                    food.position = .init(x: CGFloat(j) * level.tileSize.width + level.tileSize.width / 2 - gameField.frame.width / 2, y: CGFloat(i) * level.tileSize.height + level.tileSize.height / 2 - gameField.frame.height / 2)
                    gameField.addChild(food)
                } else if element == 1 {
                    pacman.position = .init(x: CGFloat(j) * level.tileSize.width + level.tileSize.width / 2 - gameField.frame.width / 2, y: CGFloat(i) * level.tileSize.height + level.tileSize.height / 2 - gameField.frame.height / 2)
                    pacman.animate()
                    gameField.addChild(pacman)
                } else if element == 4 {
                    let ghost = Ghost(type: .blinky, size: level.tileSize)
                    ghost.position = .init(x: CGFloat(j) * level.tileSize.width + level.tileSize.width / 2 - gameField.frame.width / 2, y: CGFloat(i) * level.tileSize.height + level.tileSize.height / 2 - gameField.frame.height / 2)
                    gameField.addChild(ghost)
                } else if element == 5 {
                    let ghost = Ghost(type: .pinky, size: level.tileSize)
                    ghost.position = .init(x: CGFloat(j) * level.tileSize.width + level.tileSize.width / 2 - gameField.frame.width / 2, y: CGFloat(i) * level.tileSize.height + level.tileSize.height / 2 - gameField.frame.height / 2)
                    gameField.addChild(ghost)
                } else if element == 6 {
                    let ghost = Ghost(type: .inky, size: level.tileSize)
                    ghost.position = .init(x: CGFloat(j) * level.tileSize.width + level.tileSize.width / 2 - gameField.frame.width / 2, y: CGFloat(i) * level.tileSize.height + level.tileSize.height / 2 - gameField.frame.height / 2)
                    gameField.addChild(ghost)
                } else if element == 7 {
                    let ghost = Ghost(type: .clyde, size: level.tileSize)
                    ghost.position = .init(x: CGFloat(j) * level.tileSize.width + level.tileSize.width / 2 - gameField.frame.width / 2, y: CGFloat(i) * level.tileSize.height + level.tileSize.height / 2 - gameField.frame.height / 2)
                    gameField.addChild(ghost)
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = CGFloat(currentTime - lastUpdateTime)
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        let previousPosition = pacman.position
        let oldJ = Int(((previousPosition.x + gameField.frame.width / 2 - level.tileSize.width / 2) / level.tileSize.width).rounded(.toNearestOrEven))
        let oldI = Int(((previousPosition.y + gameField.frame.height / 2 - level.tileSize.height / 2) / level.tileSize.height).rounded(.toNearestOrEven))
        
        let newPosition = pacman.move(direction: pacman.currentDirection, timeDelta: dt)
        let j = Int(((newPosition.x + gameField.frame.width / 2 - level.tileSize.width / 2) / level.tileSize.width).rounded(.toNearestOrEven))
        let i = Int(((newPosition.y + gameField.frame.height / 2 - level.tileSize.height / 2) / level.tileSize.height).rounded(.toNearestOrEven))
        
        if oldI >= 0 && oldI < level.map.count && oldJ >= 0 && oldI < level.map[0].count {
            level.map[level.map.count - oldI - 1][oldJ] = 0
        }
        if i >= 0 && i < level.map.count && j >= 0 && j < level.map[0].count {
            level.map[level.map.count - i - 1][j] = 1
        }
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0x00:
            pacman.currentDirection = .left
            pacman.run(SKAction.rotate(toAngle: .pi, duration: 0.2))
        case 0x01:
            pacman.currentDirection = .down
            pacman.run(SKAction.rotate(toAngle: -.pi / 2, duration: 0.2))
        case 0x0D:
            pacman.currentDirection = .up
            pacman.run(SKAction.rotate(toAngle: .pi / 2, duration: 0.2))
        case 0x02:
            pacman.currentDirection = .right
            pacman.run(SKAction.rotate(toAngle: 0, duration: 0.2))
        default:
            break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if bodyA.node?.name == "pacman" && bodyB.node?.name == "food" {
            (bodyA.node as! PacMan).eat(food: bodyB.node as! Food)
        } else if bodyB.node?.name == "pacman" && bodyA.node?.name == "food" {
            (bodyB.node as! PacMan).eat(food: bodyA.node as! Food)
        }
        
        if bodyA.node?.name == "pacman" && bodyB.node?.name == "ghost" {
            pacman.removeFromParent()
        } else if bodyA.node?.name == "ghost" && bodyB.node?.name == "pacman" {
            pacman.removeFromParent()
        }
    }
}
