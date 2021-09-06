//
//  ViewController.swift
//  PacMan
//
//  Created by Andrii Moisol on 05.09.2021.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            let scene = GameScene(size: view.bounds.size, level: Level(map: Level.levelMap1, tileSize: .init(width: 20, height: 20)))
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsPhysics = true
        }
    }
}

