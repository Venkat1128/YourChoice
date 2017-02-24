//
//  YCQuestionTableViewController.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 17/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import UIKit
protocol YCQuestionTableViewControllerDelegate{
    func selectedQuestion(question: String)
}
class YCQuestionTableViewController: UITableViewController {
    
    var questions = NSMutableArray()
    var delegate : YCQuestionTableViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        questions.add("Which one shoud I choose?")
        questions.add("Which is better?")
        questions.add("Whcih is the best place?")
        questions.add("Whcih one?")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return questions.count
    }
    
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "questionIdentifier", for: indexPath)
     cell.textLabel?.text = questions.object(at: indexPath.row) as? String
        cell.textLabel?.font = UIFont.systemFont(ofSize: 10)
     // Configure the cell...
     
     return cell
     }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.delegate != nil {
            self.delegate?.selectedQuestion(question: (questions.object(at: indexPath.row) as? String)!)
        }
    }
    
}
