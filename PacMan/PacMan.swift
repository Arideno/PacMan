//
//  PacMan.swift
//  PacMan
//
//  Created by Andrii Moisol on 05.09.2021.
//

import Foundation
import SpriteKit

class PacMan: SKSpriteNode {
    
    private var topSemicircle: SKShapeNode!
    private var bottomSemicircle: SKShapeNode!
    
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
    }
    
    func animate() {
        topSemicircle.run(SKAction.repeatForever(SKAction.sequence([SKAction.rotate(toAngle: .pi / 3, duration: 0.3), SKAction.rotate(toAngle: .pi / 8, duration: 0.3)])))
        bottomSemicircle.run(SKAction.repeatForever(SKAction.sequence([SKAction.rotate(toAngle: 2 * .pi / 3, duration: 0.3), SKAction.rotate(toAngle: 7 * .pi / 8, duration: 0.3)])))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
