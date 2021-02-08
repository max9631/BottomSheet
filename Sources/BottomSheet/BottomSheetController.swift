
import UIKit

public class BottomSheetController: UIViewController {
    // Contained view controllers
    public var masterViewController: UIViewController!
    public var overlayViewController: UIViewController!
    
    // Constraints
    private var regularConstraints: [NSLayoutConstraint] = []
    private var compactConstraints: [NSLayoutConstraint] = []
    private var bottomSheetOffset: NSLayoutConstraint!
    
    // Helper Views
    private lazy var bottomSheet: BottomSheet = {
        let sheet = BottomSheet(overlayViewController: overlayViewController, delegate: self)
        view.addSubview(sheet)
        sheet.translatesAutoresizingMaskIntoConstraints = false
        regularConstraints = [
            sheet.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            sheet.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            sheet.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            sheet.widthAnchor.constraint(equalToConstant: 320)
        ]
        bottomSheetOffset = view.bottomAnchor.constraint(equalTo: sheet.topAnchor, constant: 400)
        let heightConstraint = sheet.heightAnchor.constraint(equalTo: safeAreaContentView.heightAnchor)
        heightConstraint.priority = .defaultLow
        compactConstraints = [
            sheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSheetOffset,
            heightConstraint
        ]
        NSLayoutConstraint.activate(isRegularSizeClass ? regularConstraints : compactConstraints)
        return sheet
    }()
    
    private lazy var safeAreaContentView: UIView = {
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
//        view.layoutIfNeeded()
        return contentView
    }()
    
    // Properties
    private var gestureInitialSheetOffset: CGFloat = .zero
    private var isRegularSizeClass: Bool { traitCollection.horizontalSizeClass == .regular }
    
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
        [masterViewController, overlayViewController].forEach(self.addChild)
        bottomSheet.delegate = self
        setupComposition()
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let activateRegular = isRegularSizeClass
        NSLayoutConstraint.deactivate(activateRegular ? compactConstraints : regularConstraints)
        NSLayoutConstraint.activate(activateRegular ? regularConstraints : compactConstraints)
    }
}

private extension BottomSheetController {
    func setupComposition() {
        view.addSubview(masterViewController.view)
        view.sendSubviewToBack(masterViewController.view)
        view.sendSubviewToBack(safeAreaContentView)
        guard let masterView = masterViewController.view else { return }
        masterView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            masterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            masterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            masterView.topAnchor.constraint(equalTo: view.topAnchor),
            masterView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension BottomSheetController: BottomSheetDelegate {
    var corrdinateSystem: UIView { view }
    var sheetOffset: CGFloat { bottomSheetOffset.constant }
    
    func setOffset(offset: CGFloat) {
        bottomSheetOffset.constant = offset
    }
}
