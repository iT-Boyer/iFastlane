//
//  TaskJuggler.swift
//  CmdLib
//
//  Created by boyer on 2022/3/14.
//

import Foundation

// 得到xml文件，转为model
struct Project:Codable {
    let SaveVersion:Int = 0
    let Name:String
    let CreationDate:String
    let ScheduleFromStart:Int = 0
    let StartDate:String
    let FinishDate:String
    let DefaultStartTime:String
    let DefaultFinishTime:String
    let CalendarUID:Int = 0
    let MinutesPerDay:Float
    let MinutesPerWeek:Float
    let DaysPerMonth:Float
    let CurrentDate:String
    let StatusDate:String
    let WorkFormat:Int = 0
    let NewTasksAreManual:Int = 0
    let SpreadPercentComplete:Float
    let StandardRate:Float
    let OvertimeRate:Float
    let CurrencySymbol:String
    let CurrencyCode:String
    let Calendars:Calendars?
    let Tasks:Tasks?
    let Resources:Resources_?
    let Assignments:Assignments?
    
    enum CodingKeys: String, CodingKey {
        case SaveVersion
        case Name
        case CreationDate
        case ScheduleFromStart
        case StartDate
        case FinishDate
        case DefaultStartTime
        case DefaultFinishTime
        case CalendarUID
        case MinutesPerDay
        case MinutesPerWeek
        case DaysPerMonth
        case CurrentDate
        case StatusDate
        case WorkFormat
        case NewTasksAreManual
        case SpreadPercentComplete
        case StandardRate
        case OvertimeRate
        case CurrencySymbol
        case CurrencyCode
        case Calendars = "Calendars"
        case Tasks = "Tasks"
        case Resources = "Resources"
        case Assignments = "Assignments"
    }
}

struct Calendars:Codable {
    let items:[Calendar]
    enum CodingKeys: String, CodingKey {
        case items = "Calendar"
    }
}

struct Tasks:Codable {
    let items:[Task]
    enum CodingKeys: String, CodingKey {
        case items = "Task"
    }
}

struct Resources_:Codable {
    let items:[Resource]
    enum CodingKeys: String, CodingKey {
        case items = "Resource"
    }
}

struct Assignments:Codable {
    let items:[Assignment]
    enum CodingKeys: String, CodingKey {
        case items = "Assignment"
    }
}

struct WeekDays:Codable{
    let items:[WeekDay]
    enum CodingKeys: String, CodingKey {
        case items = "WeekDay"
    }
}
struct WorkingTimes:Codable {
    let items:[WorkingTime]
    enum CodingKeys: String, CodingKey {
        case items = "WorkingTime"
    }
}

struct Calendar:Codable {
    let UID:Int = 0
    let Name:String
    let IsBaseCalendar:Int = 0
    let BaseCalendarUID:Int = 0
    let WeekDays:WeekDays?
    
    enum CodingKeys: String, CodingKey {
        case UID
        case Name
        case IsBaseCalendar
        case BaseCalendarUID
        case WeekDays = "WeekDays"
    }
}

struct WeekDay:Codable{
    let DayType:Int = 0
    let DayWorking:Int = 0
    let WorkingTimes:WorkingTimes?
    
    enum CodingKeys: String, CodingKey {
        case DayType
        case DayWorking
        case WorkingTimes = "WorkingTimes"
    }
}

struct WorkingTime:Codable {
    let FromTime:String
    let ToTime:String
    
    enum CodingKeys: String, CodingKey {
        case FromTime
        case ToTime
    }
}

struct Task:Codable {
    let UID:Int = 0
    let ID:Int = 0
    let Active:Int = 0
    let `Type`:Int = 0
    let IsNull:Int = 0
    let Name:String
    let WBS:String
    let OutlineNumber:String
    let OutlineLevel:Int = 0
    let Priority:Int = 0
    let Start:String
    let Finish:String
    let ManualStart:String
    let ManualFinish:String
    let ActualStart:String
    let ActualFinish:String
    let ConstraintType:Int = 0
    let ConstraintDate:String
    let FixedCostAccrual:Int = 0
    let Manual:Int = 0
    let Summary:Int = 0
    let Estimated:Int = 0
    let DurationFormat:Int = 0
    let Milestone:Int = 0
    let PercentComplete:Int = 0
    let PercentWorkComplete:Int = 0
    let PredecessorLink:[PredecessorLink]
    
    enum CodingKeys: String, CodingKey {
        case UID
        case ID
        case Active
        case `Type`
        case IsNull
        case Name
        case WBS
        case OutlineNumber
        case OutlineLevel
        case Priority
        case Start
        case Finish
        case ManualStart
        case ManualFinish
        case ActualStart
        case ActualFinish
        case ConstraintType
        case ConstraintDate
        case FixedCostAccrual
        case Manual
        case Summary
        case Estimated
        case DurationFormat
        case Milestone
        case PercentComplete
        case PercentWorkComplete
        case PredecessorLink = "PredecessorLink"
    }
}
struct PredecessorLink:Codable {
    let PredecessorUID:Int = 0
    let `Type`:Int = 0
    
    enum CodingKeys: String, CodingKey {
        case PredecessorUID
        case `Type`
    }
}


struct Resource:Codable {
    let UID:Int = 0
    let `Type`:Int = 0
    let Name:String
    let Initials:String
    let StandardRate:Float
    let OvertimeRate:Float
    let MaxUnits:Float
    let CalendarUID:Int = 0
    let Group:String?
    
    enum CodingKeys: String, CodingKey {
        case UID
        case `Type`
        case Name
        case Initials
        case StandardRate
        case OvertimeRate
        case MaxUnits
        case CalendarUID
        case Group
    }
}

struct Assignment:Codable {
    let UID:Int = 0
    let TaskUID:Int = 0
    let ResourceUID:Int = 0
    let Units:Float
    let start:String
    let finish:String
    let Cost:Float
    let WorkContour:Int = 0
    let PercentWorkComplete:Float
    let TimephasedData:TimephasedData
    
    enum CodingKeys: String, CodingKey {
        case UID
        case TaskUID
        case ResourceUID
        case Units
        case start
        case finish
        case Cost
        case WorkContour
        case PercentWorkComplete
        case TimephasedData = "TimephasedData"
    }
}
struct TimephasedData:Codable {
    let UID:Int = 0
    let `Type`:Int = 0
    let Start:String
    let Finish:String
    let Unit:Int = 0
    let Value:String
    enum CodingKeys: String, CodingKey {
        case UID
        case `Type`
        case Start
        case Finish
        case Unit
        case Value
    }
}
