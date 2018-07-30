//
//  QRCodeViewController.swift
//  Platinum Points
//
//  Created by Brian Johncox on 7/29/18.
//  Copyright © 2018 DecodeProgramming. All rights reserved.
//

import UIKit

class LinkCodeViewController: UIViewController {
    var link:Link?
    @IBOutlet var activateButton: UIButton!
    @IBOutlet var qrImageView: UIImageView!
    @IBOutlet var linkDescriptionLabel: UILabel!
    @IBOutlet var qrCodeDescriptionTextView: UITextView!
    
    var qrImage:CIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateQRCode()
        if(link!.enabled){
            activateButton.setTitle("Deactivate", for: .normal)
        }
        linkDescriptionLabel.text = DataManager.sharedManager.getPointType(value: link!.pointTypeID).pointDescription
        linkDescriptionLabel.layer.borderColor = UIColor.black.cgColor
        linkDescriptionLabel.layer.borderWidth = 1
        qrCodeDescriptionTextView.text = link!.description
        qrCodeDescriptionTextView.isEditable = false
        qrCodeDescriptionTextView.layer.borderWidth = 1
        qrCodeDescriptionTextView.layer.borderColor = UIColor.black.cgColor
        
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = newBackButton
    }

    func generateQRCode(){
        let data = link!.id.data(using:String.Encoding.isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        qrImage = filter?.outputImage
        let scaleX = qrImageView.frame.size.width / qrImage!.extent.size.width
        let scaleY = qrImageView.frame.size.height / qrImage!.extent.size.height
        qrImage = qrImage!.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        qrImageView.image = UIImage(ciImage: qrImage!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveToCameraRoll(_ sender: Any) {
        let context = CIContext(options: [kCIContextUseSoftwareRenderer:true])
        let cgimg = context.createCGImage(qrImage!, from: qrImage!.extent)
        let uiimage = UIImage(cgImage: cgimg!)
        
        UIImageWriteToSavedPhotosAlbum(uiimage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil);
    }
    
    @IBAction func setActivationStatus(_ sender: Any) {
        self.link!.enabled = !(self.link!.enabled)
        DataManager.sharedManager.setLinkActivation(link: self.link!, withCompletion: {(err:Error?) in
            if(err == nil){
                if(self.link!.enabled){
                    self.notify(title: "Success", subtitle: "QR code is now active", style: .success)
                    self.activateButton.setTitle("Deactivate", for: .normal)
                }
                else{
                    self.notify(title: "Success", subtitle: "QR code was deactivated", style: .success)
                    self.activateButton.setTitle("Activate", for: .normal)
                }
            }
            else{
                self.link!.enabled = !(self.link!.enabled)
                self.notify(title: "Failure", subtitle: "QR code status could not be set.", style: .danger)
            }
        })
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if (error != nil){
            // we got back an error!
            self.notify(title: "Failure", subtitle: "Failed to save the code.", style: .danger)
            print(error.debugDescription)
        } else {
            self.notify(title: "Success", subtitle: "Saved to Camera Roll.", style: .success)
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        // Perform your custom actions
        // ...
        // Go back to the previous ViewController
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
