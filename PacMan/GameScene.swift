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
    
    override func didMove(to view: SKView) {
        pacman = PacMan(size: CGSize(width: 40, height: 40))
        pacman.position = .init(x: size.width / 2, y: size.height / 2)
        addChild(pacman)
        pacman.animate()
    }
}
