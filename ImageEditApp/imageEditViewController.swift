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
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        //讓文字顏色等於所選擇的顏色
        text.textColor = viewController.selectedColor
    }
}


class imageEditViewController: UIViewController{
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var mirrorView: UIView!
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
    
    //儲存文字跟貼圖的property
    var text = UITextField()
    var sticker = UIImageView()
    
    //儲存圖片水平旋轉狀態的property
    var mirrorNum = 1
    //儲存圖片向左旋轉次數的property
    var turnNum = 1
    
    //重設圖片的button
    @IBOutlet weak var resetButton: UIButton!
    
    
    //宣告CIContext共用
    let context = CIContext()
    
    //拖曳字的function
    @objc func moveFont(_ sender: UIPanGestureRecognizer){
        //宣告property儲存手拖曳時在containerView裡的位置點
        let point = sender.location(in: self.containerView)
        //設定中心點為拖曳點
        text.center = point
    }
    
    //拖曳貼圖的function
    @objc func moveSticker(_ sender: UIPanGestureRecognizer){
        //宣告property儲存手拖曳時在containerView裡的位置點
        let point = sender.location(in: self.containerView)
        //設定中心點為拖曳點
        sticker.center = point
    }
    
    //縮放貼圖的function
    @objc func pinchSticker(_ sender: UIPinchGestureRecognizer){
        //當兩根手指的捏合狀態改變時
        if sender.state == .changed{
            //宣告property儲存縮放範圍
            let scale = sender.scale
            //宣告property儲存原本貼圖的外框bounds的寬度
            let w = sticker.bounds.size.width
            
            //讓縮放範圍為貼圖的寬為原本的寬的0.3~2倍
            if w * scale > w * 0.3 && w * scale <= w * 2{
                //等比例縮放貼圖
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
        //text field要開啟isUserInteractionEnabled，觸控才有反應
        text.isUserInteractionEnabled = true
        //將拖曳手勢加到text field上
        text.addGestureRecognizer(panFontGestureRecognizer)
        
        //設定拖曳手勢，用在移動貼圖
        let panStickerGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveSticker(_:)))
        //設定單點觸控拖曳
        panStickerGestureRecognizer.minimumNumberOfTouches = 1
        panStickerGestureRecognizer.maximumNumberOfTouches = 1
        sticker.isUserInteractionEnabled = true
        sticker.addGestureRecognizer(panStickerGestureRecognizer)
        
        //設定捏合手勢，用在縮放貼圖
        let pinchStickerGestureRecognzier = UIPinchGestureRecognizer(target: self, action: #selector(pinchSticker(_:)))
        //將捏合手勢加入貼圖中
        sticker.addGestureRecognizer(pinchStickerGestureRecognzier)

    }
    
    @IBAction func addFont(_ sender: Any) {
        adjustFontView.isHidden = false
        fontSizeButton.isSelected = true
        fontColorButton.isSelected = false
        fontSizeSlider.isHidden = false
        selectStickerView.isHidden = true
        //先判斷containerView中是否有文字，沒有的話才加入文字，有的話就不執行動作
        if containerView.subviews.contains(text) == false{
            //設定text field的相關屬性
            text.placeholder = "輸入文字" //提示字
            text.borderStyle = .none //外框風格
            text.textAlignment = .center //文字對齊方式
            text.font = UIFont.systemFont(ofSize: 20) //文字預設大小
            text.textColor = .black //文字顏色
            text.frame.size = CGSize(width: 200, height: 100) //text field外框大小
            text.allowsEditingTextAttributes = true //設定可編輯文字屬性（選取字之後會顯示可執行的動作）
            text.center = imageView.center //讓文字出現在image view的中間
            
            //加入text field到containerView中
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
        //設定貼圖的外框大小
        sticker.frame.size = CGSize(width: 100, height: 100)
        //圖片的顯示模式為AspectFit，才能完整顯示而且不改變圖片原本比例
        sticker.contentMode = .scaleAspectFit
        //讓圖片出現在imageView中間
        sticker.center = imageView.center
        //顯示的貼圖為點選的按鈕所對應的圖片名稱
        sticker.image = UIImage(named: "sticker-" + "\(sender.tag)")
        //把貼圖加到containerView中
        containerView.addSubview(sticker)
    }
    
    //水平翻轉
    @IBAction func mirrorRotate(_ sender: Any) {
        //mirrorNum除2餘1的時候，表示圖片未水平翻轉過，做水平翻轉
        if mirrorNum % 2 == 1{
            mirrorView.transform = CGAffineTransform(scaleX: -1, y: 1)
        //mirrorNum除2餘0的時候，表示圖片已經翻轉過，轉回圖片原本的方向
        }else if mirrorNum % 2 == 0{
            mirrorView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        //每做完一次翻轉mirrorNum就+1，以判斷圖片現在的狀態
        mirrorNum += 1
        
    }
    
    
    //向左旋轉90度
    @IBAction func turnLeft(_ sender: Any) {
        //mirrorNum除2餘1，表示照片沒有水平翻轉過，仍是原本的方向
        if mirrorNum % 2 == 1{
            //判斷照片旋轉幾次，轉3次會回到原本方向，所以turnNum等於1~3的時候，要向左旋轉
            if turnNum < 4{
                //旋轉角度乘以-1代表逆時針旋轉
                imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2 * -1 * CGFloat(turnNum))
            //turnNum等於4表示要轉回原本方向了，讓旋轉值值歸0
            }else if turnNum == 4{
                imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2 * 0)
                //讓turnNum等於0是因為最後會再+1，才會回到初始值
                turnNum = 0
            }
        //mirrorNum除2餘0，表示照片水平翻轉過，旋轉方向需改變
        }else if mirrorNum % 2 == 0{
            if turnNum < 4{
                //以照片視角來說，x軸顛倒，所以向右轉才是左轉
                imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2 * 1 * CGFloat(turnNum))
            }else if turnNum == 4{
                imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2 * 0)
                turnNum = 0
            }
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
              containerView.drawHierarchy(in: imageView.bounds, afterScreenUpdates: true)
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
