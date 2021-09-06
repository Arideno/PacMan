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
    
    override func didMove(to view: SKView) {
        pacman = PacMan(size: CGSize(width: 40, height: 40))
        pacman.position = .init(x: size.width / 2, y: size.height / 2)
        addChild(pacman)
        pacman.animate()
        
        let food = Food(radius: 5)
        food.position = CGPoint(x: size.width / 2 - 100, y: size.height / 2)
        addChild(food)
        
        physicsWorld.contactDelegate = self
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
