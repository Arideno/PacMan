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
    
    private var lastUpdateTime: TimeInterval = 0
    private var dt: CGFloat = 0
    
    let level: Level
    
    init(size: CGSize, level: Level) {
        self.level = level
        super.init(size: size)
    }
    
    override func didMove(to view: SKView) {
        pacman = PacMan(size: CGSize(width: 40, height: 40))
        
        let gameField = SKShapeNode(rectOf: CGSize(width: level.tileSize.width * CGFloat(level.map[0].count), height: level.tileSize.height * CGFloat(level.map.count)))
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
        
        pacman.move(direction: pacman.currentDirection, timeDelta: dt)
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
    }
}
