//
//  Ghost.swift
//  PacMan
//
//  Created by Andrii Moisol on 06.09.2021.
//

import Foundation
import SpriteKit

class Ghost: SKSpriteNode {
    enum GhostType {
        case blinky
        case pinky
        case inky
        case clyde
    }
    
    private let type: GhostType
    
    init(type: GhostType, size: CGSize) {
        self.type = type
        super.init(texture: SKTexture(imageNamed: "ghost"), color: .clear, size: size)
        
        physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "ghost"), size: size)
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = CategoryBitMask.ghostCategory
        physicsBody?.collisionBitMask = CategoryBitMask.obstacleCategory
        physicsBody?.contactTestBitMask = CategoryBitMask.pacmanCategory
        
        name = "ghost"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
