//
//  ViewController.swift
//  FrameIT
//
//  Created by Sara Babaei on 3/6/20.
//  Copyright © 2020 Sara Babaei. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var creationFrame: UIView!
    @IBOutlet weak var creationImageView: UIImageView!
    @IBOutlet weak var startOverButton: UIButton!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var colorContainer: UIView!
    @IBOutlet weak var shareButton: UIButton!
    
    var localImages = [UIImage].init()
    let defaults = UserDefaults.standard
    var colorSwatches = [ColorSwatch].init()
    var creation = Creation.init()
    
    var initialImageViewOffset = CGPoint()
    
    let colorUserDefaultsKey = "ColorIndex"
    var savedColorSwatchIndex: Int{
        get{
            let savedIndex = defaults.value(forKey: colorUserDefaultsKey)
            if savedIndex == nil{
                defaults.set(colorSwatches.count - 1, forKey: colorUserDefaultsKey)
            }
            return defaults.integer(forKey: colorUserDefaultsKey)
        }
        set{
            if newValue >= 0 && newValue < colorSwatches.count{
                defaults.set(newValue, forKey: colorUserDefaultsKey)
            }
        }
    }
    
    func collectLocalImageSet(){
        localImages.removeAll()
        let imageNames = ["Boats", "Car", "Crocodile", "Park", "TShirts"]
        for name in imageNames{
            if let image = UIImage.init(named: name){
                localImages.append(image)
            }
        }
    }
    
    func collectColors(){
        colorSwatches = [
            ColorSwatch.init(caption: "Ocean", color: UIColor.init(red: 44/255, green: 151/255, blue: 222/255, alpha: 1)),
            ColorSwatch.init(caption: "Shamrock", color: UIColor.init(red: 28/255, green: 188/255, blue: 100/255, alpha: 1)),
            ColorSwatch.init(caption: "Candy", color: UIColor.init(red: 221/255, green: 51/255, blue: 27/255, alpha: 1)),
            ColorSwatch.init(caption: "Violet", color: UIColor.init(red: 136/255, green: 20/255, blue: 221/255, alpha: 1)),
            ColorSwatch.init(caption: "Sunshine", color: UIColor.init(red: 242/255, green: 197/255, blue: 0/255, alpha: 1))
        ]
        if colorSwatches.count == colorContainer.subviews.count{
            for i in 0..<colorSwatches.count{
                colorContainer.subviews[i].backgroundColor = colorSwatches[i].color
            }
        }
    }
    
    func isCreative() -> Bool {
        if let img = creationImageView.image {
            return img != UIImage(named: "FrameIT-placeholder")
        }
        return false
    }
    
    @IBAction func startOver(_ sender: Any) {
        creation.reset(colorSwatch: colorSwatches[savedColorSwatchIndex])
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.creationImageView.transform = .identity
        }) {(success) in
            self.animateImageChange()
            
            self.creationFrame.backgroundColor = self.creation.colorSwatch.color
            self.colorLabel.text = self.creation.colorSwatch.caption
        }
    }
    
    func animateImageChange(){
        UIView.transition(with: self.creationImageView, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.creationImageView.image = self.creation.image
        }, completion: nil)
    }
    
    @IBAction func applyColor(_ sender: UIButton) {
        if let index = colorContainer.subviews.firstIndex(of: sender){
            creation.colorSwatch = colorSwatches[index]
            creationFrame.backgroundColor = creation.colorSwatch.color
            colorLabel.text = creation.colorSwatch.caption
        }
    }
    
    @IBAction func share(_ sender: Any) {
        if isCreative(){
            if let index = colorSwatches.firstIndex(where: {$0.caption == creation.colorSwatch.caption}) {
                savedColorSwatchIndex = index
            }
            
            displaySharingOption()
        }
    }
    
    func displaySharingOption(){
        let note = "I Framed IT!"
        let image = composeCreationImage()
        let items = [image as Any, note as Any]
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        
//        activityViewController.excludedActivityTypes = [UIActivityType.mail]
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    func composeCreationImage() -> UIImage{
        UIGraphicsBeginImageContextWithOptions(creationFrame.bounds.size, false, 0)
        creationFrame.drawHierarchy(in: creationFrame.bounds, afterScreenUpdates: true)
        let screnshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return screnshot
    }
    
    @IBAction func changeImage(_ sender: UITapGestureRecognizer) {
        displayImagePickingOptions()
    }
    
    
    func displayImagePickingOptions(){
        let alertController = UIAlertController(title: "Choose image", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take photo", style: .default){
            (action) in
            self.displayCamera()
        }
        alertController.addAction(cameraAction)
        
        let libraryAction = UIAlertAction(title: "Library pick", style: .default){
            (action) in
            self.displayLibrary()
        }
        alertController.addAction(libraryAction)
        
        let randomAction = UIAlertAction(title: "Random", style: .default){
            (action) in
            self.pickRandom()
        }
        alertController.addAction(randomAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){
            (action) in
            print("Canceling image picking - doing nothing in fact :)")
        }
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    func displayCamera(){
        let sourceType = UIImagePickerController.SourceType.camera
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            let noPermissionMessage = "Looks like FrameIT doesn't have access to your camera:( Please use Settings App on your device to permit FrameIT accessing your camera"

            switch status{
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {(granted) in
                    if granted{
                        self.presentImagePicker(sourceType: sourceType)
                    }
                    else{
                        self.troubleAlert(message: noPermissionMessage)
                    }
                })

            case .authorized:
                self.presentImagePicker(sourceType: sourceType)
            case .denied, .restricted:
                self.troubleAlert(message: noPermissionMessage)
            default:
                print("Anything")
            }
        }
        else{
            troubleAlert(message: "Sincere apologies, it looks like we can't access your camera library at this time")
        }
    }
    
    func displayLibrary(){
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let status = PHPhotoLibrary.authorizationStatus()
            let noPermissionMessage = "Looks like FrameIT have access to your photos:( Please use Settings App on your device to permit FrameIT accessing your library"
         
            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({(newStatus) in
                    if newStatus == .authorized{
                        self.presentImagePicker(sourceType: sourceType)
                    }
                    else {
                        self.troubleAlert(message: noPermissionMessage)
                    }
                })
            case .authorized:
                self.presentImagePicker(sourceType: sourceType)
            case .denied, .restricted:
                self.troubleAlert(message: noPermissionMessage)
            default:
                print("Anything")
            }
        }
        else{
            troubleAlert(message: "Sincere apologies, it looks like we can't access your photo library at this time")
        }
    }
    
    func presentImagePicker(sourceType: UIImagePickerController.SourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    func troubleAlert(message: String?){
        let alertController = UIAlertController(title: "Oops...", message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "Got it", style: .cancel)
        alertController.addAction(OKAction)
        present(alertController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //got an image
        picker.dismiss(animated: true, completion: nil)
        let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        processedPick(image: newImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //canceled
        picker.dismiss(animated: true, completion: nil)
    }
    
    func processedPick(image: UIImage?){
        if let newImage = image{
            creation.image = newImage
            animateImageChange()
        }
    }
    
    func pickRandom(){
        processedPick(image: randomImage())
    }
    
    func randomImage() -> UIImage?{
        let currentImage = creationImageView.image
        if localImages.count > 0{
            let randomIndex = Int(arc4random_uniform(UInt32(localImages.count)))
            let newImage = localImages[randomIndex]
            if newImage != currentImage{
                return newImage
            }
        }
        return nil
    }
    
    @objc func moveImageView(_ sender: UIPanGestureRecognizer){
        if !isCreative() {
            return
        }
        
        let transition = sender.translation(in: creationImageView.superview)

        if sender.state == .began{
            initialImageViewOffset = creationImageView.frame.origin
        }

        let position = CGPoint(x: transition.x + initialImageViewOffset.x - creationImageView.frame.origin.x, y: transition.y + initialImageViewOffset.y - creationImageView.frame.origin.y)

        creationImageView.transform = creationImageView.transform.translatedBy(x: position.x, y: position.y)
    }

    @objc func rotateImageView(_ sender: UIRotationGestureRecognizer){
        if !isCreative() {
            return
        }
        
        creationImageView.transform = creationImageView.transform.rotated(by: sender.rotation)
        sender.rotation = 0
    }

    @objc func scaleImageView(_ sender: UIPinchGestureRecognizer){
        if !isCreative() {
            return
        }
        
        creationImageView.transform = creationImageView.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        
        if gestureRecognizer.view != creationImageView{
            return false
        }

        if gestureRecognizer is UITapGestureRecognizer || otherGestureRecognizer is UITapGestureRecognizer ||
            gestureRecognizer is UIPanGestureRecognizer || otherGestureRecognizer is UIPanGestureRecognizer {
            return false
        }

        return true
    }
    
    func configure(){
        collectLocalImageSet()
        collectColors()
        
        creation.colorSwatch = colorSwatches[savedColorSwatchIndex]
        
        creationImageView.image = creation.image
        creationFrame.backgroundColor = creation.colorSwatch.color
        colorLabel.text = creation.colorSwatch.caption
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveImageView(_:)))
        panGestureRecognizer.delegate = self
        creationImageView.addGestureRecognizer(panGestureRecognizer)
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateImageView(_:)))
        rotationGestureRecognizer.delegate = self
        creationImageView.addGestureRecognizer(rotationGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(scaleImageView(_:)))
        pinchGestureRecognizer.delegate = self
        creationImageView.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configure()
    }
}
