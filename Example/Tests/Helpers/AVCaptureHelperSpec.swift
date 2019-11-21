//
//  AVCaptureHelperSpec
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

import Quick
import Nimble
import AVFoundation

private class FakeAVCaptureDevice: AVCaptureDevice {
    static var status: AVAuthorizationStatus?

    override class func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus {
        return status!
    }

    override class func requestAccess(for mediaType: AVMediaType, completionHandler handler: @escaping (Bool) -> Void) {
        if self.status == .authorized {
            handler(true)
        } else {
            handler(false)
        }
    }

    static func setAuthorizationStatus(status: AVAuthorizationStatus) {
        self.status = status
    }
}

class AVCaptureHelperSpec: BaseSpec {
    override func spec() {
        describe("requestAccess") {
            context("when access is granted") {
                it("should call success") {
                    var successCalled = false
                    var failureCalled = false

                    FakeAVCaptureDevice.setAuthorizationStatus(status: .authorized)

                    expect(FakeAVCaptureDevice.authorizationStatus(for: .video)).to(equal(AVAuthorizationStatus.authorized))

                    AVCaptureHelper.requestAccess(
                        device: FakeAVCaptureDevice.self,
                        success: {
                            successCalled = true
                        },
                        failure: {
                            failureCalled = true
                        }
                    )

                    expect(successCalled).toEventually(beTrue())
                    expect(failureCalled).toEventuallyNot(beTrue())
                }
            }

            context("when access is denied") {
                it("should call failure") {
                    var successCalled = false
                    var failureCalled = false

                    FakeAVCaptureDevice.setAuthorizationStatus(status: .denied)

                    expect(FakeAVCaptureDevice.authorizationStatus(for: .video)).to(equal(AVAuthorizationStatus.denied))
                    
                    AVCaptureHelper.requestAccess(
                        device: FakeAVCaptureDevice.self,
                        success: {
                            successCalled = true
                        },
                        failure: {
                            failureCalled = true
                        }
                    )

                    expect(successCalled).toEventuallyNot(beTrue())
                    expect(failureCalled).toEventually(beTrue())
                }
            }
        }

        describe("cameraIsAuthorized") {
            context("when camera is authorized") {
                it("should return true") {
                    FakeAVCaptureDevice.setAuthorizationStatus(status: .authorized)

                    expect(FakeAVCaptureDevice.authorizationStatus(for: .video)).to(equal(AVAuthorizationStatus.authorized))
                    expect(AVCaptureHelper.cameraIsAuthorized(for: FakeAVCaptureDevice.self)).to(beTrue())
                }
            }

            context("when camera is denied") {
                it("should return false") {
                    FakeAVCaptureDevice.setAuthorizationStatus(status: .denied)

                    expect(FakeAVCaptureDevice.authorizationStatus(for: .video)).to(equal(AVAuthorizationStatus.denied))
                    expect(AVCaptureHelper.cameraIsAuthorized(for: FakeAVCaptureDevice.self)).toNot(beTrue())
                }
            }
        }
    }
}
