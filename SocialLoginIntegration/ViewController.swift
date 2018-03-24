//
//  ViewController.swift
//  SocialLoginIntegration
//
//  Created by iPramodSinghRawat on 18/03/18.
//  Copyright © 2018 iPramodSinghRawat. All rights reserved.
//

import UIKit
import GoogleSignIn
import FacebookCore
import FacebookLogin
import FBSDKLoginKit

class ViewController: UIViewController, GIDSignInUIDelegate,GIDSignInDelegate,FBSDKLoginButtonDelegate{
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var signOutButton: UIButton!
    //@IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    //@IBOutlet weak var facebookLoginButton: UIButton!
    //var appDelegate:AppDelegate!
    
    @IBOutlet weak var fbLogInButton: FBSDKLoginButton!
    
    var logInType: String!
    
    var dict : [String : AnyObject]!

    override func viewDidLoad() {
        super.viewDidLoad()
        //creating button
        //fbLogInButton = LoginButton(readPermissions: [ .publicProfile ])
        //loginButton.center = view.center
        
        //adding it to view
        //view.addSubview(loginButton)
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        fbLogInButton.delegate = self
        //appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ViewController.receiveToggleAuthUINotification(_:)),
                                               name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
                                               object: nil)
        
        self.statusText.text = "Initialized Swift app..."
        self.toggleGoogleAuthUI()
        // Do any additional setup after loading the view, typically from a nib.
        
        /*
        self.fbLogInButton.addTarget(self, action: #selector(self.fbLoginButtonClicked), for: .touchUpInside)
        */

        //if the user is already logged in
        if let accessToken = FBSDKAccessToken.current(){
            self.toggleFBDataUI()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print("in ViewController \n ")
        print(user)
        
        /*
        let gUser = GIDSignIn.sharedInstance().currentUser
        print(gUser)
        */
        // ...
        let googleUserId = user.userID                  // For client-side use only!
        let googleUseridToken = user.authentication.idToken // Safe to send to the server
        let googleUserFullName = user.profile.name
        let googleUserGivenName = user.profile.givenName
        let googleUserFamilyName = user.profile.familyName
        let googleUseremail = user.profile.email
        let googleUserImageURL = user.profile.imageURL(withDimension: 200)
        
        print("\n userId: \(googleUserId)")
        print("\n idToken: \(googleUseridToken)")
        print("\n fullName: \(googleUserFullName)")
        print("\n givenName: \(googleUserGivenName)")
        print("\n familyName: \(googleUserFamilyName)")
        print("\n googleUseremail: \(googleUseremail)")
        print("\n googleUserImageURL: \(googleUserImageURL)")
        
        self.statusText.text = "Google User: "+"\n fullName: \(googleUserFullName)"+"\n givenName: \(googleUserGivenName)"+"\n familyName: \(googleUserFamilyName)"+"\n familyName: \(googleUserFamilyName)"+"\n googleUseremail: \(googleUseremail)"
        
        self.loadUserImage(catPictureURL: user.profile.imageURL(withDimension: 200))
        
        signInButton.isHidden = true
        signOutButton.isHidden = false
        fbLogInButton.isHidden = true
        //disconnectButton.isHidden = false
        self.logInType = "google"
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
        print(error)
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("User Logged In")
        self.toggleFBDataUI()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
        self.toggleFBDataUI()
    }
    
    /*note(Start): Google SignIn Functions */
    // [START signout_tapped]
    @IBAction func didTapSignOut(_ sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().disconnect()
        // [START_EXCLUDE silent]
        self.statusText.text = "Signed out."
        self.toggleGoogleAuthUI()
        // [END_EXCLUDE]
    }
    // [END signout_tapped]
    // [START disconnect_tapped]
    /*
    @IBAction func didTapDisconnect(_ sender: AnyObject) {
        // [START_EXCLUDE silent]
        toggleAuthUI()
        // [END_EXCLUDE]
    }
    */
    // [END disconnect_tapped]
    // [START toggle_auth]
    func toggleGoogleAuthUI() {
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            // Signed in
            //signInButton.isHidden = true
            //signOutButton.isHidden = false
            //disconnectButton.isHidden = false
            self.statusText.text = "User SignIn"
            
            //GIDSignIn.sharedInstance().signIn()
            GIDSignIn.sharedInstance().signInSilently()
            
        } else {
            signInButton.isHidden = false
            signOutButton.isHidden = true
            fbLogInButton.isHidden = false
            //disconnectButton.isHidden = true
            self.statusText.text = "Google SignIn"
            self.userImageView.image = nil
        }
        //self.toggleFBDataUI()
    }
    
    func loadUserImage(catPictureURL:URL){
        print("loadUserImage")
        print(catPictureURL)
        
        //let catPictureURL = appDelegate.googleUserImageURL! // We can force unwrap because we are 100% certain the constructor will not return nil in this case.

        // Creating a session object with the default configuration.
        // You can read more about it here https://developer.apple.com/reference/foundation/urlsessionconfiguration
        let session = URLSession(configuration: .default)
        // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
        let downloadPicTask = session.dataTask(with: catPictureURL) { (data, response, error) in
            // The download has finished.
            if let e = error {
                print("Error downloading cat picture: \(e)")
            } else {
                
                print("Loading ...")
                // No errors found.
                // It would be weird if we didn't have a response, so check for that too.
                if let res = response as? HTTPURLResponse {
                    print("Downloaded cat picture with response code \(res.statusCode)")
                    if let imageData = data {
                        // Finally convert that Data into an image and do what you wish with it.
                        let image = UIImage(data: imageData)
                        // Do something with your image.
                        DispatchQueue.main.async {
                            self.userImageView.image = image
                            /*
                            let image = UIImage(data: imageData as Data)
                            imageView.image = image
                            imageView.contentMode = UIViewContentMode.scaleAspectFit
                            self.view.addSubview(imageView)
                            */
                        }
                        
                        print("loading Image to imageview")
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        downloadPicTask.resume()
    }
    
    // [END toggle_auth]
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
                                                  object: nil)
    }
    
    @objc func receiveToggleAuthUINotification(_ notification: NSNotification) {
        if notification.name.rawValue == "ToggleAuthUINotification" {
            self.toggleGoogleAuthUI()
            if notification.userInfo != nil {
                guard let userInfo = notification.userInfo as? [String:String] else { return }
                self.statusText.text = userInfo["statusText"]!
            }
        }
    }
    
    @IBAction func fbLoginButtonClicked() {
        
        if let accessToken = AccessToken.current {
            print("Already Logged in - accessToken \(accessToken)")
            //self.graphRequestForME({ (result) in })
            self.toggleFBDataUI()
        }else{
            let loginManager = LoginManager()
            //loginManager.loginBehavior = LoginBehavior.native
            loginManager.logIn(readPermissions: [.publicProfile], viewController: self) { (loginResult) in
            //loginManager.logIn([ReadPermission.publicProfile], viewController: self) { loginResult in
                switch loginResult {
                case .failed(let error):
                    print(error)
                case .cancelled:
                    print("User cancelled login.")
                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                    self.toggleFBDataUI()
                }
            }
        }
        
    }
    
    //function is fetching the user data
    func toggleFBDataUI(){
        print("getFBUserData")
        
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    //print(result!)
                    print(self.dict)
                    
                    let fbUserId = self.dict["id"]
                    let fbUserName = self.dict["name"]
                    let fbUserEmail = self.dict["email"]
                    
                    print("\n fbUserId: \(fbUserId)")
                    print("\n fbUserName: \(fbUserName)")
                    print("\n fbUserEmail: \(fbUserEmail)")
                    
                    self.statusText.text = "Facebook User: "+"\n fbUserId: \(fbUserId)"+"\n fbUserName: \(fbUserName)"+"\n fbUserEmail: \(fbUserEmail)"
                    
                    //print("\n \n id \(self.dict["id"]) \n ")
                    let image = self.dict["picture"]  as! [String : AnyObject]
                    //print("\n \n ImageURL \(self.dict["picture"]!) \n ")
                    let imagedata = image["data"]  as! [String : AnyObject]
                    //print("\n \n imagedata \(imagedata["url"]) \n ")
                    var facebookProfileUrl = imagedata["url"] as! String
                    self.loadUserImage(catPictureURL:URL(string: facebookProfileUrl)!)
                    //self.statusText.text = "Facebook SignIn"
                    // print user data inside statusText
                    
                    self.logInType = "facebook"
                    self.signInButton.isHidden = true // google sigin buton
                }
            })
        }else{
            self.statusText.text = "Facebook SignIn Again."
            self.userImageView.image = nil
            self.signInButton.isHidden = false // google sigin buton
            self.signOutButton.isHidden = true
        }
        //self.toggleGoogleAuthUI()
    }
    
    
    /*note(Start): Google SignIn Functions */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

