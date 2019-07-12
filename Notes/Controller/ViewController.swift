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

    // MARK: - UI Outlets
    
    @IBOutlet weak var colorsStackView: UIStackView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var expireDateSwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet var datePickerHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Interactions
    
    @IBAction func dateSwitchChanged(_ sender: UISwitch) {
        self.datePicker.isHidden = !sender.isOn
        UIView.animate(withDuration: 1) {
            self.datePickerHeightConstraint?.isActive = !sender.isOn
            self.contentView.setNeedsLayout()
        }
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        print(sender.date)
    }
    
    @IBAction func didTapColorBox(_ sender: UITapGestureRecognizer) {
        guard let selectedBoxView = sender.view as? ColorBoxView else { return }
        colorsStackView.arrangedSubviews.forEach { (view) in
            guard let colorView = view as? ColorBoxView else { return }
            colorView.isSelected = false
        }
        selectedBoxView.isSelected = true
    }
    
    @IBAction func longPressRecognized(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        print("longPressRecognized")
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupViews()
    }
    
    // MARK: - Configure UI
    
    private func setupViews() {
        colorsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        
        titleTextField.attributedPlaceholder = NSAttributedString(string: "Enter title...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        datePicker.setValue(UIColor.white, forKeyPath: "textColor")
    }
    
    // MARK: - Keyboard handling
    
    func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let adjustmentHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        scrollView.contentInset.bottom = show ? adjustmentHeight : 0
        scrollView.scrollIndicatorInsets.bottom = adjustmentHeight
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        adjustInsetForKeyboardShow(false, notification: notification)
    }
    
    // MARK: - Deinitialization
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

