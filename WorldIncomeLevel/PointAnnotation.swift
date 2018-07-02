//
//  PointAnnotation.swift
//  WorldIncomeLevel
//
//  Created by Jo Thorpe on 04/03/2017.
//  Copyright © 2017 Metropolis Studios LTD. All rights reserved.
//


import UIKit
import MapKit

class PointAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var image: UIImage?
    var eta: String?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
