//
//  imageAdjustViewController.swift
//  ImageEditApp
//
//  Created by Hsiao-Han Chi on 2022/6/7.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins


class imageAdjustViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    //調整照片亮度、對比、飽和度需要的property
    @IBOutlet weak var dialStackView: UIStackView!
    @IBOutlet var adjustSliders: [UISlider]!
    
    //editedImage是上一頁編輯後的UIImage
    var editedImage = UIImage()
    //renderImage儲存套用濾鏡後輸出的圖片，用來傳回到上一頁
    var renderImage = UIImage()
    
    //宣告CIContext共用
    let context = CIContext()
    
    //圖片檔案傳輸
    init?(coder: NSCoder, editedImage: UIImage){
        self.editedImage = editedImage
        super.init(coder: coder)
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = editedImage

        // Do any additional setup after loading the view.
    }
    
    //調整照片亮度、對比、飽和度
    @IBAction func adjustImage(_ sender: UISlider){
        //轉換照片為CIImage
        let ciImage = CIImage(image: editedImage)
        //使用CIColorControls filter，裡面才有調整亮度、對比、飽和度的功能
        let filter = CIFilter(name: "CIColorControls")
        //把CIImage放入filter中
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        //設定3個slider個別對應的功能
        filter?.setValue(adjustSliders[0].value, forKey: kCIInputBrightnessKey)
        filter?.setValue(adjustSliders[1].value, forKey: kCIInputContrastKey)
        filter?.setValue(adjustSliders[2].value, forKey: kCIInputSaturationKey)
        //輸出調整後的圖片，格式為CIImage
        if let outputImage = filter?.outputImage, let cgImage = context.createCGImage(outputImage, from: outputImage.extent){
           //取得圖片原始方向並轉成正確方向
          // let rotateImage = outputImage.oriented(CGImagePropertyOrientation(editedImage.imageOrientation))
            //把圖片轉回UIImage，放入imageView中
            let updateImage = UIImage(cgImage: cgImage)
            imageView.image = updateImage
            
        }
        
    }
    
    //返回上一頁時先執行的動作，輸出調整後的圖片
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        renderImage = imageView.image!
    }


}
