//
//  ViewController.swift
//  ATGoogleDriveDemo
//
//  Created by Dejan on 09/04/2018.
//  Copyright © 2018 Dejan. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import  Foundation

class ViewController: UIViewController {
    
    @IBOutlet weak var resultsLabel: UILabel!
    
    fileprivate let service = GTLRDriveService()
    private var drive: ATGoogleDrive?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGoogleSignIn()
        
        drive = ATGoogleDrive(service)
        
    }
    
    private func setupGoogleSignIn() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeDriveFile]
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() == true {
            GIDSignIn.sharedInstance().signInSilently()
        }else {
            view.addSubview(GIDSignInButton())
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    // MARK: - Actions
    @IBAction func uploadAction(_ sender: Any) {
        if let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            let testFilePath = documentsDir.appendingPathComponent("logo.png").path
            drive?.uploadFile("customer image", filePath: testFilePath, MIMEType: "image/png") { (fileID, error) in
                print("Upload file ID: \(String(describing: fileID)); Error: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    @IBAction func listAction(_ sender: Any) {
        drive?.listFilesInFolder("customer image") { (files, error) in
            guard let fileList = files else {
                print("Error listing files: \(String(describing: error?.localizedDescription))")
                return
            }


            let str : String = (fileList.files?.description)!
            let split = str.components(separatedBy: "\"")
            self.resultsLabel.text =  "https://drive.google.com/file/d/" + split[3]
            
        }
    }
}

// MARK: - GIDSignInDelegate
extension ViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let _ = error {
            service.authorizer = nil
        } else {
            service.authorizer = user.authentication.fetcherAuthorizer()
        }
    }
}

// MARK: - GIDSignInUIDelegate
extension ViewController: GIDSignInUIDelegate {}
