import CoreLocation
import UIKit

class SpeedometerViewController: UIViewController {
    private let locationManager: CLLocationManager

    private var speed: Speed? {
        didSet {
            guard let speed = speed else {
                return
            }

            speedLabel.text = speed.asString
            circleView.fillmentLevel = speed.fillment
            circleView.fillColor = view.tintColor
            speedLabel.textColor = nil

            if let speedLimit = speedLimit, speed.roundedSpeed > speedLimit.roundedSpeed {
                let warningColor = UIColor(red: 0.6196, green: 0, blue: 0, alpha: 1.0)
                circleView.fillColor = warningColor
                speedLabel.textColor = warningColor
            }
        }
    }

    private var coordinates: Coordinates? {
        didSet {
            guard let coordinates = coordinates  else {
                return
            }

            coordinatesLabel.text = "\(coordinates.formatted.latitude)\n\(coordinates.formatted.longitude)"
        }
    }

    private var speedLimit: Speed? {
        didSet {
            guard let speedLimit = speedLimit else {
                resetSpeedLimitLabels()

                return
            }

            UserDefaults.standard.set(speedLimit.asString, forKey: Configuration.currentSpeedLimitDefaultsKey)
            speedLimitLabel.text = "\("SpeedometerViewController.SpeedLimit.CurrentSpeedLimit".localized) \(speedLimit.asStringWithUnit)"
            speedLimitButton.setTitle("SpeedometerViewController.SpeedLimit.Button.TapToReleaseSpeedLimit".localized, for: .normal)
        }
    }

    private var unit: Unit {
        didSet {
            UserDefaults.standard.removeObject(forKey: Configuration.currentSpeedLimitDefaultsKey)

            unitLabel.text = unit.abbreviation
            UserDefaults.standard.set(unit.rawValue, forKey: Configuration.currentUnitDefaultsKey)
        }
    }

    // MARK: - Controller Lifecycle

    init(locationManager: CLLocationManager, unit: Unit) {
        self.locationManager = locationManager
        self.unit = unit

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureLocationManager()
    }

    // MARK: - Outlets & Actions

    @IBOutlet weak var circleView: CircleView!
    @IBOutlet weak var inaccurateSignalIndicatorLabel: UILabel!
    @IBOutlet weak var loadingStackView: UIStackView!
    @IBOutlet weak var speedStackView: UIStackView!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var speedLimitLabel: UILabel!
    @IBOutlet weak var speedLimitButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var unitSegmentedControl: UISegmentedControl! {
        didSet {
            unitSegmentedControl.removeAllSegments()
            units.enumerated().forEach { (index, unit) in
                unitSegmentedControl.insertSegment(withTitle: unit.abbreviation, at: index, animated: false)
            }

            unitSegmentedControl.selectedSegmentIndex = units.index(where: { $0.abbreviation == unit.abbreviation }) ?? 0
        }
    }

    // Will be implemented by a seque in storyboard later…
    @IBAction func presentImprint(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Speedometer", bundle: nil)

        present(storyboard.instantiateViewController(withIdentifier: "ImprintViewControllerIdentifier"), animated: true, completion: nil)
    }

    @IBAction func updateUnit(_ sender: UISegmentedControl) {
        updateUnit(units[sender.selectedSegmentIndex])
    }

    @IBAction func updateSpeedLimit(_ sender: UIButton) {
        updateSpeedLimit()
    }
}

// MARK: - CLLocationManagerDelegate

extension SpeedometerViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.horizontalAccuracy <= Double(Configuration.minimumHorizontalAccuracy) else {
            setDisplayMode(to: .loadingIndicator)

            return
        }

        if speedStackView.isHidden {
            setDisplayMode(to: .speed)
        }

        speed = Speed(speed: location.speed, unit: unit)
        coordinates = Coordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
}

// MARK: - Private Methods

private extension SpeedometerViewController {
    enum DisplayMode {
        case loadingIndicator
        case speed
    }

    func configureView() {
        setDisplayMode(to: .loadingIndicator)

        inaccurateSignalIndicatorLabel.text = "SpeedometerViewController.Indicator".localized
        coordinatesLabel.text = "SpeedometerViewController.NoCoordinates".localized
        unitLabel.text = unit.abbreviation
        resetSpeedLimitLabels()

        StoreReviewHelper.askForReview()
    }

    func resetSpeedLimitLabels() {
        speedLimitLabel.text = "SpeedometerViewController.SpeedLimit.NoSpeedLimit".localized
        speedLimitButton.setTitle("SpeedometerViewController.SpeedLimit.Button.TapToSetSpeedLimit".localized, for: .normal)
    }

    func setDisplayMode(to displayMode: DisplayMode) {
        switch displayMode {
        case .loadingIndicator:
            loadingStackView.isHidden = false
            speedStackView.isHidden = true
        case .speed:
            loadingStackView.isHidden = true
            speedStackView.isHidden = false
        }
    }

    func updateUnit(_ unit: Unit) {
        self.unit = unit

        guard let speedLimit = speedLimit else {
            return
        }

        self.speedLimit = Speed(speed: speedLimit, unit: unit)
    }

    func updateSpeedLimit() {
        guard speedLimit == nil else {
            speedLimit = nil

            return
        }

        speedLimit = speed
    }

    func configureLocationManager() {
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
}
