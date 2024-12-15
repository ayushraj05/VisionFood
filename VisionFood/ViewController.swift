//
//  ViewController.swift
//  VisionFood
//
//  Created by Ayush Rajpal on 13/12/24.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    @IBOutlet weak var imageView: UIImageView!
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedimage = info[.originalImage] as? UIImage{
            imageView.image = userPickedimage
            guard let ciImage = CIImage(image: userPickedimage) else {
                fatalError("Could not convert to CoreImage")
            }
            
            detect(image: ciImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage){
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else{
            fatalError("Loading Core ML model Failed")
        }
        
        let request = VNCoreMLRequest(model: model){ request, error in
            guard let results = request.results as? [VNClassificationObservation] else{
                fatalError("No results")
            }
            
            if let firstResult = results.first{
                if let range = firstResult.identifier.range(of: ",") {
                    let result = String(firstResult.identifier[..<range.lowerBound])
                    self.navigationController?.title = result
                    print(result)
                }
                else{
                    self.navigationController?.title = "Try Again"
                    print("error adding the most predicted item")
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    
    @IBAction func cameraPressed(_ sender: UIBarButtonItem){
        present(imagePicker, animated: true, completion: nil)
    }
}

