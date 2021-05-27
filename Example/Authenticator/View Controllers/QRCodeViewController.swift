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
    static let qrWindowHeight: CGFloat = AppLayout.screenHeight * 0.284
    static let cornerRadius: CGFloat = 4.0
    static let cancelButtonTopOfset: CGFloat = AppLayout.screenHeight * 0.028
    static let cancelButtonLeftOffset: CGFloat = 16.0
    static let labelsStackViewTopOffset: CGFloat = AppLayout.screenHeight * 0.16
    static let stackViewSpacing: CGFloat = AppLayout.screenHeight * 0.009
}

protocol QRCodeViewControllerDelegate: class {
    func metadataReceived(data: String)
}

final class QRCodeViewController: BaseViewController {
    private var captureSession: AVCaptureSession!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var qrCodeFrameView: UIView?

    weak var delegate: QRCodeViewControllerDelegate?

    var shouldDismissClosure: (() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        requestCameraPermission()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let captureSession = self.captureSession else { return }

        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let captureSession = self.captureSession else { return }

        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    private func requestCameraPermission() {
        AVCaptureHelper.requestAccess(
            success: {
                self.instantiateSession()
                self.createOverlay()
                self.setupCancelButton()
                self.layout()
            },
            failure: {
                self.shouldDismissClosure?()
            }
        )
    }

    private func instantiateSession() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            showInfoAlert(
                withTitle: l10n(.somethingWentWrong),
                completion: {
                    self.dismiss(animated: true)
                }
            )
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

    private func setupCancelButton() {
        let cancelButton = UIButton()
        cancelButton.setTitle(l10n(.cancel), for: .normal)
        cancelButton.setTitleColor(.lightBlue, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)

        view.addSubview(cancelButton)

        cancelButton.top(to: view, view.safeAreaLayoutGuide.topAnchor, offset: Layout.cancelButtonTopOfset)
        cancelButton.left(to: view, offset: Layout.cancelButtonLeftOffset)
    }

    @objc private func cancelPressed() {
        dismiss(animated: true, completion: shouldDismissClosure)
    }

    private func labelsStackView() -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = l10n(.scanQrCode)
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 26.0, weight: .bold)
        titleLabel.textColor = .titleColor

        let descriptionLabel = UILabel()
        descriptionLabel.text = ConnectionsCollector.allConnections.isEmpty
            ? l10n(.scanQrFirstDescription) : l10n(.scanQrToTakeAnAction)
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = .systemFont(ofSize: 17.0, weight: .regular)
        descriptionLabel.textColor = .titleColor
        descriptionLabel.numberOfLines = 0

        let stackView = UIStackView(
            axis: .vertical,
            alignment: .fill,
            spacing: Layout.stackViewSpacing,
            distribution: .fillEqually
        )
        stackView.addArrangedSubviews(titleLabel, descriptionLabel)

        return stackView
    }
}

// MARK: - Layout
extension QRCodeViewController: Layoutable {
    func layout() {
        let stackView = labelsStackView()
        view.addSubview(stackView)

        stackView.width(view.width - 76.0)
        stackView.centerX(to: view)
        stackView.topToSuperview(offset: Layout.labelsStackViewTopOffset)
    }

    private func createOverlay() {
        let overlayView = UIView()
        overlayView.alpha = 0.6
        overlayView.backgroundColor = .backgroundColor
        overlayView.frame = view.frame

        view.addSubview(overlayView)

        let path = CGMutablePath()
        path.addRoundedRect(
            in: CGRect(
                x: (view.width - Layout.qrWindowHeight) / 2,
                y: (view.height - Layout.qrWindowHeight) / 2,
                width: Layout.qrWindowHeight,
                height: Layout.qrWindowHeight
            ),
            cornerWidth: Layout.cornerRadius,
            cornerHeight: Layout.cornerRadius
        )
        path.addRect(CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))

        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = .evenOdd

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
            dismiss(
                animated: true,
                completion: {
                    self.delegate?.metadataReceived(data: string)
                }
            )
        }
    }
}
