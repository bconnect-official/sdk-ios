//
//  DiscoveryService.swift
//  BConnect
//

import Foundation

class DiscoveryService {
    
    private let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func fetch(completion: @escaping (Result<Discovery, BConnectError>) -> Void) {
        var request = URLRequest(url: url)
        request.timeoutInterval = TimeInterval(10)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                let error = BConnectError(description: "Failed to fetch discovery endpoint.")
                completion(.failure(error))
                return
            }
            guard let response = try? JSONDecoder().decode(Discovery.self, from: data) else {
                let error = BConnectError(description: "Failed to parse discovery result.")
                completion(.failure(error))
                return
            }
            completion(.success(response))
        }
        
        task.resume()
    }
}

struct Discovery: Decodable {
    let authorizeEndpoint: URL
    let tokenEndpoint: URL
    let supportedAcrValues: [String]
    
    enum CodingKeys: String, CodingKey {
        case authorizeEndpoint = "authorization_endpoint"
        case tokenEndpoint = "token_endpoint"
        case supportedAcrValues = "acr_values_supported"
    }
}
