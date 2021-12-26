//
//  Level.swift
//  PacMan
//
//  Created by Andrii Moisol on 26.29.2221.
//

import Foundation

class Level: Equatable {
    static func == (lhs: Level, rhs: Level) -> Bool {
        lhs.number == rhs.number
    }

    static let staticLevel = Level(map: Level.generateMap(numberOfRandomGhosts: 2, numberOfAStarGhosts: 2), number: 1, tileSize: .init(width: 20, height: 20))
    
    var map: [[UInt32]]
    var number: Int
    let tileSize: CGSize
    
    init(map: [[UInt32]], number: Int, tileSize: CGSize) {
        self.map = map
        self.number = number
        self.tileSize = tileSize
    }

    static func evalMap(map: [[UInt32]]) -> Double {
        var pacManPosition = Point(i: 0, j: 0)
        var ghostsPositions = [Point]()
        var foodPositions = [Point]()
        for (i, arr) in map.enumerated() {
            for (j, category) in arr.enumerated() {
                if category & CategoryBitMask.pacmanCategory != 0 {
                    pacManPosition = Point(i: i, j: j)
                }
                if category & (CategoryBitMask.blinkyCategory | CategoryBitMask.pinkyCategory) != 0 {
                    ghostsPositions.append(Point(i: i, j: j))
                }
                if category & CategoryBitMask.foodCategory != 0 {
                    foodPositions.append(Point(i: i, j: j))
                }
            }
        }

        let minGhostPosition = ghostsPositions.min { p1, p2 in
            abs(pacManPosition.i - p1.i) + abs(pacManPosition.j - p1.j) < abs(pacManPosition.i - p2.i) + abs(pacManPosition.j - p2.j)
        }!
        let minGhostDistance = Double(abs(pacManPosition.i - minGhostPosition.i) + abs(pacManPosition.j - minGhostPosition.j))

        if minGhostDistance == 0 {
            return -10000
        }

        if foodPositions.count == 0 {
            return 10000
        }

        return (1 / minGhostDistance) * -500 + (1 / Double(foodPositions.count)) * 100 + Double.random(in: 0...100)
    }

    static func childMapForMove(map: [[UInt32]], move: (Int, Int)) -> [[UInt32]]? {
        var pacManPosition = Point(i: 0, j: 0)
        var ghostsPositions = [Point]()
        for (i, arr) in map.enumerated() {
            for (j, category) in arr.enumerated() {
                if category & CategoryBitMask.pacmanCategory != 0 {
                    pacManPosition = Point(i: i, j: j)
                }
                if category & (CategoryBitMask.blinkyCategory | CategoryBitMask.pinkyCategory) != 0 {
                    ghostsPositions.append(Point(i: i, j: j))
                }
            }
        }

        var map = map

        let newPosition = Point(i: pacManPosition.i + move.0, j: pacManPosition.j + move.1)
        guard newPosition.i >= 0 && newPosition.j >= 0 && newPosition.i < map.count && newPosition.j < map[0].count && map[newPosition.i][newPosition.j] & CategoryBitMask.obstacleCategory == 0 else { return nil }
        map[pacManPosition.i][pacManPosition.j] = map[pacManPosition.i][pacManPosition.j] & (~(CategoryBitMask.pacmanCategory | CategoryBitMask.foodCategory))
        map[newPosition.i][newPosition.j] = map[newPosition.i][newPosition.j] | CategoryBitMask.pacmanCategory

        for ghostsPosition in ghostsPositions {
            let path = AStar().calculatePath(map: map, from: ghostsPosition, to: newPosition)
            guard let ghostNextPosition = path.first else { continue }
            let category = map[ghostsPosition.i][ghostsPosition.j]
            map[ghostsPosition.i][ghostsPosition.j] = map[ghostsPosition.i][ghostsPosition.j] & (~category)
            map[ghostNextPosition.i][ghostNextPosition.j] = map[ghostNextPosition.i][ghostNextPosition.j] | category
        }

        return map
    }
}

extension Level {
    // 4 - obstacle, 2 - food, 1 - pacman, 0 - empty, 8 - Blinky, 16 - Pinky, 32 - Inky, 64 - Clyde
    static func generateMap(numberOfRandomGhosts: Int, numberOfAStarGhosts: Int) -> [[UInt32]] {
        var map = Array(repeating: [UInt32](repeating: 4, count: 28), count: 30)
        let i = Int.random(in: 1..<29)
        let j = Int.random(in: 1..<27)
        
        map[i][j] = 2
        var walls = [Point]()
        walls += getNeighbors(map: map, point: Point(i: i, j: j)).filter({ map[$0.i][$0.j] & CategoryBitMask.obstacleCategory != 0 })
        
        while !walls.isEmpty {
            let currentWall = walls.randomElement()!
            if getNeighbors(map: map, point: currentWall).filter({ map[$0.i][$0.j] & CategoryBitMask.obstacleCategory == 0 }).count == 1 {
                map[currentWall.i][currentWall.j] = 2
                walls += getNeighbors(map: map, point: currentWall).filter({ map[$0.i][$0.j] & CategoryBitMask.obstacleCategory != 0 })
            }
            walls.remove(at: walls.firstIndex(of: currentWall)!)
        }
        
        var wallsToDelete = 50
        
        while wallsToDelete > 0 {
            let i = Int.random(in: 1 ..< 29)
            let j = Int.random(in: 1 ..< 27)
            if map[i][j] & CategoryBitMask.obstacleCategory != 0 && getNeighbors(map: map, point: Point(i: i, j: j)).filter({ map[$0.i][$0.j] & CategoryBitMask.obstacleCategory == 0 }).count >= 1 {
                map[i][j] = 2
                wallsToDelete -= 1
            }
        }
        
        var pacmanI = 0
        var pacmanJ = 0
        
        while map[pacmanI][pacmanJ] & CategoryBitMask.obstacleCategory != 0 {
            pacmanI = Int.random(in: 0..<30)
            pacmanJ = Int.random(in: 0..<28)
        }
        
        map[pacmanI][pacmanJ] = 1
        
        (0..<numberOfRandomGhosts).forEach { _ in
            var ghostI = 0
            var ghostJ = 0
            
            while (map[ghostI][ghostJ] & CategoryBitMask.obstacleCategory != 0) || (map[ghostI][ghostJ] & CategoryBitMask.pacmanCategory != 0) {
                ghostI = Int.random(in: 0..<30)
                ghostJ = Int.random(in: 0..<28)
            }
            
            map[ghostI][ghostJ] = CategoryBitMask.foodCategory | CategoryBitMask.blinkyCategory
        }

        (0..<numberOfAStarGhosts).forEach { _ in
            var ghostI = 0
            var ghostJ = 0

            while (map[ghostI][ghostJ] & CategoryBitMask.obstacleCategory != 0) || (map[ghostI][ghostJ] & CategoryBitMask.pacmanCategory != 0) {
                ghostI = Int.random(in: 0..<30)
                ghostJ = Int.random(in: 0..<28)
            }

            map[ghostI][ghostJ] = CategoryBitMask.foodCategory | CategoryBitMask.pinkyCategory
        }
        
        return map
    }
    
    static func getNeighbors(map: [[UInt32]], point: Point) -> [Point] {
        var neighbors = [Point]()
        let i = point.i
        let j = point.j
        if i > 1 {
            neighbors.append(Point(i: i-1, j: j))
        }
        if j > 1 {
            neighbors.append(Point(i: i, j: j-1))
        }
        if i < map.count - 2 {
            neighbors.append(Point(i: i+1, j: j))
        }
        if j < map[0].count - 2 {
            neighbors.append(Point(i: i, j: j+1))
        }
        return neighbors
    }
}
