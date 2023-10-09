//
//  annottation.swift
//  prjct17location
//
//  Created by codemac on 12/04/18.
//  Copyright © 2018 codemac. All rights reserved.
//

import UIKit
import MapKit

class annottation: NSObject,MKAnnotation
{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordin: CLLocationCoordinate2D, placeTitle: String, subTitle: String )
    {
        coordinate = coordin
        title = placeTitle
        subtitle = subTitle
    }
}
class CustomPointAnnotation: MKPointAnnotation {
    var pinCustomImageName:String!
}
