// Note app

import UIKit

enum Importance: String {
    case important
    case normal
    case notImportant
}

struct Note {
    
    let uid: String
    let title: String
    let content: String
    let color: UIColor
    let importance: Importance
    let selfDestruction: Date?
    
    init(uid: String?, title: String, content: String, importance: Importance, color: UIColor = .white, selfDestruction: Date? = nil) {
        self.uid = uid ?? UUID().uuidString
        self.title = title
        self.content = content
        self.importance = importance
        self.color = color
        self.selfDestruction = selfDestruction
    }
    
}
