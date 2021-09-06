//
//  Food.swift
//  PacMan
//
//  Created by Andrii Moisol on 06.09.2021.
//

import Foundation
import SpriteKit

class Food: SKSpriteNode {
    init(radius: CGFloat) {
        super.init(texture: nil, color: .clear, size: CGSize(width: radius * 2, height: radius * 2))
        
        let cirlce = SKShapeNode(circleOfRadius: radius)
        cirlce.fillColor = .purple
        cirlce.strokeColor = .clear
        addChild(cirlce)
        
        physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody?.affectedByGravity = false
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = CategoryBitMask.foodCategory
        physicsBody?.contactTestBitMask = CategoryBitMask.pacmanCategory
        
        name = "food"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
