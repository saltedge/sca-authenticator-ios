//
//  QRCodeViewController.swift
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2019 Salt Edge Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, version 3 or later.
//
//  This program is distributed in the hope that it will be useful, but
//  WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//  General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <http://www.gnu.org/licenses/>.
//
//  For the additional permissions granted for Salt Edge Authenticator
//  under Section 7 of the GNU General Public License see THIRD_PARTY_NOTICES.md
//

import UIKit
import AVFoundation
import AudioToolbox

private struct Layout {
    static let sideLength: CGFloat = UIScreen.main.bounds.width * 0.65
    static let cornerRadius: CGFloat = 20.0
    static let yOffset: CGFloat = 100.0
}

final class QRCodeViewController: UIViewController {
    private var captureSession: AVCaptureSession!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var qrCodeFrameView: UIView?

    var metadataReceived: ((UIViewController, String) ->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        instantiateSession()
        createOverlay(frame: view.frame)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    private func instantiateSession() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            captureSession = nil
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            captureSession = nil
            return
        }

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.frame = view.layer.bounds
        videoPreviewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(videoPreviewLayer)

        captureSession.startRunning()
    }

    private func setup() {
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: l10n(.cancel),
            style: .plain,
            target: self,
            action: #selector(cancelPressed)
        )
    }

    @objc private func cancelPressed() {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }

    private func createOverlay(frame: CGRect) {
        let overlayView = UIView()
        overlayView.alpha = 0.6
        overlayView.backgroundColor = UIColor.black
        overlayView.frame = frame
        view.addSubview(overlayView)

        let path = CGMutablePath()
        path.addRoundedRect(
            in: CGRect(
                x: view.center.x - (Layout.sideLength / 2),
                y: view.center.y - (Layout.sideLength / 2) - Layout.yOffset,
                width: Layout.sideLength,
                height: Layout.sideLength
            ),
            cornerWidth: Layout.cornerRadius,
            cornerHeight: Layout.cornerRadius
        )
        path.addRect(CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))

        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd

        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
        view.bringSubviewToFront(overlayView)
    }
}

extension QRCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        output.setMetadataObjectsDelegate(nil, queue: nil)

        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }

        guard let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else { return }

        if metadataObj.type == AVMetadataObject.ObjectType.qr,
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj) {
            qrCodeFrameView?.frame = barCodeObject.bounds

            guard let string = metadataObj.stringValue else {
                HapticFeedbackHelper.produceErrorFeedback()
                dismiss(animated: true)
                return
            }

            HapticFeedbackHelper.produceImpactFeedback(.heavy)
            self.metadataReceived?(self, string)
        }
    }
}
