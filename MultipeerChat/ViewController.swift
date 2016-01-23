//
//  ViewController.swift
//  MultipeerChat
//
//  Created by Maria  Isabel on 1/22/16.
//  Copyright © 2016 UPC. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import AVFoundation

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate {
    
    // create a sound ID, in this case its the tweet sound.
    let systemSoundID: SystemSoundID = 1003
    let serviceType = "multipeer-chat"
    var browser : MCBrowserViewController!
    var assistant : MCAdvertiserAssistant!
    var session : MCSession!
    var peerID: MCPeerID!

    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var chatView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        
        //create the browser ViewController with a unique service name
        self.browser = MCBrowserViewController(serviceType: serviceType, session: self.session)
        self.browser.delegate = self
        
        self.assistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: self.session)
        self.assistant.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendChat(sender: AnyObject) {
        
        let msg = self.messageField.text?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        
        do{
            try self.session.sendData(msg!, toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Unreliable)
            self.updateChat(self.messageField.text!, fromPeer: self.peerID)
            self.messageField.text = ""
        } catch{
            print("Error ocurred")
        }
    }
    
    func updateChat(text : String, fromPeer peerID: MCPeerID){
        var name : String
        
        switch(peerID){
        case self.peerID:
            name = "Me"
        default:
            name = peerID.displayName
            AudioServicesPlaySystemSound (systemSoundID)
        }
        
        let message = "\(name): \(text)\n"
        self.chatView.text = self.chatView.text + message
    }
    
    
    @IBAction func showBrowser(sender: AnyObject) {
        self.presentViewController(self.browser, animated: true, completion: nil)
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func session(session: MCSession, didReceiveData data : NSData, fromPeer peerID: MCPeerID){
        dispatch_async(dispatch_get_main_queue()){
            let msg = NSString(data: data, encoding: NSUTF8StringEncoding)
            self.updateChat(msg! as String, fromPeer: peerID)
        }
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    // The following methods do nothing, but the MCSessionDelegate protocol
    // requires that we implement them.
    func session(session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, withProgress progress: NSProgress)  {
            
            // Called when a peer starts sending a file to us
    }
    
    func session(session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        atURL localURL: NSURL, withError error: NSError?)  {
            // Called when a file has finished transferring from another peer
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream,
        withName streamName: String, fromPeer peerID: MCPeerID)  {
            // Called when a peer establishes a stream with us
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        switch state {
        case MCSessionState.Connected:
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.Connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.NotConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }

}

