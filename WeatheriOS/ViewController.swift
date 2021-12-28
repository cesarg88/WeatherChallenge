//
//  ViewController.swift
//  WeatheriOS
//
//  Created by César González on 27/12/21.
//

import UIKit
import WeatherChallenge

protocol ViewProtocol: AnyObject {
    func display(_ viewModel: ViewModel)
}

final class ViewController: UIViewController, ViewProtocol {
    
    @IBOutlet weak var cityNameLabel: UILabel! {didSet{cityNameLabel.text = ""}}
    @IBOutlet weak var temperatureLabel: UILabel! {didSet{temperatureLabel.text = ""}}
    @IBOutlet weak var descriptionLabel: UILabel! {didSet{descriptionLabel.text = ""}}
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var latitudLabel: UILabel! {didSet{latitudLabel.text = ""}}
    @IBOutlet weak var longitudLabel: UILabel! {didSet{longitudLabel.text = ""}}
    private let presenter: PresenterProtocol
    
    init?(coder: NSCoder, presenter: PresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoadAction()
    }
    
    func display(_ viewModel: ViewModel) {
        cityNameLabel.text = viewModel.cityName
        longitudLabel.text = viewModel.longitude
        latitudLabel.text = viewModel.latitude
        temperatureLabel.text = viewModel.temperature
        iconImageView.image = UIImage(systemName: viewModel.weatherIcon)?.withRenderingMode(.alwaysOriginal)
        descriptionLabel.text = viewModel.weatherDescription
    }
    @IBAction func changeLocation(_ sender: Any) {
        presenter.reloadAction()
    }
}

