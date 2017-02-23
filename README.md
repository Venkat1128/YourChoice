# YourChoice
How to run the app?:

Checked out the code from https://github.com/Venkat1128/YourChoice you must open the YourChoice.xcworkspace file, not the YourChoice.xcworkspace.xcodeproj file. This is necessary for the project to use the Cocoapod dependencies that have been included with the project. Once the workspace has been opened you should be able to the build and run the project as usual.
Intended User Experience.

Summary: 
YourChoice is an app that helps people make difficult choices. For example, if someone can't decide which place they want to go for today's party they can use YourChoice to create a poll and ask other users to vote which place they think looks best. Once users have placed their votes, the poll creator can check what percentage of users voted for each option, allowing them to make more informed decisions.

Login and Registration:
When the user starts the app for the first time they will be required to log in with an email address and password. If they do not have an account they will first need to register by clicking on the "Register" button on the navigation bar of the login screen. On the registration screen, the user will need to enter a username, email address, and password. The user will also be able to select an optional profile picture. After all the registration details have been completed, the user can register. If the registration is successful, then the user will navigate to the home screen of the app.

Home Screen:
The home screen of the app displays a list of user choices. A segmented control appears below the navigation bar with two options: "My Choices” and "All Choices". The "My Choices" option will only display the currently signed in user's choices while "All Choices" displays all registered user's choices. A "Logout" button is provided on the left of the navigation bar. If the user clicks on the "Logout" button, they will navigate back to the login screen. A "+" button is visible on the right of the navigation bar and lets users create new choices. A user can select any choice in the Choices list to vote on that Choice.

Get a Vote:
On the get a vote creation screen, the user needs to provide a question within a 140 character limit or select from predefined questions from the hint drop-down menu on the right of the text field and also provide between 2-4 images. The user cannot add more than four images. The user adds new images by tapping on the "Add Photo" button. Each photo selected by the user will be displayed in a collection view on the screen. The user can change or delete any of the selected photos by clicking on one of the items in the collection view. When the user is ready to create the poll they can click on the "Add Choice” button. After the "Add Choice” button is clicked the user will navigate back to the Home screen and the choices will be displayed at the top of the choice list.

Voting on a choice:
When the user selects a choice from the choice list (tap on any collection view cell also will navigate to voting screen), they will navigate to the voting screen. The voting screen lets the user horizontally scroll through all the images submitted for that poll. The screen contains the poll question, the thumbnails for all the images, the currently displayed image and a button for casting a vote. When the user scrolls through the images, the thumbnails will be highlighted appropriately to indicate which image in the list is being viewed. If the user has selected one of their own polls, the percentage of votes for each option will be displayed inside the thumbnails. Voting will also be disabled in this case. If the user selects a choice they have not voted on, then the voting buttons will be enabled at the bottom of the screen. Once they select one of the options they will navigate back to the home screen. If they view a choice where they have already voted, then they will be able to see the percentage of votes for each option, as well as the option they voted for. They will not be able to vote again as the voting button will be disabled.

General:
The app aims to make the user experience as simple as possible.  All the data and images are synchronized in the background without blocking the user from using the app. If network connectivity is lost, the user will be able to continue using the app as usual. When the app regains connectivity all the data and images will be uploaded in the background.
