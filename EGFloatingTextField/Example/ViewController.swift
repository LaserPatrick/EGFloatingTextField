//
//  ViewController.swift
//  Example
//
//  Created by Mac HD on 9.08.2015.
//
//

import UIKit
import EGFloatingTextField
import PureLayout
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let emailLabel = EGFloatingTextField(frame: CGRect(x: 8, y: 64, width: (self.view.bounds).width - 16, height: 48))
        emailLabel.floatingLabel = true
        emailLabel.setPlaceHolder("Email")
        emailLabel.validationType = .Email
        emailLabel.keyboardType = .emailAddress
        self.view.addSubview(emailLabel)
        
        let passwordLabel = EGFloatingTextField(frame: CGRect(x: 8, y: 128, width: (self.view.bounds).width - 16, height: 48))
        passwordLabel.floatingLabel = true
        passwordLabel.isSecureTextEntry = true
        passwordLabel.setPlaceHolder("Password")
        self.view.addSubview(passwordLabel)
        
        emailLabel.autoPinEdge(ALEdge.left, to:ALEdge.left, of:self.view, withOffset:8)
        emailLabel.autoPinEdge(ALEdge.right, to:ALEdge.right, of:self.view, withOffset:-8)
        emailLabel.autoPin(toTopLayoutGuideOf: self, withInset:16)
        emailLabel.autoSetDimension(ALDimension.height, toSize:44)
        
        passwordLabel.autoPinEdge(ALEdge.left, to:ALEdge.left, of:self.view, withOffset:8)
        passwordLabel.autoPinEdge(ALEdge.right, to:ALEdge.right, of:self.view, withOffset:-8)
        passwordLabel.autoPinEdge(ALEdge.top, to:ALEdge.bottom, of:emailLabel, withOffset:16)
        passwordLabel.autoSetDimension(ALDimension.height, toSize:44)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

