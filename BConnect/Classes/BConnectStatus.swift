//
//  BConnectStatus.swift
//  BConnect
//

import Foundation

class BConnectStatus {
    
    func isReachable(completion: @escaping (Bool) -> Void) {
        assertionFailure("Must set an url!")
        let url = URL(string: "http://localhost")!
        var request = URLRequest(url: url)
        request.timeoutInterval = TimeInterval(0.2)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let succeed = response.isValid || error.isTimeout
            completion(succeed)
        }
        task.resume()
    }
}

private extension Optional<URLResponse> {
    var isValid: Bool {
        let statusCode = (self as? HTTPURLResponse)?.statusCode
        return statusCode == 200
    }
}

private extension Optional<Error> {
    var isTimeout: Bool {
        switch (self as? URLError)?.code {
        case .some(.timedOut):
            return true
        default:
            return false
        }
    }
}
