//
//  BConnect.swift
//  BConnect
//

import Foundation
import AppAuth

/// Result from an authorize request.
public enum BConnectResult {
    /// Request authorize succeed, from a private client.
    case authorizeSucceed(AuthorizeResponse)
    /// Request authorize succeed, from a public client.
    case tokenSucceed(TokenResponse)
    /// Session was cancelled by user.
    case cancelledByUser
    /// An error occurred.
    case error(Error)
}

public struct BConnectError: Error {
    let description: String
}

public struct AuthorizeResponse {
    let authorizationCode: String
    let state: String
    let codeChallenge: String
}

public struct TokenResponse {
    let accessToken: String
    let idToken: String
}

/// Entry point of BConnect SDK.
public class BConnect {
    
    private var configuration: BConnectConfiguration?
    private var authorizeService: AuthorizeService?
    private var discoveryService: DiscoveryService?
    
    /// The shared instance of BConnect.
    public static let shared = BConnect()
    
    /// Configure the BConnect SDK. Must be done before any authorization request.
    public func setup(configuration: BConnectConfiguration) {
        self.configuration = configuration
        self.authorizeService = AuthorizeService(bconnectConfiguration: configuration)
        self.discoveryService = DiscoveryService(url: configuration.discoveryUrl)
    }
    
    /// Request an authorize in-app.
    /// Will use the best solution depending on iOS version (ASWebAuthenticationSession, SFAuthenticationSession, SFSafariViewController)
    /// to perform the request.
    /// - Parameters:
    ///     - presenting: the UIViewController that could present the in-app web browser for authentication.
    ///     - completion: callback when the authorization is done.
    @available(iOS 16, *)
    public func requestAuthorize(presenting viewController: UIViewController, completion: @escaping (BConnectResult) -> Void) {
        discoveryService?.fetch() { [unowned self] response in
            DispatchQueue.main.async {
                switch response {
                case let .success(discovery):
                    self.authorizeService?.requestAuthorize(discovery: discovery, presenting: viewController, completion: completion)
                case let .failure(error):
                    completion(.error(error))
                }
            }
        }
    }
    
    /// Must be called in AppDelegate or SceneDelegate callback when application is opened from an URL.
    ///
    /// - Parameters:
    ///     - url: opened url.
    ///
    /// - Returns: a boolean that indicate if url is handled.
    public func application(open url: URL) -> Bool {
        return authorizeService?.application(open: url) ?? false
    }
}
