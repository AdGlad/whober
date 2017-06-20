//
//  ViewController.swift
//  whober
//
//  Created by Adam Glasdstone on 6/6/17.
//  Copyright © 2017 swiftary. All rights reserved.
//

import UIKit
import os.log
import AWSCore
import AWSS3
import AWSCognito
import AWSLambda

let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.EUWest1, identityPoolId:"eu-west-1:b14e9e58-afca-44fe-a995-42b89826a1e3")
let configuration = AWSServiceConfiguration(region:.EUWest1, credentialsProvider:credentialsProvider)
let cognitoId = credentialsProvider.identityId


    var imageFileName = String()


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var requestId = String()
    var imageURL = NSURL()
    var userId = 123
    var faceId = String()
    var matchStatus = String()
    var localPath : String = String()
    var uploadFileURL = NSURL()
    var tempBucketName = "swiftarycelebritytemp"
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var matchStatusLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var surNameLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    

    
    
    
    var request: matchRequest?
    
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let fileManager = FileManager.default
         localPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("whober.jpg")
        
        print("localPath \(localPath)")
        let imageData = UIImageJPEGRepresentation(image, 0.1)
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
    self.surNameLabel.text="SurName"

        AWSServiceManager.default().defaultServiceConfiguration = configuration

                
    }

    
    
    @IBAction func recogniseButton(_ sender: Any) {
        
        self.activityIndicatorView.startAnimating()
        
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
            self.requestId = JSONDictionary["RequestId"] as! String
            
            print("Result: \(uploadOutput!)")
            print("Result: \(String(describing: JSONDictionary))")
            print("Result: \(JSONDictionary["ImageFile"]!)")
            print("imageFileName: \(imageFileName)")
            print("requestId: \(self.requestId)")
            
            let uploadToS3Status = self.uploadToS3Button()

            
            return nil
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

    
    func uploadToS3Button() -> String
    {
        let transferManager = AWSS3TransferManager.default()
        let uploadingFileURL = URL(fileURLWithPath: localPath)
        print ("uploadingFileURL \(uploadingFileURL)")
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.bucket = tempBucketName
        uploadRequest?.key = imageFileName
        uploadRequest?.body = uploadingFileURL as URL
        
        transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
         //   let fetchDetailsStatus  = self.fetchDetails()
            let MatchFaceStatus  = self.MatchFace()
            
            if let error = task.error as NSError? {
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
    return "Success"
    }
    
    func MatchFace() -> String {
        // Dispose of any resources that can be recreated.
        
        print ("userId \(userId)")
        print ("requestId \(requestId)")
        let lambdaInvoker = AWSLambdaInvoker.default()
        let jsonObject: [String: Any] = ["UserId" :  userId,"RequestId" : requestId, "Bucket" : tempBucketName, "ImageFile" : imageFileName]
        
        lambdaInvoker.invokeFunction("MatchFace_SWLD", jsonObject: jsonObject).continueWith(block: { (task:AWSTask) -> AnyObject? in
            if let error = task.error {
                print("\(error)")
                return nil
            }
            // Handle response in task.result
            let JSONDictionary = task.result as! NSDictionary
            let uploadOutput = task.result
            print("Result: \(uploadOutput!)")
            
            
            //'UserId'          : lv_UserId,
            //'RequestId'       : lv_RequestId,
            //'FaceId'          : lv_FaceId,
            //'EndDateTime'     : lv_DateTime,
            //'ExternalImageId' : lv_ExternalImageId ,
            //'FirstName'       : lv_FirstName      ,
            //'SurName'         : lv_SurName         ,
            //'MatchedFaceUrl'  : lv_MatchedFaceUrl ,
            //'Status'          : lv_Status,
            //'RequestStatus'   : lv_RequestStatus
            
            
            let firstName = JSONDictionary["FirstName"] as! String
            let surName = JSONDictionary["SurName"] as! String
            
            let RequestStatus = JSONDictionary["RequestStatus"] as! String
            
            print("firstName: \(firstName)")
            print("surName: \(surName)")
            print("RequestStatus: \(RequestStatus)")
    
            
            DispatchQueue.main.async(execute: {
                self.matchStatusLabel.text = "Matched"
                self.firstNameLabel.text = "\(firstName)"
                self.surNameLabel.text = "\(surName)"
                
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidesWhenStopped = true
                
            })
            return nil
        })
        return "Success"
    }
    
    
    func fetchDetails() -> String {
        // Dispose of any resources that can be recreated.
        
        print ("userId \(userId)")
        print ("requestId \(requestId)")
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
            let RequestStatus = JSONDictionary["RequestStatus"] as! String
            
            print("firstName: \(firstName)")
            print("surName: \(surName)")
            print("RequestStatus: \(RequestStatus)")
            
            
            
            DispatchQueue.main.async(execute: {
                self.matchStatusLabel.text = "Matched"
                self.firstNameLabel.text = "\(firstName)"
                self.surNameLabel.text = "\(surName)"
                
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidesWhenStopped = true
                
            })
            return nil
        })
            return "Success"
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Navigation
    
    
    // This method lets you configure a view controller before it's presented.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        super.prepare(for: segue, sender: sender)
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let matchstatus = matchStatusLabel.text ?? ""
        let firstName   = firstNameLabel.text ?? ""
        let surname     = surNameLabel.text ?? ""
        let photo       = ImageView.image
        
        request = matchRequest(userId: "123", requestId: requestId, photo: photo, matchStatus: matchstatus, firstName: firstName, surname: surname)
        
        
    }
    
}

