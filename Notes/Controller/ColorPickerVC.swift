//
//  ColorPickerVC.swift
//  Notes
//
//  Created by Генрих Берайлик on 20/07/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import UIKit

class ColorPickerVC: UIViewController {
    
    weak var delegate: ColorPickerDelegate?
    
    // MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Color picker"
        
        setupViews()
    }
    
    // MARK: - Configure UI
    
    private func setupViews() {
        view.backgroundColor = UIColor(hex: "#1f2124")
        navigationItem.setHidesBackButton(true, animated: true)
        colorPicker.delegate = self
        
        view.addSubview(colorPicker)
        colorPicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        colorPicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        colorPicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        colorPicker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    // MARK: - UI Elements
    
    private let colorPicker: ColorPickerView = {
        let view = ColorPickerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
}

extension ColorPickerVC: ColorPickerDelegate {
    func cancelPicker() {
        delegate?.cancelPicker()
        navigationController?.popViewController(animated: true)
    }
    
    func pickedColor(_ color: UIColor) {
        delegate?.pickedColor(color)
        navigationController?.popViewController(animated: true)
    }
    
}
