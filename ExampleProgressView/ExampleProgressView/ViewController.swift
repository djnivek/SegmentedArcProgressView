//
//  ViewController.swift
//  ExampleProgressView
//
//  Created by Kévin MACHADO on 11/06/2018.
//  Copyright © 2018 Kévin MACHADO. All rights reserved.
//

import UIKit
import SegmentedArcProgressView

class ViewController: UIViewController {
    
    let sliderView = UISlider(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
    let arcView: SegmentedArcProgressView = {
        let arcRect = CGRect(x: 5, y: 460, width: 355, height: 200)
        return SegmentedArcProgressView(frame: arcRect)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = UIView()
        view.backgroundColor = .white
        
        arcView.nbSegments = 37
        arcView.progress = 0.07
        
        sliderView.addTarget(self, action: #selector(updateProgress), for: UIControlEvents.valueChanged)
        
        view.addSubview(sliderView)
        view.addSubview(arcView)
        
        self.view = view
        
    }
    
    @objc func updateProgress() {
        arcView.progress = Double(sliderView.value)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

