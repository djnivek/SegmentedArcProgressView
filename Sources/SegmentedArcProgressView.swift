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
    
    var margin: Double = 35 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var progress: Double? {
        didSet {
            //DispatchQueue.global(qos: .background).async {
            self.layerDraw = self.layerDraw(self.bounds)
            self.setNeedsDisplay()
            //}
        }
    }
    
    /// nb of segments drawn of the arc
    public var nbSegments = 5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var layerDraw: CALayer?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(_ aDecoder:) method not implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.backgroundColor = UIColor.white
        self.backgroundColor?.setFill()
        UIGraphicsGetCurrentContext()!.fill(rect)
        
        layer.removeSublayers()
        if let layerDraw = self.layerDraw {
            layer.addSublayer(layerDraw)
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
            if let progress = self.progress {
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
        
        // draw shape with the path above
        let maskSegmentShapeLayer = CAShapeLayer()
        maskSegmentShapeLayer.path = segmentsPath.cgPath
        
        let gradient = CAGradientLayer()
        gradient.mask = maskSegmentShapeLayer
        
        let startGradient = UIColor.cyan
        let halfGradient = UIColor.purple
        let endGradient = UIColor.red
        
        gradient.colors = [startGradient.cgColor, halfGradient.cgColor, endGradient.cgColor]
        gradient.locations = [0, 0.5, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        
        gradient.frame = rect
        
        return gradient
    }
    
}

extension CALayer {
    func removeSublayers() {
        self.sublayers?.removeLayers()
    }
}

extension Array: Element where Element: CALayer {
    func removeLayers() {
        self.forEach { (layer) in
            (layer as CALayer).removeFromSuperlayer()
        }
    }
}
