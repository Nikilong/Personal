//
//  XMMetorMapViewController.swift
//  虾兽维度
//
//  Created by Niki on 18/4/15.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit

class XMMetorMapViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    var imgV = UIImageView()
    var pinchScale : CGFloat!
    // pan手势
    var panG : UIPanGestureRecognizer!
    // 缩放手势
    var pinG : UIPinchGestureRecognizer!
    
    // 地图路径
    let mapPath = NSHomeDirectory().appending("/Documents/map.png") as String
    
    // 地铁图下载url
    let urlMap = "http://cs.gzmtr.com/clkweb/doDownloadMap.do"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        imgV.backgroundColor = UIColor.clear
        imgV.frame = self.view.bounds
        imgV.contentMode = .scaleAspectFit
        view.addSubview(imgV)
        
        // 检查是否本地有缓存地图
        if (FileManager.default.fileExists(atPath: mapPath)){
            imgV.image = UIImage(contentsOfFile: mapPath)
        
        }else{
            // 异步下载图片
            downloadImage()
        }
    
        
        // 双击手势,用于恢复图片原状
        let doubleTapG = UITapGestureRecognizer.init(target: self, action: #selector(tapDouble(_ :)))
        doubleTapG.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapG)
        
        // 点击手势,用于隐藏导航条
        let tapG = UITapGestureRecognizer.init(target: self, action: #selector(tap(_ :)))
        // 解决单击和双击同时反应,优先处理双击
        tapG.require(toFail: doubleTapG)
        view.addGestureRecognizer(tapG)
        
        // 移动手势
        panG = UIPanGestureRecognizer.init(target: self, action: #selector(pan(_ :)))
        // 缩放手势
        pinG = UIPinchGestureRecognizer.init(target: self, action: #selector(pinch(_ :)))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openAlbum))
        let updateBtn = UIBarButtonItem(title: "更新", style: .plain, target: self , action: #selector(downloadImage))
        let saveBtn = UIBarButtonItem(title: "保存", style: .plain, target: self , action: #selector(saveToAlbum))
        self.navigationItem.rightBarButtonItems = [addBtn, updateBtn,saveBtn]
        
        let backBtn = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backBtn
        
    }

    //MARK:- 手势类方法
    func addGesture(){
        view.addGestureRecognizer(panG)
        view.addGestureRecognizer(pinG)
    }
    func removeGesture(){
        view.removeGestureRecognizer(panG)
        view.removeGestureRecognizer(pinG)
    }

    
    func pan(_ gest:UIPanGestureRecognizer){
        let point = gest.translation(in: view)
        if(gest.state == .began){
//            self.navigationController?.navigationBar.isHidden = true
        }else if(gest.state == .changed){
//            imgV.transform = imgV.transform.translatedBy(x: (self.imgV.frame.origin.x < 0) ? 0 : point.x, y:(self.imgV.frame.origin.y < 0) ? 0 : point.y)
            imgV.transform = imgV.transform.translatedBy(x: point.x, y: point.y)
            gest.setTranslation(CGPoint(), in: view)
        }else if(gest.state == .ended){
            
        }
    
    }
    
    func pinch(_ gest:UIPinchGestureRecognizer){
        if(gest.state == .began){
            pinchScale = gest.scale
//            self.navigationController?.navigationBar.isHidden = true
        }else if(gest.state == .changed){
            if (gest.scale > pinchScale){
                imgV.transform = imgV.transform.scaledBy(x:1.01, y: 1.01)
            }else{
                imgV.transform = imgV.transform.scaledBy(x:0.99, y: 0.99)
            }
            pinchScale = gest.scale
        }else if(gest.state == .ended){
            
        }
    
    }
    
    func tap(_ gest:UITapGestureRecognizer){
        if (self.navigationController?.navigationBar.isHidden == true){
            // 移除手势
            removeGesture()
            self.view.backgroundColor = UIColor.white
            self.navigationController?.navigationBar.isHidden = false
            
        }else{
            // 添加手势
            addGesture()
            self.view.backgroundColor = UIColor.black
            self.navigationController?.navigationBar.isHidden = true
        }
//        if(gest.state == .ended){
//            self.navigationController?.navigationBar.isHidden = !((self.navigationController?.navigationBar.isHidden)!)
//        }
        
    }
    
    func tapDouble(_ gest:UITapGestureRecognizer){
        
        if (self.navigationController?.navigationBar.isHidden == true){
            // 恢复图片,显示导航条
            removeGesture()
            self.view.backgroundColor = UIColor.white
            self.navigationController?.navigationBar.isHidden = false
            imgV.transform = CGAffineTransform.identity
            
        }else{
            // 隐藏导航条
            addGesture()
            self.view.backgroundColor = UIColor.black
            self.navigationController?.navigationBar.isHidden = true
            
            // 将双击的位置放大并居中
            let point = gest.location(in: self.view)
            let scale : CGFloat = 7
            self.imgV.transform = self.imgV.transform.translatedBy(x:(self.imgV.center.x - point.x) * scale , y: (self.imgV.center.y - point.y) * scale).scaledBy(x: scale, y: scale)
    
        }

    }
    
    //MARK:- 下载图片
    func downloadImage(){
        // 异步下载图片
        DispatchQueue.global().async {
            let url = URL(string:self.urlMap)
            let request = URLRequest(url:url!)
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                
                if (error == nil){
                    // 将图片写入沙盒
                    try! data?.write(to: URL(fileURLWithPath:self.mapPath))
                    
                    // 主线程更新ui
                    DispatchQueue.main.async {
                        
                        self.imgV.image = UIImage.init(data: data!)
                    }
                    
                }
                
            }) as URLSessionDataTask
            
            dataTask.resume()
        }
    }
    
    // MARK:导航栏按钮事件
    /// 返回
    func back() {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
//        if(self.navigationController != nil){
//        }else{
//        }
    }
    /// 打开相册
    func openAlbum(){
        if ((UIImagePickerController.availableMediaTypes(for:.photoLibrary)) != nil){
            let pickVC = UIImagePickerController()
            pickVC.delegate = self
            self.navigationController?.present(pickVC, animated: true, completion: nil)
        
        }
        
    }
    
    /// 保存到本地相册
    func saveToAlbum(){
//        let data = UIImageJPEGRepresentation(self.imgV.image!, 0.5)
        UIImageWriteToSavedPhotosAlbum(self.imgV.image!, nil, nil, nil)
    }
    
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // 选择完图片需要dismiss图片选择器
        picker.dismiss(animated: true, completion: (() -> Void)?{
            // 设置图片显示并且保存到本地
            let seleImg: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            self.imgV.image = seleImg
            
            // 保存到沙盒,并且不处理异常
            let data = UIImageJPEGRepresentation(seleImg, 0.5)
            try! data?.write(to: URL(fileURLWithPath:self.mapPath))
        
        
        })
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
