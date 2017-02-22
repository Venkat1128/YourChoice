//
//  YCGetVotePageViewController.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 21/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import UIKit

class YCGetVotePageViewController: YCBaseViewController,UIPageViewControllerDelegate,UIPageViewControllerDataSource,YCGetVoteViewControllerDelegate {

    static let Identifier = "YCGetVotePageViewController"
    
    let NetworkTimeout: TimeInterval = 30
    
    var poll: Choice!
    var voteState = VoteState.disabled
    
    var networkTimer: Timer?
    var isError = false
    
    var pageViewController: UIPageViewController!
    
    var pollPictureThumbnails:[UIImage?]!
    var pollPictures: [UIImage?]!
    var votePollViewControllers = [UIViewController]()

    // MARK: - Interface builder outlets and actions.
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var thumbnailsStackView: UIStackView!
    @IBOutlet weak var pageViewControllerView: UIView!
    
    // MARK: - Lifecycle methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionLabel.text = poll.question
        initPollPictureButtons()
        initPageViewController()
        initVoteState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
        networkTimer?.invalidate()
    }
}
extension YCGetVotePageViewController{
    // MARK: - Initialisation methods.
    
    func initPollPictureButtons() {
        pollPictureThumbnails = YCDataModel.getPollPictures(poll, isThumbnail: true, rowIndex: nil)
        startNetworkTimer(pollPictureThumbnails)
        for (index, subview) in thumbnailsStackView.arrangedSubviews.enumerated() {
            // Check if there is an image for the current poll picture thumbnail
            let hasImage = index < pollPictureThumbnails.count
            if hasImage {
                let pollPictureThumbnail = pollPictureThumbnails[index]
                let image = pollPictureThumbnail != nil ? pollPictureThumbnail! : UIImage(named: "PollPicture")!
                updatePollPictureButton(subview, image: image, highlighted: index == 0)
            } else {
                subview.removeFromSuperview()
            }
        }
    }
    
    func initPageViewController() {
        pollPictures = YCDataModel.getPollPictures(poll, isThumbnail: false, rowIndex: 0)
        startNetworkTimer(pollPictures)
        pageViewController = storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.setViewControllers([viewControllerAtIndex(0)], direction: .forward, animated: true, completion: nil)
        pageViewController.view.frame = CGRect(x: 0, y: 0, width: pageViewControllerView.frame.width, height: pageViewControllerView.frame.height)
        
        addChildViewController(pageViewController)
        pageViewControllerView.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
    }
    
    func initVoteState() {
        if YCDataModel.getUserId() != poll.userId {
            YCDataModel.getPollOptionIndex(poll)
        } else {
            updatePollPictureButtonVotes()
        }
    }
    
    func addObservers() {
        defaultCenter.addObserver(self, selector: #selector(photoDownloadCompleted(_:)), name: NSNotification.Name(rawValue: NotificationNames.PhotoDownloadCompleted), object: nil)
        defaultCenter.addObserver(self, selector: #selector(getPollOptionIndexCompleted(_:)), name: NSNotification.Name(rawValue: NotificationNames.GetPollOptionIndexCompleted), object: nil)
    }
    
    func removeObservers() {
        defaultCenter.removeObserver(self, name: NSNotification.Name(rawValue: NotificationNames.PhotoDownloadCompleted), object: nil)
        defaultCenter.removeObserver(self, name: NSNotification.Name(rawValue: NotificationNames.GetPollOptionIndexCompleted), object: nil)
    }

}
// MARK: - REST calls and response methods.
extension YCGetVotePageViewController{
    
    func photoDownloadCompleted(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            print(Error.UserInfoNoData)
            return
        }
        
        networkTimer?.invalidate()
        let photo = userInfo[NotificationData.Photo] as! Photo
        let currentVotePollViewController = pageViewController.viewControllers![0] as! YCGetVoteViewController
        let pollPictureIndex = getPollPictureIndex(photo)
        
        if photo.isThumbnail {
            pollPictureThumbnails[pollPictureIndex] = photo.image
            let pollPictureButton = thumbnailsStackView.arrangedSubviews[pollPictureIndex] as! UIButton
            pollPictureButton.setBackgroundImage(photo.image, for: UIControlState())
        } else {
            pollPictures[pollPictureIndex] = photo.image
            let pageIndex = currentVotePollViewController.pageIndex
            if (pageIndex == pollPictureIndex) {
                currentVotePollViewController.pollPicture = photo.image
                currentVotePollViewController.updatePollPicture()
            }
        }
    }
    
    func getPollOptionIndexCompleted(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let pollOptionIndex = userInfo[NotificationData.PollOptionIndex] as! Int
            voteState = VoteState.cast(pollOptionIndex)
            updatePollPictureButtonVotes()
        } else {
            voteState = VoteState.pending
        }
        updateVotePollViewController()
    }
    
    // MARK: - Update methods.
    
    func updatePollPictureButtons(_ pollOptionIndex: Int) {
        for (index, subview) in thumbnailsStackView.arrangedSubviews.enumerated() {
            updatePollPictureButton(subview, image: nil, highlighted: index == pollOptionIndex)
        }
    }
    
    func updatePollPictureButton(_ subview: UIView, image: UIImage?, highlighted: Bool) {
        let pollPictureButton = subview as! UIButton
        pollPictureButton.isHighlighted = highlighted
        pollPictureButton.isEnabled = !highlighted
        if let image = image {
            pollPictureButton.setBackgroundImage(image, for: UIControlState())
        }
    }
    
    func updatePollPictureButtonVotes() {
        let voteCountTotal = getVoteCountTotal()
        for (index, subview) in thumbnailsStackView.arrangedSubviews.enumerated() {
            let pollOption = poll.pollOptions[index]
            let pollPictureButton = subview as! UIButton
            let title = getVotePercentage(pollOption.voteCount, voteCountTotal: voteCountTotal)
            pollPictureButton.setTitle(title, for: UIControlState())
        }
    }
    
    func updateVotePollViewController() {
        let votePollViewController = pageViewController.viewControllers?[0] as! YCGetVoteViewController
        votePollViewController.voteState = voteState
        votePollViewController.updateVoteButton()
    }

}
// MARK: - UIPageViewControllerDataSource and UIPageViewControllerDelegate methods.
extension YCGetVotePageViewController{
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let votePollViewController = viewController as! YCGetVoteViewController
        let pageIndex = votePollViewController.pageIndex - 1
        
        return viewControllerAtIndex(pageIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let votePollViewController = viewController as! YCGetVoteViewController
        let pageIndex = votePollViewController.pageIndex + 1
        
        return viewControllerAtIndex(pageIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let votePollViewController = pageViewController.viewControllers?[0] as! YCGetVoteViewController
            updatePollPictureButtons(votePollViewController.pageIndex)
        }
    }
    
    // MARK: - VotePollViewControllerDelegate methods.
    
    func voteSelected(_ pageIndex: Int) {
        YCDataModel.voteOnPoll(poll, pollOptionIndex: pageIndex)
        _ = navigationController?.popViewController(animated: true)
    }
}
 // MARK: - Convenience methods.
extension YCGetVotePageViewController{
    
    func viewControllerAtIndex(_ index: Int) -> YCGetVoteViewController {
        let pollOptions = poll.pollOptions
        
        var currentIndex = index
        if currentIndex < 0 {
            currentIndex = pollOptions.count - 1
        } else if currentIndex >= pollOptions.count {
            currentIndex = 0
        }
        
        let votePollViewController = storyboard?.instantiateViewController(withIdentifier: YCGetVoteViewController.Identifier) as! YCGetVoteViewController
        votePollViewController.pageIndex = currentIndex
        votePollViewController.pollPicture = pollPictures[currentIndex]
        votePollViewController.voteState = voteState
        votePollViewController.isError = isError
        votePollViewController.delegate = self
        
        return votePollViewController
    }
    
    func getPollPictureIndex(_ photo: Photo) -> Int {
        var pollPictureIndex = 0
        for (index, pollOption) in poll.pollOptions.enumerated() {
            let id = photo.isThumbnail ? pollOption.pollPictureThumbnailId : pollOption.pollPictureId
            if photo.id == id {
                pollPictureIndex = index
            }
        }
        
        return pollPictureIndex
    }
    
    func getVoteCountTotal() -> Int {
        var voteCountTotal = 0
        for pollOption in poll.pollOptions {
            voteCountTotal += pollOption.voteCount
        }
        
        return voteCountTotal
    }
    
    func getVotePercentage(_ voteCount: Int, voteCountTotal: Int) -> String {
        let voteCountFraction = voteCountTotal > 0 ? Float(voteCount) * 100 / Float(voteCountTotal) : 0.0
        return String(format: "%.0f", voteCountFraction) + "%"
    }
    
    func startNetworkTimer(_ images: [UIImage?]) {
        guard networkTimer == nil else {
            return
        }
        
        var imagesDownloading = false
        for image in images {
            if image == nil {
                imagesDownloading = true
                break
            }
        }
        
        guard imagesDownloading else {
            return
        }
        
        networkTimer = Timer.scheduledTimer(timeInterval: NetworkTimeout, target: self, selector: #selector(showNetworkAlertController), userInfo: nil, repeats: false)
    }
    
    func showNetworkAlertController() {
        if !isError {
            isError = true
            let currentVotePollViewController = pageViewController.viewControllers![0] as! YCGetVoteViewController
            currentVotePollViewController.isError = isError
            currentVotePollViewController.updatePollPicture()
            createAlertController(Title.NetworkError, message: Error.UnableToDownloadImage)
        }
    }

}
