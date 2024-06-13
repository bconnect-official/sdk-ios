//
//  FSViewController.swift
//  BConnect
//

import UIKit
import BConnect
import SafariServices

class FSViewController: UIViewController {

    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var bconnectButton: BconnectButton!
    
    @IBOutlet private weak var clientSwitch: UISwitch!
    @IBOutlet private weak var modeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = Bundle.main.name ?? ""
        setupBconnect()
    }
    
    // - BConnect
    
    private func setupBconnect() {
        print("\n# FSViewController.setupBconnect")
        
        guard #available(iOS 16, *) else {
            bconnectButton.removeFromSuperview()
            return
        }

        CustomBconnectConfiguration.shared.setup(publicClient: clientSwitch.isOn, activeMode: modeSwitch.isOn)
        
        bconnectButton.set(style: .standard_white_noborder)
        bconnectButton.addTarget(self, action: #selector(onTapBConnect), for: .touchUpInside)
    }
    
    @objc
    private func onTapBConnect(sender : UIButton) {
        guard #available(iOS 16, *) else { return }
        
        BConnect.shared.requestAuthorize(presenting: self) { [weak self] result in
            self?.handleBconnectResult(result)
        }
    }
    
    private func handleBconnectResult(_ result: BConnectResult) {
        DispatchQueue.main.async {
            print("\n# FSViewController.handleBconnectResult")
            print(result)
            
            let alert = UIAlertController(title: "Info résultat", message: "\(result)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Fermer", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    // - Actions
    
    @IBAction func onSettingsChanged(_ sender: Any) {
        CustomBconnectConfiguration.shared.setup(publicClient: clientSwitch.isOn, activeMode: modeSwitch.isOn)
    }
}

private extension Bundle {
    var name: String? {
        return object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}
