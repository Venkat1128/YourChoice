//
//  YCRegistationViewController.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 15/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import UIKit
import SwiftValidator

class YCRegistationViewController: YCImagePickerViewController,UITextFieldDelegate,ValidationDelegate,UIGestureRecognizerDelegate {

    let validator = Validator()
    var uid: String?
    
    // MARK: - Interface builder outlets and actions.
    
    @IBOutlet weak var profilePictureImage: UIImageView!

    @IBOutlet weak var registerButton: UIButton!

    @IBOutlet weak var passwordValidationView: YCValidation!
    @IBOutlet weak var emailValidationView: YCValidation!
    @IBOutlet weak var usernameValidationView: YCValidation!
    @IBAction func registerAction(_ sender: Any) {
        validator.validate(self)
    }

    // MARK: - Lifecycle methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissKeyboardOnTap()
        initValidationViews()
        initValidationRules()
        initProfilePic()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
}
// MARK: - ValidationDelegate methods.
extension YCRegistationViewController{
    
    
    func validationSuccessful() {
        let username = usernameValidationView.inputTextField.text!
        let email = emailValidationView.inputTextField.text!
        let password = passwordValidationView.inputTextField.text!
        createUser(username, email: email, password: password, profilePicture: profilePictureImage.image)
    }
    
    func validationFailed(errors: [UITextField : ValidationError]) {
        for (_, error) in errors {
            error.errorLabel?.text = error.errorMessage
            error.errorLabel?.isHidden = false
        }
    }
    
    func handleValidation(_ textField: UITextField) {
        validator.validateField(textField: textField) { error in
            if let validationError = error {
                validationError.errorLabel!.isHidden = false
                validationError.errorLabel!.text = validationError.errorMessage
            }
        }
    }
    
    // MARK: - Initialisation methods.
    func initProfilePic(){
        let geastureRecogniser:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(YCRegistationViewController.setProfilePicture))
        geastureRecogniser.delegate = self
        profilePictureImage.addGestureRecognizer(geastureRecogniser)
        profilePictureImage.isUserInteractionEnabled = true
        profilePictureImage.layer.cornerRadius = profilePictureImage.frame.size.width / 2;
        profilePictureImage.clipsToBounds = true;
        profilePictureImage.layer.borderWidth = 3.0;
        profilePictureImage.layer.borderColor = UIColor.white.cgColor;
    }
    func setProfilePicture(){
        createImagePickerAlertController()
    }
    func initValidationViews() {
        usernameValidationView.initInputTextField(.default, returnKeyType: .next, spellCheckingType: .no, delegate: self, secureTextEntry: false)
        emailValidationView.initInputTextField(.emailAddress, returnKeyType: .next, spellCheckingType: .no, delegate: self, secureTextEntry: false)
        passwordValidationView.initInputTextField(.default, returnKeyType: .done, spellCheckingType: .no, delegate: self, secureTextEntry: true)
    }
    
    func initValidationRules() {
        // Register the username text field and validation rules.
        let usernameInputTextField = usernameValidationView.inputTextField
        let usernameErrorLabel = usernameValidationView.errorLabel
        let usernameRequiredRule = RequiredRule(message: Error.UsernameRequired)
        validator.registerField(usernameInputTextField!, errorLabel: usernameErrorLabel!, rules: [usernameRequiredRule])
        
        // Register the email text field and validation rules.
        let emailInputTextField = emailValidationView.inputTextField
        let emailErrorLabel = emailValidationView.errorLabel
        let emailRequiredRule = RequiredRule(message: Error.EmailRequired)
        let emailRule = EmailRule(message: Error.EmailInvalid)
        validator.registerField(emailInputTextField!, errorLabel: emailErrorLabel!, rules: [emailRequiredRule, emailRule])
        
        // Register the password text field and validation rules.
        let passwordInputTextField = passwordValidationView.inputTextField
        let passwordErrorLabel = passwordValidationView.errorLabel
        let passwordRequiredRule = RequiredRule(message: Error.PasswordRequired)
        let passwordRule = MinLengthRule(length: 8, message: Error.PasswordRule)
        validator.registerField(passwordInputTextField!, errorLabel: passwordErrorLabel!, rules: [passwordRequiredRule, passwordRule])
    }
    
    func addObservers() {
        defaultCenter.addObserver(self, selector: #selector(createUserCompleted(_:)), name: NSNotification.Name(rawValue: NotificationNames.CreateUserCompleted), object: nil)
    }
    
    func removeObservers() {
        defaultCenter.removeObserver(self, name: NSNotification.Name(rawValue: NotificationNames.CreateUserCompleted), object: nil)
    }

    // MARK: - UIImagePickerControllerDelegate and UINavigationControllerDelegate methods.
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            //profilePictureImage.setImage(pickedImage, for: UIControlState())
            profilePictureImage.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
 // MARK: - REST calls and response handler methods.
extension YCRegistationViewController{
    
    func createUser(_ username: String, email: String, password: String, profilePicture: UIImage?) {
        if YCDataModel.isConnectedToNetwork() {
            toggleRequestProgress(true)
            YCDataModel.createUserWithEmail(username, email: email, password: password, profilePicture: profilePicture)
        }
        else{
            createAlertController(Error.NetworkErrorTitle, message: Error.NetworkErrorMsg)
        }
    }
    
    func createUserCompleted(_ notification: Notification) {
        toggleRequestProgress(false)
        if let userInfo = notification.userInfo {
            let message = userInfo[NotificationData.Message] as! String
            createAlertController(Title.Error, message: message)
        } else {
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    func toggleRequestProgress(_ inProgress: Bool) {
        inProgress ? activityIndicatorUtils.showProgressView(view) : activityIndicatorUtils.hideProgressView()
        usernameValidationView.enabled = !inProgress
        emailValidationView.enabled = !inProgress
        passwordValidationView.enabled = !inProgress
        registerButton.isEnabled = !inProgress
    }
}
//MARK:- Textfeild delegate
extension YCRegistationViewController{
    func animateTextField(textField: UITextField, up: Bool)
    {
        let movementDistance:CGFloat = -100
        let movementDuration: Double = 0.3
        
        var movement:CGFloat = 0
        if up
        {
            movement = movementDistance
        }
        else
        {
            movement = -movementDistance
        }
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField == passwordValidationView.inputTextField) || (textField == emailValidationView.inputTextField) {
            self.animateTextField(textField: textField, up:false)
        }
        
        switch textField {
        case emailValidationView.inputTextField:
            emailValidationView.errorLabel.isHidden = true
            handleValidation(emailValidationView.inputTextField)
            break
        case passwordValidationView.inputTextField:
            passwordValidationView.errorLabel.isHidden = true
            handleValidation(passwordValidationView.inputTextField)
            break;
        case usernameValidationView.inputTextField:
            usernameValidationView.errorLabel.isHidden = true
            handleValidation(usernameValidationView.inputTextField)
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch textField {
        case usernameValidationView.inputTextField:
            emailValidationView.inputTextField.becomeFirstResponder()
            break
        case emailValidationView.inputTextField:
            passwordValidationView.inputTextField.becomeFirstResponder()
            break
        case passwordValidationView.inputTextField:
            dismissKeyboard()
            validator.validate(self)
            break
        default:
            break
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if (textField == passwordValidationView.inputTextField) || (textField == emailValidationView.inputTextField){
            self.animateTextField(textField: textField, up:true)
        }
    }
}
