//
//  DataController.swift
//  pickerViewDemo
//
//  Created by 陳家豪 on 2020/8/30.
//

import Foundation
struct DataController {
    static let shared = DataController()
    let formatter = DateFormatter()
    
    func fetchDateData() -> [String]{
        let today = Date()
        var availableDates = [today]
        let secondsPerDay:Double = 60 * 60 * 24
        for times in 1...10 {
            let availableDay = today.timeIntervalSince1970 + secondsPerDay * Double(times)
            availableDates.append(Date(timeIntervalSince1970: availableDay))
        }
        
        let availableDays: [String]
        availableDays = availableDates.map { (date) -> String in
            formatter.dateFormat = "yyyy/MM/dd"
            return formatter.string(from: date)
        }
        return availableDays
    }
    func fetchTimeData() -> [String:[String]]{
        var hours = [String]()
        var minutes = [String]()
        for hour in 1...24 {
            hours.append("\(hour)時")
        }
        for minute in 0...59 {
            if minute < 10 {
                minutes.append("0\(minute)分")
            }else {
                minutes.append("\(minute)分")
            }
        }
        var time = [String:[String]]()
        time["hours"] = hours
        time["minutes"] = minutes
        return time
    }
    func fetchStationData() -> [String:[String]]? {
        let stationUrl = Bundle.main.url(forResource: "Station", withExtension: "plist")!
        guard let data = try? Data(contentsOf: stationUrl), let allStations = try? PropertyListDecoder().decode([String:[String]].self, from: data) else {return nil}
        return allStations
    }
}
