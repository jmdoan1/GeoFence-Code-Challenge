//
//  Annotaion.swift
//  GeoFenceCodeChallenge
//
//  Created by Justin Doan on 9/9/16.
//  Copyright © 2016 Justin Doan. All rights reserved.
//

import Foundation
import MapKit

class Annotation: NSObject, MKAnnotation {
    var coordinate = CLLocationCoordinate2D()
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
