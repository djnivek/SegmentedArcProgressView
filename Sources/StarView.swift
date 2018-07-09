//
//  StarView.swift
//  SegmentedArcProgressView-iOS
//
//  Created by Kévin MACHADO on 12/06/2018.
//  Copyright © 2018 Zerty Color. All rights reserved.
//

import UIKit

public class StarView: UIView, AnimatableView {
    
    private var _animatorProgress: Double = 0
    
    private var progress: Double = 0
    
    private var progressionTimer: Timer?
    
    func animate() {
        self.animate(from: _animatorProgress, to: 1)
    }
    
    func rewind() {
        self.animate(from: _animatorProgress, to: 0)
    }
    
    private func animate(from startProgress: Double, to endProgress: Double, duration: Double = 0.2) {
        if self.progressionTimer != nil {
            self.progressionTimer?.invalidate()
            self.progressionTimer = nil
        }
        if #available(iOSApplicationExtension 10.0, *) {
            self.progressionTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { (timer) in
                
                var isProgressionDone: ((_ currentProgress: Double, _ endProgress: Double) -> Bool)!
                
                // should I increment or decrement ?
                var animatorProgress: Double!
                if endProgress > startProgress {
                    isProgressionDone = { $0 >= $1 }
                    animatorProgress = self._animatorProgress + 0.02
                    animatorProgress = min(animatorProgress, endProgress)
                } else {
                    isProgressionDone = { $0 <= $1 }
                    animatorProgress = self._animatorProgress - 0.02
                    animatorProgress = max(animatorProgress, endProgress)
                }
                
                // set the new progress
                self._animatorProgress = animatorProgress
                
                // invalidate the timer
                if isProgressionDone(self._animatorProgress, endProgress) {
                    timer.invalidate()
                }
            }
        } else {
            self._animatorProgress = endProgress
        }
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        let roundBezier = UIBezierPath(ovalIn: rect)
        let roundShape = CAShapeLayer()
        roundShape.path = roundBezier.cgPath
        roundShape.lineWidth = 2
        roundShape.strokeColor = UIColor.red.cgColor
        self.layer.removeSublayers()
        self.layer.addSublayer(roundShape)
    }
    
}
