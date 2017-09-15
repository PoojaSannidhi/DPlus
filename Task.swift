//
//  Task.swift
//  XcodeLoginExample
//
//  Created by Mahesh Rapaka on 8/27/17.
//  Copyright © 2017 Belal Khan. All rights reserved.
//

import Foundation
enum TaskType
{
    case Daily,TwoWeekly,Weekly
}

struct Task{
    var name : String
    var type : TaskType
    var completed : Bool
    var lastcompleted : NSDate?
}
