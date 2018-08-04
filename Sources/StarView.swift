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
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else {
            fatalError("Unable to get the current context")
        }
        
        // initial parameters
        let centerPoint = CGPoint(x: rect.width/2, y: rect.height/2)
        let radius = rect.width / 2
        
        // configure context
        context.setLineWidth(2)
        context.setFillColor(UIColor.orange.cgColor)
        
        // 144 degrees
        let theta = 2.0 * Double.pi * (2.0/5.0)
        
        // start from the top
        context.move(to: CGPoint(x: centerPoint.x, y: centerPoint.y + -radius))
        
        // draw all peaks
        for i in 1...5 {
            let x = Double(radius) * sin(Double(i) * theta)
            let y = Double(radius) * cos(Double(i) * theta)
            context.addLine(to: CGPoint(x: -x+Double(centerPoint.x), y: -y+Double(centerPoint.y)))
        }
        
        context.closePath()
        context.fillPath()
    }
    
}
