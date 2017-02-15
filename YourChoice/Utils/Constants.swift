//
//  Constants.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 14/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import Foundation

struct FirebaseConstants {
    static let Users = "users"
    static let Username = "username"
    static let ProfilePictureId = "profile_picture_id"
    static let VotedPolls = "voted_polls"
    
    static let Polls = "polls"
    static let Question = "question"
    static let UserId = "user_id"
    static let CreationDate = "creation_date"
    static let Closed = "closed"
    static let PhotosUploaded = "photos_uploaded"
    static let SelectedOption = "selected_option"
    static let PollOptions = "poll_options"
    static let PollPictureId = "poll_picture_id"
    static let PollPictureThumbnailId = "poll_picture_thumbnail_id"
    static let VoteCount = "vote_count"
    
    static let InfoConnected = ".info/connected"
    
    static let BucketProfilePictures = "profile_pictures"
    static let BucketPollPictures = "poll_pictures"
}
struct Button {
    static let Ok = "Ok"
    static let Cancel = "Cancel"
    static let Reset = "Reset"
    static let Camera = "Camera"
    static let PhotoLibrary = "Photo Library"
}
struct NotificationNames {
    static let AuthUserCompleted = "com.yourchoice.AuthUserCompleted"
    static let ResetPasswordForUserCompleted = "com.yourchoice.ResetPasswordForUserCompleted"
    static let CreateUserCompleted = "com.yourchoice.CreateUserCompleted"
    static let SetUserDetailsCompleted = "com.yourchoice.SetUserDetailsCompleted"
    static let GetPollsCompleted = "com.yourchoice.GetPollsCompleted"
    static let PhotoDownloadCompleted = "com.yourchoice.PhotoDownloadCompleted"
    static let GetPollOptionIndexCompleted = "com.yourchoice.GetPollOptionIndexCompleted"
}
struct NotificationData {
    static let Title = "Title"
    static let Message = "Message"
    static let Polls = "Polls"
    static let Photo = "Photo"
    static let RowIndex = "RowIndex"
    static let PollOptionIndex = "PollOptionIndex"
}

struct Title {
    static let ResetPassword = "Reset Password"
    static let PasswordReset = "Password Reset"
    static let Error = "Error"
    static let AddProfilePicture = "Add Profile Picture"
    static let AddPicture = "Add Picture"
    static let AddPollQuestion = "Add Question"
    static let AddPollPictures = "Add Pictures"
    static let NetworkError = "Network Error"
}
struct Placeholder {
    static let Email = "Email"
}
struct Message {
    static let EmailEnter = "Please enter your email."
    static let CheckEmailForPassword = "Please check your email to get your temporary password."
    static let AddPollQuestion = "Please add a question to the poll."
    static let AddPollPictures = "Please add a minimum of two pictures to the poll."
}
struct Error {
    static let EmailInvalid = "Invalid email address."
    static let EmailRequired = "Email is required."
    static let EmailTaken = "An account already exists for that email address."
    static let PasswordRequired = "Password is required."
    static let PasswordRule = "Must be at least 8 characters long."
    static let UsernameRequired = "Username is required."
    static let ErrorResettingPassword = "There was an error resetting your password."
    static let EmailInvalidTryAgain = "Invalid email address. Please try again."
    static let PasswordIncorrectTryAgain = "Incorrect password. Please try again."
    static let UserDoesNotExist = "That user does not exist. Please try again."
    static let UnexpectedError = "An unexpected error occured. Please try again."
    static let UnableToUploadProfilePicture = "Unable to upload profile picture. Would you like to try again?"
    static let UserInfoNoData = "No data passsed to user info!"
    static let UnableToDownloadImage = "Unable to download image."
}
