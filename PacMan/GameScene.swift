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
    private var gameField: SKShapeNode!
    private var scoreLabel: SKLabelNode!
    private var score: Int

    private var ghosts: [Ghost] = []

    private var timeLabel: SKLabelNode!
    
    private var lastUpdateTime: TimeInterval = 0
    private var dt: CGFloat = 0
    
    let level: Level
    
    let expectimax: Bool = false
    var isGameOver = false

    let startTime = Date()
    
    init(size: CGSize, level: Level, score: Int = 0) {
        self.level = Level(map: level.map, number: level.number, tileSize: level.tileSize)
        self.score = score
        super.init(size: size)
    }
    
    override func didMove(to view: SKView) {
        pacman = PacMan(size: CGSize(width: 40, height: 40))
        
        gameField = SKShapeNode(rectOf: CGSize(width: level.tileSize.width * CGFloat(level.map[0].count), height: level.tileSize.height * CGFloat(level.map.count)))
        gameField.fillColor = .black
        gameField.strokeColor = .clear
        gameField.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(gameField)
        
        scoreLabel = SKLabelNode(text: "Score: \(0)")
        scoreLabel.color = .white
        scoreLabel.position = CGPoint(x: size.width - 70, y: size.height - 50)
        scoreLabel.fontSize = 16
        addChild(scoreLabel)
        
        let levelLabel = SKLabelNode(text: "Level: \(level.number)")
        levelLabel.color = .white
        levelLabel.position = CGPoint(x: size.width - 70, y: size.height - 100)
        levelLabel.fontSize = 14
        addChild(levelLabel)
        
        timeLabel = SKLabelNode(text: "\(0)")
        timeLabel.color = .white
        timeLabel.position = CGPoint(x: size.width - 70, y: size.height - 150)
        timeLabel.fontSize = 13
        addChild(timeLabel)
        
        physicsWorld.contactDelegate = self
        
        for (i, array) in level.map.reversed().enumerated() {
            for (j, element) in array.enumerated() {
                if element & CategoryBitMask.obstacleCategory != 0 {
                    let obstacle = Obstacle(size: level.tileSize)
                    obstacle.position = .init(x: CGFloat(j) * level.tileSize.width + level.tileSize.width / 2 - gameField.frame.width / 2, y: CGFloat(i) * level.tileSize.height + level.tileSize.height / 2 - gameField.frame.height / 2)
                    gameField.addChild(obstacle)
                }
                
                if element & CategoryBitMask.foodCategory != 0 {
                    let food = Food(radius: 3)
                    food.position = .init(x: CGFloat(j) * level.tileSize.width + level.tileSize.width / 2 - gameField.frame.width / 2, y: CGFloat(i) * level.tileSize.height + level.tileSize.height / 2 - gameField.frame.height / 2)
                    gameField.addChild(food)
                }
                
                if element & CategoryBitMask.pacmanCategory != 0 {
                    pacman.position = .init(x: CGFloat(j) * level.tileSize.width + level.tileSize.width / 2 - gameField.frame.width / 2, y: CGFloat(i) * level.tileSize.height + level.tileSize.height / 2 - gameField.frame.height / 2)
                    pacman.zPosition = 1
                    pacman.animate()
                    gameField.addChild(pacman)
                }
                
                if element & CategoryBitMask.blinkyCategory != 0 {
                    let ghost = Ghost(type: .blinky, size: level.tileSize)
                    ghost.position = .init(x: CGFloat(j) * level.tileSize.width + level.tileSize.width / 2 - gameField.frame.width / 2, y: CGFloat(i) * level.tileSize.height + level.tileSize.height / 2 - gameField.frame.height / 2)
                    gameField.addChild(ghost)
                    ghost.zPosition = 1
                    ghosts.append(ghost)
                }
                
                if element & CategoryBitMask.pinkyCategory != 0 {
                    let ghost = Ghost(type: .pinky, size: level.tileSize)
                    ghost.position = .init(x: CGFloat(j) * level.tileSize.width + level.tileSize.width / 2 - gameField.frame.width / 2, y: CGFloat(i) * level.tileSize.height + level.tileSize.height / 2 - gameField.frame.height / 2)
                    gameField.addChild(ghost)
                    ghost.zPosition = 1
                    ghosts.append(ghost)
                }
                
                if element & CategoryBitMask.inkyCategory != 0 {
                    let ghost = Ghost(type: .inky, size: level.tileSize)
                    ghost.position = .init(x: CGFloat(j) * level.tileSize.width + level.tileSize.width / 2 - gameField.frame.width / 2, y: CGFloat(i) * level.tileSize.height + level.tileSize.height / 2 - gameField.frame.height / 2)
                    gameField.addChild(ghost)
                    ghost.zPosition = 1
                    ghosts.append(ghost)
                }
                
                if element & CategoryBitMask.clydeCategory != 0 {
                    let ghost = Ghost(type: .clyde, size: level.tileSize)
                    ghost.position = .init(x: CGFloat(j) * level.tileSize.width + level.tileSize.width / 2 - gameField.frame.width / 2, y: CGFloat(i) * level.tileSize.height + level.tileSize.height / 2 - gameField.frame.height / 2)
                    gameField.addChild(ghost)
                    ghost.zPosition = 1
                    ghosts.append(ghost)
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = CGFloat(currentTime - lastUpdateTime)
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime

        let previousPosition = pacman.position
        let oldJ = Int(((previousPosition.x + gameField.frame.width / 2 - level.tileSize.width / 2) / level.tileSize.width).rounded(.toNearestOrEven))
        let oldI = Int(((previousPosition.y + gameField.frame.height / 2 - level.tileSize.height / 2) / level.tileSize.height).rounded(.toNearestOrEven))

        ghosts.forEach { ghost in
            if !ghost.hasActions() {
                if ghost.type == .blinky {
                    ghost.moveRandom(level: level)
                } else if ghost.type == .pinky {
                    ghost.moveAStar(level: level, to: Point(i: level.map.count - oldI - 1, j: oldJ))
                }
            }
        }

        if !pacman.hasActions() {
            if let bestMove = PacMan.bestMove(map: level.map, expectimax: expectimax) {
                pacman.move(level: level, move: bestMove)
            }
        }
        
        checkWin()
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if bodyA.node?.name == "pacman" && bodyB.node?.name == "food" {
            (bodyA.node as! PacMan).eat(food: bodyB.node as! Food)
            increaseScore(by: 10)
        } else if bodyB.node?.name == "pacman" && bodyA.node?.name == "food" {
            (bodyB.node as! PacMan).eat(food: bodyA.node as! Food)
            increaseScore(by: 10)
        }
        
        if bodyA.node?.name == "pacman" && bodyB.node?.name == "ghost" {
            gameOver()
        } else if bodyA.node?.name == "ghost" && bodyB.node?.name == "pacman" {
            gameOver()
        }
    }
    
    private func increaseScore(by amount: Int) {
        score += amount
        scoreLabel.text = "Score: \(score)"
    }

    private func writeResultsToFile(win: Bool) {
        let time = Date().timeIntervalSince(startTime)
        let fileURL = URL(fileURLWithPath: "results.csv", isDirectory: false)
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: "win,time,score,algo\n".data(using: .utf8), attributes: nil)
        }
        guard let handle = FileHandle(forWritingAtPath: fileURL.path) else { return }

        defer {
            try! handle.close()
        }

        try! handle.seekToEnd()
        try! handle.write(contentsOf: "\(win ? "win" : "lose"),\(time),\(score),\(self.expectimax ? "expectimax" : "minimax")\n".data(using: .utf8)!)
    }
    
    private func checkWin() {
        if !level.map.contains(where: { $0.contains(where: { $0 & CategoryBitMask.foodCategory != 0 }) }) {
            writeResultsToFile(win: true)
            let nextLevel = Level.staticLevel
            nextLevel.number += 1
            let gameScene = GameScene(size: size, level: nextLevel, score: score)
            gameScene.scaleMode = .aspectFill
            view?.presentScene(gameScene, transition: .fade(withDuration: 0.5))
        }
    }
    
    private func gameOver() {
        guard !isGameOver else { return }
        isGameOver = true
        writeResultsToFile(win: false)
        let highScore = UserDefaults.standard.integer(forKey: "highScore")
        
        if score > highScore {
            UserDefaults.standard.setValue(score, forKey: "highScore")
        }
        
        let scene = StartScene(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: .fade(withDuration: 0.5))
    }
}
