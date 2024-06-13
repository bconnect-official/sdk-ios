//
//  BConnectConfiguration.swift
//  BConnect
//

import Foundation

/// Configuration class for BConnect.
public struct BConnectConfiguration {
    
    let clientType: BConnectClientType
    let redirectUrl: URL
    let clientID: String
    let clientSecret: String?
    let discoveryUrl: URL
    let scopes: [String]
    let authenticationMode: BConnectAuthenticationMode
    
    /// - Parameters:
    ///     - clientType: 
    ///     Set `private` if you want the SDK to only request an authorization code,
    ///     then it will then be your responsibility to retrieve an access token from your server.
    ///     It's more secure because your server is the only one to know some informations.
    ///     Else, set `public` if you want the SDK to take care of everything and retrieve a token.
    ///     - scheme: 
    ///     The scheme of your application.
    ///     It will be useful for returning to the application at the end of the authentication process.
    ///     You must only give the scheme, without colon and slashes.
    ///     For example: `myapp`.
    ///     - clientID:
    ///     A client ID.
    ///     - clientSecret:
    ///     A client secret, if needed.
    ///     - discoveryUrl:
    ///     The discovery endpoint URL. The default value is set to the production server. You can change the endpoint if you need to use another environment.
    ///     - scopes:
    ///     A list of scopes. Default value is `openid`.
    ///     - authenticationMode:
    ///     Set `active` if you want to force a full user authentification with his bank,
    ///     otherwise the b.connect server will decide according to the level of risk.
    /// - Returns:
    ///     A configuration or nil if some parameters are invalid.
    public init?(
        clientType: BConnectClientType,
        scheme: String,
        clientID: String,
        clientSecret: String? = nil,
        discoveryUrl: URL = URL(string: "https://api.bconnect.net/sso/v2/oauth2/bconnect/.well-known/openid-configuration")!,
        scopes: [String] = ["openid"],
        authenticationMode: BConnectAuthenticationMode = .default
    ) {
        guard let redirectUrl = URL(string: "\(scheme)://bconnect") else {
            assertionFailure("Bad scheme!")
            return nil
        }
        self.clientType = clientType
        self.redirectUrl = redirectUrl
        self.discoveryUrl = discoveryUrl
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.scopes = scopes
        self.authenticationMode = authenticationMode
    }
}

public enum BConnectAuthenticationMode {
    /// Will force a full user authentification with his bank.
    case active
    /// The b.connect server will decide if a full authentication is needed according to the level of risk.
    case `default`
}

public enum BConnectClientType {
    case `public`
    case `private`
}
