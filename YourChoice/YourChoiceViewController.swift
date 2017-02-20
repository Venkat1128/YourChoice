//
//  YourChoiceViewController.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 16/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import UIKit

class YourChoiceViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    let SegmentedControlIndexKey = "SegmentedControlIndex"
    
    let userDefaults = UserDefaults.standard
    let defaultCenter = NotificationCenter.default
    var polls = [Choice]()
    var pollsType = PollsType.myPolls
    var storedOffsets = [Int: CGFloat]()
    // MARK: - Interface builder outlets and actions.
    
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var tableViewActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableViewChoice: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentedControlAction(_ sender: Any) {
        addObserverForSegmentedContol(segmentedControl.selectedSegmentIndex)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewChoice.delegate = self
        tableViewChoice.dataSource = self
        updateTableViewState(TableViewState.loading)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        YCDataModel.signOut()
        dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return polls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let poll = polls[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: YCMainTableViewCell.Identifier, for: indexPath) as! YCMainTableViewCell
        configureCell(cell, poll: poll, rowIndex: indexPath.row)
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.cornerRadius = 10
        cell.contentView.backgroundColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? YCMainTableViewCell else { return }
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? YCMainTableViewCell else { return }
        
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }

    func configureCell(_ cell: YCMainTableViewCell, poll: Choice, rowIndex: Int) {
        cell.questionLabel.text = poll.question
        
        let profilePicture = YCDataModel.getProfilePicture(poll.profilePictureId, rowIndex: rowIndex)
        cell.profileImageView.image = profilePicture
    }
}
 // MARK: - Initialisation methods.
extension YourChoiceViewController{
    
    func addObservers() {
        let segmentedControlIndex = userDefaults.integer(forKey: SegmentedControlIndexKey)
        segmentedControl.selectedSegmentIndex = segmentedControlIndex
        addObserverForSegmentedContol(segmentedControlIndex)
        YCDataModel.addConnectionStateObserver()
        defaultCenter.addObserver(self, selector: #selector(getPollsCompleted(_:)), name: NSNotification.Name(rawValue: NotificationNames.GetPollsCompleted), object: nil)
        defaultCenter.addObserver(self, selector: #selector(photoDownloadCompleted(_:)), name: NSNotification.Name(rawValue: NotificationNames.PhotoDownloadCompleted), object: nil)
    }
    
    func removeObservers() {
        YCDataModel.removePollListObserver()
        YCDataModel.removeConnectionStateObserver()
        defaultCenter.removeObserver(self, name: NSNotification.Name(rawValue: NotificationNames.GetPollsCompleted), object: nil)
        defaultCenter.removeObserver(self, name: NSNotification.Name(rawValue: NotificationNames.PhotoDownloadCompleted), object: nil)
    }
}
// MARK: - REST response methods.
extension YourChoiceViewController{
    
    func getPollsCompleted(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            print(Error.UserInfoNoData)
            return
        }
        
        polls.removeAll()
        polls = userInfo[NotificationData.Polls] as! [Choice]
        tableViewChoice.reloadData()
        updateTableViewState(polls.count > 0 ? TableViewState.populated : TableViewState.empty)
    }
    
    func photoDownloadCompleted(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            print(Error.UserInfoNoData)
            return
        }
        
        let rowIndex = userInfo[NotificationData.RowIndex] as! Int
        let indexPath = IndexPath(row: rowIndex, section: 0)
        tableViewChoice.reloadRows(at: [indexPath], with: .none)
    }

}
// MARK: - Convenience methods.
extension YourChoiceViewController{
    
    func updateTableViewState(_ tableViewState: TableViewState) {
        emptyLabel.isHidden = TableViewState.empty != tableViewState
        tableViewActivityIndicator.isHidden = TableViewState.loading != tableViewState
        TableViewState.loading == tableViewState ? tableViewActivityIndicator.startAnimating() : tableViewActivityIndicator.stopAnimating()
    }
    
    func addObserverForSegmentedContol(_ index: Int) {
        userDefaults.set(index, forKey: SegmentedControlIndexKey)
        switch index {
        case PollsType.myPolls.rawValue:
            YCDataModel.addMyPollsListObserver()
        default:
            YCDataModel.addAllPollsListObserver()
        }
    }
}
//MARK:- Collectionview delegate and datasource
extension YourChoiceViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        return polls[ collectionView.tag].pollOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YCMainCollectionCell", for: indexPath) as! YCMainCollectionViewCell
        cell.setImageViewProperties()
        cell.contentView.backgroundColor = UIColor.white
        let poll = polls[collectionView.tag]
        let pollPictures = YCDataModel.getPollPictures(poll, isThumbnail: true, rowIndex: collectionView.tag)
        cell.imageView.image = pollPictures[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        let cellWidth = (width - 10) / 2
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
    }
}
