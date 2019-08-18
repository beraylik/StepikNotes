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

class EditNoteViewController: UIViewController {

    // MARK: - Properties
    
    var note: Note?
    private var selectedColor: UIColor = .white
    var context: NSManagedObjectContext?
    
    // MARK: - UI Outlets
    
    @IBOutlet weak var colorsStackView: UIStackView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var expireDateSwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var changebleColorBox: ColorBoxView!
    
    @IBOutlet var datePickerHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Interactions
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text, !title.isEmpty else { return }
        guard let content = contentTextView.text, !content.isEmpty else { return }
        let expireDate: Date? = expireDateSwitch.isOn ? datePicker.date : nil
        let color = selectedColor
        
        let newNote = Note(uid: note?.uid, title: title, content: content, importance: .normal, color: color, selfDestruction: expireDate)
        saveNote(newNote)
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
    
    private func saveNote(_ note: Note) {
        guard let context = context else {
            print("NO CONTEXT")
            self.navigationController?.popViewController(animated: true)
            return
        }
        let backendQueue = OperationQueue()
        let dbQueue = OperationQueue()
        let commonQueue = OperationQueue()
        
        let saveNoteOperation = SaveNoteOperation(
            note: note,
            context: context,
            backendQueue: backendQueue,
            dbQueue: dbQueue
        )
        commonQueue.addOperation(saveNoteOperation)
        
        let updateUI = BlockOperation { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        saveNoteOperation.completionBlock = {
            OperationQueue.main.addOperation(updateUI)
        }
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupViews()
        setupData()
    }
    
    private func setupData() {
        guard let note = note else { return }
        
        titleTextField.text = note.title
        contentTextView.text = note.content
        if let date = note.selfDestruction {
            expireDateSwitch.isOn = true
            dateSwitchChanged(expireDateSwitch)
            datePicker.date = date
        }
        if note.color != .white {
           pickedColor(note.color)
        }
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

// MARK: Color picker delegate

extension EditNoteViewController: ColorPickerDelegate {
    
    func cancelPicker() {
        // unused
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

