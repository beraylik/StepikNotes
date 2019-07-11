//
//  File.swift
//  
//
//  Created by Миландр on 21/06/2019.
//

import UIKit

extension Note {
    
    var json: [String: Any] {
        var jsonItem = [String: Any]()
        jsonItem["uid"] = uid
        jsonItem["title"] = title
        jsonItem["content"] = content
        
        if importance != .normal {
            jsonItem["importance"] = importance.rawValue
        }
        if let date = selfDestruction {
            jsonItem["selfDestruction"] = date.timeIntervalSince1970
        }
        if color != .white {
            jsonItem["color"] = color.cgColor.components
        }
        return jsonItem
    }
    
    static func parse(json: [String: Any]) -> Note? {
        guard
            let uid = json["uid"] as? String,
            let title = json["title"] as? String,
            let content = json["content"] as? String
            else {
                return nil
        }
        let importance: Importance = {
            guard
                let importanceRaw = json["importance"] as? String,
                let importance = Importance.init(rawValue: importanceRaw)
                else {
                    return Importance.normal
            }
            return importance
        }()
        let color: UIColor = {
            guard
                let colorRaw = json["color"] as? [CGFloat],
                colorRaw.count == 4
                else {
                    return UIColor.white
            }
            return UIColor.init(red: colorRaw[0], green: colorRaw[1], blue: colorRaw[2], alpha: colorRaw[3])
        }()
        let date: Date? = {
            if let timeInterval = json["selfDestruction"] as? TimeInterval {
                return Date.init(timeIntervalSince1970: timeInterval)
            }
            return nil
        }()
        return Note(uid: uid, title: title, content: content, importance: importance, color: color, selfDestruction: date)
    }
}
