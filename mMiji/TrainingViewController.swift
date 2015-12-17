//
//  TrainingViewController.swift
//  
//
//  Created by Alan Hasty on 11/28/15.
//
//

import UIKit
import Foundation
import CoreGraphics
import WMGaugeView
import SFCountdownView


struct Timers {
    var workoutTime: Int = 0
    var effortTime: Int = 0
    var intervalTime: Int = 0
}

class TrainingViewController: UIViewController {
    
    var tonightsWorkoutStr = ""
    var tonightsWorkout = 999
    
    var runningTimer = NSTimer()
    var wkoutTimers: Timers = Timers()
    
    var timerSpeed: Double = 0.2 // Change this to 1.0 if you want proper time
    var selectedRiderIndex: Int = 0
    var wkoutIndex = 0
    var hardwork: WorkoutPPP = WorkoutPPP()
    
    var hudShowing: Bool = false
    var pingPong:Bool = false
    
    @IBOutlet weak var WorkoutName: UILabel!
    
    @IBOutlet weak var intervalTimerDesc: UILabel!
    @IBOutlet weak var intervalTimerString: UILabel!
    @IBOutlet weak var intervalTextString: UILabel!
    @IBOutlet weak var effortTimerString: UILabel!
    @IBOutlet weak var workoutTimerString: UILabel!
    
    @IBOutlet weak var curEffortStr: UILabel!
    @IBOutlet weak var curGearStr: UILabel!
    @IBOutlet weak var curDescStr: UILabel!
    
    @IBOutlet weak var nextEffortStr: UILabel!
    @IBOutlet weak var nextGearStr: UILabel!
    @IBOutlet weak var nextDescStr: UILabel!
    
    var curEffortStruct =  Effort(duration: 2.0, finishTime: 58.0, gear:"B17", desc:"Test", intervals: [])
    var nextEffortStruct = Effort(duration:4.00, finishTime: 62.0, gear: "S15",desc: "Spin doctor", intervals: [])
    
    @IBAction func returnToWorkoutSelction(segue:UIStoryboardSegue) {
        // This will get us back I think!
    }
    
    @IBAction func startHUD(sender: AnyObject) {
        print("Button Pressed")
    }
  
    @IBOutlet weak var cadenceView: WMGaugeView!
    
    func manageTicks() {
        wkoutTimers.workoutTime += 1
        wkoutTimers.effortTime -= 1
        if hardwork.tonightsWorkout.efforts[wkoutIndex].intervals.count != 0
        {
            wkoutTimers.intervalTime -= 1
        }
        else
        {
            wkoutTimers.intervalTime = 0
        }
      
        let newVal = Float(cscDevices[pairedRiderIndex].wheelRevs)
        cadenceView.setValue(newVal, animated: false)
    }
    
    func intervalTime()
    {
        let iMin = wkoutTimers.intervalTime / 60
        let iSec = wkoutTimers.intervalTime % 60
        intervalTimerString.text = String(format: "%.2d:%.2d",iMin, iSec)
    
    }
    
    func updateIntervalTimerText()
    {
        let currentEffort = hardwork.tonightsWorkout.efforts[wkoutIndex]
        if currentEffort.intervals.count != 0
        {
            intervalTime()
            updateInterval()
        }
    }
    
    func updateInterval()
    {
        let currentEffort = hardwork.tonightsWorkout.efforts[wkoutIndex]
        if currentEffort.intervals.count != 0
        {
            if wkoutTimers.intervalTime == 0
            {
                intervalTimerString.hidden = false
                intervalTextString.hidden = false
                intervalTimerDesc.hidden = false
                if ( pingPong == true )
                {
                    intervalTextString.text = currentEffort.intervals[1].intString
                    wkoutTimers.intervalTime = currentEffort.intervals[1].intTime
                    print("Setting Interval Time = \(wkoutTimers.intervalTime)")
                    intervalTime()
                    pingPong = false
                }
                else
                {
                    intervalTextString.text = currentEffort.intervals[0].intString
                    wkoutTimers.intervalTime = currentEffort.intervals[0].intTime
                    intervalTime()
                    print("Setting Interval Time = \(wkoutTimers.intervalTime)")
                    pingPong = true
                }
            }
        }
        else
        {
            // This is the case that there is no interval timer 
            intervalTimerString.hidden = true
            intervalTextString.hidden = true
            intervalTimerDesc.hidden = true
        }
    
    }
    
    func updateEffortTimerText()
    {
        let effMin = wkoutTimers.effortTime / 60
        let effSec = wkoutTimers.effortTime % 60
        
        effortTimerString.text = String(format: "%.2d:%.2d",effMin, effSec)
        
        if wkoutTimers.effortTime < 5  && hudShowing == false {
            hudShowing = true;
        }
    }
    
    func updateWorkoutTimerText()
    {
        let curMin = wkoutTimers.workoutTime / 60
        let curSec = wkoutTimers.workoutTime % 60
        
        workoutTimerString.text = String(format: "%.2d:%.2d",curMin, curSec)
    
    }
    
    func isEndOfEffort() -> Bool {
        let endOfEffort = Int(hardwork.tonightsWorkout.efforts[wkoutIndex].finishTime)
        if endOfEffort == wkoutTimers.workoutTime / 60  {
            return true
        }
        return false
    }
    
    func manageTimersAndUpdateWorkout()
    {
        manageTicks()
        
        if isEndOfEffort() {
            wkoutIndex++
            if wkoutIndex < hardwork.tonightsWorkout.efforts.count {
                updateCurrentEfffortLine(wkoutIndex)
                updateNextEffortLine(wkoutIndex)

                hudShowing = false
                
            }
            else
            {
                runningTimer.invalidate()
                let alertController = UIAlertController(title: "Whew!", message: "Workout Done", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil ))
                presentViewController(alertController, animated: true, completion: nil)
                workoutRunning = OperationState.Finished
            }
        }
        else
        {
            updateWorkoutTimerText()
            updateEffortTimerText()
            updateIntervalTimerText()
        }
    }
    
    func updateCurrentEfffortLine(index: Int) {
        if index < hardwork.tonightsWorkout.efforts.count {
            curEffortStruct = hardwork.tonightsWorkout.efforts[index]
            curEffortStr.text = String(curEffortStruct.duration)
            curGearStr.text = curEffortStruct.gear
            curDescStr.text = curEffortStruct.desc
            
            wkoutTimers.effortTime = Int((curEffortStruct.duration * 60 ) )
            print("Setting Effort Time = \(wkoutTimers.effortTime)")
            pingPong = false
            updateInterval()
        }
    }
    
    func updateNextEffortLine(index: Int) {

        if ( index < hardwork.tonightsWorkout.efforts.count-1){
            nextEffortStruct = hardwork.tonightsWorkout.efforts[index+1]
            nextEffortStr.text = String(nextEffortStruct.duration)
            nextGearStr.text = nextEffortStruct.gear
            nextDescStr.text = nextEffortStruct.desc
        }
        else
        {
            // This means the workout is on the last effort (cool down)
            // clear the next lables as there are no more efforts
            nextEffortStr.text = ""
            nextGearStr.text = ""
            nextDescStr.text = ""

        }
    }
    
    enum OperationState {
        case NotStarted
        case Running
        case Paused
        case Finished
    }
    var workoutRunning: OperationState = OperationState.NotStarted
    
    @IBAction func startTonightsWorkout(sender: UIButton) {
        // Here we go..
        if ( workoutRunning == OperationState.NotStarted)
        {
            runningTimer = NSTimer.scheduledTimerWithTimeInterval(timerSpeed, target: self, selector: "manageTimersAndUpdateWorkout",
                userInfo: nil, repeats: true)
            workoutRunning = OperationState.Running

            sender.setTitle("Pause", forState: UIControlState.Normal)
        }
        else
        {
            if workoutRunning == OperationState.Running
            {
                runningTimer.invalidate()
                sender.setTitle("Continue", forState: UIControlState.Normal)
                workoutRunning = OperationState.Paused
            }
            else if workoutRunning == OperationState.Paused
            {
                runningTimer = NSTimer.scheduledTimerWithTimeInterval(timerSpeed, target: self, selector: "manageTimersAndUpdateWorkout",
                    userInfo: nil, repeats: true)
                workoutRunning = OperationState.Running
                sender.setTitle("Pause", forState: UIControlState.Normal)
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
       // Do any additional setup after loading the view.
        hardwork = WorkoutPPP(workoutSelection: tonightsWorkoutStr)
        
        print(hardwork)
        WorkoutName.text = String("Workout #\(hardwork.tonightsWorkout.name)")
        wkoutIndex = 0
        updateCurrentEfffortLine(wkoutIndex)
        updateNextEffortLine(wkoutIndex)
        updateEffortTimerText()
        
        var loopCount = 0
        for rider in cscDevices
        {
            if (( rider.paired ) == true )
            {
                selectedRiderIndex = loopCount
                break
            }
            loopCount += 1
        }

        //cadenceView.style = WMGaugeView.WMGaugeViewStyleFlatThin
        cadenceView.setValue(10, animated: false)
        cadenceView.maxValue = 200.0
        cadenceView.scaleDivisions = 5
        cadenceView.scaleSubdivisions = 10
        cadenceView.scaleStartAngle = 36
        cadenceView.scaleEndAngle = 324
        cadenceView.scaleDivisionColor = UIColor.redColor()
        //cadenceView.showScaleShadow = NO
        //cadenceView.scaleFont = UIFont(fontWithName:@"AvenirNext-UltraLight" size:0.065)
        cadenceView.scalesubdivisionsaligment = WMGaugeViewSubdivisionsAlignmentCenter;
        cadenceView.scaleSubdivisionsWidth = 0.002;
        cadenceView.scaleSubdivisionsLength = 0.04;
        cadenceView.scaleDivisionsWidth = 0.007;
        cadenceView.scaleDivisionsLength = 0.07;
 
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
