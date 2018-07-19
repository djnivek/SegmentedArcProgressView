//
//  StarredSegmentedArcProgressView.swift
//  SegmentedArcProgressView-iOS
//
//  Created by Kévin MACHADO on 09/07/2018.
//  Copyright © 2018 Zerty Color. All rights reserved.
//

import UIKit

public class CheckpointSegmentedArcProgressView: SegmentedArcProgressView {
    
    /// This array define the location of the checkpoints
    ///
    /// Location must be a `Double` between `0` to `1` that represent the progress ratio.
    public var checkpointLocations: [Double] = [] {
        didSet {
            self.instantiateViews()
        }
    }
    
    private var slots: [AnimatedView] = []
    
    override var _animatorProgress: Double? {
        didSet {
            self.updateAnimationStatus()
            self.prepareDrawing(then: setNeedsDisplay)
        }
    }
    
    private var _lastBounds = CGRect.zero
    private func hasBoundChanged(rect: CGRect) -> Bool {
        defer {
            _lastBounds = rect
        }
        return rect != _lastBounds
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if hasBoundChanged(rect: bounds) {
            let positions = self.searchSlotPositions(in: bounds)
            for (index, view) in self.slots.enumerated() {
                let pos = positions[index]
                view.slotRatioPosition = pos.ratio
                view.frame = CGRect(origin: pos.point, size: CGSize(width: 10, height: 10))
            }
        }
    }
    
    private func updateAnimationStatus() {
        guard let progression = self._animatorProgress else { return }
        let slotsToAnimateIfNeeded = self.slots.filter({$0.slotRatioPosition <= progression})
        let slotsToRewindIfNeeded = self.slots.filter({$0.slotRatioPosition > progression})
        slotsToAnimateIfNeeded.forEach({$0.animate()})
        slotsToRewindIfNeeded.forEach({$0.rewind()})
    }
    
    private func searchSlotPositions(in rect: CGRect) -> [(point: CGPoint, ratio: Double)] {
        var slotsPoint = [(CGPoint, Double)]()
        for ratio in self.checkpointLocations {
            let angleA = Double(180) * ratio
            let cosA = cos(angleA * Double.pi / 180)
            let sinA = sin(angleA * Double.pi / 180)
            
            let slotMargin = Double(20)
            let radiusSlot = (Double(rect.size.width)/2) - slotMargin
            let distABSlot = radiusSlot
            let distACSlot = cosA * distABSlot
            let distBCSlot = sinA * distABSlot
            let anchorSlot = CGPoint(x: radiusSlot, y: radiusSlot)
            let segmentSlotPosX = Double(anchorSlot.x) - distACSlot + slotMargin
            let segmentSlotPosY = Double(anchorSlot.y) - distBCSlot + slotMargin
            let segmentSlotPos = CGPoint(x: segmentSlotPosX, y: segmentSlotPosY)
            slotsPoint.append((segmentSlotPos, ratio))
        }
        return slotsPoint
    }
    
    private func instantiateViews() {
        self.slots.forEach { $0.removeFromSuperview() }
        self.slots.removeAll()
        // instantiate and attach the checkpoint views to the parent view.
        for _ in 1...self.checkpointLocations.count {
            let view = StarView(frame: CGRect.zero)
            self.addSubview(view)
            self.slots.append(view)
        }
    }
    
}
