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
            Orientation.Zero:       [(0, 0)],
            Orientation.Ninety:     [(0, 0)],
            Orientation.OneEighty:  [(0, 0)],
            Orientation.TwoSeventy: [(0, 0)]
        ]
    }
    
}