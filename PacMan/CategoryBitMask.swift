//
//  CategoryBitMask.swift
//  PacMan
//
//  Created by Andrii Moisol on 06.09.2021.
//

import Foundation

struct CategoryBitMask {
    static let pacmanCategory: UInt32 = 1 << 0
    static let foodCategory: UInt32 = 1 << 1
    static let obstacleCategory: UInt32 = 1 << 2
}
