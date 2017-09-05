//
//  JShortShape.swift
//  2nLine
//
//  Created by Alexey Yurko on 12.04.16.
//  Copyright © 2016 Alexey Yurko. All rights reserved.
//

class JShortShape:Shape {
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.zero:       [(0, 1), (0, 0), (1, 0)],
            Orientation.ninety:     [(1, 0), (0, 0), (0, -1)],
            Orientation.oneEighty:  [(0, -1), (0, 0), (-1, 0)],
            Orientation.twoSeventy: [(-1, 0), (0, 0), (0, 1)]
        ]
    }
    
}
