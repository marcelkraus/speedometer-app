import CoreLocation
import UIKit

class CircularViewController: UIViewController {

    // MARK: - Properties

    let locationManager = CLLocationManager()

    var background: UIColor

    var filling: UIColor

    // MARK: - View Controller Lifecycle

    init(background: UIColor = .lightGray, filling: UIColor = .darkGray) {
        self.background = background
        self.filling = filling

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }

    override func loadView() {
        view = CircularView(background: background, filling: filling)
    }
}

extension CircularViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var unit: Unit {
            return Unit(rawValue: UserDefaults.standard.string(forKey: AppConfiguration.currentUnitDefaultsKey)!)!
        }

        guard let location = locations.last else {
            return
        }

        let speed = Speed(speed: location.speed, unit: unit)
        (view as? CircularView)?.fillmentLevel = speed.fillment
    }
}
