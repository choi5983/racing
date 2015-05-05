//
//  ViewController.swift
//  RacingGame
//
//  Created by Michael on 5/5/15.
//  Copyright (c) 2015 CodingDojo. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController, UITextFieldDelegate {

    weak var delegate: ViewController?
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var colorView: UIView!
    let backgroundColors: [UIColor] = [UIColor.blueColor(), UIColor.brownColor(), UIColor.blackColor(), UIColor.orangeColor(), UIColor.purpleColor(), UIColor.redColor(), UIColor.yellowColor()]
    var currentColorIndex = 0
    var player_name: NSMutableString = "Player "
    let manager = CMMotionManager()
    let socket = SocketIOClient(socketURL: "192.168.15.192:7777")
    
    @IBAction func editingChanged(sender: UITextField) {
        print(sender.text)
        socket.emit("nameChanged", ["name": sender.text])
    }
    
    @IBAction func growTapped(sender: UITapGestureRecognizer) {
        socket.emit("grow")
    }
    @IBAction func tapped(sender: UITapGestureRecognizer) {
        currentColorIndex++
        if(currentColorIndex >= backgroundColors.count) {
            currentColorIndex = 0
        }
        colorView.backgroundColor = backgroundColors[currentColorIndex%backgroundColors.count]
        socket.emit("backgroundChanged", ["backgroundColorIndex": currentColorIndex])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        nameLabel.delegate = self
       
        //change the player name
        let letters: NSString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        player_name.appendFormat("%C", letters.characterAtIndex(randomIntBetween(0, max: letters.length)))
        nameLabel.text = player_name as String
        
        //make socket connections!
        socket.connect()
        
        socket.on("connect") { data, ack in
            println("iOS::WE ARE USING SOCKETS!")
            if self.manager.deviceMotionAvailable {
                self.manager.deviceMotionUpdateInterval = 0.1
                self.manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
                    [weak self] (data: CMDeviceMotion!, error: NSError!) in
//                    println("Roll (y-direction): \(data.attitude.roll) Pitch (x-direction): \(data.attitude.pitch) Yaw: \(data.attitude.yaw)")
                    self!.socket.emit("angle", ["roll": data.attitude.roll, "pitch": data.attitude.pitch, "yaw": data.attitude.yaw])

                    //for now also send the background and the name
                    //refactor this later
                    self!.socket.emit("backgroundChanged", ["backgroundColorIndex": self!.currentColorIndex])
                    self!.socket.emit("nameChanged", ["name": self!.nameLabel.text])
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func randomIntBetween(min: Int, max: Int) -> Int{
        return Int(arc4random_uniform(UInt32(max-min+1)))+min
    }
    
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            var length = UInt32 (letters.length)
            var rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    


}

