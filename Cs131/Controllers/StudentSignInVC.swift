//
//  SignInViewController.swift
//  Cs131
//
//  Created by Aaron Miller on 6/1/18.
//  Copyright © 2018 Aaron Miller. All rights reserved.
//

import UIKit
import SVProgressHUD

class StudentSignInVC: StudentNetwork, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    
    @IBOutlet weak var studentIdText: UITextField!
    @IBOutlet weak var studentKeyText: UITextField!
    @IBOutlet weak var studentCommentText: UITextField!
    @IBOutlet weak var classPicker: UIPickerView!
    @IBOutlet weak var classNumberLabel: UILabel!
    lazy var classes:[String] = ["CSC 20", "CSC 130", "CSC 131", "CSC 133", "CSC 135"]
    var keys:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        classNumberLabel.text! = classes[0]
        self.hideKeyboardWhenTappedAround()
        self.studentKeyText.delegate = self
        self.classPicker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func checkStudentIn(_ sender: Any) {
        SVProgressHUD.show()
        studentGetSheet(classSection:classNumberLabel.text!, id:studentIdText.text!, key:studentKeyText.text!, comment:studentCommentText.text!)
        if Reachability.isConnectedToNetwork() {
            if studentIdText.text! == "" || studentKeyText.text! == "" {
                showAlert("Empty Field", message: "At least one of the text fields have not been filled out.", action: "Ok")
                enableScreen()
                SVProgressHUD.dismiss()
            } else { 
                studentIdText.isEnabled = false
                studentKeyText.isEnabled = false
                classPicker.isUserInteractionEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0){
                    if self.studIsCorrect() {
                        if self.studIsOnTime() {
                            self.studentPostX()
                            SVProgressHUD.dismiss()
                            self.performSegue(withIdentifier: "checkInToReceipt", sender: nil)
                        } else {
                            self.showAlert("Your late", message: "Check with your teacher for attendance.", action: "Ok")
                            self.enableScreen()
                            SVProgressHUD.dismiss()
                        }
                    } else {
                        self.enableScreen()
                        SVProgressHUD.dismiss()
                        self.showAlert("Wrong Id and Key", message: "please try again.", action: "Ok")
                    }
                }
            }
        } else {
            showAlert("No Network Connection", message: "Your device is not connected to a network.", action: "Ok")
            SVProgressHUD.dismiss()
        }
    }
    
    
    func enableScreen(){
        self.studentIdText.isEnabled = true
        self.studentKeyText.isEnabled = true
        self.classPicker.isUserInteractionEnabled = true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "checkInToReceipt" {
            let destinationVC = segue.destination as! StudentReceiptVC
            destinationVC.studentID = self.studentIdText.text!
            destinationVC.classSectionS = self.classNumberLabel.text!
//            destinationVC.studRows = self.studRows
//            destinationVC.studColPost = self.studColPost
//            destinationVC.studClassNumber = self.studClassNumber
        }
        

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



