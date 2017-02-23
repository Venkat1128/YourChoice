//
//  YCLoginViewController.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 14/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import UIKit
import SwiftValidator
class YCLoginViewController: YCBaseViewController,UITextFieldDelegate,ValidationDelegate {
    
    let validator = Validator()
    
    var emailResetPasswordTextField: UITextField?
    
    // MARK: - Interface builder outlets and actions.
    @IBOutlet weak var emailValidationView: YCValidation!
    @IBOutlet weak var passwordValidationView: YCValidation!
    @IBOutlet weak var registerBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    //MARK:- Login Action
    @IBAction func LoginAction(_ sender: Any) {
        validator.validate(self)
    }
    //MARK:- Reset Password
    @IBAction func resetPassword(_ sender: Any) {
        alertController = YCUtils.createAlertController(Title.ResetPassword, message: Message.EmailEnter, okButtonName: Button.Reset, noButtonName: Button.Cancel, positiveButtonAction: resetPasswordHandler, negativeButtonAction: nil, textFieldHandler: emailTextFieldConfiguration)
        present(alertController!, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardOnTap()
        initValidationViews()
        initValidationRules()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        YCDataModel.authUser() { isCurrentUser in
            if isCurrentUser {
                self.toggleRequestProgress(true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    
    // MARK: - ValidationDelegate methods.
    
    func validationSuccessful() {
        let email = emailValidationView.inputTextField.text!
        let password = passwordValidationView.inputTextField.text!
        authUser(email, password: password)
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
    
    func initValidationViews() {
        emailValidationView.initInputTextField(.emailAddress, returnKeyType: .next, spellCheckingType: .no, delegate: self, secureTextEntry: false)
        passwordValidationView.initInputTextField(.default, returnKeyType: .done, spellCheckingType: .no, delegate: self, secureTextEntry: true)
    }
    
    func initValidationRules() {
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
        validator.registerField(passwordInputTextField!, errorLabel: passwordErrorLabel!, rules: [passwordRequiredRule])
    }
    func addObservers() {
        defaultCenter.addObserver(self, selector: #selector(authUserCompleted(_:)), name: NSNotification.Name(rawValue: NotificationNames.AuthUserCompleted), object: nil)
        defaultCenter.addObserver(self, selector: #selector(resetPasswordForUserCompleted(_:)), name: NSNotification.Name(rawValue: NotificationNames.ResetPasswordForUserCompleted), object: nil)
    }
    
    func removeObservers() {
        defaultCenter.removeObserver(self, name: NSNotification.Name(rawValue: NotificationNames.AuthUserCompleted), object: nil)
        defaultCenter.removeObserver(self, name: NSNotification.Name(rawValue: NotificationNames.ResetPasswordForUserCompleted), object: nil)
    }
    // MARK: - Reset password configuration and handler.
    
    func resetPasswordHandler(_ alertAction: UIAlertAction) {
        let email = emailResetPasswordTextField!.text!
        resetPasswordForUser(email)
    }
    
    func emailTextFieldConfiguration(_ textField: UITextField) {
        emailResetPasswordTextField = textField
        emailResetPasswordTextField!.placeholder = Placeholder.Email
    }
    
    // MARK: - REST calls and response methods.
    
    func authUser(_ email: String, password: String) {
        if YCDataModel.isConnectedToNetwork() {
            toggleRequestProgress(true)
            YCDataModel.signInWithEmail(email, password: password)
        }
        else{
            createAlertController(Error.NetworkErrorTitle, message: Error.NetworkErrorMsg)
        }
    }
    
    func resetPasswordForUser(_ email: String) {
        
        if YCDataModel.isConnectedToNetwork() {
            toggleRequestProgress(true)
            YCDataModel.resetPasswordWithEmail(email)
        }
        else{
            createAlertController(Error.NetworkErrorTitle, message: Error.NetworkErrorMsg)
        }
        
    }
    
    func authUserCompleted(_ notification: Notification) {
        toggleRequestProgress(false)
        if let userInfo = notification.userInfo {
            let message = userInfo[NotificationData.Message] as! String
            createAlertController(Title.Error, message: message)
        } else {
            clearValidationViews()
            let mainNavigationController = navigationController!.storyboard!.instantiateViewController(withIdentifier: "MainNavigationController")
            navigationController!.present(mainNavigationController, animated: true, completion: nil)
        }
    }
    
    func resetPasswordForUserCompleted(_ notification: Notification) {
        toggleRequestProgress(false)
        guard let userInfo = notification.userInfo else {
            print(Error.UserInfoNoData)
            return
        }
        
        let title = userInfo[NotificationData.Title] as! String
        let message = userInfo[NotificationData.Message] as! String
        
        createAlertController(title, message: message)
    }

    // MARK: - Convenience methods.
    
    func toggleRequestProgress(_ inProgress: Bool) {
        inProgress ? activityIndicatorUtils.showProgressView(view) : activityIndicatorUtils.hideProgressView()
        emailValidationView.enabled = !inProgress
        passwordValidationView.enabled = !inProgress
        registerBarButtonItem.isEnabled = !inProgress
        loginButton.isEnabled = !inProgress
        resetPasswordButton.isEnabled = !inProgress
    }
    
    func clearValidationViews() {
        emailValidationView.inputTextField.text = ""
        passwordValidationView.inputTextField.text = ""
    }
    // MARK: - UITextFieldDelegate methods.
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case emailValidationView.inputTextField:
            emailValidationView.errorLabel.isHidden = true
            handleValidation(emailValidationView.inputTextField)
            break
        case passwordValidationView.inputTextField:
            passwordValidationView.errorLabel.isHidden = true
            handleValidation(passwordValidationView.inputTextField)
            break;
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch textField {
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
}
