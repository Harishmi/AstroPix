//
//  FavouritesViewModel.swift
//  AstroPix
//
//  Created by Harish_Heathrow on 03/10/21.
//

import Foundation
import CoreData

class FavouritesViewModel {
    
    func fetchFromStore()->[AstroData]?{
        // Create a fetch request with a string filter
        // for an entity’s name
        let fetchRequest: NSFetchRequest<AstroData>
        fetchRequest = AstroData.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(
            format: "isFavourite = %d", true
        )
        
        // Get a reference to a NSManagedObjectContext
        let context = CoreDataStorage.shared.managedObjectContext()
        
        // Perform the fetch request to get the objects
        // matching the predicate
        do{
            let astroData = try context.fetch(fetchRequest)
            print("object found")
            return astroData
        }
        catch {
            print(error)
        }
        
        return nil
    }
}
