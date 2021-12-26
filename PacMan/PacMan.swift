//
//  PacMan.swift
//  PacMan
//
//  Created by Andrii Moisol on 05.09.2021.
//

import Foundation
import SpriteKit

enum Direction: Int {
    case left
    case right
    case up
    case down
}

class PacMan: SKSpriteNode {
    
    private var topSemicircle: SKShapeNode!
    private var bottomSemicircle: SKShapeNode!
    
    var currentDirection: Direction = .right
    private let currentSpeed: CGFloat = 50
    
    let chompActionSound: SKAction = {
        return SKAction.playSoundFileNamed("pacman_chomp", waitForCompletion: false)
    }()
    
    init(size: CGSize) {
        super.init(texture: nil, color: .clear, size: size)
        
        self.size = size
        let path = CGMutablePath()
        path.addArc(center: .zero, radius: size.width / 4, startAngle: 0, endAngle: .pi, clockwise: false)
        topSemicircle = SKShapeNode(path: path)
        topSemicircle.fillColor = .yellow
        topSemicircle.zRotation = .pi / 8
        topSemicircle.strokeColor = .clear
        bottomSemicircle = SKShapeNode(path: path)
        bottomSemicircle.fillColor = .yellow
        bottomSemicircle.zRotation = 7 * .pi / 8
        bottomSemicircle.strokeColor = .clear
        self.addChild(topSemicircle)
        self.addChild(bottomSemicircle)
        
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 4)
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = CategoryBitMask.pacmanCategory
        physicsBody?.collisionBitMask = CategoryBitMask.obstacleCategory
        physicsBody?.contactTestBitMask = CategoryBitMask.foodCategory | CategoryBitMask.blinkyCategory | CategoryBitMask.inkyCategory | CategoryBitMask.clydeCategory
        
        name = "pacman"
    }
    
    func animate() {
        topSemicircle.run(SKAction.repeatForever(SKAction.sequence([SKAction.rotate(toAngle: .pi / 3, duration: 0.3), SKAction.rotate(toAngle: .pi / 8, duration: 0.3)])))
        bottomSemicircle.run(SKAction.repeatForever(SKAction.sequence([SKAction.rotate(toAngle: 2 * .pi / 3, duration: 0.3), SKAction.rotate(toAngle: 7 * .pi / 8, duration: 0.3)])))
    }

    func move(level: Level, move: (Int, Int)) {
        let oldJ = Int(((position.x + parent!.frame.width / 2 - level.tileSize.width / 2) / level.tileSize.width).rounded(.toNearestOrEven))
        let oldI = Int(((position.y + parent!.frame.height / 2 - level.tileSize.height / 2) / level.tileSize.height).rounded(.toNearestOrEven))

        level.map[level.map.count - oldI - 1][oldJ] = level.map[level.map.count - oldI - 1][oldJ] & (~(CategoryBitMask.pacmanCategory | CategoryBitMask.foodCategory))

        let i = oldI - move.0
        let j = oldJ + move.1

        if oldI > i && currentDirection != .down {
            currentDirection = .down
            run(SKAction.rotate(toAngle: -.pi / 2, duration: 0.2))
        } else if oldI < i && currentDirection != .up {
            currentDirection = .up
            run(SKAction.rotate(toAngle: .pi / 2, duration: 0.2))
        } else if oldJ > j && currentDirection != .left {
            currentDirection = .left
            run(SKAction.rotate(toAngle: .pi, duration: 0.2))
        } else if oldJ < j && currentDirection != .right {
            currentDirection = .right
            run(SKAction.rotate(toAngle: 0, duration: 0.2))
        }

        level.map[level.map.count - i - 1][j] = level.map[level.map.count - i - 1][j] | (CategoryBitMask.pacmanCategory & ~CategoryBitMask.foodCategory)

        let newPosition = CGPoint(x: CGFloat(j) * level.tileSize.width + level.tileSize.width / 2 - parent!.frame.width / 2, y: CGFloat(i) * level.tileSize.height + level.tileSize.height / 2 - parent!.frame.height / 2)

        run(SKAction.move(to: newPosition, duration: 0.5))
    }
    
    func eat(food: Food) {
        food.run(SKAction.removeFromParent())
//        run(chompActionSound)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func bestMove(map: [[UInt32]], expectimax: Bool = false) -> (Int, Int)? {
        var bestMove: (Int, Int)?
        var bestValue: Double = -100000

        for move in [(0, 1), (1, 0), (0, -1), (-1, 0)].shuffled() {
            if let childMap = Level.childMapForMove(map: map, move: move) {
                var value: Double
                if expectimax {
                    value = PacMan.expectimax(map: childMap, depth: 3, isMaximizingPlayer: false)
                } else {
                    value = PacMan.minimax(map: childMap, depth: 3, alpha: 0, beta: 0, isMaximizingPlayer: true)
                }
                if value > bestValue {
                    bestValue = value
                    bestMove = move
                }
            }
        }

        return bestMove
    }

    static func minimax(map: [[UInt32]], depth: Int, alpha: Double, beta: Double, isMaximizingPlayer: Bool) -> Double {
        if depth == 0 {
            return Level.evalMap(map: map)
        }
        var alpha = alpha
        var beta = beta
        if isMaximizingPlayer {
            var value: Double = -100000
            for move in [(0, 1), (1, 0), (0, -1), (-1, 0)].shuffled() {
                if let childMap = Level.childMapForMove(map: map, move: move) {
                    value = max(value, minimax(map: childMap, depth: depth - 1, alpha: alpha, beta: beta, isMaximizingPlayer: true))
                    if value >= beta {
                        break
                    }
                    alpha = max(alpha, value)
                }
            }
            return value
        } else {
            var value: Double = 100000
            for move in [(0, 1), (1, 0), (0, -1), (-1, 0)].shuffled() {
                if let childMap = Level.childMapForMove(map: map, move: move) {
                    value = min(value, minimax(map: childMap, depth: depth - 1, alpha: alpha, beta: beta, isMaximizingPlayer: true))
                    if value <= alpha {
                        break
                    }
                    beta = min(beta, value)
                }
            }
            return value
        }
    }

    static func expectimax(map: [[UInt32]], depth: Int, isMaximizingPlayer: Bool) -> Double {
        if depth == 0 {
            return Level.evalMap(map: map)
        }
        if isMaximizingPlayer {
            var value: Double = -100000
            for move in [(0, 1), (1, 0), (0, -1), (-1, 0)].shuffled() {
                if let childMap = Level.childMapForMove(map: map, move: move) {
                    value = max(value, expectimax(map: childMap, depth: depth - 1, isMaximizingPlayer: false)) * [0, 0.25, 0.5, 0.75].randomElement()!
                }
            }
            return value
        } else {
            var value: Double = 100000
            for move in [(0, 1), (1, 0), (0, -1), (-1, 0)].shuffled() {
                if let childMap = Level.childMapForMove(map: map, move: move) {
                    value = min(value, expectimax(map: childMap, depth: depth - 1, isMaximizingPlayer: true)) * [0, 0.25, 0.5, 0.75].randomElement()!
                }
            }
            return value
        }
    }
}
