//
//  CoreDataStorage.swift
//  AstroPix
//
//  Created by Harish_Heathrow on 02/10/21.
//

import Foundation
import CoreData

class CoreDataStorage {
    static let shared = CoreDataStorage()
    
    lazy var persistentContainer: NSPersistentContainer = {
       
        let container = NSPersistentContainer(name: "AstroModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func managedObjectContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }

}
