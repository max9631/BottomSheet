
import UIKit

public class BottomSheetController: UIViewController {
    public weak var masterViewController: UIViewController!
    public weak var overlayViewController: UIViewController!
    public var bottomSheet: UIView = UIView()
    private var safeAreaContentView: UIView = UIView()
    
    private var isRegularSizeClass: Bool { traitCollection.horizontalSizeClass == .regular }
    
    private var regularConstraints: [NSLayoutConstraint] = []
    private var compactConstraints: [NSLayoutConstraint] = []
    private var bottomSheetOffset: NSLayoutConstraint!
    
    init(masterViewController: UIViewController, overlayViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        self.masterViewController = masterViewController
        self.overlayViewController = overlayViewController
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func loadView() {
        super.loadView()
        if (storyboard != nil) {
            performSegue(withIdentifier: "master", sender: self)
            performSegue(withIdentifier: "overlay", sender: self)
        }
    }
    
    public override func performSegue(withIdentifier identifier: String, sender: Any?) {
        super.performSegue(withIdentifier: identifier, sender: sender)
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "master": masterViewController = segue.destination
            case "overlay": overlayViewController = segue.destination
            default: break
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupComposition()
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        regularConstraints.forEach { $0.isActive = isRegularSizeClass }
        compactConstraints.forEach { $0.isActive = !isRegularSizeClass }
    }
}

private extension BottomSheetController {
    func setupComposition() {
        [masterViewController, overlayViewController].forEach(self.addChild)
        self.view.addSubview(masterViewController.view)
        self.view.addSubview(bottomSheet)
        self.bottomSheet.addSubview(overlayViewController.view)
        [masterViewController.view, overlayViewController.view, bottomSheet].forEach { view in
            view?.translatesAutoresizingMaskIntoConstraints = false
        }
        setupMasterComposition()
        setupSheetComposition()
        setupSafeAreaContentView()
        setupBottomSheetContainer()
    }
    
    func setupMasterComposition() {
        guard let masterView = masterViewController.view else { return }
        NSLayoutConstraint.activate([
            masterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            masterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            masterView.topAnchor.constraint(equalTo: view.topAnchor),
            masterView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupSheetComposition() {
        guard let overlayView = overlayViewController.view else { return }
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: bottomSheet.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: bottomSheet.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: bottomSheet.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomSheet.bottomAnchor, constant: view.safeAreaInsets.bottom)
        ])
    }
    
    func setupSafeAreaContentView() {
        safeAreaContentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeAreaContentView)
        NSLayoutConstraint.activate([
            safeAreaContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            safeAreaContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            safeAreaContentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            safeAreaContentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        view.layoutIfNeeded()
    }
    
    func setupBottomSheetContainer() {
        regularConstraints = [
            bottomSheet.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            bottomSheet.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            bottomSheet.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            bottomSheet.widthAnchor.constraint(equalToConstant: 320)
        ]
        
        bottomSheetOffset = view.bottomAnchor.constraint(equalTo: bottomSheet.topAnchor, constant: 400)
        let heightConstraint = bottomSheet.heightAnchor.constraint(equalTo: safeAreaContentView.heightAnchor)
        heightConstraint.priority = .defaultLow
        compactConstraints = [
            bottomSheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSheetOffset,
            heightConstraint
        ]
        NSLayoutConstraint.activate(isRegularSizeClass ? regularConstraints : compactConstraints)
    }
}
