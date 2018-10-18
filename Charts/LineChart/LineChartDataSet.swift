//
//  ValueLineDataSet.swift
//  podTest
//
//  Created by Jetec-RD on 2018/10/15.
//  Copyright © 2018年 Jetec-RD. All rights reserved.
//

import UIKit

open class LineChartDataSet: NSObject {
    public enum LineStyle {
        case defaule
        case index
    }
    
    public var data: [Double]!
    public var lineColor: UIColor = UIColor.blue
    public var name: String = ""
    public var dashPoint: [NSNumber]!
    public var lineStyle: LineStyle = LineStyle.defaule
    public var indexValue: Double!
    
    public init(data: [Double], name: String) {
        self.data = data
        self.name = name
    }
    public init(indexValue: Double, name: String) {
        self.data = [indexValue]
        self.indexValue = indexValue
        self.name = name
        self.lineStyle = LineStyle.index
    }
}
