//
//  CustomBconnectConfiguration.swift
//  BConnect
//

import Foundation
import BConnect

class CustomBconnectConfiguration {
    
    static let shared = CustomBconnectConfiguration()
    
    func setup(publicClient: Bool, activeMode: Bool) {
        assertionFailure("Must set a valid Client ID!")
        
        guard let scheme = Bundle.main.infoDictionary?["BaseURI"] as? String else {
            assertionFailure("BaseURI not found in Info.plist!")
            return
        }
        guard let configuration = BConnectConfiguration(
            clientType: publicClient ? .public : .private,
            scheme: scheme,
            clientID: "clientId",
            authenticationMode: activeMode ? .active : .default
        ) else {
            assertionFailure("Must create a BConnectConfiguration!")
            return
        }
        
        print("\n# BConnect setup with configuration: \(configuration)")
        
        BConnect.shared.setup(configuration: configuration)
    }
}
