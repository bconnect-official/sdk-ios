//
//  AuthorizeService.swift
//  BConnect
//

import Foundation
import AppAuth

class AuthorizeService {
    
    private let bconnectConfiguration: BConnectConfiguration

    private var request: OIDAuthorizationRequest?
    private var userAgent: OIDExternalUserAgent?
    private var session: OIDExternalUserAgentSession?
    
    init(bconnectConfiguration: BConnectConfiguration) {
        self.bconnectConfiguration = bconnectConfiguration
    }
    
    func requestAuthorize(discovery: Discovery, presenting viewController: UIViewController, completion: @escaping (BConnectResult) -> Void) {
        request = makeRequest(discovery: discovery)
        userAgent = inAppUserAgent(presenting: viewController)
        
        guard let userAgent = userAgent, let request = request else {
            let error = BConnectError(description: "Authorize configuration error.")
            cleanVars()
            completion(.error(error))
            return
        }
        
        switch bconnectConfiguration.clientType {
        case .public:
            publicRequestAuthorizeInApp(presenting: request, with: userAgent, completion: completion)
        case .private:
            privateRequestAuthorizeInApp(presenting: request, with: userAgent, completion: completion)
        }
    }
    
    private func inAppUserAgent(presenting viewController: UIViewController) -> OIDExternalUserAgent? {
        return OIDExternalUserAgentIOS(presenting: viewController)
    }
    
    private func externalUserAgent() -> OIDExternalUserAgent {
        return OIDExternalUserAgentIOSCustomBrowser.customBrowserSafari()
    }
    
    private func publicRequestAuthorizeInApp(
        presenting request: OIDAuthorizationRequest,
        with userAgent: OIDExternalUserAgent,
        completion: @escaping (BConnectResult) -> Void) {
            session = OIDAuthState.authState(byPresenting: request, externalUserAgent: userAgent) { [weak self] authState, error in
                let result: BConnectResult
                if let authState = authState, 
                    let accessToken = authState.lastTokenResponse?.accessToken,
                    let idToken = authState.lastTokenResponse?.idToken {
                    result = .tokenSucceed(TokenResponse(accessToken: accessToken, idToken: idToken))
                } else if error?.isCancelledByUser == true {
                    result = .cancelledByUser
                } else {
                    let error = BConnectError(description: "AppAuth public authorize error. \(String(describing: error))")
                    result = .error(error)
                }
                completion(result)
                self?.cleanVars()
            }
    }
    
    func privateRequestAuthorizeInApp(
        presenting request: OIDAuthorizationRequest,
        with userAgent: OIDExternalUserAgent,
        completion: @escaping (BConnectResult) -> Void) {
            session = OIDAuthorizationService.present(request, externalUserAgent: userAgent) { [weak self] response, error in
                let result: BConnectResult
                if let response = response,
                   let authorizationCode = response.authorizationCode,
                   let state = response.state,
                   let codeChallenge = request.codeChallenge {
                    result = .authorizeSucceed(AuthorizeResponse(
                        authorizationCode: authorizationCode,
                        state: state,
                        codeChallenge: codeChallenge
                    ))
                } else if error?.isCancelledByUser == true {
                    result = .cancelledByUser
                } else {
                    let error = BConnectError(description: "AppAuth private authorize error. \(String(describing: error))")
                    result = .error(error)
                }
                completion(result)
                self?.cleanVars()
            }
    }
    
    func application(open url: URL) -> Bool {
        let handled = session?.resumeExternalUserAgentFlow(with: url) ?? false
        
        if handled {
            cleanVars()
        }
        
        return handled
    }
    
    private func makeRequest(discovery: Discovery) -> OIDAuthorizationRequest {
        let configuration = OIDServiceConfiguration(
            authorizationEndpoint: discovery.authorizeEndpoint,
            tokenEndpoint: discovery.tokenEndpoint
        )
        return OIDAuthorizationRequest(
            configuration: configuration,
            clientId: bconnectConfiguration.clientID,
            clientSecret: bconnectConfiguration.clientSecret,
            scopes: bconnectConfiguration.scopes,
            redirectURL: bconnectConfiguration.redirectUrl,
            responseType: OIDResponseTypeCode,
            additionalParameters: additionalParameters(discovery: discovery)
        )
    }
    
    private func additionalParameters(discovery: Discovery) -> [String : String]? {
        var parameters = [String : String]()
        
        if bconnectConfiguration.authenticationMode == .active, let value = discovery.supportedAcrValues.first {
            parameters["acr_values"] = value
        }
        
        parameters["sdk_type"] = "ios"
        parameters["sdk_version"] = sdkVersion()
        
        return parameters
    }
    
    private func sdkVersion() -> String {
        let version = Bundle(identifier: "org.cocoapods.BConnect")?.infoDictionary?["CFBundleShortVersionString"] as? String
        return version ?? "0"
    }
    
    private func cleanVars() {
        session = nil
        userAgent = nil
        request = nil
    }
}

private extension Error {
    var isCancelledByUser: Bool {
        let nserror = self as NSError
        return nserror.code == -3 && nserror.domain == OIDGeneralErrorDomain
    }
}
