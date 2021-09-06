//
//  Obstacle.swift
//  PacMan
//
//  Created by Andrii Moisol on 06.09.2021.
//

import Foundation
import SpriteKit

class Obstacle: SKSpriteNode {
    init(size: CGSize) {
        super.init(texture: nil, color: .clear, size: size)
        
        let rect = SKShapeNode(rectOf: size)
        rect.fillColor = .blue
        rect.strokeColor = .clear
        
        addChild(rect)
        
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.affectedByGravity = false
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = CategoryBitMask.obstacleCategory
        physicsBody?.collisionBitMask = CategoryBitMask.pacmanCategory
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
