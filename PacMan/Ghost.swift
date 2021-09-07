//
//  Ghost.swift
//  PacMan
//
//  Created by Andrii Moisol on 06.09.2021.
//

import Foundation
import SpriteKit

struct Point: Hashable, Equatable {
    let i: Int
    let j: Int
}

class Ghost: SKSpriteNode {
    enum GhostType: UInt32 {
        case blinky = 8
        case pinky = 16
        case inky = 32
        case clyde = 64
    }
    
    private let type: GhostType
    
    init(type: GhostType, size: CGSize) {
        self.type = type
        super.init(texture: SKTexture(imageNamed: "ghost"), color: .clear, size: size)
        
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.affectedByGravity = false
    
        switch type {
        case .blinky:
            physicsBody?.categoryBitMask = CategoryBitMask.blinkyCategory
        case .pinky:
            physicsBody?.categoryBitMask = CategoryBitMask.pinkyCategory
        case .inky:
            physicsBody?.categoryBitMask = CategoryBitMask.inkyCategory
        case .clyde:
            physicsBody?.categoryBitMask = CategoryBitMask.clydeCategory
        }
        
        physicsBody?.collisionBitMask = CategoryBitMask.obstacleCategory
        physicsBody?.contactTestBitMask = CategoryBitMask.pacmanCategory
        
        name = "ghost"
    }
    
    func move(level: Level) {
        let randomDirection = Direction(rawValue: Int.random(in: 0...3))!
        
        let oldJ = Int(((position.x + parent!.frame.width / 2 - level.tileSize.width / 2) / level.tileSize.width).rounded(.toNearestOrEven))
        let oldI = Int(((position.y + parent!.frame.height / 2 - level.tileSize.height / 2) / level.tileSize.height).rounded(.toNearestOrEven))
        
        level.map[level.map.count - oldI - 1][oldJ] = (level.map[level.map.count - oldI - 1][oldJ] & (~type.rawValue))
        
        var i: Int = 0
        var j: Int = 0
        
        var isOk = true
        
        if randomDirection == .up {
            if oldI < level.map.count - 1 {
                i = oldI + 1
                j = oldJ
            } else {
                isOk = false
            }
        } else if randomDirection == .down {
            if oldI > 0 {
                i = oldI - 1
                j = oldJ
            } else {
                isOk = false
            }
        } else if randomDirection == .left {
            if oldJ > 0 {
                i = oldI
                j = oldJ - 1
            } else {
                isOk = false
            }
        } else if randomDirection == .right {
            if oldJ < level.map[0].count - 1 {
                i = oldI
                j = oldJ + 1
            } else {
                isOk = false
            }
        }
        
        guard isOk && (level.map[level.map.count - i - 1][j] & CategoryBitMask.obstacleCategory == 0) else {
            move(level: level)
            return
        }
        
        level.map[level.map.count - i - 1][j] = level.map[level.map.count - i - 1][j] | type.rawValue
        
        let newPosition = CGPoint(x: CGFloat(j) * level.tileSize.width + level.tileSize.width / 2 - parent!.frame.width / 2, y: CGFloat(i) * level.tileSize.height + level.tileSize.height / 2 - parent!.frame.height / 2)
        
        run(SKAction.sequence([
            SKAction.move(to: newPosition, duration: 0.5),
            SKAction.run { [weak self] in
                self?.move(level: level)
            }
        ]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
