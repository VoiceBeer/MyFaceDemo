//
//  FaceView.swift
//  MyFaceDemo
//
//  Created by VoiceBeer on 2017/8/19.
//  Copyright © 2017年 VoiceBeer. All rights reserved.
//

import UIKit

@IBDesignable
class FaceView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
     */
    
    // 通过对比得到屏幕最小的那一边除以2后乘以比率得到圆半径
    private var skullRadius: CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    //        let skullCenter = convert(center, from: superview)
    // 得到圆中心
    private var skullCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    // 比率
    @IBInspectable
    var scale: CGFloat = 0.9 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var eyesOpen: Bool = false { didSet { setNeedsDisplay() } }
    
    // 贝塞尔曲线里用到的嘴巴弧度
    @IBInspectable
    var mouthCurvature: Double = -0.5 { didSet { setNeedsDisplay() } } //1.0 is full smile, -1.0 is full frown
    
    @IBInspectable
    var lineWidth:CGFloat = 5.0 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var color: UIColor = UIColor.blue { didSet { setNeedsDisplay() } }
    
    private enum Eye {
        case left
        case right
    }
    
    // 通过 Pinch 手势改变 scale, 因为这个 handler 只改变了 View 里的 scale, 没有改变 Model, 所以写在 View 里就可以
    @objc func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed,.ended:
            scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
        default:
            break
        }
    }
    
    // 眼睛的路径
    private func pathForEye(_ eye: Eye) -> UIBezierPath {
        
        // 眼睛的圆心
        func centerOfEye(_ eye: Eye) -> CGPoint {
            let eyeOffset = skullRadius / Ratios.skullRadiusToEyeOffset
            
            // 以脸的中心为基本，再配以 x，y 的偏移来确定眼睛的中心
            var eyeCenter = skullCenter
            eyeCenter.y -= eyeOffset
            eyeCenter.x += ((eye == .left) ? -1 : 1) * eyeOffset
            return eyeCenter
        }
        
        let eyeRadius = skullRadius / Ratios.skullRadiusToEyeRadius
        let eyeCenter = centerOfEye(eye)
        
        let path: UIBezierPath
        if eyesOpen {
            // 如果是睁眼就使用画圆的，参数依次是：贝塞尔曲线中心，半径，开始的角度，结束的角度(角度都是弧度制)，顺时针还是逆时针，false是逆时针
            path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
        } else {
            // 否则就只要 move 到一个点然后添加直线到另一个点
            path = UIBezierPath()
            path.move(to: CGPoint(x: eyeCenter.x - eyeRadius, y: eyeCenter.y))
            path.addLine(to: CGPoint(x: eyeCenter.x + eyeRadius, y: eyeCenter.y))
        }
        path.lineWidth = lineWidth
        return path
    }
    
    // 嘴的路径
    private func pathForMouth() -> UIBezierPath {
        let mouthWidth = skullRadius / Ratios.skullRadiusToMouthWidth
        let mouthHeight = skullRadius / Ratios.skullRadiusToMouthHeight
        let mouthOffset = skullRadius / Ratios.skullRadiusToEyeOffset
        
        // 确定嘴形所在的长方形，初始点为长方形左上角点的 x，y 坐标然后是长方形的宽度高度，以此来确定一个长方形，顺带一提坐标轴是 x右加y下加
        let mouthRect = CGRect(x: skullCenter.x - mouthWidth / 2, y: skullCenter.y + mouthOffset, width: mouthWidth, height: mouthHeight)
        
        // 微笑的弧度偏移，先确定 [-1,1] 区间的值后乘以高度来确定微笑的偏移
        let smileOffset = CGFloat(max(-1, min(mouthCurvature, 1))) * mouthRect.height
        
        // 贝塞尔曲线的弧线里用到的起始点终止点以及用到的两个偏移点
        let start = CGPoint(x: mouthRect.minX, y: mouthRect.midY)
        let end = CGPoint(x: mouthRect.maxX, y: mouthRect.midY)
        let cp1 = CGPoint(x: start.x + mouthRect.width / 3, y: start.y + smileOffset)
        let cp2 = CGPoint(x: end.x - mouthRect.width / 3, y: start.y + smileOffset)
        
//        let path = UIBezierPath(rect: mouthRect)
        let path = UIBezierPath()
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        return path
    }
    
    // 头骨的路径
    private func pathForSkull() -> UIBezierPath {
        let path = UIBezierPath(arcCenter: skullCenter, radius: skullRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
        path.lineWidth = lineWidth
        return path
    }
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        color.set()
        pathForSkull().stroke()
        pathForEye(.left).stroke()
        pathForEye(.right).stroke()
        pathForMouth().stroke()
    }
    
    private struct Ratios {
        static let skullRadiusToEyeOffset: CGFloat = 3
        static let skullRadiusToEyeRadius: CGFloat = 10
        static let skullRadiusToMouthWidth: CGFloat = 1
        static let skullRadiusToMouthHeight: CGFloat = 3
        static let skullRadiusToMouthOffset: CGFloat = 3
    }
}
