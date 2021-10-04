//
//  ViewModel.swift
//  AstroPix
//
//  Created by Harish_Heathrow on 02/10/21.
//

import Foundation
import CoreData

class APODViewModel {
    
    let K = Constants()
    
    
    func getUrlString(date: String) -> String {
        let urlString = "\(K.baseURL)?api_key=\(K.apiKey)&date=\(date)"
        return urlString
    }
    func dateFormatter(date: Date)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
        
    }
    
    func getImageData(date: Date, completion: @escaping (Result<APOD, Error>)-> Void){
        let formatDate = dateFormatter(date: date)
        //print(formatDate)
        let urlString = getUrlString(date: formatDate)
        //print(urlString)
        
        NetworkManager.shared.fetchRequest(urlString: urlString) { result in
            switch result {
            case .failure(let error):
                print ("failure", error)
            case .success(let data) :
                let decoder = JSONDecoder()
                do
                {
                    let response = try decoder.decode(APOD.self, from: data)
                    completion(.success(response))
                    
                } catch {
                    // deal with error from JSON decoding if used in production
                    completion(.failure(error))
                }
            }
        }
        
    }
    
    func saveToStore(apod:APOD) {
        let managedContext = CoreDataStorage.shared.managedObjectContext()
        NetworkManager.shared.fetchRequest(urlString: apod.url) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                let astroData = AstroData(context: managedContext)
                astroData.image = data
                astroData.explanation = apod.explanation
                astroData.date = apod.date
                astroData.title = apod.title
                do {
                    try managedContext.save()
                    //print("saved succesfully")
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    func checkRecordExists(date:Date) -> Bool {
        let context = CoreDataStorage.shared.managedObjectContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AstroData")
        fetchRequest.predicate = NSPredicate(format: "date LIKE %@", dateFormatter(date: date))
        
        var results: [NSManagedObject] = []
        
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return results.count > 0
    }
    
    func fetchFromStore(date:Date)->AstroData?{
        // Create a fetch request with a string filter
        // for an entity’s name
        let fetchRequest: NSFetchRequest<AstroData>
        fetchRequest = AstroData.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        fetchRequest.predicate = NSPredicate(
            format: "date LIKE %@", dateFormatter(date: date)
        )
        
        // Get a reference to a NSManagedObjectContext
        let context = CoreDataStorage.shared.managedObjectContext()
        
        // Perform the fetch request to get the objects
        // matching the predicate
        do{
            let astroData = try context.fetch(fetchRequest).first
            //print("object found")
            return astroData
        }
        catch {
            print(error)
        }
        
        return nil
    }
    
    func updateFavouriteFromStore(date:Date, isFavourite: Bool) {
        let managedContext = CoreDataStorage.shared.managedObjectContext()
        let astroData = fetchFromStore(date: date)
        astroData?.isFavourite = isFavourite
        
        do {
            try managedContext.save()
            //print("updated succesfully")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
}



