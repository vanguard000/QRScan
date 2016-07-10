//
//  ViewController.swift
//  QRSample
//
//  Created by MacOS on 7/10/16.
//  Copyright © 2016 MacOS. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var msgLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        msgLabel.textColor = UIColor.whiteColor()
        msgLabel.font = UIFont.boldSystemFontOfSize(14)
        qr_scanning()
    }
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]
    //
    func qr_scanning(){
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do{
            //get instance ofthe avcapturedeviceInput class using the previousdevice object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            captureSession?.startRunning()
            
            view.bringSubviewToFront(msgLabel)
            
            qrCodeFrameView = UIView()
            if let qrCodeFrameView = qrCodeFrameView{
                qrCodeFrameView.layer.borderColor = UIColor.greenColor().CGColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
            
        }catch let error as NSError{
            print(error.localizedDescription)
            return
        }
    }
    
    //AVCapture delegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0{
            qrCodeFrameView?.frame = CGRectZero
            msgLabel.text = "No barcode/ QR code is detected"
            return
        }
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if supportedBarCodes.contains(metadataObj.type){
            if metadataObj.type == AVMetadataObjectTypeQRCode{
                let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj)
                qrCodeFrameView?.frame = barCodeObject!.bounds
                if metadataObj.stringValue != nil{
                    msgLabel.text = metadataObj.stringValue
                }
            }
        }
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

