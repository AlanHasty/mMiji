//
//  workoutParser.swift
//  mMiji
//
//  Created by Alan Hasty on 11/21/15.
//  Copyright © 2015 Alan Hasty. All rights reserved.
//

import Foundation
import SwiftyJSON
//-------------//
// MARK:- Model
//-------------//

//{ "duration": 1.0, "finishTime": 19.0, "gear": "S16", "description": "100+RPM" } ,
struct Effort {
    let duration: Float
    let finishTime: Float
    let gear: String
    let desc: String
}

extension Effort: CustomStringConvertible {
    var description: String { return "Effort \(desc) in \(gear)"}
}

struct Workout {
    let name: Int
    let efforts: [Effort]
}

extension Workout: CustomStringConvertible {
    var description: String { return "Workout \(name) has xx efforts"}
}

class WorkoutPPP {
    
    var tonightsWorkout: Workout
    
    init (workoutSelection: String )
    {
        /* Import the JSON from a file */
        let jsonURL = NSBundle.mainBundle().pathForResource(workoutSelection, ofType: "json")
        let rawJSON = NSData(contentsOfFile: jsonURL!)
        
        let json = JSON(data: rawJSON!, error: nil)
        
        var effortsList = [Effort]()
        let workoutNum : Int = json["workoutNum"].int!
        
        json["efforts"][1]["description"]
        json["efforts"].count
        
        let subJson = json["efforts"][3]
        
        subJson["description"]
        
        for index in 0..<json["efforts"].count {
            let effortJson = json["efforts"][index]
            let duration = effortJson["duration"].float
            let finishT  = effortJson["finishTime"].float
            let gear = effortJson["gear"].string
            let desc = effortJson["description"].string
            let e1 = Effort(duration: duration!, finishTime: finishT!, gear: gear!, desc: desc!)
            e1
            effortsList += [e1]
        }
        
        tonightsWorkout = Workout(name: workoutNum, efforts:effortsList)
        
        print("workout efforts = \(tonightsWorkout.efforts.count)")
        for index in 0..<tonightsWorkout.efforts.count
        {
            print("Effort \(index) is : \(tonightsWorkout.efforts[index].desc)")
        }
    }

}


