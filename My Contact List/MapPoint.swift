//
//  MapPoint.swift
//  My Contact List
//
//  Created by Andrew Lawrence on 4/22/25.
//

import Foundation
import MapKit

class MapPoint: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var email: String?
    var latitude: Double
    var longitude: Double

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(latitude: Double, longitude: Double, title: String? = nil, subtitle: String? = nil, email: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.title = title
        self.subtitle = subtitle
        self.email = email
    }
}
