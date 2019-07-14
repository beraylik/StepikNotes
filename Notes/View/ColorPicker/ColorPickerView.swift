//
//  ColorPickerView.swift
//  Notes
//
//  Created by Миландр on 12/07/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import UIKit

// MARK: - Color picker delegate protocol

protocol ColorPickerDelegate: class {
    func cancelPicker()
    func pickedColor(_ color: UIColor)
}

// MARK: - Color picker view class

class ColorPickerView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: ColorPickerDelegate?
    private var selectedColor: UIColor = .green
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Interactions
    
    @objc private func updatedSliderValue(sender: UISlider) {
        let percent: CGFloat = CGFloat(sender.value)
        colorsPallete.updateBrightness(percent)
    }
    
    @objc private func saveButtonPressed() {
        delegate?.pickedColor(selectedColor)
    }
    
    @objc private func cancelButtonPressed() {
        delegate?.cancelPicker()
    }

    private func handleNewColor(_ color: UIColor) {
        self.selectedColor = color
        self.currentColorView.backgroundColor = color
        self.colorCodeLabel.text = color.hexString
        
        var hue, saturation, brightness, alpha: CGFloat
        hue = 0; saturation = 0; brightness = 0; alpha = 0;
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        self.brightnessSlider.value = Float(brightness)
    }
    
    // MARK: - Configure UI
    
    private func setupViews() {
        handleNewColor(selectedColor)
        colorsPallete.colorDragHandler = { (color: UIColor) in
            self.handleNewColor(color)
        }
        colorsPallete.targetColor = selectedColor
        
        brightnessSlider.addTarget(self, action: #selector(updatedSliderValue(sender:)), for: .valueChanged)
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        
        addSubview(currentColorView)
        addSubview(colorsPallete)
        addSubview(brightnessSlider)
        addSubview(saveButton)
        addSubview(cancelButton)
        addSubview(brightnessLabel)
        
        currentColorView.addSubview(colorCodeLabel)
    }
    
    private func setupConstraints() {
        // Color view contraints
        currentColorView.topAnchor.constraint(equalTo: topAnchor, constant: 24).isActive = true
        currentColorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        currentColorView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        currentColorView.widthAnchor.constraint(equalTo: currentColorView.heightAnchor).isActive = true
        
        // Color code label
        colorCodeLabel.leadingAnchor.constraint(equalTo: currentColorView.leadingAnchor).isActive = true
        colorCodeLabel.trailingAnchor.constraint(equalTo: currentColorView.trailingAnchor).isActive = true
        colorCodeLabel.bottomAnchor.constraint(equalTo: currentColorView.bottomAnchor).isActive = true
        
        // Slider constraints
        brightnessSlider.centerYAnchor.constraint(equalTo: currentColorView.centerYAnchor).isActive = true
        brightnessSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        brightnessSlider.widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
        let leading = brightnessSlider.leadingAnchor.constraint(equalTo: currentColorView.trailingAnchor, constant: 16)
        leading.priority = .defaultLow
        leading.isActive = true
        
        // Brightness label
        brightnessLabel.leadingAnchor.constraint(equalTo: brightnessSlider.leadingAnchor).isActive = true
        brightnessLabel.trailingAnchor.constraint(equalTo: brightnessSlider.trailingAnchor).isActive = true
        brightnessLabel.bottomAnchor.constraint(equalTo: brightnessSlider.topAnchor, constant: -4).isActive = true
        
        // Colors pallete
        colorsPallete.topAnchor.constraint(equalTo: currentColorView.bottomAnchor, constant: 24).isActive = true
        colorsPallete.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        colorsPallete.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        colorsPallete.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16).isActive = true
        
        // Cancel button
        cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -16).isActive = true
        
        // Save button
        saveButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24).isActive = true
        saveButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 16).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        
    }
    
    // MARK: - UIElements
    
    private let currentColorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        return view
    }()
    
    private let colorCodeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.text = "#FFFFFF"
        label.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        label.textColor = .white
        return label
    }()
    
    private let brightnessLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = "Brightness:"
        return label
    }()
    
    private let colorsPallete: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .green
        return view
    }()
    
    private let brightnessSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 1
        slider.isContinuous = true
        return slider
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save", for: .normal)
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.red, for: .normal)
        return button
    }()
    
}
