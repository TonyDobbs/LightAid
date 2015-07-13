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
    @IBOutlet var infoCancelLabel: UILabel!
    @IBOutlet var therapyTimerLabel: UILabel!
    
    
    @IBOutlet var cancelTherapy: UITapGestureRecognizer!
    
    var userBrightness: CGFloat = UIScreen.mainScreen().brightness
    let infoLabelAnimateDuration: NSTimeInterval = 0.6 //seconds to end the timer

    var timer = NSTimer() //make a timer variable, but don't do anything yet
    let timeInterval: NSTimeInterval = 0.05 //0.5x the smallest unit of time
    let timerEnd: NSTimeInterval = 60 //seconds to end the timer
    var timeCount: NSTimeInterval = 0.0 // counter for the timer
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        startView.hidden = false
        therapyView.hidden = true
        
        infoCancelLabel.alpha = 0
    }
    

    @IBAction func beginTherapyBtnAction(sender: UIButton) {
        showInstructionsAlert()
        
    }
    
    @IBAction func tapEndTherapyGestureAction(sender: UITapGestureRecognizer) {
        endTherapySession()
    }

    // MARK: Therapy Session Methods 
    func showInstructionsAlert() {
        let message = "For best results, rotate screen to landscape and place screen 6 inches away from face"
        var alert = UIAlertController(title: "Instructions", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ (action) -> Void in
            self.startTherapySession()
        }))
        self.presentViewController(alert, animated: true, completion:nil)

    }
    

    
    func startTherapySession() {
        //Change to Therapy Screen
        startView.hidden = true
        therapyView.hidden = false
        
        //Save userSetScreenBrightnessValue and set to max
        userBrightness = UIScreen.mainScreen().brightness
        UIScreen.mainScreen().brightness = CGFloat(1.0)
    
        resetTimeCount()
        therapyTimerLabel.text = timeString(timeCount)
        
        var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
 

            //Start Therapy Timer, Reset Time Count, & Set timerLabel
            if !self.timer.valid{ //prevent more than one timer on the thread
                self.resetTimeCount()
                self.therapyTimerLabel.text = self.timeString(self.timeCount)
                self.timer = NSTimer.scheduledTimerWithTimeInterval(self.timeInterval,
                    target: self,
                    selector: "timerDidEnd:",
                    userInfo: nil,
                    repeats: true) //repeating timer in the second iteration
            }

        })

        
        
        //Animate the Info Label Fade
        animateInfoLabel()

    }
    
    func animateInfoLabel() {
        //Need to fade in and out 3x.
        //Start 0->1->0->1->0->1->0
        
        UIView.animateWithDuration(self.infoLabelAnimateDuration, animations: { () -> Void in
            self.infoCancelLabel.alpha = 1.0
            }) { (finished) -> Void in
                UIView.animateWithDuration(self.infoLabelAnimateDuration, animations: { () -> Void in
                    self.infoCancelLabel.alpha = 0.0
                    }) { (finished) -> Void in
                        UIView.animateWithDuration(self.infoLabelAnimateDuration, animations: { () -> Void in
                            self.infoCancelLabel.alpha = 1.0
                            }) { (finished) -> Void in
                                UIView.animateWithDuration(self.infoLabelAnimateDuration, animations: { () -> Void in
                                    self.infoCancelLabel.alpha = 0.0
                                    }) { (finished) -> Void in
                                        UIView.animateWithDuration(self.infoLabelAnimateDuration, animations: { () -> Void in
                                            self.infoCancelLabel.alpha = 1.0
                                            }) { (finished) -> Void in
                                                UIView.animateWithDuration(self.infoLabelAnimateDuration, animations: { () -> Void in
                                                    self.infoCancelLabel.alpha = 0.0
                                                    }) { (finished) -> Void in
                                                        
                                                        
                                                }
                                                
                                        }
                                        
                                }
                                
                        }
                        
                }
        }
        
        
        
    }
    
    func endTherapySession() {
        timer.invalidate()
        
        //Change to StartScreen
        therapyView.hidden = true;
        startView.hidden = false;
        
        //Revert back to user set brightness
        UIScreen.mainScreen().brightness = userBrightness;
    }


    // MARK: Timer Methods

    func timerDidEnd(timer:NSTimer){
        //timer that counts down
        timeCount = timeCount - timeInterval
        if timeCount <= 0 {  //test for target time reached.
            self.therapyTimerLabel.text = "Finished!"
            timer.invalidate()
            
            var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                // your function here
                self.endTherapySession()
            })
        } else { //update the time on the clock if not reached
            self.therapyTimerLabel.text = timeString(timeCount)
        }

    

    }

    func resetTimeCount() {
        timeCount = timerEnd
    }
    
    
    func timeString(time:NSTimeInterval) -> String {
        //Formats the timeCount for Label output
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        //let secondFraction = Int((time - Double(seconds + (minutes*60))) * 10.0)
        return String(format:"%02i:%02i",minutes,seconds)
    }



}
