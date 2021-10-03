//
//  NetworkManager.swift
//  AstroPix
//
//  Created by Harish_Heathrow on 02/10/21.
//

import Foundation


class NetworkManager{
    
    let k = Constants()
    static let shared: NetworkManager = NetworkManager()
    
    enum NetworkError: Error {
        case invalidUrl
        case invalidResponse(Data?, URLResponse?)
    }
    
    

    
    func fetchRequest(urlString: String, completion: @escaping (Result<Data,Error>) -> Void){
        let url = URL(string:urlString)
        //print(urlString)
        guard let url = url else {
            completion(.failure(NetworkError.invalidUrl))
            return }
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            guard
                let responseData = data,
                let httpResponse = response as? HTTPURLResponse,
                200 ..< 300 ~= httpResponse.statusCode else {
                    completion(.failure(NetworkError.invalidResponse(data, response)))
                    return
                }
            
            completion(.success(responseData))
            
        }
        task.resume()
    }

}
