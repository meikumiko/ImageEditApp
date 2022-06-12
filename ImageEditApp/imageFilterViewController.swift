//
//  imageFilterViewController.swift
//  ImageEditApp
//
//  Created by Hsiao-Han Chi on 2022/6/6.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins


class imageFilterViewController: UIViewController{
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    //editedImage是上一頁編輯後的UIImage
    var editedImage = UIImage()
    //renderImage儲存套用濾鏡後輸出的圖片，用來傳回到上一頁
    var renderImage = UIImage()
    
    //使用濾鏡需要的property
    @IBOutlet weak var filterView: UIView!
    @IBOutlet var filterButton: [UIButton]!
    let filterArray = ["", "CIPhotoEffectChrome", "CIPhotoEffectFade", "CIPhotoEffectInstant", "CIPhotoEffectMono", "CIPhotoEffectNoir", "CIPhotoEffectProcess", "CIPhotoEffectTonal", "CIPhotoEffectTransfer"]
    
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
    
    //設定濾鏡選單的按鈕背景圖為編輯的照片，並套用濾圖片中
    func filterAdoptUI(){
        let image = editedImage
        for i in 0...8{
            //設定按鈕背景圖片
            filterButton[i].configuration?.background.image = image
            //設定圖片顯示模式
            filterButton[i].configuration?.background.imageContentMode = .scaleAspectFill
            //轉換照片為CIImage
            let ciImage = CIImage(image: (filterButton[i].configuration?.background.image)!)
            //設定濾鏡
            if let filter = CIFilter(name: filterArray[i]){
                //把圖片放入filter中
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                //輸出套用濾鏡後的圖片，格式為CIImage
                if let outputImage = filter.outputImage, let cgImage = context.createCGImage(outputImage, from: outputImage.extent){
                //    let newImage = CIImage(cgImage: cgImage)
                    //取得圖片原始方向並轉成正確方向
                  //  let rotateImage = newImage.oriented(CGImagePropertyOrientation(editedImage.imageOrientation))
                    //把圖片轉回UIImage，放入對應的按鈕中
                    let filterImage = UIImage(cgImage: cgImage)
                    filterButton[i].configuration?.background.image = filterImage
                }
            }
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = editedImage
        filterAdoptUI()

        // Do any additional setup after loading the view.
    }
    
    //使用濾鏡
    @IBAction func filterAdopt(_ sender: UIButton){
        //轉換照片為CIImage
        let ciImage = CIImage(image: editedImage)
        //如果選擇第一個按鈕，顯示原圖（不套用濾鏡）
        if sender.tag == 0{
            imageView.image = editedImage
        //選擇第2~8個按鈕，根據tag編號套用對應濾鏡
        }else if sender.tag >= 1{
            //判斷使用的濾鏡是哪一個
            if let filter = CIFilter(name: filterArray[sender.tag]){
                //把圖片放入filter
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                //輸出套用濾鏡後的圖片，格式為CIImage
                if let outputImage = filter.outputImage, let cgImage = context.createCGImage(outputImage, from: outputImage.extent){
                    //取得圖片原始方向並轉成正確方向
               //     let newImage = CIImage(cgImage: cgImage)
               //     let rotateImage = newImage.oriented(CGImagePropertyOrientation(editedImage.imageOrientation))
                    //把圖片轉回UIImage，放入imageView中
                    let filterImage = UIImage(cgImage: cgImage)
                    imageView.image = filterImage
                }
            }
            
        }
        
    }
    

    //返回上一頁時先執行的動作，輸出套用完濾鏡的圖片
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //let renderer = UIGraphicsImageRenderer(size: containerView.bounds.size)
        //renderImage = renderer.image(actions: { (context) in
         //     containerView.drawHierarchy(in: containerView.bounds, afterScreenUpdates: true)
        //   })
        renderImage = imageView.image!
    }

}
