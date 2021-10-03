//
//  Model.swift
//  AstroPix
//
//  Created by Harish_Heathrow on 02/10/21.
//

import Foundation

struct APOD: Codable {
    let explanation: String
    let url: String
    let date: String
    let title: String
}
