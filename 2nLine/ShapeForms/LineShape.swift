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
            Orientation.zero:       [(-1, 0), (0, 0), (1, 0), (2, 0)],
            Orientation.ninety:     [(0, -1), (0, 0), (0, 1), (0, 2)],
            Orientation.oneEighty:  [(2, 0), (1, 0), (0, 0), (-1, 0)],
            Orientation.twoSeventy: [(0, 2), (0, 1), (0, 0), (0, -1)]
        ]
    }
    
}
