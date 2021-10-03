//
//  Algorithms.swift
//  PacMan
//
//  Created by Andrii Moisol on 13.09.2021.
//

import Foundation

protocol Algorithm {
    var name: String { get }
    
    func calculatePath(map: [[UInt32]], from: Point, to: Point) -> [Point]
}

class DFS: Algorithm {
    let name: String = "DFS"
    
    func calculatePath(map: [[UInt32]], from: Point, to: Point) -> [Point] {
        var points = [Point]()
        
        var path = [Point: Point]()
        
        var stack = [Point]()
        var visited = Set<Point>()
        
        stack.append(from)
        
        while !stack.isEmpty {
            let top = stack.removeFirst()
            visited.insert(top)
            if top == to {
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
        
        var currentPoint = to
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
    
    func calculatePath(map: [[UInt32]], from: Point, to: Point) -> [Point] {
        var points = [Point]()
        
        var path = [Point: Point]()
        
        var queue = [Point]()
        var visited = Set<Point>()
        
        queue.append(from)
        
        while !queue.isEmpty {
            let top = queue.removeFirst()
            visited.insert(top)
            if top == to {
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
        
        var currentPoint = to
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
    
    func calculatePath(map: [[UInt32]], from: Point, to: Point) -> [Point] {
        var points = [Point]()
        
        var path = [Point: Point]()
        
        var queue = PriorityQueue<Node>(order: { $0.cost > $1.cost })
        queue.push(Node(point: from, cost: 0))
        var visited = Set<Point>()
        
        while !queue.isEmpty {
            let node = queue.pop()!
            
            if node.point == to {
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
        
        var currentPoint = to
        while path[currentPoint] != nil {
            points.append(currentPoint)
            currentPoint = path[currentPoint]!
        }
        
        return points.reversed()
    }
}

class AStar: Algorithm {
    var name: String = "A*"

    struct Node: Comparable {
        var point: Point
        var g: Int
        var h: Int
        var f: Int {
            g + h
        }

        static func < (lhs: AStar.Node, rhs: AStar.Node) -> Bool {
            lhs.f < rhs.f
        }
    }

    func dist(_ x: Point, _ y: Point) -> Int {
        abs(x.i - y.i) + abs(x.j - y.j)
    }

    func calculatePath(map: [[UInt32]], from: Point, to: Point) -> [Point] {
        var points = [Point]()

        var path = [Point: Point]()

        var queue = PriorityQueue<Node>(order: { $0.f > $1.f })
        queue.push(Node(point: from, g: 0, h: dist(from, to)))

        var visited = Set<Point>()

        while !queue.isEmpty {
            let currentNode = queue.pop()!
            visited.insert(currentNode.point)
            if currentNode.point == to {
                break
            }

            Level.getNeighbors(map: map, point: currentNode.point).forEach { neighbor in
                guard map[neighbor.i][neighbor.j] & CategoryBitMask.obstacleCategory == 0 else { return }
                let score = currentNode.g + 1
                if let neighborNode = queue.first(where: { $0.point == neighbor }) {
                    if score < neighborNode.g {
                        path[neighbor] = currentNode.point
                        var newNode = neighborNode
                        newNode.g = score
                        queue.remove(neighborNode)
                        queue.push(newNode)
                    }
                } else if !visited.contains(neighbor) {
                    path[neighbor] = currentNode.point
                    queue.push(Node(point: neighbor, g: score, h: dist(neighbor, to)))
                }
            }
        }

        var currentPoint = to
        while path[currentPoint] != nil {
            points.append(currentPoint)
            currentPoint = path[currentPoint]!
        }

        return points.reversed()
    }
}
