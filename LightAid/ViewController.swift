//
//  ViewController.swift
//  LightAid
//
//  Created by Tony Dobbs on 7/11/15.
//  Copyright (c) 2015 PaperCrane. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBAction func beginTherapy(sender: AnyObject) {
        therapyView.hidden=false;
    }

    @IBOutlet weak var therapyView: UIView!
    
    @IBOutlet var cancelTherapy: UITapGestureRecognizer!
    
    @IBAction func endTherapy(sender: AnyObject) {
        therapyView.hidden=true;
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        therapyView.hidden=true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

