//
//  AnimatedULogoView.swift
//  UberAnimationTest
//
//  Created by 李家斌 on 2018/10/8.
//  Copyright © 2018 李家斌. All rights reserved.
//

import UIKit
import QuartzCore

open class AnimatedULogoView: UIView {
    fileprivate let strokeEndTimingFunction   = CAMediaTimingFunction(controlPoints: 1.00, 0.0, 0.35, 1.0)
    fileprivate let squareLayerTimingFunction      = CAMediaTimingFunction(controlPoints: 0.25, 0.0, 0.20, 1.0)
    fileprivate let circleLayerTimingFunction   = CAMediaTimingFunction(controlPoints: 0.65, 0.0, 0.40, 1.0)
    fileprivate let fadeInSquareTimingFunction = CAMediaTimingFunction(controlPoints: 0.15, 0, 0.85, 1.0)
    
    fileprivate let radius: CGFloat = 37.5
    fileprivate let squareLayerLength = 21.0
    fileprivate let startTimeOffset = 0.7 * kAnimationDuration
    
    fileprivate var circleLayer: CAShapeLayer!
    fileprivate var lineLayer: CAShapeLayer!
    fileprivate var squareLayer: CAShapeLayer!
    fileprivate var maskLayer: CAShapeLayer!
    
    var beginTime: CFTimeInterval = 0
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        circleLayer = generateCircleLayer()
        lineLayer = generateLineLayer()
        squareLayer = generateSquareLayer()
        maskLayer = generateMaskLayer()
        
        layer.mask = maskLayer
        layer.addSublayer(circleLayer)
        layer.addSublayer(lineLayer)
        layer.addSublayer(squareLayer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func startAnimating() {
        beginTime = CACurrentMediaTime()
        layer.anchorPoint = CGPoint.zero
        
        animateMaskLayer()
        animateCircleLayer()
        animateLineLayer()
        animateSquareLayer()
    }
}

extension AnimatedULogoView {
    
    fileprivate func generateMaskLayer()->CAShapeLayer {
        let layer = CAShapeLayer()
        layer.frame = CGRect(x: -radius, y: -radius, width: radius * 2.0, height: radius * 2.0)
        layer.allowsGroupOpacity = true
        layer.backgroundColor = UIColor.white.cgColor
        return layer
    }
    
    // 生成圆形图层
    fileprivate func generateCircleLayer() -> CAShapeLayer {
        // 初始化layer层
        let layer = CAShapeLayer()
        // 在此使用半径为宽度
        layer.lineWidth = radius
        
        /**
         *  center:弧线中心点的坐标 radius:弧线所在圆的半径 startAngle:弧线开始的角度值 endAngle:弧线结束的角度值 clockwise:是否顺时针画弧线
         */
        
        //开始和结束的角度之和需要达到360°
        layer.path = UIBezierPath(arcCenter: .zero, radius: radius/2, startAngle: CGFloat(-2 * Double.pi/2), endAngle: CGFloat(2 * Double.pi/2), clockwise: true).cgPath
        // 填充的颜色
        layer.strokeColor = UIColor.white.cgColor
        //如果不将此设置为指定颜色,将显示黑色
        layer.fillColor = UIColor.clear.cgColor
        
        return layer
    }
    
    // 生成横线图层
    fileprivate func generateLineLayer() -> CAShapeLayer {
        // 初始化layer层
        let layer = CAShapeLayer()
        layer.position = .zero
        layer.frame = .zero
        layer.allowsGroupOpacity = true
        layer.lineWidth = 5.0
        // 填充的颜色
        layer.strokeColor = UIColor.fuberBlue().cgColor
        
        let bezierPath = UIBezierPath()
        // 设置起点
        bezierPath.move(to: .zero)
        // 划线
        bezierPath.addLine(to: CGPoint(x: -40, y: 0.0))
        layer.path = bezierPath.cgPath
        
        return layer
    }
    
    // 生成正方形图层
    fileprivate func generateSquareLayer()->CAShapeLayer {
        let layer = CAShapeLayer()
        layer.position = CGPoint.zero
        layer.frame = CGRect(x: -squareLayerLength / 2.0, y: -squareLayerLength / 2.0, width: squareLayerLength, height: squareLayerLength)
        layer.cornerRadius = 1.5
        layer.allowsGroupOpacity = true
        layer.backgroundColor = UIColor.fuberBlue().cgColor
        
        return layer
    }
}


extension AnimatedULogoView {
    
    fileprivate func animateMaskLayer() {
        // bounds
        let boundsAnimation = CABasicAnimation(keyPath: "bounds")
        boundsAnimation.fromValue = NSValue(cgRect: CGRect(x: 0.0, y: 0.0, width: radius * 2.0, height: radius * 2))
        boundsAnimation.toValue = NSValue(cgRect: CGRect(x: 0.0, y: 0.0, width: 2.0/3.0 * squareLayerLength, height: 2.0/3.0 * squareLayerLength))
        boundsAnimation.duration = kAnimationDurationDelay
        boundsAnimation.beginTime = kAnimationDuration - kAnimationDurationDelay
        boundsAnimation.timingFunction = circleLayerTimingFunction
        
        // cornerRadius
        let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        cornerRadiusAnimation.beginTime = kAnimationDuration - kAnimationDurationDelay
        cornerRadiusAnimation.duration = kAnimationDurationDelay
        cornerRadiusAnimation.fromValue = radius
        cornerRadiusAnimation.toValue = 2
        cornerRadiusAnimation.timingFunction = circleLayerTimingFunction
        
        // Group
        let groupAnimation = CAAnimationGroup()
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = CAMediaTimingFillMode.both
        groupAnimation.beginTime = beginTime
        groupAnimation.repeatCount = Float.infinity
        groupAnimation.duration = kAnimationDuration
        groupAnimation.animations = [boundsAnimation, cornerRadiusAnimation]
        groupAnimation.timeOffset = startTimeOffset
        maskLayer.add(groupAnimation, forKey: "looping")
    }
    
    //执行动画, 画圆
    fileprivate func animateCircleLayer() {
        // 关键帧（keyframe）使我们能够定义动画中任意的一个点，然后让 Core Animation 填充所谓的中间帧。
        let strokeEndAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
        //设定动画的速度变化 x - y - x - y
        strokeEndAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 1.0, 0.0, 0.35, 1.0)
        
        strokeEndAnimation.duration = kAnimationDuration - kAnimationDurationDelay
        
        //确保是一个完整的圆
        strokeEndAnimation.values = [0.0, 1.0]
        //keyTimes是确保开始到结束的时从0.0-1.0分别设置，避免其中的动画产生跳转。
        strokeEndAnimation.keyTimes = [0.0, 1.0]
        
        // transform
        let transformAnimation = CABasicAnimation(keyPath: "transform")
        transformAnimation.timingFunction = strokeEndTimingFunction
        transformAnimation.duration = kAnimationDuration - kAnimationDurationDelay
        
        var startingTransform = CATransform3DMakeRotation(-CGFloat(Double.pi/4), 0, 0, 1)
        startingTransform = CATransform3DScale(startingTransform, 0.25, 0.25, 1)
        transformAnimation.fromValue = NSValue(caTransform3D: startingTransform)
        transformAnimation.toValue = NSValue(caTransform3D: CATransform3DIdentity)
        
        let groupAnimation = CAAnimationGroup()
        //添加动画, 可以在此删除任一种动画, 会看到另类效果
        groupAnimation.animations = [strokeEndAnimation, transformAnimation]
        //重复次数
        groupAnimation.repeatCount = Float.infinity
        groupAnimation.duration = kAnimationDuration
        groupAnimation.beginTime = beginTime
        groupAnimation.timeOffset = 0.7 * kAnimationDuration
        circleLayer.add(groupAnimation, forKey: "looping")
    }
    
    // 执行画线动画
    fileprivate func animateLineLayer() {
        // lineWidth
        let lineWidthAnimation = CAKeyframeAnimation(keyPath: "lineWidth")
        lineWidthAnimation.values = [0.0, 5.0, 0.0]
        lineWidthAnimation.timingFunctions = [strokeEndTimingFunction, circleLayerTimingFunction]
        lineWidthAnimation.duration = kAnimationDuration
        lineWidthAnimation.keyTimes = [0.0, NSNumber(value: 1.0-kAnimationDurationDelay/kAnimationDuration), 1.0]
        
        // transform
        let transformAnimation = CAKeyframeAnimation(keyPath: "transform")
        transformAnimation.timingFunctions = [strokeEndTimingFunction, circleLayerTimingFunction]
        transformAnimation.duration = kAnimationDuration
        transformAnimation.keyTimes = [0.0, NSNumber(value: 1.0-kAnimationDurationDelay/kAnimationDuration), 1.0]
        
        var transform = CATransform3DMakeRotation(-CGFloat(Double.pi/4), 0.0, 0.0, 1.0)
        transform = CATransform3DScale(transform, 0.25, 0.25, 1.0)
        transformAnimation.values = [NSValue(caTransform3D: transform),
                                     NSValue(caTransform3D: CATransform3DIdentity),
                                     NSValue(caTransform3D: CATransform3DMakeScale(0.15, 0.15, 1.0))]
        
        
        // Group
        let groupAnimation = CAAnimationGroup()
        groupAnimation.repeatCount = Float.infinity
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.duration = kAnimationDuration
        groupAnimation.beginTime = beginTime
        groupAnimation.animations = [lineWidthAnimation, transformAnimation]
        groupAnimation.timeOffset = startTimeOffset
        
        lineLayer.add(groupAnimation, forKey: "looping")
    }
    
    // 执行正方形动画
    fileprivate func animateSquareLayer() {
        // 2/3
        let b1 = NSValue(cgRect: CGRect(x: 0.0, y: 0.0, width: 2.0/3.0 * squareLayerLength, height: 2.0/3.0  * squareLayerLength))
        //全长
        let b2 = NSValue(cgRect: CGRect(x: 0.0, y: 0.0, width: squareLayerLength, height: squareLayerLength))
        //0
        let b3 = NSValue(cgRect: .zero)
        
        let boundsAnimation = CAKeyframeAnimation(keyPath: "bounds")
        boundsAnimation.values = [b1, b2, b3]
        boundsAnimation.timingFunctions = [fadeInSquareTimingFunction, squareLayerTimingFunction]
        boundsAnimation.duration = kAnimationDuration
        boundsAnimation.keyTimes = [0, NSNumber(value: 1.0-kAnimationDurationDelay/kAnimationDuration), 1.0]
        
        // 背景色
        let backgroundColorAnimation = CABasicAnimation(keyPath: "backgroundColor")
        backgroundColorAnimation.fromValue = UIColor.white.cgColor
        backgroundColorAnimation.toValue = UIColor.fuberBlue().cgColor
        backgroundColorAnimation.timingFunction = squareLayerTimingFunction
        backgroundColorAnimation.fillMode = CAMediaTimingFillMode.both
        backgroundColorAnimation.beginTime = kAnimationDurationDelay * 2.0 / kAnimationDuration
        backgroundColorAnimation.duration = kAnimationDuration / (kAnimationDuration - kAnimationDurationDelay)
        
        
        // 放在Group之中
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [boundsAnimation, backgroundColorAnimation]
        groupAnimation.repeatCount = Float.infinity
        groupAnimation.duration = kAnimationDuration
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.beginTime = beginTime
        groupAnimation.timeOffset = startTimeOffset
        squareLayer.add(groupAnimation, forKey: "looping")
    }
}
