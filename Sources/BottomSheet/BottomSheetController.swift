
import UIKit

public class BottomSheetController<LevelType: BottomSheetLevel>: UIViewController {
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
    
    // Computed properties
    
    
    internal var delegate: BottomSheetDelegateBase? {
        [
            (overlayViewController as? UINavigationController)?.presentingViewController, overlayViewController]
            .compactMap { $0 as? BottomSheetDelegateBase }
            .first
    }
    
    private var offsets: [BottomSheetOffset] {
        delegate?.offsets ?? BottomSheetDefaultLevel.allCases.map(\.offset)
    }
    
    init(masterViewController: UIViewController, overlayViewController: UIViewController, levelDefinition: LevelType) {
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

public extension BottomSheetController {
    func setLevel(_ level: LevelType, animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        setOffset(offset: level.offset, animated: animated, velocity: 0, completion: completion)
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

extension BottomSheetController: BottomSheetPositionDelegate {
    var corrdinateSystem: UIView { view }
    var sheetOffset: CGFloat { bottomSheetOffset.constant }
    
    private func constant(for offset: BottomSheetOffset) -> CGFloat {
        switch offset {
        case let .specific(offset):
            return offset
        case let .relative(percentage, offsettedBy):
            return view.safeAreaInsets.bottom + (safeAreaContentView.frame.height * percentage) + offsettedBy
        }
    }
    
    func setConstant(constant: CGFloat) {
        bottomSheetOffset.constant = constant
    }
    
    func setOffset(offset: BottomSheetOffset, animated: Bool = true, velocity: CGFloat = 0, completion: ((Bool) -> Void)? = nil) {
        if !animated {
            setConstant(constant: constant(for: offset))
        }
        var distance = constant(for: offset) - bottomSheetOffset.constant
        distance = distance == 0 ? 1 : distance
        UIView.animate(
            withDuration: 0.8,
            delay: 0,
            usingSpringWithDamping: velocity == 0 ? 0 : 0.7,
            initialSpringVelocity: distance == 0 ? velocity : velocity / distance,
            options: .allowUserInteraction,
            animations: {
                self.setConstant(constant: self.constant(for: offset))
                self.view.layoutIfNeeded()
            },
            completion: completion
        )
    }
    
    func nearestOffset(for projection: CGFloat) -> BottomSheetOffset {
        let offsets = self.offsets
        let index = offsets
            .map(constant(for:))
            .enumerated()
            .map { index, offset in (index, abs(offset - projection)) }
            .min { $0.1 < $1.1 }?.0
        return index != nil ? offsets[index!] : BottomSheetDefaultLevel.min.offset
    }
}
