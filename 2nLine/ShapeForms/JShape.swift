//
//  JShape.swift
//  
//
//  Created by Alexey Yurko on 03.03.16.
//  Copyright © 2016 Alexey Yurko. All rights reserved.
//

class JShape:Shape {
    
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.Zero:  [(0, 1),  (0, 0), (0, -1), (-1, -1)],
            Orientation.Ninety:     [(1, 0),  (0, 0),  (-1, 0), (-1, 1)],
            Orientation.OneEighty:  [(0, -1),  (0, 0), (0, 1), (1, 1)],
            Orientation.TwoSeventy: [(-1, 0), (0, 0), (1, 0), (1, -1)]
        ]
    }

}