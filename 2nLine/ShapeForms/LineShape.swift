//
//  LineShape.swift
//  
//
//  Created by Alexey Yurko on 03.03.16.
//  Copyright © 2016 Alexey Yurko. All rights reserved.
//

class LineShape:Shape {
   
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
      return [
            Orientation.Zero:       [(-1, 0), (0, 0), (1, 0), (2, 0)],
            Orientation.Ninety:     [(0, -1), (0, 0), (0, 1), (0, 2)],
            Orientation.OneEighty:  [(2, 0), (1, 0), (0, 0), (-1, 0)],
            Orientation.TwoSeventy: [(0, 2), (0, 1), (0, 0), (0, -1)]
        ]
    }
    
}