//
//  RouteMapViewController.swift
//  mScoreNew
//
//  Created by Perfect on 22/10/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RouteMapViewController: UIViewController,MKMapViewDelegate {

    
    @IBOutlet weak var mapview: MKMapView!{
        didSet{
            mapview.delegate = self
        }
    }
    var destLat = Double()
    var desLong = Double()
    var bankName = String()
    var annotationArray = [MKAnnotation]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let ann = annottation.init(coordin: CLLocationCoordinate2D( latitude: destLat,
                                                                    longitude: desLong ),
                                   placeTitle: bankName,
                                   subTitle: "")
        annotationArray.append(ann)
        mapview.addAnnotations(annotationArray)
        mapview.showAnnotations(annotationArray, animated: true)
    }
    
    
    func removeNastyMapMemory() {
            
        mapview.delegate = nil
        mapview.removeFromSuperview()
        
        }

    override func viewWillDisappear(_ animated: Bool) {
        removeNastyMapMemory()
    }
    
    @IBAction func back(_ sender: UIBarButtonItem)
    {
        navigationController?.popViewController(animated: true)
    }

    
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.mapview.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            
            self.mapview.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapview.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        renderer.lineWidth = 5.0
        
        return renderer
    }
}
