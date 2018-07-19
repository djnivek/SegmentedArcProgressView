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
    
    let sliderView = UISlider(frame: CGRect(x: 25, y: 0, width: 200, height: 150))
//    let arcView: SegmentedArcProgressView = {
//        let arcRect = CGRect(x: 5, y: 460, width: 355, height: 200)
//        let progressView = SegmentedArcProgressView(frame: arcRect)
//        return progressView
//    }()
    
    let arcView: CheckpointSegmentedArcProgressView = {
        let arcRect = CGRect(x: 5, y: 460, width: 355, height: 200)
        let progressView = CheckpointSegmentedArcProgressView(frame: arcRect)
        progressView.checkpointLocations = [0.0, 0.2, 0.5, 0.8, 1.0]
        return progressView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        arcView.nbSegments = 37
        arcView.progress = 0.07
        
        sliderView.addTarget(self, action: #selector(updateProgress), for: UIControlEvents.valueChanged)
        
        view.addSubview(sliderView)
        view.addSubview(arcView)
    }
    
    @IBAction func updateRatio(_ sender: UIButton) {
        if let ratio = sender.titleLabel?.text, ratio != "nil" {
            arcView.progress = Double(ratio)
        } else {
            arcView.progress = nil
        }
    }
    
    @objc func updateProgress() {
        arcView.progress = Double(sliderView.value)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

