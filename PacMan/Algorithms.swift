//
//  Algorithms.swift
//  PacMan
//
//  Created by Andrii Moisol on 13.09.2021.
//

import Foundation

protocol Algorithm {
    var name: String { get }
    
    func calculatePath(map: [[UInt32]], pacmanPosition: Point, ghostPosition: Point) -> [Point]
}

class DFS: Algorithm {
    let name: String = "DFS"
    
    func calculatePath(map: [[UInt32]], pacmanPosition: Point, ghostPosition: Point) -> [Point] {
        var points = [Point]()
        
        var path = [Point: Point]()
        
        var stack = [Point]()
        var visited = Set<Point>()
        
        stack.append(pacmanPosition)
        
        while !stack.isEmpty {
            let top = stack.removeFirst()
            visited.insert(top)
            if top == ghostPosition {
                break
            }
            let neighbors = Level.getNeighbors(map: map, point: top)
            neighbors.forEach({
                if !visited.contains($0) && map[$0.i][$0.j] & CategoryBitMask.obstacleCategory == 0 {
                    path[$0] = top
                    stack.insert($0, at: 0)
                }
            })
        }
        
        var currentPoint = ghostPosition
        while path[currentPoint] != nil {
            points.append(currentPoint)
            currentPoint = path[currentPoint]!
        }
        
        points.append(currentPoint)
        
        return points
    }
}

class BFS: Algorithm {
    let name: String = "BFS"
    
    func calculatePath(map: [[UInt32]], pacmanPosition: Point, ghostPosition: Point) -> [Point] {
        var points = [Point]()
        
        var path = [Point: Point]()
        
        var queue = [Point]()
        var visited = Set<Point>()
        
        queue.append(pacmanPosition)
        
        while !queue.isEmpty {
            let top = queue.removeFirst()
            visited.insert(top)
            if top == ghostPosition {
                break
            }
            let neighbors = Level.getNeighbors(map: map, point: top)
            neighbors.forEach({
                if !visited.contains($0) && (map[$0.i][$0.j] & CategoryBitMask.obstacleCategory == 0) {
                    path[$0] = top
                    queue.append($0)
                }
            })
        }
        
        var currentPoint = ghostPosition
        while path[currentPoint] != nil {
            points.append(currentPoint)
            currentPoint = path[currentPoint]!
        }
        
        points.append(currentPoint)
        
        return points
    }
}

class UCS: Algorithm {
    var name: String = "UCS"
    
    struct Node: Comparable {
        var point: Point
        var cost: Int
        
        static func < (lhs: UCS.Node, rhs: UCS.Node) -> Bool {
            lhs.cost < rhs.cost
        }
    }
    
    func calculatePath(map: [[UInt32]], pacmanPosition: Point, ghostPosition: Point) -> [Point] {
        var points = [Point]()
        
        var path = [Point: Point]()
        
        var queue = PriorityQueue<Node>(order: { $0.cost > $1.cost })
        queue.push(Node(point: pacmanPosition, cost: 0))
        var visited = Set<Point>()
        
        while !queue.isEmpty {
            let node = queue.pop()!
            
            if node.point == ghostPosition {
                break
            }
            
            if !visited.contains(node.point) {
                let neighbors = Level.getNeighbors(map: map, point: node.point)
                neighbors.forEach { point in
                    if !visited.contains(point) && map[point.i][point.j] & CategoryBitMask.obstacleCategory == 0 {
                        path[point] = node.point
                        queue.push(Node(point: point, cost: node.cost + 1))
                    }
                }
            }
            
            visited.insert(node.point)
        }
        
        var currentPoint = ghostPosition
        while path[currentPoint] != nil {
            points.append(currentPoint)
            currentPoint = path[currentPoint]!
        }
        
        points.append(currentPoint)
        
        return points
    }
}
