//
//  StartLivenessService.swift
//  Runner
//
//  Created by Farhan Fadhilah on 13/03/24.
//

import Foundation
import vidaLiveness
import UIKit
import Flutter

private let apiKey = "b9vlxmTgut4D9cV6"
private let licenseKey = "b63e6572-a7e1-5cfa-a4d8-d2cee8be34d2"

class StartLivenessService {
    /// Customise the UI components for colors, font and font size, if required, using ``SDKUIComponentConfig``.
    private var sdkUIComponentConfig: SDKUIComponentConfig = SDKUIComponentConfig(
        tutorialScrBackgroundColor: UIColor.white,
        tutorialScrTextColor: UIColor.black,
        cameraPermissionScrBackgroundColor: UIColor.white,
        cameraPermissionScrTextColor: UIColor.black,
        primaryCTAConfig: CTAConfig(
            backgroundColor: UIColor(red: 0.35, green: 0.74, blue: 0.95, alpha: 1),
            textColor: UIColor.white,
            textFont: UIFont(name: "HelveticaNeue-Bold", size: 15.0)
        ),
        secondaryCTAConfig: CTAConfig(
            backgroundColor: UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1),
            textColor: UIColor.black,
            textFont: UIFont(name: "HelveticaNeue", size: 15.0)
        ),
        cameraPreviewScrBackgroundColor: UIColor.white,
        overlayShape: .square,
        overlayBackgroundColor: UIColor(white: 0, alpha: 0.7),
        overlayBorderColor: UIColor.white,
        overlayBorderWidth: 10,
        strokeBorderColor: UIColor.systemPink,
        cameraMessageTextColor: UIColor.black,
        cameraMessageFont: UIFont(name: "HelveticaNeue-Bold", size: 16.0),
        reviewScreenBackgroundColor: UIColor.white,
        reviewScreenTextColor: UIColor.black,
        reviewInstructionTextColor: UIColor(red: 0.617, green: 0.633, blue: 0.667, alpha: 1),
        reviewInstructionFont: UIFont(name: "HelveticaNeue", size: 15.0)
    )

    /// Customise the detection options, if required, using ``VIDAFaceDetectionOptions``.
    private var detectionOptions: VIDAFaceDetectionOptions = VIDAFaceDetectionOptions(
        detectionTimeout: 30,
        minimumStableFrame: 20,
        eyeOpenProbability: 0.4,
        enableActiveLiveness: true
    )

    private var vidaLiveness: VIDALiveness = VIDALiveness()

    public func startLivenessProcess() {
        let vidaLivenessRequest = VIDALivenessRequest()
        vidaLivenessRequest.apiKey = apiKey
        vidaLivenessRequest.licenseKey = licenseKey
        guard let app = UIApplication.shared.delegate as? AppDelegate, let window = app.window else {
            return
        }
        guard let navigationController = window.rootViewController as? UINavigationController else {
            return
        }
        vidaLiveness.initialize(
            vidaLivenessRequest: vidaLivenessRequest,
            sdkUIComponentConfig: sdkUIComponentConfig,
            detectionOptions: detectionOptions,
            shouldShowTutorialFlow: true, // Customise to show or not show the tutorial before liveness
            delegate: self,
            presentNavigationController: navigationController
        )
    }

    private func releaseVIDALiveness() {
            vidaLiveness.releaseSDK()
        }

}

extension StartLivenessService: VIDALivenessProtocol {
    func onError(errorCode: Int, errorMessage: String, response: VIDALivenessResponse) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let methodChannel = appDelegate.methodChannel else { return}

        // Call ``releaseVIDALiveness()`` to relase the liveness instance.
        self.releaseVIDALiveness()
        let message: String = "Liveness Status: Failure ❌ 😢\nReason: \(errorMessage)\nLiveness Score: \(response.livenessScore)\nManipulation Score: \(response.manipulationScore)"
        if let imageData = response.imageData, let image = UIImage(data: imageData) {
        methodChannel.invokeMethod("liveness_status", arguments: [
        "imageData": imageData,
         "value1": message
        ])
        } else {
           methodChannel.invokeMethod("liveness_status", arguments: [
            "imageData": Data(),
            "value1": message
        ])
        }
    }

    func onSuccess(response: VIDALivenessResponse) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let methodChannel = appDelegate.methodChannel else { return}
        // Call ``releaseVIDALiveness()`` to relase the liveness instance.
        self.releaseVIDALiveness()
        let message: String = "Liveness Status: Success ✅ 🥳\nLiveness Score: \(response.livenessScore)\nManipulation Score: \(response.manipulationScore)"
        if let imageData = response.imageData, let image = UIImage(data: imageData) {
        methodChannel.invokeMethod("liveness_status", arguments: [
        "imageData": imageData,
        "value1": message
        ])
        } else {
         methodChannel.invokeMethod("liveness_status", arguments: [
          "imageData": Data(),
         "value1": message
         ])
        }
    }

    func onInitialized() {
        vidaLiveness.startDetection()
    }
}

