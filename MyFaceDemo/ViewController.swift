//
//  ViewController.swift
//  MyFaceDemo
//
//  Created by VoiceBeer on 2017/8/19.
//  Copyright © 2017年 VoiceBeer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }

    //定义 M 层里的 Mouth 枚举对应的值
    private let mouthCurvatures = [FacialExpression.Mouth.grin: 0.5, .frown: -1.0, .smile: 1.0, .neutral: 0.0, .smirk: -0.5]
    
    @IBOutlet weak var faceView: FaceView! {
        didSet {
            // Pinch 的识别器, 首先定义对应的处理函数, 然后定义 pinch识别器, 最后加到 View 上
            let handler = #selector(FaceView.changeScale(byReactingTo:))
            let pinchRecognizer = UIPinchGestureRecognizer(target: faceView, action: handler)
            faceView.addGestureRecognizer(pinchRecognizer)
            
            // Tap 的识别器, 使用在 Controller 里的 toggleEyes 作为 handler 来定义 tap识别器, 最后加到 View 上
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleEyes(byReactingTo:)))
            tapRecognizer.numberOfTapsRequired = 1
            faceView.addGestureRecognizer(tapRecognizer)
            
            // Swipe 的识别器, 使用下面的两个函数来做 handler 定义识别器
            let swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(increaseHappiness))
            swipeUpRecognizer.direction = .up
            let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(decreaseHappiness))
            swipeDownRecognizer.direction = .down
            faceView.addGestureRecognizer(swipeUpRecognizer)
            faceView.addGestureRecognizer(swipeDownRecognizer)
            updateUI()
        }
    }
    
    // 这里没有参数是因为 swipe 是瞬间的不连续的, 所以不需要知道对应的 state
    @objc func increaseHappiness() {
        expression = expression.happier
    }
    
    @objc func decreaseHappiness() {
        expression = expression.sadder
    }
    
    //通过 Tap 手势改变 expression.eyes 的状态, 因为这个 handler 改变了 Model, 所以写在 Controller 里
    @objc func toggleEyes(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        if tapRecognizer.state == .ended {
            let eyes: FacialExpression.Eyes = (expression.eyes == .closed) ? .open : .closed
            self.expression = FacialExpression(eyes: eyes, mouth: self.expression.mouth)
        }
    }
    
    var expression = FacialExpression(eyes: .closed, mouth: .grin) {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        switch expression.eyes {
        case .open:
            faceView?.eyesOpen = true // faceView 加 ? 是由于如果是 expression先被设置的话那么调用 updateUI 的时候, faceView 是还没背初始化的,所以是可选值
        case .closed:
            faceView?.eyesOpen = false
        case .squinting:
            faceView?.eyesOpen = false
        }
        faceView?.mouthCurvature = mouthCurvatures[expression.mouth] ?? 0.0
    }
    
}

