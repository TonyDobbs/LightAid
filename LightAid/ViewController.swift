//
//  ViewController.swift
//  LightAid
//
//  Created by Tony Dobbs on 7/11/15.
//  Copyright (c) 2015 PaperCrane. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    @IBOutlet var startView: UIView!
    @IBOutlet var therapyView: UIView!
    
    @IBOutlet var cancelTherapy: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        startView.hidden = false;
        therapyView.hidden = true;
    }

    
    @IBAction func beginTherapyBtnAction(sender: UIButton) {
        startView.hidden = true;
        therapyView.hidden = false;
    }
    
    @IBAction func tapEndTherapyGestureAction(sender: UITapGestureRecognizer) {
        therapyView.hidden = true;
        startView.hidden = false;
    }



}

