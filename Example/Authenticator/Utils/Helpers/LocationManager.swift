//
//  LocationManager
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2021 Salt Edge Inc.
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

import Foundation
import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    static var currentLocation: CLLocationCoordinate2D?
    private var locationManager: CLLocationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
    }

    var notDeterminedAuthorization: Bool {
        CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .notDetermined
    }
    
    var geolocationSharingIsEnabled: Bool {
        CLLocationManager.locationServicesEnabled() && [.authorizedAlways, .authorizedWhenInUse].contains(CLLocationManager.authorizationStatus())
    }

    func requestLocationAuthorization() {
        if #available(iOS 13.4, *) {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.requestAlwaysAuthorization()
        }
    }

    func startUpdatingLocation() {
        if geolocationSharingIsEnabled {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        LocationManager.currentLocation = manager.location?.coordinate
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            startUpdatingLocation()
        }
    }
}

extension CLLocationCoordinate2D {
    var headerValue: String {
        return "GEO:\(self.latitude);\(self.longitude)"
    }
}
