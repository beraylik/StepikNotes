//
//  ImageCollectionVC.swift
//  Notes
//
//  Created by Генрих Берайлик on 20/07/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import UIKit

// MARK: - ImageCollection class

class ImageCollectionVC: UIViewController {
    
    // MARK: - Properties
    
    private let cellId = "cellId"
    private var images = [UIImage]()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var collectionVIew: UICollectionView!
    
    // MARK: - IBActions
    
    @IBAction func addButtonTapped(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.images = ImageService.shared.images
        collectionVIew.reloadData()
    }
    
    // MARK: - Configure UI
    
    private func setupViews() {
        collectionVIew.delegate = self
        collectionVIew.dataSource = self
        let cellNib = UINib(nibName: "GalleryCell", bundle: Bundle.main)
        collectionVIew.register(cellNib, forCellWithReuseIdentifier: cellId)
    }
    
}

// MARK: - CollectionView Delegate

extension ImageCollectionVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let scrollVC = storyboard.instantiateViewController(withIdentifier: "ScrollViewController") as! ScrollViewController
        scrollVC.set(images: images, selectedIndex: indexPath.row)
        navigationController?.pushViewController(scrollVC, animated: true)
    }
    
}

// MARK: - CollectoinView DataSource

extension ImageCollectionVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionVIew.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GalleryCell
        
        cell.imageView.image = images[indexPath.row]
        return cell
    }
    
}

extension ImageCollectionVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = (view.frame.width / 3) - 16
        return CGSize(width: side, height: side)
    }
}

// MARK: - UIImagePicker Delegate

extension ImageCollectionVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            ImageService.shared.add(image: image)
            dismiss(animated: true, completion: nil)
        }
    }
    
}
