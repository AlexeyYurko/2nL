//
//  OneBlockShape.swift
//  2nLine
//
//  Created by Alexey Yurko on 12.04.16.
//  Copyright © 2016 Alexey Yurko. All rights reserved.
//

class OneBlockShape:Shape {
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.zero:       [(0, 0)],
            Orientation.ninety:     [(0, 0)],
            Orientation.oneEighty:  [(0, 0)],
            Orientation.twoSeventy: [(0, 0)]
        ]
    }
    
}
