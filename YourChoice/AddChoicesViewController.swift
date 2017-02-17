//
//  AddChoicesViewController.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 17/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import UIKit

class AddChoicesViewController: UIViewController {

    @IBOutlet weak var topInputView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
self.topInputView.layer.borderColor = UIColor.gray.cgColor
        self.topInputView.layer.borderWidth = 2
        self.topInputView.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
