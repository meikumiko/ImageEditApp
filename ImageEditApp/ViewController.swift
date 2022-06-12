//
//  ViewController.swift
//  ImageEditApp
//
//  Created by Hsiao-Han Chi on 2022/6/3.
//

import UIKit
import PhotosUI

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate{
    
    //拍照後執行的function
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //儲存點選的照片資訊的property
        let photo = info[.originalImage] as? UIImage
        self.coverStackView.isHidden = true
        dismiss(animated: true) {
            self.photoImage = photo!
            self.selectedImageView.image = self.photoImage
            self.editButton.isHidden = false
        }
        
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        let itemProviders = results.map(\.itemProvider)
        if let itemProvider = itemProviders.first, itemProvider.canLoadObject(ofClass: UIImage.self){
            let previousImage = self.photoImage
            self.coverStackView.isHidden = true
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, Error) in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage, self.photoImage == previousImage else { return }
                    self.photoImage = image
                    self.selectedImageView.image = self.photoImage
                    self.editButton.isHidden = false

                }
            }
        }
    }
    
    //宣告儲存拍照的照片或是選擇相簿照片的變數
    var photoImage = UIImage()
    
    @IBOutlet weak var coverStackView: UIStackView!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editButton.isHidden = true
    }

    @IBAction func takePhoto(_ sender: Any) {
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func selectImage(_ sender: Any) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @IBSegueAction func imageEdit(_ coder: NSCoder) -> imageEditViewController? {
        return imageEditViewController(coder: coder, selectItem: photoImage)
    }
    
    
}

