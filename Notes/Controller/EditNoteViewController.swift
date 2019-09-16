//
//  ViewController.swift
//  Notes
//
//  Created by Миландр on 24/06/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import UIKit
import CocoaLumberjack
import CoreData

protocol EditNoteVCProtocol: class {
    func saveCompleted()
    func setText(title: String, content: String)
    func setDate(_ date: Date)
    func setNoteColor(_ color: UIColor)
}

final class EditNoteViewController: UIViewController {

    // MARK: - Properties
    
    private var selectedColor: UIColor = .white
    var presenter: EditNotePresenterProtocol!
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var colorsStackView: UIStackView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var expireDateSwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var changebleColorBox: ColorBoxView!
    
    @IBOutlet var datePickerHeightConstraint: NSLayoutConstraint!
    
    // MARK: - IB Actions
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text, !title.isEmpty else { return }
        guard let content = contentTextView.text, !content.isEmpty else { return }
        let expireDate: Date? = expireDateSwitch.isOn ? datePicker.date : nil
        
        presenter.saveNoteItem(title: title, content: content, color: selectedColor, expireDate: expireDate)
    }
    
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
        selectedColor = selectedBoxView.backgroundColor ?? .white
    }
    
    @IBAction func longPressRecognized(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        showColorPicker()
    }
    
    // MARK: - Interactions
    
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
        setKeyboardObservers()
        
        setupViews()
        presenter.fillViewContent()
    }
    
    // MARK: - Configure UI
    
    private func setupViews() {
        colorsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        
        titleTextField.attributedPlaceholder = NSAttributedString(string: "Enter title...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        setGradientLayer(view: changebleColorBox)
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
    
    private func setKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
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

extension EditNoteViewController: ColorPickerDelegate {
    
    func cancelPicker() {
        navigationController?.popViewController(animated: true)
    }
    
    func pickedColor(_ color: UIColor) {
        changebleColorBox.backgroundColor = color
        changebleColorBox.layer.sublayers?.forEach({ (layer) in
            let gradient = layer as? CAGradientLayer
            gradient?.removeFromSuperlayer()
        })
        selectedColor = color
        selectColorView(changebleColorBox)
    }
    
    private func showColorPicker() {
        contentView.endEditing(true)
        let pickerVC = ColorPickerVC()
        pickerVC.delegate = self
        navigationController?.pushViewController(pickerVC, animated: true)
    }
    
}

// MARK: - EditNote Presenter Delegate

extension EditNoteViewController: EditNoteVCProtocol {
    
    func saveCompleted() {
        navigationController?.popViewController(animated: true)
    }
    
    func setText(title: String, content: String) {
        titleTextField.text = title
        contentTextView.text = content
    }
    
    func setDate(_ date: Date) {
        expireDateSwitch.isOn = true
        dateSwitchChanged(expireDateSwitch)
        datePicker.date = date
    }
    
    func setNoteColor(_ color: UIColor) {
        if color != .white {
            pickedColor(color)
        }
    }
    
}
