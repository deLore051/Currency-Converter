//
//  APICaller.swift
//  CurrencyConverter
//
//  Created by Stefan Dojcinovic on 25.10.21..
//

import Foundation

final class APICaller {
    
    static let shared = APICaller()
    
    private init() { }
    
    struct Constants {
        static let baseAPIurl = "https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1"
        static let currenciesAPI = "/latest/currencies.json"
    }
    
    enum APIError: Error {
        case failedToGetData
    }
    
    /// Get all avalable currencies from API
    public func getAllCurrencies(completion: @escaping (Result<CurrencyResponse, Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseAPIurl + Constants.currenciesAPI)") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                guard let result = json as? [String: String] else { return }
                let currencies = CurrencyResponse(currnecies: result)
                completion(.success(currencies))
            } catch (let jsonError) {
                completion(.failure(jsonError))
            }
        }
        task.resume()
    }
    
    /// Get conversion rate between two currencies from listing, on the chosen date.
    public func getConversionValue(
        date: String,
        currency1: String,
        currency2: String,
        completion: @escaping (Result<Dictionary<String, Any>, Error>) -> Void) {
        let maxDate = "2021-10-24"
        let minDate = "2020-11-22"
        
        var url: URL?
        
        if date.compare(maxDate) == .orderedDescending || date.compare(minDate) == .orderedAscending {
            url = URL(string: "\(Constants.baseAPIurl)/latest/currencies/\(currency1)/\(currency2).json")
        } else {
            url = URL(string: "\(Constants.baseAPIurl)/\(date)/currencies/\(currency1)/\(currency2).json")
        }
        
        guard let newUrl = url else { return }
        
        let task = URLSession.shared.dataTask(with: newUrl) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                guard let result = json as? Dictionary<String, Any> else {
                    print("Failed to get data")
                    return
                }
                completion(.success(result))
            } catch (let jsonError) {
                completion(.failure(jsonError))
            }
        }
        task.resume()
    }
        
}
