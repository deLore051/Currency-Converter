//
//  ConversionRateResponse.swift
//  CurrencyConverter
//
//  Created by Stefan Dojcinovic on 25.10.21..
//

import Foundation

struct ConversionRateResponse: Codable {
    let rate: [String: Double]
    
}

struct Test: Codable {
    let date: String
    let rate: Double

}

