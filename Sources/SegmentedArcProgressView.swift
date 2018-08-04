//
//  SegmentedArcProgressView.swift
//  SegmentedArcProgressView-iOS
//
//  Created by Kévin MACHADO on 11/06/2018.
//  Copyright © 2018 Zerty Color. All rights reserved.
//

import UIKit

public class SegmentedArcProgressView: UIView {
    
    var size = CGSize(width: 2, height: 16) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var margin: Double = 60 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var progressionTimer: Timer?
    
    public var progress: Double? {
        didSet {
            if let progress = self.progress {
                self.animate(from: _animatorProgress ?? 0, to: progress)
            } else {
                self.dehighlightIndicator()
            }
        }
    }
    
    var _animatorProgress: Double? {
        didSet {
            self.prepareDrawing(then: setNeedsDisplay)
        }
    }
    
    /// nb of segments drawn of the arc
    public var nbSegments = 5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private func dehighlightIndicator() {
        self._animatorProgress = nil
    }
    
    private func animate(from startProgress: Double, to endProgress: Double, duration: Double = 0.2) {
        if self.progressionTimer != nil {
            self.progressionTimer?.invalidate()
            self.progressionTimer = nil
        }
        if #available(iOS 10.0, *) {
            self.progressionTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { (timer) in
                
                var isProgressionDone: ((_ currentProgress: Double, _ endProgress: Double) -> Bool)!
                
                // should I increment or decrement ?
                var animatorProgress: Double!
                if endProgress > startProgress {
                    isProgressionDone = { $0 >= $1 }
                    animatorProgress = (self._animatorProgress ?? 0) + 0.02
                    animatorProgress = min(animatorProgress, endProgress)
                } else {
                    isProgressionDone = { $0 <= $1 }
                    animatorProgress = (self._animatorProgress ?? 0) - 0.02
                    animatorProgress = max(animatorProgress, endProgress)
                }
                
                // set the new progress
                self._animatorProgress = animatorProgress
                
                // invalidate the timer
                if isProgressionDone(self._animatorProgress!, endProgress) {
                    timer.invalidate()
                }
            }
        } else {
            self._animatorProgress = endProgress
        }
        
    }
    
    /// This method calculate all path to prepare for drawing then call the completion block in the main thread.
    ///
    /// - parameters:
    ///     - completion: The block that will be called after calculating all draws.
    ///         **Called in the main thread.**
    func prepareDrawing(then completion: @escaping () -> Void) {
        // 🤟 Access to the UIView.bound within the main thread
        let bounds = self.bounds
        
        // calculate all paths withing the `background` then fire 🎉
        DispatchQueue.global(qos: .background).async {
            self.layerDraw = self.layerDraw(bounds)
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    private var layerDraw: CALayer? {
        willSet {
            layerDraw?.removeFromSuperlayer()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(_ aDecoder:) method not implemented")
    }

    public override func draw(_ rect: CGRect) {
        super.draw(rect)

        // set the background color to `clear`
        self.backgroundColor = UIColor.clear
        self.backgroundColor?.setFill()
        UIGraphicsGetCurrentContext()!.fill(rect)

        if let layerDraw = self.layerDraw {
            self.layer.addSublayer(layerDraw)
        }
    }
    
    private func layerDraw(_ rect: CGRect) -> CALayer {
        
        /// radius of the semi-circle
        let radius = (Double(rect.size.width)-(margin*2))/2
        
        /// base of the arc
        let anchor = CGPoint(x: margin+radius, y: margin+radius)
        
        /// Radius that separate each segment drawing
        let segmentRadiusSpacing = Double(180)/Double(nbSegments-1)
        
        let segmentsPath = UIBezierPath()
        
        //    B
        //    | -
        //    |   -
        //  o |     -  h (radius)
        //    |       -
        //    |         -
        //  C ------------ A
        //       a
        //
        for segmentIndex in 0...nbSegments - 1 {
            
            // initial datas
            let angleA = segmentRadiusSpacing * Double(segmentIndex)
            let cosA = cos(angleA * Double.pi / 180)
            let sinA = sin(angleA * Double.pi / 180)
            
            var drawingRatio: Double = 1
            if let progress = self._animatorProgress {
                let progressAngle = progress * 180
                let dist = angleA - progressAngle
                if abs(dist) < segmentRadiusSpacing {
                    if progressAngle < angleA {
                        // how far to the previous
                        drawingRatio = 1 - ((dist)/segmentRadiusSpacing)
                    }
                    else if progressAngle > angleA {
                        // how far to the next
                        drawingRatio = 1 + ((dist)/segmentRadiusSpacing)
                    }
                    else { // get current only
                        drawingRatio = 1
                    }
                    drawingRatio = drawingRatio + 1
                }
            }
            
            // calculate length for each side of the triangle
            let distAB = radius
            let distAC = cosA * distAB
            let distBC = sinA * distAB
            
            // origin of the segment
            let segmentPosX = Double(anchor.x) - distAC
            let segmentPosY = Double(anchor.y) - distBC
            let segmentPos = CGPoint(x: segmentPosX, y: segmentPosY)
            
            // path
            let width = Double(self.size.width) * drawingRatio
            let height = Double(self.size.height) * drawingRatio
            let segmentPath = UIBezierPath(rect: CGRect(x: Double(segmentPos.x) - 1 - width/2,
                                                        y: Double(segmentPos.y) - height/2,
                                                        width: width,
                                                        height: height))
            
            // move origin to center of the segment
            segmentPath.apply(CGAffineTransform(translationX: CGFloat(-segmentPosX), y: CGFloat(-segmentPosY)))
            
            // apply the rotation (angle - angle90)
            let radAngleA = CGFloat(angleA * Double.pi / 180)
            let rad90 = CGFloat(90 * Double.pi / 180)
            segmentPath.apply(CGAffineTransform(rotationAngle: (radAngleA - rad90)))
            
            // move anchor back to origin
            segmentPath.apply(CGAffineTransform(translationX: CGFloat(segmentPosX), y: CGFloat(segmentPosY)))
            
            segmentsPath.append(segmentPath)
        }
        
        // draw shape (mask) with the path above
        let maskSegmentShapeLayer = CAShapeLayer()
        maskSegmentShapeLayer.path = segmentsPath.cgPath
        
        // create the gradient and define the mask
        let gradient = CAGradientLayer()
        gradient.mask = maskSegmentShapeLayer
        
        // configure gradient's colors
        let startGradient = UIColor.cyan
        let halfGradient = UIColor.purple
        let endGradient = UIColor.red
        
        // configure the gradient
        gradient.colors = [startGradient.cgColor, halfGradient.cgColor, endGradient.cgColor]
        gradient.locations = [0, 0.5, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        
        // define the gradient's frame
        gradient.frame = rect
        
        return gradient
    }
    
}

extension CALayer {
    func removeSublayers() {
        self.sublayers?.removeLayers()
    }
}

extension Array where Element == CALayer {
    func removeLayers() {
        self.forEach { (layer) in
            (layer as CALayer).removeFromSuperlayer()
        }
    }
}
