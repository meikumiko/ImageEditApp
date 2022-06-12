//
//  imageEditViewController.swift
//  ImageEditApp
//
//  Created by Hsiao-Han Chi on 2022/6/3.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

extension imageEditViewController: UIColorPickerViewControllerDelegate{
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        text.textColor = viewController.selectedColor
    }
}


class imageEditViewController: UIViewController{
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    //selectItem儲存上一頁傳過來的圖片
    var selectItem = UIImage()
    //renderImage儲存最後編輯完輸出的圖片
    var renderImage = UIImage()
    //editedImage儲存這一頁編輯完的圖片
    var editedImage = UIImage()
    
    //顯示現在是哪個編輯畫面的圓點property
    @IBOutlet var dotImageViews: [UIImageView]!
    
    //調整照片亮度、對比、飽和度需要的property
    @IBOutlet weak var dialEditButton: UIButton!
    
    //連接到濾鏡編輯畫面的按鈕
    @IBOutlet weak var filterEditButton: UIButton!
    
    //連接到編輯圖片尺寸畫面的按鈕
    @IBOutlet weak var ratioEditButton: UIButton!
    
    //裝飾照片用的property
    @IBOutlet weak var decorationView: UIView!
    @IBOutlet weak var addFontButton: UIButton!
    @IBOutlet weak var fontSizeButton: UIButton!{
        didSet{
            fontSizeButton.configurationUpdateHandler = {
                fontSizeButton in fontSizeButton.alpha = fontSizeButton.isSelected ? 1 : 0.4
                // 1 : 0.4，代表按鈕在 isSelected 狀態時的透明度是1，normol 狀態時透明度是 0.4
            }
        }
    }
    
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var fontColorButton: UIButton!{
        didSet{
            fontColorButton.configurationUpdateHandler = {
                fontColorButton in fontColorButton.alpha = fontColorButton.isSelected ? 1 : 0.4
                // 1 : 0.4，代表按鈕在 isSelected 狀態時的透明度是1，normol 狀態時透明度是 0.4
            }
        }
    }
    @IBOutlet weak var addStickerButton: UIButton!
    @IBOutlet weak var adjustFontView: UIView!
    @IBOutlet weak var selectStickerView: UIView!
    var text = UITextField()
    var sticker = UIImageView()
    
    var mirrorNum = 1
    var turnNum = 1
    
    //重設圖片的button
    @IBOutlet weak var resetButton: UIButton!
    
    
    //宣告CIContext共用
    let context = CIContext()
    
    //拖曳字的function
    @objc func moveFont(_ sender: UIPanGestureRecognizer){
        let point = sender.location(in: self.imageView)
        //設定中心點為拖曳點
        text.center = point
    }
    
    //拖曳貼圖的function
    @objc func moveSticker(_ sender: UIPanGestureRecognizer){
        let point = sender.location(in: self.imageView)
        //設定中心點為拖曳點
        sticker.center = point
    }
    
    //縮放貼圖的function
    @objc func pinchSticker(_ sender: UIPinchGestureRecognizer){
        if sender.state == .changed{
            let scale = sender.scale
            let w = sticker.frame.size.width
            
            
            
            //設定縮放範圍0.4~1倍
            if w * scale > w * 0.3 && w * scale <= w * 2{
                sticker.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }
    
    
    //圖片檔案傳輸
    init?(coder: NSCoder, selectItem: UIImage){
        self.selectItem = selectItem
        super.init(coder: coder)
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //點選畫面任一處收鍵盤
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            view.endEditing(true)
        }
    
    @objc func closeKeyboard() {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = selectItem
        for i in 0...2{
            dotImageViews[i].isHidden = true
        }
        //按return鍵收鍵盤
        text.addTarget(self, action: #selector(closeKeyboard), for: .editingDidEndOnExit)
        
        //設定拖曳手勢，用在移動字
        let panFontGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveFont(_:)))
        //設定單點觸控拖曳
        panFontGestureRecognizer.minimumNumberOfTouches = 1
        panFontGestureRecognizer.maximumNumberOfTouches = 1
        //UIView要開啟isUserInteractionEnabled，觸控才有反應
        text.isUserInteractionEnabled = true
        text.addGestureRecognizer(panFontGestureRecognizer)
        
        //設定拖曳手勢，用在移動貼圖
        let panStickerGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveSticker(_:)))
        //設定單點觸控拖曳
        panStickerGestureRecognizer.minimumNumberOfTouches = 1
        panStickerGestureRecognizer.maximumNumberOfTouches = 1
        sticker.isUserInteractionEnabled = true
        sticker.addGestureRecognizer(panStickerGestureRecognizer)
        
        //設定縮放手勢，用在縮放貼圖
        let pinchStickerGestureRecognzier = UIPinchGestureRecognizer(target: self, action: #selector(pinchSticker(_:)))
        sticker.addGestureRecognizer(pinchStickerGestureRecognzier)

        
        
    }
    
    @IBAction func addFont(_ sender: Any) {
        adjustFontView.isHidden = false
        fontSizeButton.isSelected = true
        fontColorButton.isSelected = false
        fontSizeSlider.isHidden = false
        selectStickerView.isHidden = true
        
        if containerView.subviews.contains(text) == false{
            text.placeholder = "輸入文字"
            text.borderStyle = .none
            text.textAlignment = .center
            text.font = UIFont.systemFont(ofSize: 20)
            text.textColor = .black
            text.frame.size = CGSize(width: 200, height: 100)
            text.allowsEditingTextAttributes = true
            text.center = imageView.center
            
            containerView.addSubview(text)
        }
        
    }
    
    @IBAction func showSlider(_ sender: Any) {
        fontSizeButton.isSelected = true
        fontColorButton.isSelected = false
        fontSizeSlider.isHidden = false
        
    }
    
    @IBAction func setFontSize(_ sender: Any) {
        text.font = UIFont.systemFont(ofSize: CGFloat(fontSizeSlider.value))
    }
    
    
    @IBAction func editFontColor(_ sender: Any) {
        fontSizeButton.isSelected = false
        fontColorButton.isSelected = true
        fontSizeSlider.isHidden = true
        
        //設定並呼叫選顏色的controller畫面
        let controller = UIColorPickerViewController()
        controller.delegate = self
        present(controller, animated: true)
    }
    
    @IBAction func showSticker(_ sender: Any) {
        selectStickerView.isHidden = false
        adjustFontView.isHidden = true
    }
    
    @IBAction func AddSticker(_ sender: UIButton){
        sticker.contentMode = .scaleAspectFit
        sticker.frame.size = CGSize(width: 100, height: 100)
        sticker.center = imageView.center
        sticker.image = UIImage(named: "sticker-" + "\(sender.tag)")
        containerView.addSubview(sticker)
    }
    
    
    @IBAction func mirrorRotate(_ sender: Any) {
        if mirrorNum % 2 == 1{
            imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }else if mirrorNum % 2 == 0{
            imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        mirrorNum += 1
        
    }
    
    
    
    @IBAction func turnLeft(_ sender: Any) {
        if turnNum < 4{
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2 * -1 * CGFloat(turnNum))
        }else if turnNum == 4{
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2 * 0)
            turnNum = 0
        }
        
        turnNum += 1
    }
    
    //將現階段的view儲存，觸發開啟圖片調整畫面的Segue
    @IBAction func dialEditEnter(_ sender: Any) {
        //儲存現在的imageView圖片
        editedImage = imageView.image!
        //觸發Segue
        performSegue(withIdentifier: "dialEditSegue", sender: nil)
        
    }
    
    //觸發dialEditSegue後傳輸的資料
    @IBSegueAction func dialEditSegue(_ coder: NSCoder) -> imageAdjustViewController? {
        return imageAdjustViewController(coder: coder, editedImage: editedImage)
    }
    
    
    //將現階段的view儲存，觸發開啟濾鏡編輯畫面的Segue
    @IBAction func filterEditEnter(_ sender: Any) {
        //儲存現在的imageView圖片
        editedImage = imageView.image!
        //觸發Segue
        performSegue(withIdentifier: "filterEditSegue", sender: nil)
        
    }
    
    //觸發filteEditSegue後傳輸的資料
    @IBSegueAction func filterEditSegue(_ coder: NSCoder) -> imageFilterViewController? {
        return imageFilterViewController(coder: coder, editedImage: editedImage)
    }
    
    //將現階段的view儲存，觸發更改圖片尺寸畫面的Segue
    @IBAction func ratioEditEnter(_ sender: Any) {
        //儲存現在的imageView圖片
        editedImage = imageView.image!
        
        performSegue(withIdentifier: "ratioEditSegue", sender: nil)
        
    }
    
    //觸發ratioEditSegue後傳輸的資料
    @IBSegueAction func ratioEditSegue(_ coder: NSCoder) -> imageRatioEditViewController? {
        return imageRatioEditViewController(coder: coder, editedImage: editedImage)
    }
    
    //回到上一頁
    @IBAction func returnPage(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func reset(_ sender: Any) {
        text.removeFromSuperview()
        text.text?.removeAll()
        sticker.removeFromSuperview()
        imageView.image = selectItem
        adjustFontView.isHidden = true
        fontSizeSlider.isHidden = true
        fontSizeSlider.value = 20
        selectStickerView.isHidden = true
        
    }
    
    //從調整亮度、對比、飽和度畫面回來
    @IBAction func unwindToAdjustView(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source as? imageAdjustViewController
        //imageView顯示的圖片是傳回來的輸出圖片
        imageView.image = sourceViewController?.renderImage
        // Use data from the view controller which initiated the unwind segue
    }
    
    //從選擇濾鏡畫面回來
    @IBAction func unwindToFilterView(_ unwindSegue: UIStoryboardSegue) {
        //設定回傳資料的來源是哪個controller
        let sourceViewController = unwindSegue.source as? imageFilterViewController
        //imageView顯示的圖片是傳回來的輸出圖片
        imageView.image = sourceViewController?.renderImage
        // Use data from the view controller which initiated the unwind segue
    }
    
    //從編輯圖片尺寸畫面回來
    @IBAction func unwindToEditView(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source as? imageRatioEditViewController
        imageView.image = sourceViewController?.renderImage
        // Use data from the view controller which initiated the unwind segue
    }
    
    
    @IBAction func saveImage(_ sender: Any) {
        editedImage = imageView.image!
        let imgW = editedImage.size.width
        let imgH = editedImage.size.height
        let viewW = imageView.bounds.width
        let viewH = imageView.bounds.height
        let scale = min(viewW / imgW, viewH / imgH)
        let newWidth = imgW * scale
        let newHeight = imgH * scale
        let offsetX = (viewW - newWidth) / 2
        let offsetY = (viewH - newHeight) / 2
        

        let renderer = UIGraphicsImageRenderer(bounds: CGRect(x: imageView.frame.minX + offsetX, y: imageView.frame.minY + offsetY, width: newWidth, height: newHeight))
        renderImage = renderer.image(actions: { (context) in
              containerView.drawHierarchy(in: imageView.frame, afterScreenUpdates: true)
        })
        
        let activityViewController = UIActivityViewController(activityItems: [renderImage], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
        
        
    }
    
    
    
    
    /*
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
