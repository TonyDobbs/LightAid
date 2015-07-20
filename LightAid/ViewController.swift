//
//  ViewController.swift
//  LightAid
//
//  Created by Tony Dobbs on 7/11/15.
//  Copyright (c) 2015 PaperCrane. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}


class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    

    @IBOutlet var startView: UIView!
    @IBOutlet var pickerLabel: UILabel!
    @IBOutlet var beginBtn: UIButton!
    @IBOutlet var pickerView: UIPickerView!
    
    @IBOutlet var intermittentView: UIView!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var rotateImageView: UIImageView!
    
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
    
    let minutes = Array(1...4)
    var selectedMinute: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        setupStartView()
        setupTherapyView()
        setupIntermittentView()
        
        pickerView.delegate = self;
        pickerView.dataSource = self;
        
        showStartView()
        
        infoCancelLabel.alpha = 0
    }
    

    @IBAction func beginTherapyBtnAction(sender: UIButton) {
        let statusBarOrientation = UIApplication.sharedApplication().statusBarOrientation
        if (statusBarOrientation == UIInterfaceOrientation.Portrait || statusBarOrientation == UIInterfaceOrientation.PortraitUpsideDown) {
            showIntermittentView()
        } else {
            startTherapySession()
        }
    }
    
    @IBAction func tapEndTherapyGestureAction(sender: UITapGestureRecognizer) {
        endTherapySession()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            println("landscape")
            if (intermittentView.hidden == false) {
                self.infoLabel.text = "Thank you"
                self.rotateImageView.image = UIImage(named: "Happy-99")
                self.rotateImageView.image = self.rotateImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                
                var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    self.startTherapySession()
                })
                
            }
        } else {
            println("portrait")
        }
    }

    
    // MARK: View Handling
    func setupStartView() {
        startView.backgroundColor = UIColor(netHex:ColorConstants.kStartViewBackgroundColor)
        pickerLabel.textColor = UIColor(netHex: ColorConstants.kStartViewLabelMainColor)
        beginBtn.tintColor = UIColor(netHex: ColorConstants.kStartViewLabelMainColor)
        
    }
    func setupTherapyView() {
        therapyView.backgroundColor = UIColor(netHex:ColorConstants.kTherapyBlue)
        infoCancelLabel.tintColor = UIColor(netHex: ColorConstants.kTherapyViewLabelColor)
        therapyTimerLabel.tintColor = UIColor(netHex: ColorConstants.kTherapyViewLabelColor)
    }
    
    func setupIntermittentView() {
        intermittentView.backgroundColor = UIColor(netHex: ColorConstants.kIntermittentViewBackgroundColor)
        
        rotateImageView.image = rotateImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        rotateImageView.tintColor = UIColor(netHex: ColorConstants.kIntermittentViewMainColor)
        
        infoLabel.textColor = rotateImageView.tintColor
        infoLabel.font = UIFont(name: "HelveticaNeue", size: 30.0)
        
        infoLabel.text = "Please rotate device to landscape"
        
    }
    
    func showStartView() {
        intermittentView.hidden = true
        therapyView.hidden = true
        startView.hidden = false

    }
    
    func showTherapyView() {
        startView.hidden = true
        intermittentView.hidden = true
        therapyView.hidden = false
    }
    
    func showIntermittentView() {
        rotateImageView.image = UIImage(named: "Rotate To Landscape-99")
        rotateImageView.image = rotateImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)

        infoLabel.text = "Please rotate device to landscape"
        
        startView.hidden = true
        therapyView.hidden = true
        intermittentView.hidden = false
    }

    // MARK: Therapy Session Methods 

    
    func startTherapySession() {
        //Change to Therapy Screen
        showTherapyView()
        
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
        showStartView()
        
        //Revert back to user set brightness
        UIScreen.mainScreen().brightness = userBrightness;
    }


    // MARK: Timer Methods

    func timerDidEnd(timer:NSTimer)
    {
        //timer that counts down
        timeCount = timeCount - timeInterval
        
        if timeCount <= 0
        {  //test for target time reached.
            self.therapyTimerLabel.text = "Finished!"
            timer.invalidate()
            
            var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(),
                {
                // your function here
                self.endTherapySession()
            })
        } else { //update the time on the clock if not reached
            self.therapyTimerLabel.text = timeString(timeCount)
        }

    

    }

    func resetTimeCount()
    {
        timeCount = timerEnd
    }
    
    
    func timeString(time:NSTimeInterval) -> String
    {
        //Formats the timeCount for Label output
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        //let secondFraction = Int((time - Double(seconds + (minutes*60))) * 10.0)
        return String(format:"%02i:%02i",minutes,seconds)
    }

    //MARK: PickerView Implementation
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return minutes.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
        if minutes[row] == 1
        {
            return String(format: "%d minute", minutes[row])
        } else
        {
            return String(format: "%d minutes", minutes[row])
            
        }
    }
    
//    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
//        var pickerLabel = view as! UILabel!
//        if view == nil {  //if no label there yet
//            pickerLabel = UILabel()
//            //color the label's background
//            let hue = CGFloat(row)/CGFloat(minutes.count)
//            pickerLabel.backgroundColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
//        }
//        let titleData: String!
//        if component == 0
//        {
//            if minutes[row] == 1
//            {
//                titleData = String(format: "%d minute", minutes[row])
//            } else
//            {
//                titleData =  String(format: "%d minutes", minutes[row])
//                
//            }
//        } else
//        {
//            if seconds[row] == 1
//            {
//                titleData = String(format: "%d second", seconds[row])
//            } else
//            {
//                titleData = String(format: "%d seconds", seconds[row])
//                
//            }
//        }
//
//        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 26.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
//        pickerLabel!.attributedText = myTitle
//        
//        return pickerLabel
//        
//    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        var minutesStr:String!
        
        if minutes[row] == 1
        {
            minutesStr = String(format: "%d minute", minutes[row])
        } else
        {
            minutesStr = String(format: "%d minutes", minutes[row])
            
        }
        
        var attributedString = NSAttributedString(string: minutesStr, attributes: [NSForegroundColorAttributeName : UIColor.redColor()])
        

        
        return attributedString
    }

    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedMinute = minutes[row]
        setPickerLabel()
        
    }
    
    func setPickerLabel ()
    {
        /*
        SetPickerLabel
        Formats and sets the string needed from the PickerView onto the PickerLabel
        */
        
        var minutesStr: String;
        
        if selectedMinute == 1
        {
            minutesStr = String(format: "%d minute", selectedMinute)
        } else {
            minutesStr = String(format: "%d minutes", selectedMinute)
        }
        
        pickerLabel.text = String(format: "%@", minutesStr)

    }
}
