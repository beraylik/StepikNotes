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
    @IBOutlet weak var changebleColorBox: ColorBoxView!
    @IBOutlet weak var colorPicker: ColorPickerView!
    
    @IBOutlet var datePickerHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Interactions
    
    @IBAction func dateSwitchChanged(_ sender: UISwitch) {
        self.datePicker.isHidden = !sender.isOn
        self.datePickerHeightConstraint.isActive = !sender.isOn
        UIView.animate(withDuration: 0.5) {
            self.contentView.layoutSubviews()
        }
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        print(sender.date)
    }
    
    @IBAction func didTapColorBox(_ sender: UITapGestureRecognizer) {
        guard let selectedBoxView = sender.view as? ColorBoxView else { return }
        selectColorView(selectedBoxView)
    }
    
    @IBAction func longPressRecognized(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        print("longPressRecognized")
        showColorPicker()
    }
    
    private func selectColorView(_ view: ColorBoxView) {
        colorsStackView.arrangedSubviews.forEach { (view) in
            guard let colorView = view as? ColorBoxView else { return }
            colorView.isSelected = false
        }
        view.isSelected = true
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
        setGradientLayer(view: changebleColorBox)
        
        // Setup Color picker
        colorPicker.delegate = self
        colorPicker.layer.cornerRadius = 24
        colorPicker.layer.shadowPath = .none
        colorPicker.layer.shadowColor = UIColor.lightGray.cgColor
        colorPicker.layer.shadowOffset = .zero
        colorPicker.layer.shadowRadius = 12
        colorPicker.layer.shadowOpacity = 0.3
    }
    
    private func setGradientLayer(view: UIView) {
        let rainbow: [UIColor] = [.red, .orange, .yellow, .green, .cyan, .blue, .purple, .red]
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = rainbow.map({ $0.cgColor })
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = view.bounds
        
        let brightnessLayer = CAGradientLayer()
        brightnessLayer.colors = [UIColor.white.cgColor, UIColor.clear.cgColor, UIColor.black.cgColor]
        brightnessLayer.startPoint = CGPoint(x: 0.5, y: 0)
        brightnessLayer.endPoint = CGPoint(x: 0.5, y: 1)
        brightnessLayer.frame = view.bounds
        
        view.backgroundColor = .clear
        view.layer.addSublayer(gradientLayer)
        view.layer.addSublayer(brightnessLayer)
    }
    
    // MARK: - Keyboard handling
    
    private func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
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

// MARK: Color picker delegate

extension ViewController: ColorPickerDelegate {
    
    func cancelPicker() {
        dissmissColorPicker()
    }
    
    func pickedColor(_ color: UIColor) {
        changebleColorBox.backgroundColor = color
        changebleColorBox.layer.sublayers?.forEach({ (layer) in
            let gradient = layer as? CAGradientLayer
            gradient?.removeFromSuperlayer()
        })
        selectColorView(changebleColorBox)
        dissmissColorPicker()
    }
    
    private func dissmissColorPicker() {
        UIView.transition(with: colorPicker, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.colorPicker.alpha = 0
        }) { (_) in
            self.colorPicker.isHidden = true
            self.colorPicker.alpha = 1
        }
        
    }
    
    private func showColorPicker() {
        contentView.endEditing(true)
        UIView.transition(with: colorPicker, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.colorPicker.isHidden = false
        })
    }
    
}
