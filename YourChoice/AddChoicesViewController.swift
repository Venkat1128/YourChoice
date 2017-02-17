//
//  AddChoicesViewController.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 17/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import UIKit
//MARK:- AddChoicesViewController
class AddChoicesViewController: YCImagePickerViewController,YCImageUpdateViewControllerDeleage,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextViewDelegate {
    
    @IBOutlet weak var hintButton: UIButton!
    //Intialization
    @IBOutlet weak var topInputView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var characherLimit: UILabel!
    @IBAction func AddChoicesAction(_ sender: Any) {
        // Check if the question has been completed.
        guard let question = questionTextView.text, question.characters.count > 0 else {
            createAlertController(Title.AddPollQuestion, message: Message.AddPollQuestion)
            return
        }
        
        // Check if the minimum number of pictures have been added.
        guard pollPictures.count > PollPictureMin else {
            createAlertController(Title.AddPollPictures, message: Message.AddPollPictures)
            return
        }
        
        addNewPoll(question)
        _ = navigationController?.popViewController(animated: true)
    }
    let PollPictureMax = 4
    let PollPictureMin = 2
    let QuestionCharacterLimit = 140
    let AddPhoto = "Add Photo"
    let FullScreenImageSegue = "FullScreenImageSegue"
    let DefaultQuestionText = "Question (140 character limit)"
    
    var selectedPictureIndex = 0
    var pollPictures = [UIImage?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialise the poll pictures array with a nil image.
        pollPictures.append(nil)
        
        questionTextView.delegate = self
        questionTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        self.configureUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == FullScreenImageSegue {
            let viewController = segue.destination as! YCImageUpdateViewController
            let pollPicture = sender as! UIImage
            viewController.image = pollPicture
            viewController.delegate = self
        }
    }
    func configureUI(){
        self.hintButton.contentMode = .center
        self.hintButton.imageView?.contentMode = .center
        self.topInputView.layer.borderColor = UIColor.gray.cgColor
        self.topInputView.layer.borderWidth = 2
        self.topInputView.layer.cornerRadius = 10
    }
    
}
//MARK:- Deleagte methods
extension AddChoicesViewController{
    // MARK: - UIImagePickerControllerDelegate and UINavigationControllerDelegate methods.
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            if pollPictures.count < PollPictureMax {
                pollPictures.insert(pickedImage, at: pollPictures.count - 1)
            } else {
                pollPictures[PollPictureMax - 1] = pickedImage
            }
        }
        picker.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
    // MARK: - FullScreenImageViewControllerDelegate method.
    
    func imageChanged(_ image: UIImage?) {
        if image == nil {
            // Check if the maximum number of images were selected.
            let hasReachedTotal = pollPictures.count == PollPictureMax && pollPictures[PollPictureMax - 1] != nil
            
            // Remove the deleted image from the image list.
            pollPictures.remove(at: selectedPictureIndex)
            if hasReachedTotal {
                // Append an empty image to the end of the list because the maximum number of images were selected.
                pollPictures.append(nil)
            }
        } else {
            pollPictures[selectedPictureIndex] = image
        }
        collectionView.reloadData()
    }
}
// MARK: - UICollectionViewDelegate, UICollectionViewDatasource and UICollectionViewDelegateFlowlayout methods.
extension AddChoicesViewController{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pollPictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddChoicesCollectionViewCell", for: indexPath) as! AddChoicesCollectionViewCell
        
        let pollPicture = pollPictures[indexPath.row]
        let isPollPicture = pollPicture != nil
        cell.imageView.backgroundColor = isPollPicture ? UIColor.white : UIColor.gray
        cell.imageView.image = pollPicture
        cell.imageView.isHidden = !isPollPicture
        cell.label.isHidden = isPollPicture
        cell.label.text = AddPhoto
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPictureIndex = indexPath.row
        guard let pollPicture = pollPictures[selectedPictureIndex] else {
            createImagePickerAlertController()
            return
        }
        
        // Instantiate full screen image view controller
        performSegue(withIdentifier: FullScreenImageSegue, sender: pollPicture)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        let cellWidth = (width - 10) / 2
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
  // MARK: - UITextViewDelegate methods.
extension AddChoicesViewController{
  
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == DefaultQuestionText {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = DefaultQuestionText
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if textView.text.characters.count < QuestionCharacterLimit || text == ""{
            self.characherLimit.text = "\(textView.text.characters.count)/140"
            return true
        }
        
        return false
    }
}
// MARK: - REST calls and response methods.
extension AddChoicesViewController{

    func addNewPoll(_ question: String) {
        var images = [UIImage]()
        for pollPicture in pollPictures {
            if let image = pollPicture {
                images.append(image)
            }
        }
        //YCDataModel.addPoll(question, images: images)
    }
}
