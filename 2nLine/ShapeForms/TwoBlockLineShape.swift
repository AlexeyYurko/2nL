//
//  TwoBlockLineShape.swift
//  2nLine
//
//  Created by Alexey Yurko on 12.04.16.
//  Copyright © 2016 Alexey Yurko. All rights reserved.
//

class TwoBlockLineShape:Shape {
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.zero:       [(0, 1), (1, 1)],
            Orientation.ninety:     [(1, 1), (1, 0)],
            Orientation.oneEighty:  [(1, 0), (0, 0)],
            Orientation.twoSeventy: [(0, 0), (0, 1)]
        ]
    }
    
}
