//
//  ViewController.swift
//  WeatheriOS
//
//  Created by César González on 27/12/21.
//

import UIKit
import WeatherChallenge
import MapKit

public protocol ViewProtocol: AnyObject {
    func display(_ viewModel: ViewModel)
    func displayErrorWith(text: String)
}

public final class ViewController: UIViewController, ViewProtocol {
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak public private(set) var cityNameLabel: UILabel! {didSet{cityNameLabel.text = ""}}
    @IBOutlet weak public private(set) var temperatureLabel: UILabel! {didSet{temperatureLabel.text = ""}}
    @IBOutlet weak public private(set) var descriptionLabel: UILabel! {didSet{descriptionLabel.text = ""}}
    @IBOutlet weak public private(set) var iconImageView: UIImageView!
    @IBOutlet weak public private(set) var latitudLabel: UILabel! {didSet{latitudLabel.text = ""}}
    @IBOutlet weak public private(set) var longitudLabel: UILabel! {didSet{longitudLabel.text = ""}}
    private let presenter: PresenterProtocol
    
    let locationManager = CLLocationManager()
    
    public init?(coder: NSCoder, presenter: PresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoadAction()
        locationManager.delegate = self
    }
    private var currentAnnotation: MKPointAnnotation?
    
    public func display(_ viewModel: ViewModel) {
        cityNameLabel.text = viewModel.cityName
//        longitudLabel.text = viewModel.longitude
//        latitudLabel.text = viewModel.latitude
        temperatureLabel.text = viewModel.temperature
        iconImageView.image = UIImage(systemName: viewModel.weatherIcon)?.withRenderingMode(.alwaysOriginal)
        descriptionLabel.text = viewModel.weatherDescription
        if let currentAnnotation = currentAnnotation {
            mapView.removeAnnotation(currentAnnotation)
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = viewModel.coords
        annotation.title = viewModel.cityName
        annotation.subtitle = viewModel.temperature
        currentAnnotation = annotation
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: viewModel.coords, span: MKCoordinateSpan(latitudeDelta: 0.9, longitudeDelta: 0.9))
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction private func changeLocation(_ sender: Any) {
        changeLocation()
    }
    
    public func changeLocation() {
        errorView?.removeFromSuperview()
        errorView = nil
        presenter.reloadAction()
    }
    
    public func displayErrorWith(text: String) {
        if errorView == nil {
            errorView = createErrorView(text: text)
        }
        
        errorView?.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y - 50, width: view.frame.self.width, height: 50)
        view.addSubview(errorView!)
        let newFrame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y + 50, width: view.frame.self.width, height: 50)
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear) {
            self.errorView?.frame = newFrame
        }
    }
    
    public private(set) var errorView: UIView?
    
    private func createErrorView(text: String) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.systemRed
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.textAlignment = .center
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        return view
    }
}

extension ViewController: CLLocationManagerDelegate {
    
}

