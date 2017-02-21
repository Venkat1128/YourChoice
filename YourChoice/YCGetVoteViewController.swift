//
//  YCGetVoteViewController.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 21/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import UIKit
protocol YCGetVoteViewControllerDelegate {
    func voteSelected(_ pageIndex: Int)
}

class YCGetVoteViewController: YCBaseViewController {

    static let Identifier = "YCGetVoteViewController"
    
    var pageIndex: Int!
    var pollPicture: UIImage?
    var voteSelected = false
    var isError = false
    var voteState = VoteState.disabled
    var delegate: YCGetVoteViewControllerDelegate?
    
    // MARK: - Interface builder outlets and actions.
    
    @IBOutlet weak var pollPictureImageView: UIImageView!
    @IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var voteButton: UIButton!
    @IBOutlet weak var imageUnavailableLabel: UILabel!
    @IBAction func vote(_ sender: UIButton) {
        voteSelected = !voteSelected
        voteButton.isSelected = voteSelected
        delegate?.voteSelected(pageIndex)
    }
    
    // MARK: - Lifecycle methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVoteButton()
        updatePollPicture()
    }
    
    // MARK: - Initialisation methods.
    
    func initVoteButton() {
        voteButton.setImage(UIImage(named: "TickNormal"), for: UIControlState())
        voteButton.setImage(UIImage(named: "TickSelected"), for: .selected)
        voteButton.setImage(UIImage(named: "TickSelected"), for: .highlighted)
        updateVoteButton()
    }
    
    // MARK: - Update methods.
    
    func updatePollPicture() {
        let loading = pollPicture == nil && !isError
        loading ? imageActivityIndicator.startAnimating() : imageActivityIndicator.stopAnimating()
        imageActivityIndicator.isHidden = !loading
        imageUnavailableLabel.isHidden = !isError
        pollPictureImageView.image = pollPicture
    }
    
    func updateVoteButton() {
        switch voteState {
        case VoteState.disabled:
            updateVoteButton(false, enabled: false, hidden: true)
        case VoteState.pending:
            updateVoteButton(false, enabled: true, hidden: false)
        case VoteState.cast(let pollOptionIndex):
            updateVoteButton(pageIndex == pollOptionIndex, enabled: false, hidden: false)
        }
    }
    
    func updateVoteButton(_ selected: Bool, enabled: Bool, hidden: Bool) {
        voteSelected = selected
        let normalImageNamed = voteSelected ? "TickSelected" : "TickNormal"
        voteButton.setImage(UIImage(named: normalImageNamed), for: UIControlState())
        voteButton.isSelected = voteSelected
        voteButton.isEnabled = enabled
        voteButton.isHidden = hidden
    }

}
