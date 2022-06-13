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
        //儲存點選的照片資訊的property，利用參數 info的.originalImage取得圖片相關資料
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
        //從 PHPickerResult的itemProvider載入選擇的照片
        let itemProviders = results.map(\.itemProvider)
        //使用者有可能沒有選擇照片，所以用if let先檢查itemProviders裡面有沒有值
        if let itemProvider = itemProviders.first, itemProvider.canLoadObject(ofClass: UIImage.self){
            //previousImage用來儲存本來imageView顯示的照片，以判斷選擇照片時原本的照片是否還是同一張，如果是才將照片替換成選擇的照片
            let previousImage = self.photoImage
            self.coverStackView.isHidden = true
            //載入照片
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, Error) in
                DispatchQueue.main.async {
                    //判斷照片是否仍是同一張
                    guard let self = self, let image = image as? UIImage, self.photoImage == previousImage else { return }
                    //變數photoImage儲存選擇的照片
                    self.photoImage = image
                    //imageView顯示選擇的照片
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
        //sourceType設為.camera代表呼叫controller是用來開啟相機
        controller.sourceType = .camera
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func selectImage(_ sender: Any) {
        var configuration = PHPickerConfiguration()
        //PHPickerConfiguration可以設定選擇照片或影片，nil則兩種都可以選擇，我們只要選擇照片，所以設定 .images
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @IBSegueAction func imageEdit(_ coder: NSCoder) -> imageEditViewController? {
        return imageEditViewController(coder: coder, selectItem: photoImage)
    }
    
    
}

