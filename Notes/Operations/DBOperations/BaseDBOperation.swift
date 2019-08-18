import Foundation
import CoreData

class BaseDBOperation: AsyncOperation {
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
}
