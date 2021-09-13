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
    
    private var algoLabel: SKLabelNode!
    private var timeLabel: SKLabelNode!
    
    private var lastUpdateTime: TimeInterval = 0
    private var dt: CGFloat = 0
    private var allDt: CGFloat = 0
    
    let level: Level
    
    private var isSearching: Bool = false
    private let algorithms: [Algorithm] = [DFS(), BFS(), UCS()]
    private var currentAlgorithmIndex = 0
    
    init(size: CGSize, level: Level, score: Int = 0) {
        self.level = level
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
        
        algoLabel = SKLabelNode(text: "Algorithm: \(algorithms[currentAlgorithmIndex].name)")
        algoLabel.color = .white
        algoLabel.position = CGPoint(x: size.width - 70, y: size.height - 150)
        algoLabel.fontSize = 16
        addChild(algoLabel)
        
        timeLabel = SKLabelNode(text: "\(0)")
        timeLabel.color = .white
        timeLabel.position = CGPoint(x: size.width - 70, y: size.height - 200)
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
                    ghost.move(level: level)
                }
                
                if element & CategoryBitMask.pinkyCategory != 0 {
                    let ghost = Ghost(type: .pinky, size: level.tileSize)
                    ghost.position = .init(x: CGFloat(j) * level.tileSize.width + level.tileSize.width / 2 - gameField.frame.width / 2, y: CGFloat(i) * level.tileSize.height + level.tileSize.height / 2 - gameField.frame.height / 2)
                    gameField.addChild(ghost)
                    ghost.zPosition = 1
                    ghost.move(level: level)
                }
                
                if element & CategoryBitMask.inkyCategory != 0 {
                    let ghost = Ghost(type: .inky, size: level.tileSize)
                    ghost.position = .init(x: CGFloat(j) * level.tileSize.width + level.tileSize.width / 2 - gameField.frame.width / 2, y: CGFloat(i) * level.tileSize.height + level.tileSize.height / 2 - gameField.frame.height / 2)
                    gameField.addChild(ghost)
                    ghost.zPosition = 1
                    ghost.move(level: level)
                }
                
                if element & CategoryBitMask.clydeCategory != 0 {
                    let ghost = Ghost(type: .clyde, size: level.tileSize)
                    ghost.position = .init(x: CGFloat(j) * level.tileSize.width + level.tileSize.width / 2 - gameField.frame.width / 2, y: CGFloat(i) * level.tileSize.height + level.tileSize.height / 2 - gameField.frame.height / 2)
                    gameField.addChild(ghost)
                    ghost.zPosition = 1
                    ghost.move(level: level)
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
        allDt += dt
        
        guard !isSearching, allDt > 1 else { return }
        
        let previousPosition = pacman.position
        let oldJ = Int(((previousPosition.x + gameField.frame.width / 2 - level.tileSize.width / 2) / level.tileSize.width).rounded(.toNearestOrEven))
        let oldI = Int(((previousPosition.y + gameField.frame.height / 2 - level.tileSize.height / 2) / level.tileSize.height).rounded(.toNearestOrEven))
        
        let newPosition = pacman.move(direction: pacman.currentDirection, timeDelta: dt)
        let j = Int(((newPosition.x + gameField.frame.width / 2 - level.tileSize.width / 2) / level.tileSize.width).rounded(.toNearestOrEven))
        let i = Int(((newPosition.y + gameField.frame.height / 2 - level.tileSize.height / 2) / level.tileSize.height).rounded(.toNearestOrEven))
        
        if oldI >= 0 && oldI < level.map.count && oldJ >= 0 && oldI < level.map[0].count {
            level.map[level.map.count - oldI - 1][oldJ] = level.map[level.map.count - oldI - 1][oldJ] & (~(CategoryBitMask.pacmanCategory | CategoryBitMask.foodCategory))
        }
        if i >= 0 && i < level.map.count && j >= 0 && j < level.map[0].count {
            level.map[level.map.count - i - 1][j] = (level.map[level.map.count - oldI - 1][oldJ] | CategoryBitMask.pacmanCategory) & (~CategoryBitMask.foodCategory)
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
        case 0x35:
            if isSearching {
                gameField.children.filter({ $0.name == "path" }).forEach({ $0.removeFromParent() })
                isSearching = false
                pacman.isPaused = isSearching
                gameField.children.filter({ $0.name == "ghost" }).forEach({ $0.isPaused = isSearching })
                currentAlgorithmIndex = 0
            } else {
                search()
            }
        case 0x06:
            guard isSearching else { return }
            currentAlgorithmIndex += 1
            if currentAlgorithmIndex >= algorithms.count {
                currentAlgorithmIndex = 0
            }
            algoLabel.text = "Algorithm: \(algorithms[currentAlgorithmIndex].name)"
            search()
        default:
            break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func search() {
        gameField.children.filter({ $0.name == "path" }).forEach({ $0.removeFromParent() })
        isSearching = true
        pacman.isPaused = isSearching
        gameField.children.filter({ $0.name == "ghost" }).forEach({ $0.isPaused = isSearching })
        guard isSearching else { return }
        
        let pacmanJ = Int(((pacman.position.x + gameField.frame.width / 2 - level.tileSize.width / 2) / level.tileSize.width).rounded(.toNearestOrEven))
        let pacmanI = level.map.count - Int(((pacman.position.y + gameField.frame.height / 2 - level.tileSize.height / 2) / level.tileSize.height).rounded(.toNearestOrEven)) - 1
        
        var ghostsPoints = [Point]()
        
        gameField.children.filter({ $0.name == "ghost" }).forEach({
            let ghostJ = Int((($0.position.x + gameField.frame.width / 2 - level.tileSize.width / 2) / level.tileSize.width).rounded(.toNearestOrEven))
            let ghostI = level.map.count - Int((($0.position.y + gameField.frame.height / 2 - level.tileSize.height / 2) / level.tileSize.height).rounded(.toNearestOrEven)) - 1
            ghostsPoints.append(Point(i: ghostI, j: ghostJ))
        })
        
        var allTime: CFAbsoluteTime = 0
        
        ghostsPoints.forEach { point in
            let timer = ParkBenchTimer()
            let path = algorithms[currentAlgorithmIndex].calculatePath(map: level.map, pacmanPosition: Point(i: pacmanI, j: pacmanJ), ghostPosition: point)
            allTime += timer.stop()
            
            path.forEach { point in
                let node = SKSpriteNode(color: .red, size: .init(width: 20, height: 20))
                node.position = .init(x: CGFloat(point.j) * level.tileSize.width + level.tileSize.width / 2 - gameField.frame.width / 2, y: CGFloat(level.map.count - point.i - 1) * level.tileSize.height + level.tileSize.height / 2 - gameField.frame.height / 2)
                node.zPosition = 0
                node.name = "path"
                gameField.addChild(node)
            }
        }
        
        timeLabel.text = String(format: "%.2fms", allTime * 1000)
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
    
    private func checkWin() {
        if !level.map.contains(where: { $0.contains(where: { $0 & CategoryBitMask.foodCategory != 0 }) }) {
            let nextLevel = Level(map: Level.generateMap(), number: level.number + 1, tileSize: .init(width: 20, height: 20))
            let gameScene = GameScene(size: size, level: nextLevel, score: score)
            gameScene.scaleMode = .aspectFill
            view?.presentScene(gameScene, transition: .fade(withDuration: 0.5))
        }
    }
    
    private func gameOver() {
        let highScore = UserDefaults.standard.integer(forKey: "highScore")
        
        if score > highScore {
            UserDefaults.standard.setValue(score, forKey: "highScore")
        }
        
        let scene = StartScene(size: size)
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: .fade(withDuration: 0.5))
    }
}
