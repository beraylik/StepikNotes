//
//  ViewController.swift
//  Notes
//
//  Created by Миландр on 24/06/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import UIKit
import CocoaLumberjack

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("\(type(of: self)): \(#function)")
    }

    override func viewWillAppear(_ animated: Bool) {
        DDLogInfo("\(type(of: self)): \(#function)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DDLogInfo("\(type(of: self)): \(#function)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        DDLogInfo("\(type(of: self)): \(#function)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        DDLogInfo("\(type(of: self)): \(#function)")
    }
    
}

