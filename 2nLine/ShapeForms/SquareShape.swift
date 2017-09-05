//
//  SquareShape.swift
//  
//
//  Created by Alexey Yurko on 03.03.16.
//  Copyright © 2016 Alexey Yurko. All rights reserved.
//

class SquareShape:Shape {
  
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.zero:       [(0, 0), (0, 1), (1, 1), (1, 0)],
            Orientation.oneEighty:  [(1, 1), (1, 0), (0, 0), (0, 1)],
            Orientation.ninety:     [(0, 1), (1, 1), (1, 0), (0, 0)],
            Orientation.twoSeventy: [(1, 0), (0, 0), (0, 1), (1, 1)]
        ]
    }
    
}

