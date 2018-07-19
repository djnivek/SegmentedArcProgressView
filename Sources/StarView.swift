//
//  StarView.swift
//  SegmentedArcProgressView-iOS
//
//  Created by Kévin MACHADO on 12/06/2018.
//  Copyright © 2018 Zerty Color. All rights reserved.
//

import UIKit

public class StarView: AnimatedView {
    
    private var _animatorProgress: Double = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    private var progress: Double = 0
    
    private var progressionTimer: Timer?
    
    final override public func animateView(then block: @escaping () -> Void) {
        self.animate(from: _animatorProgress, to: 1, completion: block)
    }
    
    final override public func rewindView(then block: @escaping () -> Void) {
        self.animate(from: _animatorProgress, to: 0, completion: block)
    }
    
    private func animate(from startProgress: Double, to endProgress: Double, duration: Double = 0.2, completion block: @escaping () -> Void) {
        if self.progressionTimer != nil {
            self.progressionTimer?.invalidate()
            self.progressionTimer = nil
        }
        if #available(iOSApplicationExtension 10.0, *) {
            self.progressionTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { (timer) in
                
                var isProgressionDone: ((_ currentProgress: Double, _ endProgress: Double) -> Bool)!
                
                // should I increment or decrement ?
                var animatorProgress: Double!
                if endProgress > startProgress {
                    isProgressionDone = { $0 >= $1 }
                    animatorProgress = self._animatorProgress + 0.04
                    animatorProgress = min(animatorProgress, endProgress)
                } else {
                    isProgressionDone = { $0 <= $1 }
                    animatorProgress = self._animatorProgress - 0.04
                    animatorProgress = max(animatorProgress, endProgress)
                }
                
                // set the new progress
                self._animatorProgress = animatorProgress
                
                // invalidate the timer
                if isProgressionDone(self._animatorProgress, endProgress) {
                    timer.invalidate()
                    block()
                }
            }
        } else {
            self._animatorProgress = endProgress
            block()
        }
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let roundBezier = UIBezierPath(ovalIn: rect)
        
        let roundShape = CAShapeLayer()
        roundShape.path = roundBezier.cgPath
        roundShape.lineWidth = 2
        roundShape.fillColor = UIColor.clear.cgColor
        roundShape.strokeColor = UIColor.red.cgColor
        
        let fillRoundShape = CAShapeLayer()
        fillRoundShape.path = roundBezier.cgPath
        fillRoundShape.fillColor = UIColor.red.cgColor
        fillRoundShape.opacity = Float(self._animatorProgress)
        
        self.layer.removeSublayers()
        self.layer.addSublayer(fillRoundShape)
        self.layer.addSublayer(roundShape)
    }
    
}
