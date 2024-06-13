//
//  BconnectButton.swift
//  BConnect
//

import UIKit
import AlamofireImage

public class BconnectButton: UIButton {
    
    public enum Style {
        case icon
        case standard_black
        case standard_blue
        case standard_white
        case standard_white_grey
        case standard_white_noborder
        case standard_white_grey_noborder
        case custom(name: String)
        
        var imageUrl: String {
            return "https://www.bconnect.net/sdk/\(imageName).png"
        }
        
        var imageName: String {
            switch self {
            case .icon:
                return "bconnect_button"
            case .standard_black:
                return "bconnect_largebutton_black"
            case .standard_blue:
                return "bconnect_largebutton_blue"
            case .standard_white:
                return "bconnect_largebutton_white"
            case .standard_white_grey:
                return "bconnect_largebutton_white_bw"
            case .standard_white_noborder:
                return "bconnect_largebutton_white_noborder"
            case .standard_white_grey_noborder:
                return "bconnect_largebutton_white_noborder_bw"
            case let .custom(name):
                return name
            }
        }
        
        var bundle: Bundle {
            if case .custom = self {
                return Bundle.main
            }
            return Bundle(for: BconnectButton.self)
        }
    }
    
    @available(iOS 16, *)
    public func set(style: Style) {
        backgroundColor = .clear
        imageView?.contentMode = .scaleAspectFit
        accessibilityLabel = "B Connect"
        
        let placeholder = UIImage(named: style.imageName, in: style.bundle, with: nil)
        
        if let url = URL(string: style.imageUrl) {
            let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
            af.setImage(for: .normal, urlRequest: request, placeholderImage: placeholder)
        } else {
            setImage(placeholder, for: .normal)
        }
    }
}
