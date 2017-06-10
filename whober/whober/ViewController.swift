//
//  ViewController.swift
//  whober
//
//  Created by Adam Glasdstone on 6/6/17.
//  Copyright © 2017 swiftary. All rights reserved.
//

import UIKit
import AWSCore
import AWSS3
import AWSCognito
import AWSLambda

let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.EUWest1, identityPoolId:"eu-west-1:b14e9e58-afca-44fe-a995-42b89826a1e3")
let configuration = AWSServiceConfiguration(region:.EUWest1, credentialsProvider:credentialsProvider)
let cognitoId = credentialsProvider.identityId

    var requestId = String()
    var imageFileName = String()

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
    var imageURL = NSURL()
    var userId = 112
    var faceId = String()
    var matchStatus = String()
    var localPath : String = String()
    var uploadFileURL = NSURL()
    
    
    @IBOutlet weak var ImageView: UIImageView!
    
    @IBOutlet weak var matchStatusLabel: UILabel!
    
    @IBOutlet weak var firstNameLabel: UILabel!
    
    @IBOutlet weak var surNameLabel: UILabel!
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        
        let fileManager = FileManager.default
         localPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("whober.jpg")
        
        print("localPath \(localPath)")
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        fileManager.createFile(atPath: localPath as String, contents: imageData, attributes: nil)
        
        let imagePAth = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("whober.jpg")
        
                print("imagePAth \(imagePAth)")
        
        ImageView.image = UIImage(contentsOfFile: imagePAth)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
   override func viewDidLoad() {
        super.viewDidLoad()
    self.matchStatusLabel.text="Match Status"
    self.firstNameLabel.text="First Name"
    self.surNameLabel.text="Sur Name"

        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
    
                
    }

    
    @IBAction func uploadToS3Button(_ sender: Any) {
        let transferManager = AWSS3TransferManager.default()
        
        let uploadingFileURL = URL(fileURLWithPath: localPath)
        
        print ("uploadingFileURL \(uploadingFileURL)")
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        
        uploadRequest?.bucket = "swiftarycelebritytemp"
        uploadRequest?.key = imageFileName
        uploadRequest?.body = uploadingFileURL as URL
        
        transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            if let error = task.error as? NSError {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: (error.code)) {
                    switch code {
                    case .cancelled, .paused:
                        break
                    default:
                        print("Error uploading: \(uploadRequest?.key) Error: \(error)")
                    }
                }
                else {
                    print("Error uploading: \(uploadRequest?.key) Error: \(error)")
                }
                return nil
            }
            
            let uploadOutput = task.result
            print("Upload complete for: \(uploadRequest?.key)")
            return nil
        })
        
        
    }
    
    @IBAction func recogniseButton(_ sender: Any) {
        // Dispose of any resources that can be recreated.
        let lambdaInvoker = AWSLambdaInvoker.default()
        let jsonObject: [String: Any] = ["UserId" :  userId]
        //let jsonObject: [String: Any] = ["UserId" :  "\(String(describing: cognitoId))"]
        
        print("cognitoId: \(String(describing: cognitoId))")
        lambdaInvoker.invokeFunction("InsertRequest_SWLD", jsonObject: jsonObject).continueWith(block: { (task:AWSTask) -> AnyObject? in
            if let error = task.error {
                print("\(error)")
                return nil
            }
            
            // Handle response in task.result
            let JSONDictionary = task.result as! NSDictionary
            let uploadOutput = task.result
            imageFileName = JSONDictionary["ImageFile"] as! String
            requestId = JSONDictionary["RequestId"] as! String
            
            print("Result: \(uploadOutput!)")
            print("Result: \(String(describing: JSONDictionary))")
            print("Result: \(JSONDictionary["ImageFile"]!)")
            print("imageFileName: \(imageFileName)")
            print("requestId: \(requestId)")
            return nil
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func fetchDetailsButton(_ sender: UIButton) {
        // Dispose of any resources that can be recreated.
        let lambdaInvoker = AWSLambdaInvoker.default()
        let jsonObject: [String: Any] = ["UserId" :  userId,"RequestId" : requestId]
        
        lambdaInvoker.invokeFunction("FetchRequestDetails_SWLD", jsonObject: jsonObject).continueWith(block: { (task:AWSTask) -> AnyObject? in
            if let error = task.error {
                print("\(error)")
                return nil
            }
            // Handle response in task.result
            let JSONDictionary = task.result as! NSDictionary
            let uploadOutput = task.result
            print("Result: \(uploadOutput!)")

            let firstName = JSONDictionary["Firstname"] as! String
            let surName = JSONDictionary["SurName"] as! String
            let requestStatus = JSONDictionary["Request_Status"] as! String
            
            print("firstName: \(firstName)")
            print("surName: \(surName)")
            print("requestStatus: \(requestStatus)")
            
            DispatchQueue.main.async(execute: {
                self.matchStatusLabel.text = "Matched"
                self.firstNameLabel.text = "\(firstName)"
                self.surNameLabel.text = "\(surName)"
                
            })
            
            self.surNameLabel.text=surName
            
            
            return nil
        })
        
    }
    
    @IBAction func chooseImages(_ sender: UIButton) {
        
    let imagePickerController = UIImagePickerController()
        
    imagePickerController.delegate = self
        
    let actionSheet = UIAlertController(title: "Photo Source", message: "Choose A Source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action:UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera)
            {
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
            } else {
                print("Camera not available")
            }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {(action:UIAlertAction) in
            
            imagePickerController.sourceType = .photoLibrary
            
            self.present(imagePickerController, animated: true, completion: nil)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
        
        
        
    }

    @IBAction func UpdateRequestButton(_ sender: UIButton) {
        // Dispose of any resources that can be recreated.
        let lambdaInvoker = AWSLambdaInvoker.default()
        let jsonObject: [String: Any] = ["UserId" :  userId,"RequestId" : requestId,"FaceId"    :    "", "Status"    :    "ImageUploaded"]
        
        lambdaInvoker.invokeFunction("UpdateRequest_SWLD", jsonObject: jsonObject).continueWith(block: { (task:AWSTask) -> AnyObject? in
            if let error = task.error {
                print("\(error)")
                return nil
            }
            // Handle response in task.result
            let JSONDictionary = task.result as! NSDictionary
            let uploadOutput = task.result
            print("Result: \(uploadOutput!)")
            print("Result: \(String(describing: JSONDictionary))")
            print("Result: \(JSONDictionary["ImageFile"]!)")
            imageFileName = JSONDictionary["ImageFile"] as! String
            requestId = JSONDictionary["RequestId"] as! String
            print("imageFileName: \(imageFileName)")
            return nil
        })
        
    }

}

