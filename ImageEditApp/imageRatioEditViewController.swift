//
//  imageRatioEditViewController.swift
//  ImageEditApp
//
//  Created by Hsiao-Han Chi on 2022/6/6.
//

import UIKit

extension imageRatioEditViewController: UIScrollViewDelegate {
    func viewForZooming(in imageScrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ imageScrollView: UIScrollView) {
            let insetHeight = (imageScrollView.bounds.height - imageView.frame.height) / 2
            let insetWidth = (imageScrollView.bounds.width - imageView.frame.width) / 2
            imageScrollView.contentInset = .init(top: max(insetHeight, 0), left: max(insetWidth, 0), bottom: 0, right: 0)
           
    }
}

class imageRatioEditViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    //editImage儲存上一頁傳過來的圖片，用來顯示在這裡的imageView中
    var editedImage = UIImage()
    //renderImage儲存這一頁編輯完輸出的圖片，用來傳回到上一頁
    var renderImage = UIImage()
    //cropFrame用來裝裁切框線的layer，以及作為截圖範圍
    var cropFrame = UIView()
    
    //調整圖片方向、尺寸需要的property
    @IBOutlet weak var rotationStackView: UIStackView!
    @IBOutlet weak var orientationStackView: UIStackView!
    @IBOutlet weak var portraitButton: UIButton!{
        didSet{
            portraitButton.configurationUpdateHandler = {
                portraitButton in portraitButton.alpha = portraitButton.isSelected ? 1 : 0.4
                // 1 : 0.4，代表按鈕在 isSelected 狀態時的透明度是1，normol 狀態時透明度是 0.4
            }
        }
    }
    @IBOutlet weak var landscapeButton: UIButton!{
        didSet{
            landscapeButton.configurationUpdateHandler = {
                landscapeButton in landscapeButton.alpha = landscapeButton.isSelected ? 1 : 0.4
                // 1 : 0.4，代表按鈕在 isSelected 狀態時的透明度是1，normol 狀態時透明度是 0.4
            }
        }
    }
    
    @IBOutlet var ratioButtons: [UIButton]!
    
    //num用來判斷選擇裁切框是直的還是橫的
    var num = 0
    
    
    //圖片檔案傳輸
    init?(coder: NSCoder, editedImage: UIImage){
        self.editedImage = editedImage
        super.init(coder: coder)
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            updateZoomSizeFor(size: containerView.bounds.size)
    }
    
    func updateZoomSizeFor(size: CGSize) {
            let widthScale = size.width / imageView.bounds.width
            let heightScale = size.height / imageView.bounds.height
            let scale = min(widthScale, heightScale)
            imageScrollView.minimumZoomScale = scale
            imageScrollView.zoomScale = scale
    }
    
    //拖曳手勢function
    @objc func move(_ sender: UIPanGestureRecognizer){
        let point = sender.location(in: self.imageScrollView)
        //設定中心點為拖曳點
        cropFrame.center = point
        
        let imgW = editedImage.size.width
        let imgH = editedImage.size.height
        let viewW = imageScrollView.bounds.width
        let viewH = imageScrollView.bounds.height
        let scale = min(viewW / imgW, viewH / imgH)
        let scaledImgW = imgW * scale
        let scaledImgH = imgH * scale
        let frameW = cropFrame.frame.size.width
        let frameH = cropFrame.frame.size.height
        let overX = scaledImgW - frameW
        let overY = scaledImgH - frameH
        
        if cropFrame.frame.origin.x < 0{
            cropFrame.frame.origin.x = 0
        }
        
        if cropFrame.frame.origin.x > overX{
            cropFrame.frame.origin.x = overX
        }
        
        if cropFrame.frame.origin.y < 0{
            cropFrame.frame.origin.y = 0
        }
        
        if cropFrame.frame.origin.y > overY{
            cropFrame.frame.origin.y = overY
        }
        
        print("frame",cropFrame.frame,   cropFrame.frame.minX, cropFrame.frame.minY, "bounds", cropFrame.bounds, cropFrame.bounds.minX, cropFrame.bounds.minY)
        
    }
    
    //縮放手勢function
    @objc func pinch(_ sender: UIPinchGestureRecognizer){
        if sender.state == .changed{
            let scale = sender.scale
            let w = cropFrame.frame.size.width
            
            
            
            //設定縮放範圍0.4~1倍
            if w * scale > w * 0.4 && w * scale <= w{
                cropFrame.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //顯示傳遞過來的圖片
        imageView.image = editedImage
        portraitButton.isSelected = false
        landscapeButton.isSelected = true
        //宣告圖片寬、高的property
        let imgW = editedImage.size.width
        let imgH = editedImage.size.height
        //設定scrollview寬、高的property
        let viewW = imageScrollView.bounds.width
        let viewH = imageScrollView.bounds.height
        //scale是圖片在imageView的縮放比例，取scrollview跟圖片的寬跟高的比中較小的值
        let scale = min(viewW / imgW, viewH / imgH)
        //圖片縮放後的寬跟高會等於原本的寬跟高乘以比例
        let scaledImgW = imgW * scale
        let scaledImgH = imgH * scale
        //讓比例框線view的寬跟高 = 圖片縮放後的寬跟高
        cropFrame.frame.size.width = scaledImgW
        cropFrame.frame.size.height = scaledImgH
        
        //將畫好的外框線、內框線跟四個角放到比例框線view中
        cropFrame.layer.addSublayer(drawRect())
        cropFrame.layer.addSublayer(drawLine())
        cropFrame.layer.addSublayer(drawCorner())
        //把比例框線view加到containerView中
        containerView.addSubview(cropFrame)
        
        //設定拖曳手勢，用在移動比例框線
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(move(_:)))
        //設定單點觸控拖曳
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 1
        //UIView要開啟isUserInteractionEnabled，觸控才有反應
        cropFrame.isUserInteractionEnabled = true
        cropFrame.addGestureRecognizer(panGestureRecognizer)
        
        //設定縮放手勢，用在縮放比例框線
        let pinchGestureRecognzier = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
        cropFrame.addGestureRecognizer(pinchGestureRecognzier)

        // Do any additional setup after loading the view.
    }
    
    
    //畫比例裁切框線
    //外框線
    func drawRect() -> CAShapeLayer{
        let imgW = editedImage.size.width
        let imgH = editedImage.size.height
        let viewW = imageScrollView.bounds.width
        let viewH = imageScrollView.bounds.height
        let scale = min(viewW / imgW, viewH / imgH)
        let scaledImgW = imgW * scale
        let scaledImgH = imgH * scale
        let offsetX = (viewW - imgW * scale) / 2
        let offsetY = (viewH - imgH * scale) / 2
        
        
        let path = UIBezierPath(rect: CGRect(x: offsetX, y: offsetY, width: scaledImgW, height: scaledImgH))
        let rectangleLayer = CAShapeLayer()
        rectangleLayer.path = path.cgPath
        rectangleLayer.fillColor = UIColor.clear.cgColor
        rectangleLayer.strokeColor = UIColor.white.cgColor
        rectangleLayer.lineWidth = 2
        
        return rectangleLayer
    }
    
    //內框線
    func drawLine() -> CAShapeLayer{
        let imgW = editedImage.size.width
        let imgH = editedImage.size.height
        let viewW = imageScrollView.bounds.width
        let viewH = imageScrollView.bounds.height
        let scale = min(viewW / imgW, viewH / imgH)
        let scaledImgW = imgW * scale
        let scaledImgH = imgH * scale
        let offsetX = (viewW - imgW * scale) / 2
        let offsetY = (viewH - imgH * scale) / 2
        
        let line = UIBezierPath()
        line.move(to: CGPoint(x: offsetX + scaledImgW / 3, y: offsetY))
        line.addLine(to: CGPoint(x: offsetX + scaledImgW / 3, y: offsetY + scaledImgH))
        line.move(to: CGPoint(x: offsetX + scaledImgW / 3 * 2, y: offsetY))
        line.addLine(to: CGPoint(x: offsetX + scaledImgW / 3 * 2, y: offsetY + scaledImgH))
        line.move(to: CGPoint(x: offsetX, y: offsetY + scaledImgH / 3))
        line.addLine(to: CGPoint(x: offsetX + scaledImgW, y: offsetY + scaledImgH / 3))
        line.move(to: CGPoint(x: offsetX, y: offsetY + scaledImgH / 3 * 2))
        line.addLine(to: CGPoint(x: offsetX + scaledImgW, y: offsetY + scaledImgH / 3 * 2))
        let lineLayer = CAShapeLayer()
        lineLayer.path = line.cgPath
        lineLayer.strokeColor = UIColor.white.cgColor
        lineLayer.lineWidth = 1
        
        return lineLayer
    }
    
    //四個角
    func drawCorner() -> CAShapeLayer{
        let imgW = editedImage.size.width
        let imgH = editedImage.size.height
        let viewW = imageScrollView.bounds.width
        let viewH = imageScrollView.bounds.height
        let scale = min(viewW / imgW, viewH / imgH)
        let scaledImgW = imgW * scale
        let scaledImgH = imgH * scale
        let offsetX = (viewW - imgW * scale) / 2
        let offsetY = (viewH - imgH * scale) / 2
        
        let corner = UIBezierPath()
        //左上角
        corner.move(to: CGPoint(x: offsetX, y: offsetY))
        corner.addLine(to: CGPoint(x: offsetX + scaledImgW / 9, y: offsetY))
        corner.move(to: CGPoint(x: offsetX, y: offsetY))
        corner.addLine(to: CGPoint(x: offsetX, y: offsetY + scaledImgH / 9))
        //右上角
        corner.move(to: CGPoint(x: offsetX + scaledImgW, y: offsetY))
        corner.addLine(to: CGPoint(x: offsetX + scaledImgW / 9 * 8, y: offsetY))
        corner.move(to: CGPoint(x: offsetX + scaledImgW, y: offsetY))
        corner.addLine(to: CGPoint(x: offsetX + scaledImgW, y: offsetY + scaledImgH / 9))
        //右下角
        corner.move(to: CGPoint(x: offsetX + scaledImgW, y: offsetY + scaledImgH))
        corner.addLine(to: CGPoint(x: offsetX + scaledImgW / 9 * 8, y: offsetY + scaledImgH))
        corner.move(to: CGPoint(x: offsetX + scaledImgW, y: offsetY + scaledImgH))
        corner.addLine(to: CGPoint(x: offsetX + scaledImgW, y: offsetY + scaledImgH / 9 * 8))
        //左下角
        corner.move(to: CGPoint(x: offsetX, y: offsetY + scaledImgH))
        corner.addLine(to: CGPoint(x: offsetX + scaledImgW / 9, y: offsetY + scaledImgH))
        corner.move(to: CGPoint(x: offsetX, y: offsetY + scaledImgH))
        corner.addLine(to: CGPoint(x: offsetX, y: offsetY + scaledImgH / 9 * 8))
        
        
        let cornerLayer = CAShapeLayer()
        cornerLayer.path = corner.cgPath
        cornerLayer.strokeColor = UIColor.white.cgColor
        cornerLayer.lineWidth = 4
        
        return cornerLayer
    }
    

    
    
    
    
    @IBAction func setPortrait(_ sender: Any) {
        num = 1
        portraitButton.isSelected = true
        landscapeButton.isSelected = false
    }
    
    @IBAction func setLandscape(_ sender: Any) {
        num = 0
        portraitButton.isSelected = false
        landscapeButton.isSelected = true
        
    }
    
    @IBAction func changeRatio(_ sender: UIButton){
        let imgW = editedImage.size.width
        let imgH = editedImage.size.height
        let viewW = imageScrollView.bounds.width
        let viewH = imageScrollView.bounds.height
        let scale = min(viewW / imgW, viewH / imgH)
        let originalWidth = imgW * scale
        let originalHeight = imgH * scale
        let ratioValue = min(originalWidth, originalHeight)
        
        if sender.tag == 1{
            portraitButton.isEnabled = false
            landscapeButton.isEnabled = false
        }else if sender.tag == 0 || sender.tag >= 2{
            portraitButton.isEnabled = true
            landscapeButton.isEnabled = true
        }
        
        if num == 0{
            switch sender.tag{
            case 0:
                cropFrame.transform = CGAffineTransform(scaleX: 1, y: 1)
                landscapeButton.isSelected = true
            case 1:
                cropFrame.transform = CGAffineTransform(scaleX: ratioValue / originalWidth, y: ratioValue / originalHeight)
                portraitButton.isSelected = false
                landscapeButton.isSelected = false
            case 2:
                cropFrame.transform = CGAffineTransform(scaleX: ratioValue / originalWidth, y: ratioValue / originalHeight * 9 / 16)
                landscapeButton.isSelected = true
            case 3:
                cropFrame.transform = CGAffineTransform(scaleX: ratioValue / originalWidth, y: ratioValue / originalHeight * 4 / 5)
                landscapeButton.isSelected = true
            case 4:
                cropFrame.transform = CGAffineTransform(scaleX: ratioValue / originalWidth, y: ratioValue / originalHeight * 5 / 7)
                landscapeButton.isSelected = true
            case 5:
                cropFrame.transform = CGAffineTransform(scaleX: ratioValue / originalWidth, y: ratioValue / originalHeight * 3 / 4)
                landscapeButton.isSelected = true
            case 6:
                cropFrame.transform = CGAffineTransform(scaleX: ratioValue / originalWidth, y: ratioValue / originalHeight * 3 / 5)
                landscapeButton.isSelected = true
            case 7:
                cropFrame.transform = CGAffineTransform(scaleX: ratioValue / originalWidth, y: ratioValue / originalHeight * 2 / 3)
                landscapeButton.isSelected = true
                
            default:
                break
            }
            
        }else if num == 1{
            switch sender.tag{
            case 0:
                cropFrame.transform = CGAffineTransform(scaleX: 1, y: 1)
                portraitButton.isSelected = true
            case 1:
                cropFrame.transform = CGAffineTransform(scaleX: ratioValue / originalWidth, y: ratioValue / originalHeight)
                portraitButton.isSelected = false
                landscapeButton.isSelected = false
            case 2:
                cropFrame.transform = CGAffineTransform(scaleX: ratioValue / originalWidth * 9 / 16, y: ratioValue / originalHeight)
                portraitButton.isSelected = true
            case 3:
                cropFrame.transform = CGAffineTransform(scaleX: ratioValue / originalWidth * 4 / 5, y: ratioValue / originalHeight)
                portraitButton.isSelected = true
            case 4:
                cropFrame.transform = CGAffineTransform(scaleX: ratioValue / originalWidth * 5 / 7, y: ratioValue / originalHeight)
                portraitButton.isSelected = true
            case 5:
                cropFrame.transform = CGAffineTransform(scaleX: ratioValue / originalWidth * 3 / 4, y: ratioValue / originalHeight)
                portraitButton.isSelected = true
            case 6:
                cropFrame.transform = CGAffineTransform(scaleX: ratioValue / originalWidth * 3 / 5, y: ratioValue / originalHeight)
                portraitButton.isSelected = true
            case 7:
                cropFrame.transform = CGAffineTransform(scaleX: ratioValue / originalWidth * 2 / 3, y: ratioValue / originalHeight)
                portraitButton.isSelected = true
            default:
                break
            }
        }
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        cropFrame.removeFromSuperview()
        
        
        let imgW = editedImage.size.width
        let imgH = editedImage.size.height
        
        let offsetX = (containerView.bounds.width - cropFrame.frame.width) / 2
        let offsetY = (containerView.bounds.height - cropFrame.frame.height) / 2
        
        if imgW > imgH{
            let renderer = UIGraphicsImageRenderer(bounds: CGRect(x: cropFrame.frame.minX, y: cropFrame.frame.minY + offsetY, width: cropFrame.frame.width, height: cropFrame.frame.height))
            renderImage = renderer.image(actions: { (context) in
                  containerView.drawHierarchy(in: containerView.bounds, afterScreenUpdates: true)
            })
            
        }else if imgW < imgH{
            let renderer = UIGraphicsImageRenderer(bounds: CGRect(x: cropFrame.frame.minX + offsetX, y: cropFrame.frame.minY, width: cropFrame.frame.width, height: cropFrame.frame.height))
            renderImage = renderer.image(actions: { (context) in
                  containerView.drawHierarchy(in: containerView.bounds, afterScreenUpdates: true)
            })
        }
    
    }

}
