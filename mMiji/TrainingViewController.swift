//
//  TrainingViewController.swift
//  
//
//  Created by Alan Hasty on 11/28/15.
//
//

import UIKit

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
    
    var timerSpeed: Float = 0.1 // Change this to 1.0 if you want proper time
    
    var wkoutIndex = 0
    var hardwork: WorkoutPPP = WorkoutPPP()
    
    @IBOutlet weak var WorkoutName: UILabel!
    
    @IBOutlet weak var intervalTimerString: UILabel! 
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
    
    required init? (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    func manageTicks() {
        wkoutTimers.effortTime -= 1
        wkoutTimers.intervalTime -= 1
        wkoutTimers.workoutTime += 1
    }

//    func updateIntervalTimerText(index:Int)
//    {
//        if hardwork.tonightsWorkout.efforts[index].
//    }
    func updateEffortTimerText()
    {
        let effMin = wkoutTimers.effortTime / 60
        let effSec = wkoutTimers.effortTime % 60
        
        effortTimerString.text = String(format: "%.2d:%.2d",effMin, effSec)
        
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
        updateWorkoutTimerText()
        updateEffortTimerText()
        
        
        if isEndOfEffort() {
            wkoutIndex++
            if wkoutIndex < hardwork.tonightsWorkout.efforts.count {
                updateCurrentEfffortLine(wkoutIndex)
                updateNextEffortLine(wkoutIndex)
                //updateIntervalTimerText(wkoutIndex)
                
            }
            else
            {
                runningTimer.invalidate()
                let alertController = UIAlertController(title: "Whew!", message: "Workout Done", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil ))
                presentViewController(alertController, animated: true, completion: nil)
            }

        }
        
    }
    
    func updateCurrentEfffortLine(index: Int) {
        if index < hardwork.tonightsWorkout.efforts.count {
            curEffortStruct = hardwork.tonightsWorkout.efforts[index]
            curEffortStr.text = String(curEffortStruct.duration)
            curGearStr.text = curEffortStruct.gear
            curDescStr.text = curEffortStruct.desc
            
            wkoutTimers.effortTime = Int((curEffortStruct.duration * 60 ) )
            print("Setting EfforTime = \(wkoutTimers.effortTime)")
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
    
    @IBAction func startTonightsWorkout(sender: UIButton) {
        // Here we go..
        if ( wkoutTimers.workoutTime == 0 )
        {
            runningTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "manageTimersAndUpdateWorkout",
                userInfo: nil, repeats: true)

            sender.setTitle("Pause", forState: UIControlState.Normal)
        }
        else
        {
            runningTimer.invalidate()
            sender.setTitle("Start", forState: UIControlState.Normal)
            wkoutTimers.workoutTime = 0
            wkoutTimers.effortTime = 0
            wkoutTimers.intervalTime = 0 
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
