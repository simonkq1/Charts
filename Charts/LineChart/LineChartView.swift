//
//  LineChartView.swift
//  Simon's Tools
//
//  Created by Jetec-RD on 2018/10/17.
//  Copyright © 2018年 Simon. All rights reserved.
//

import UIKit

open class LineChartView: UIView {
    
    public var scrollView: UIScrollView!
    private var contentView: UIView!
    
    
    fileprivate static var minimum: Double = 0
    fileprivate static var maximum: Double = 100
    private var linePointX: [[CGFloat]] = []
    private var linePointY: [[CGFloat]] = []
    private var heightOffset: CGFloat = 80
    private var originPoint: CGPoint!
    private var xOffset: CGFloat!
    private var chartIsDraw: Bool = false
    private var iconsSize: CGFloat = 7
    private var basicLineOffset: CGFloat = -200
    private var maxAndMinInterval: Double = 10
    private var contentViewWidthValue: CGFloat = 0 {
        didSet {
            if contentViewWidthConstraint != nil {
                DispatchQueue.main.async {
                    self.contentViewWidthConstraint.constant = self.contentViewWidthValue
                }
            }
        }
    }
    private var scrollViewLeftConstraint: NSLayoutConstraint!
    private var contentViewWidthConstraint: NSLayoutConstraint!
    private var contentViewBottomConstraint: NSLayoutConstraint!
    
    
    open var data: [LineChartDataSet] = [] {
        didSet {
            dataProcessing()
        }
    }
    
    public var xLabelText: [String]!
    public var yAxisScaleNumber = 10
    public var xAxisScaleLength = 20
    public var spacingBetweenPoints = 4
    
    public enum Axis {
        case x
        case y
    }
    
    //    var dataAverage: Double!
    
    
    
    
    override open func awakeFromNib() {
        
        self.addScrollView()
        //        self.backgroundColor = UIColor.blue
        if self.data.count > 0 {
            DispatchQueue.global().async {
                usleep(100000)
                DispatchQueue.main.async {
                    self.setLineChart()
                }
            }
        }
        
        
    }
    
    private func addScrollView() {
        
        self.scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        //        DispatchQueue.global().async {
        
        DispatchQueue.main.async {
            self.addSubview(self.scrollView)
            let topConstraint = NSLayoutConstraint(item: self.scrollView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0)
            self.scrollViewLeftConstraint = NSLayoutConstraint(item: self.scrollView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 40)
            
            let rightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.scrollView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0)
            let bottomConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.scrollView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0)
            self.addConstraints([topConstraint, bottomConstraint, self.scrollViewLeftConstraint, rightConstraint])
        }
        //        }
        self.scrollView.clipsToBounds = false
        addContentView()
        self.scrollView.clipsToBounds = true
        print("scrollView Finish")
    }
    
    private func addContentView() {
        
        self.contentView = UIView()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.backgroundColor = UIColor.clear
        
        
        DispatchQueue.main.async {
            self.scrollView.addSubview(self.contentView)
            
            let topConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.contentView.superview, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
            
            self.contentViewBottomConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.contentView.superview, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 50)
            
            let leftConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.contentView.superview, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
            
            let rightConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.contentView.superview, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
            
            let verticallyConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.contentView.superview, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
            //
            self.contentViewWidthConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.contentViewWidthValue)
            
            NSLayoutConstraint.activate([topConstraint, self.contentViewBottomConstraint, leftConstraint, rightConstraint, verticallyConstraint, self.contentViewWidthConstraint])
            
        }
        //        innerView.addConstraints([topConstraint, bottomConstraint, leftConstraint, rightConstraint])
        
        print("contentView Finish")
    }
    
    
    
    private func dataProcessing() {
        
        
        if contentViewWidthConstraint != nil {
            DispatchQueue.main.async {
                if self.data.count >= 1 {
                    self.contentViewWidthValue = {
                        let v = CGFloat(100 + (self.data[0].data.count * self.spacingBetweenPoints))
                        if v < self.bounds.size.width {
                            return self.bounds.size.width
                        }else {
                            return v
                        }
                    }()
                }
            }
        }
        
        var d = [Double]()
        if self.data.count != 0{
            for i in self.data {
                d += i.data
            }
            var max = d.max() ?? 100
            var min = d.min() ?? 0
            if max.truncatingRemainder(dividingBy: maxAndMinInterval) != 0 {
                if max < 0 {
                    max = Double(max - max.truncatingRemainder(dividingBy: maxAndMinInterval))
                }else {
                    max = Double(max - max.truncatingRemainder(dividingBy: maxAndMinInterval) + maxAndMinInterval)
                }
            }
            if min.truncatingRemainder(dividingBy: maxAndMinInterval) != 0 {
                if min < 0 {
                    min = min - min.truncatingRemainder(dividingBy: maxAndMinInterval) - maxAndMinInterval
                }else {
                    min = Double(min - min.truncatingRemainder(dividingBy: maxAndMinInterval))
                }
            }
            LineChartView.maximum = max
            LineChartView.minimum = min
        }
        DispatchQueue.global().async {
            usleep(100000)
            DispatchQueue.main.async {
                if self.data.count > 0 {
                    if self.chartIsDraw {
                        self.cleanChart()
                        usleep(1000000)
                        self.awakeFromNib()
                    }else {
                        self.setLineChart()
                    }
                }
            }
        }
    }
    
    
    private func setLineChart() {
        linePointX = []
        linePointY = []
        drawBasicLine()
        drawScale()
        drawDataLine()
    }
    
    private func drawBasicLine() {
        let xAxisShapeLayer = CAShapeLayer()
        let xLinePath = UIBezierPath()
        let yAxisShapeLayer = CAShapeLayer()
        let yLinePath = UIBezierPath()
        
        originPoint = CGPoint(x: 0, y: self.contentView.frame.size.height - self.contentViewBottomConstraint.constant)
        yLinePath.move(to: CGPoint(x: scrollViewLeftConstraint.constant, y: originPoint.y))
        yLinePath.addLine(to: CGPoint(x: scrollViewLeftConstraint.constant, y: 10))
        xLinePath.move(to: CGPoint(x: self.basicLineOffset, y: originPoint.y))
        xLinePath.addLine(to: CGPoint(x: contentViewWidthValue * 1.2, y: originPoint.y))
        
        yAxisShapeLayer.strokeColor = UIColor.black.cgColor
        yAxisShapeLayer.fillColor = UIColor.clear.cgColor
        yAxisShapeLayer.path = yLinePath.cgPath
        
        xAxisShapeLayer.strokeColor = UIColor.black.cgColor
        xAxisShapeLayer.fillColor = UIColor.clear.cgColor
        xAxisShapeLayer.path = xLinePath.cgPath
        
        self.layer.addSublayer(yAxisShapeLayer)
        self.contentView.layer.addSublayer(xAxisShapeLayer)
    }
    
    
    private func drawScale() {
        let shapeLayer = CAShapeLayer()
        let linePath = UIBezierPath()
        let min = LineChartView.minimum
        let max = LineChartView.maximum
        let offset = 0.05
        func drawYScale() {
            for i in 0...self.yAxisScaleNumber {
                let value = min + ((max - min) / Double(self.yAxisScaleNumber)) * Double(i)
                
                let y = (contentView.bounds.size.height - heightOffset) * (value.percent)
                if i == 0 {
                    self.xOffset = CGFloat(value)
                }
                let lineLength: CGFloat = (i == 0 || i == self.yAxisScaleNumber) ? 5 : 4
                linePath.move(to: CGPoint(x: self.basicLineOffset , y: y))
                linePath.addLine(to: CGPoint(x: contentViewWidthValue * 1.2, y: y))
                let labelText = String(format: "%.0f", value)
                
                if i % 2 == 0 {
                    drawAxisLabel(CGPoint(x: originPoint.x, y: y), axis: .y, text: labelText)
                }
            }
        }
        
        func drawXScale() {
            let df = DateFormatter()
            let time = Date()
            var labelCount: Int {
                let n = self.data.count / self.xAxisScaleLength
                return n
            }
            for i in 0..<self.data[0].data.count {
                if i != 0, (i + 1) % 20 != 0{
                    continue
                }
                let value = String(describing: i)
                let x = (heightOffset / 2) + CGFloat(i * self.spacingBetweenPoints)
                linePath.move(to: CGPoint(x: x, y: self.originPoint.y))
                linePath.addLine(to: CGPoint(x: x, y: 10))
                var labelText = String()
                
                if self.xLabelText != nil {
                    labelText = (i <= xLabelText.count - 1) ? String(describing: xLabelText[i]) : ""
                }else {
                    labelText = String(describing: value)
                }
                drawAxisLabel(CGPoint(x: x, y: originPoint.y), axis: .x, text: labelText)
                
            }
        }
        drawYScale()
        drawXScale()
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.path = linePath.cgPath
        self.contentView.layer.addSublayer(shapeLayer)
    }
    private func drawAxisLabel(_ point: CGPoint, axis: Axis, text: String) {
        if axis == Axis.y {
            let yLabel = UILabel()
            yLabel.frame.size = CGSize(width: 30, height: 20)
            yLabel.text = text
            yLabel.textColor = UIColor.black
            yLabel.font = UIFont.systemFont(ofSize: 12)
            yLabel.sizeToFit()
            let positionX: CGFloat = scrollViewLeftConstraint.constant - 8 - (yLabel.frame.size.width)
            yLabel.frame.origin = CGPoint(x: positionX, y: point.y)
            yLabel.center.y = point.y
            self.addSubview(yLabel)
        }
        if axis == Axis.x {
            
            let xLabel = UILabel()
            xLabel.numberOfLines = 2
            xLabel.frame.size = CGSize(width: 60, height: 20)
            xLabel.text = text
            xLabel.textColor = UIColor.black
            xLabel.font = UIFont.systemFont(ofSize: 13)
            xLabel.textAlignment = NSTextAlignment.center
            xLabel.adjustsFontSizeToFitWidth = true
            xLabel.sizeToFit()
            let positionY: CGFloat = originPoint.y
            xLabel.frame.origin = CGPoint(x: point.x, y: positionY)
            xLabel.center.x = point.x
            self.contentView.addSubview(xLabel)
        }
    }
    
    private func drawDataLine() {
        linePointX.append([])
        linePointY.append([])
        for i in 0..<self.data.count {
            
            let shapeLayer = CAShapeLayer()
            let linePath = UIBezierPath()
            if self.data[i].lineStyle == .defaule {
                for ii in 0..<self.data[i].data.count {
                    let pointX = self.originPoint.x + (heightOffset / 2) + CGFloat(ii * spacingBetweenPoints)
                    let pointY = (contentView.bounds.size.height - heightOffset) * self.data[i].data[ii].percent
                    linePointX[0].append(pointX)
                    linePointY[0].append(pointY)
                    if ii == 0 {
                        linePath.move(to: CGPoint(x: pointX, y: pointY))
                    }else {
                        linePath.addLine(to: CGPoint(x: pointX, y: pointY))
                    }
                    
                }
            }else {
                let pointX = self.basicLineOffset
                let pointY = (contentView.bounds.size.height - heightOffset) * self.data[i].indexValue.percent
                linePath.move(to: CGPoint(x: pointX, y: pointY))
                linePath.addLine(to: CGPoint(x: self.contentViewWidthValue * 1.2, y: pointY))
            }
            
            shapeLayer.strokeColor = self.data[i].lineColor.cgColor
            shapeLayer.fillColor = UIColor.clear.cgColor
            if let dashPoint = self.data[i].dashPoint {
                shapeLayer.lineDashPattern = dashPoint
            }
            shapeLayer.path = linePath.cgPath
            self.contentView.layer.addSublayer(shapeLayer)
            
        }
        drawIcons()
        chartIsDraw = true
    }
    
    private func drawIcons() {
        var lastPosition: CGFloat!
        let widthBetweenIcons: CGFloat = 10
        let widthBetweenIconsAndLabel: CGFloat = 3
        for i in 0..<self.data.count {
            let shapeLayer = CAShapeLayer()
            let linePath = UIBezierPath(rect: CGRect(x: lastPosition == nil ? scrollViewLeftConstraint.constant : lastPosition + widthBetweenIcons, y: self.frame.size.height - iconsSize, width: iconsSize, height: iconsSize))
            shapeLayer.strokeColor = self.data[i].lineColor.cgColor
            shapeLayer.fillColor = self.data[i].lineColor.cgColor
            shapeLayer.path = linePath.cgPath
            
            let label = UILabel(frame: CGRect(
                x: lastPosition == nil ? scrollViewLeftConstraint.constant + iconsSize + widthBetweenIconsAndLabel : lastPosition + widthBetweenIconsAndLabel + iconsSize + widthBetweenIcons,
                y: self.frame.size.height - iconsSize,
                width: 60,
                height: 30))
            label.textColor = UIColor.black
            label.font = UIFont.systemFont(ofSize: 13)
            label.textAlignment = NSTextAlignment.center
            label.text = self.data[i].name
            label.sizeToFit()
            label.center.y = self.frame.size.height - iconsSize / 2
            if self.data[i].name == "" {label.frame.size.width = 30}
            label.adjustsFontSizeToFitWidth = true
            self.layer.addSublayer(shapeLayer)
            self.addSubview(label)
            if lastPosition == nil {
                lastPosition = scrollViewLeftConstraint.constant + iconsSize + label.frame.size.width
            }else {
                lastPosition += iconsSize + 7 + label.frame.size.width
            }
        }
    }
    
    
    // MARK: - User can use
    
    
    /// remove all subviews and CAShapeLayer
    public func cleanChart() {
        for i in self.subviews {
            i.removeFromSuperview()
        }
        for i in self.layer.sublayers ?? [] {
            if i is CAShapeLayer {
                i.removeFromSuperlayer()
            }
        }
    }
    
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

// MARK: - Extension
fileprivate extension Float {
    var percent: CGFloat {
        return CGFloat(1 - ((Double(self) - LineChartView.minimum) / (LineChartView.maximum - LineChartView.minimum)) + 0.05)
    }
}
fileprivate extension Double {
    var percent: CGFloat {
        return CGFloat(1 - ((self - LineChartView.minimum) / (LineChartView.maximum - LineChartView.minimum)) + 0.05)
    }
}
fileprivate extension Int {
    var percent: CGFloat {
        return CGFloat(1 - ((Double(self) - LineChartView.minimum) / (LineChartView.maximum - LineChartView.minimum)) + 0.05)
    }
}

extension Array where Element == Int {
    var total: Int {return reduce(0, +)}
    var average: Double {return (Double(total) / Double(count))}
}


extension Array where Element == Double {
    var total: Double {return reduce(0, +)}
    var average: Double {return (total / Double(count))}
}


extension Array where Element == Float {
    var total: Float {return reduce(0, +)}
    var average: Double {return (Double(total) / Double(count))}
}
