//
//  AnimatableView.swift
//  SegmentedArcProgressView-iOS
//
//  Created by Kévin MACHADO on 12/06/2018.
//  Copyright © 2018 Zerty Color. All rights reserved.
//

import UIKit

public class AnimatedView: UIView, AnimatableView {
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var slotRatioPosition: Double = 0
    var isAnimated: Bool = false
    private var isAnimating: Bool = false
    
    public func animateView(then block: @escaping () -> Void) {}
    public func rewindView(then block: @escaping () -> Void) {}
    
    
    func animate() {
        if self.isAnimated || self.isAnimating { return }
        print("▶️ animate in \(slotRatioPosition) ratio")
        self.isAnimating = true
        self.animateView(then: {
            self.isAnimating = false
            self.isAnimated = true
        })
    }
    
    func rewind() {
        if self.isAnimated == false || self.isAnimating { return }
        print("⏪ rewind in \(slotRatioPosition) ratio")
        self.isAnimating = true
        self.rewindView(then: {
            self.isAnimating = false
            self.isAnimated = false
        })
    }
}

protocol AnimatableView where Self: UIView {
    var isAnimated: Bool { get set }
    func animate()
    func animateView(then block: @escaping () -> Void)
    func rewind()
    func rewindView(then block: @escaping () -> Void)
}
