//
//  ConversionRateResponse.swift
//  CurrencyConverter
//
//  Created by Stefan Dojcinovic on 25.10.21..
//

import Foundation

struct ConversionRateResponse: Codable {
    let rate: [String: String]  // Ovde bi trebalo da ide [String: Any] ali ne moze zbog codable ....
    
}

// Probao sam nesto za [String: Test]
struct Test: Codable {
    let date: String
    let value: Double

}

