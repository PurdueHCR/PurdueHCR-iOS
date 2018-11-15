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
    @IBOutlet var qrImageView: UIImageView!
    @IBOutlet var linkDescriptionLabel: UILabel!
    @IBOutlet var qrCodeDescriptionTextView: UITextView!
    @IBOutlet var activateSwitch: UISwitch!
    @IBOutlet var archiveSwitch: UISwitch!
    @IBOutlet var saveToPhotosButton: UIButton!
    
    
    var qrImage:CIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateQRCode()
        if(link!.enabled){
            activateSwitch.setOn(true, animated: false)
        }
        linkDescriptionLabel.text = DataManager.sharedManager.getPointType(value: link!.pointTypeID).pointDescription
        qrCodeDescriptionTextView.text = link!.description
        qrCodeDescriptionTextView.isEditable = false
        qrCodeDescriptionTextView.layer.borderWidth = 1
        qrCodeDescriptionTextView.layer.borderColor = UIColor.black.cgColor
        activateSwitch.setOn(link!.enabled, animated: false)
        archiveSwitch.setOn(link!.archived, animated: false)
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = newBackButton
    }

    func generateQRCode(){
        let linkCode = "hcrpoint://addpoints/"+link!.id
        print(linkCode)
        let data = linkCode.data(using:String.Encoding.isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")
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
        saveToPhotosButton.isEnabled = false
        let context = CIContext(options: convertToOptionalCIContextOptionDictionary([convertFromCIContextOption(CIContextOption.useSoftwareRenderer):true]))
        let cgimg = context.createCGImage(qrImage!, from: qrImage!.extent)
        let uiimage = UIImage(cgImage: cgimg!)
        
        UIImageWriteToSavedPhotosAlbum(uiimage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil);
    }
    
    
    @IBAction func setActivationStatus(_ sender: UISwitch) {
        self.link!.enabled = sender.isOn
        DataManager.sharedManager.setLinkActivation(link: self.link!, withCompletion: {(err:Error?) in
            if(err == nil){
                if(self.link!.enabled){
                    self.notify(title: "Success", subtitle: "QR code is now active", style: .success)
                }
                else{
                    self.notify(title: "Success", subtitle: "QR code was deactivated", style: .success)
                }
            }
            else{
                sender.setOn(!sender.isOn, animated: true)
                self.link!.enabled = sender.isOn
                self.notify(title: "Failure", subtitle: "QR code status could not be set.", style: .danger)
            }
        })
    }
    
    @IBAction func setArchiveStatus(_ sender: UISwitch) {
        self.link!.archived = sender.isOn
        DataManager.sharedManager.setLinkArchived(link: self.link!, withCompletion: {(err:Error?) in
            if(err == nil){
                if(self.link!.archived){
                    self.notify(title: "Success", subtitle: "QR code is now archived.", style: .success)
                }
                else{
                    self.notify(title: "Success", subtitle: "QR code was unarchived.", style: .success)
                }
            }
            else{
                sender.setOn(!sender.isOn, animated: true)
                self.link!.archived = sender.isOn
                self.notify(title: "Failure", subtitle: "QR code could not be archived.", style: .danger)
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
        saveToPhotosButton.isEnabled = true
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalCIContextOptionDictionary(_ input: [String: Any]?) -> [CIContextOption: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (CIContextOption(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCIContextOption(_ input: CIContextOption) -> String {
	return input.rawValue
}
