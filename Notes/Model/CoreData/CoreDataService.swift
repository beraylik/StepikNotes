//
//  CoreDataService.swift
//  Notes
//
//  Created by Генрих Берайлик on 18/08/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import Foundation
import CoreData

class CoreDataService {
    
    // MARK: - Properties
    
    let noteEntityName = "NoteEntity"
    
    // MARK: - Singletone instance
    
    static let shared = CoreDataService()
    private init() {}
    
    // MARK: - Persistence container
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

}
