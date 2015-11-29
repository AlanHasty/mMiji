//
//  TrainingViewController.swift
//  
//
//  Created by Alan Hasty on 11/28/15.
//
//

import UIKit

class TrainingViewController: UIViewController {

    @IBOutlet weak var intervalTimerString: UILabel! 
    @IBOutlet weak var effortTimerString: UILabel!
    @IBOutlet weak var workoutTimerString: UILabel!
    
    @IBOutlet weak var curEffortStr: UILabel!
    @IBOutlet weak var curGearStr: UILabel!
    @IBOutlet weak var curDescStr: UILabel!
    
    @IBOutlet weak var nextEffortStr: UILabel!
    @IBOutlet weak var nextGearStr: UILabel!
    @IBOutlet weak var nextDescStr: UILabel!
    
    var curEffortStruct =  Effort(duration: 2.0, finishTime: 58.0, gear:"B17", desc:"Test")
    var nextEffortStruct = Effort(duration:4.00, finishTime: 62.0, gear: "S15",desc: "Spin doctor")
    
    
    required init? (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

//        intervalTimerString.text = "9:99"
//        effortTimerString.text = "8:00"
//        workoutTimerString.text = "11:11"
//        
//        curEffortStr.text = "8"
//        curGearStr.text = "B17"
//        curDescStr.text = "Spin"
//        nextEffortStr.text = "8"
//        nextGearStr.text = "B17"
//        nextDescStr.text = "Spin"
        
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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