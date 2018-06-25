//
//  ProfessorSignIn.swift
//  Cs131
//
//  Created by Aaron Miller on 6/14/18.
//  Copyright © 2018 Aaron Miller. All rights reserved.
//

import UIKit

class ProfessorSignInVC: NetworkRequest, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var reminderView: UIView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var classNumberLabel: UILabel!
    @IBOutlet weak var classPicker: UIPickerView!
    
    lazy var classes:[String] = ["CSC 20", "CSC 131", "CSC 133", "CSC 135"]
    let key = Int(arc4random_uniform(8999) + 1000)
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reminderView.dropShadow()
        
        //don't want them tripping over each other
        let netSHA = NetworkRequest()
        netSHA.professorGetSHA()
        
        //do a completion handler instead
//        timer = Timer.(timeInterval: 1.0, target: self, selector: #selector(timedGet()), userInfo: nil, repeats: true)
        

        
        classNumberLabel.text = classes[0]
        self.hideKeyboardWhenTappedAround()
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        self.classPicker.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func checkIn(_ sender: Any) {
        //check if the fields are empty
        if usernameField.text! == "" ||
            passwordField.text! == "" {
            showAlert("Empty Field", message: "At least one of the text fields have not been filled out", action: "Ok")
        }
        //check with the server if the ID, class section, and key all line up
        else if usernameField.text! != "DNguyen" ||
            passwordField.text!.sha256().uppercased() != UserDefaults.standard.string(forKey: "sheetSHA256") {
            showAlert("Please try again", message: "The information entered does not match the credentials in the system", action: "Ok")
        } else {
            print(passwordField.text!.sha256().uppercased())
            UserDefaults.standard.set(usernameField.text, forKey: "professorUsername")
            UserDefaults.standard.set(classNumberLabel.text, forKey: "classSection")
            UserDefaults.standard.set(key, forKey: "randomKey")
            professorPOST(randomKey:key)
            //make sure the post for the new key went well
            self.performSegue(withIdentifier: "professorCheckInToReciept", sender: nil)
        }
    }
    
    @objc func timedGet(){
        professorGetClass(classNumber:classNumberLabel.text!)
    }
    
    
    //delegate for UITextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //delegate for UIPicker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return classes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return classes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        classNumberLabel.text! = classes[row]
    }

}

extension String {
    
    func sha256() -> String{
        if let stringData = self.data(using: String.Encoding.utf8) {
            return hexStringFromData(input: digest(input: stringData as NSData))
        }
        return ""
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
    
}

