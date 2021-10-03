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
    
    func move(level: Level, to: Point) {
        let oldJ = Int(((position.x + parent!.frame.width / 2 - level.tileSize.width / 2) / level.tileSize.width).rounded(.toNearestOrEven))
        let oldI = Int(((position.y + parent!.frame.height / 2 - level.tileSize.height / 2) / level.tileSize.height).rounded(.toNearestOrEven))

        level.map[level.map.count - oldI - 1][oldJ] = (level.map[level.map.count - oldI - 1][oldJ] & (~type.rawValue))
        
        let path = UCS().calculatePath(map: level.map, from: Point(i: level.map.count - oldI - 1, j: oldJ), to: to)
        guard let point = path.first else { return }
        let i = level.map.count - point.i - 1
        let j = point.j
        
        level.map[level.map.count - i - 1][j] = level.map[level.map.count - i - 1][j] | type.rawValue
        
        let newPosition = CGPoint(x: CGFloat(j) * level.tileSize.width + level.tileSize.width / 2 - parent!.frame.width / 2, y: CGFloat(i) * level.tileSize.height + level.tileSize.height / 2 - parent!.frame.height / 2)

        run(SKAction.move(to: newPosition, duration: 0.5))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
