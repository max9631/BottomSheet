
import UIKit

public protocol BottomSheetControllerDelegate {
    func bottomSheetWillChangeContext(to viewController: UIViewController)
    func bottomSheetDidChangeContext(to viewController: UIViewController)
    func bottomSheetDidChangeHeight(to height: CGFloat)
}

@IBDesignable
public class BottomSheetController: UIViewController {
    // MARK: - Contained view controllers
    public var masterViewController: UIViewController?
    public var contextViewControllers: [UIViewController] = []
    
    // MARK: - BottomSheet subviews
    // Constraints
    private var regularConstraints: [NSLayoutConstraint] = []
    private var compactConstraints: [NSLayoutConstraint] = []
    private var bottomSheetOffsetConstraint: NSLayoutConstraint?
    
    // Helper Views
    var bottomSheet: BottomSheet = BottomSheet()
    var masterContainer: ContainerView = ContainerView()
    private var contentFrameView: UIView = UIView()
    
    // MARK: - Properties
    // Public properties
    @IBInspectable public var initialHeight: CGFloat = 400
    public var currentHeight: CGFloat { bottomSheetOffsetConstraint?.constant ?? initialHeight }
    
    // Computed properties
    internal var maxContentHeight: CGFloat { contentFrameView.frame.height }
    internal var isRegularSizeClass: Bool { traitCollection.horizontalSizeClass == .regular }
    
    // MARK: - Initializers
    public init(masterViewController: UIViewController, overlayViewController: UIViewController, initialHeight: CGFloat = 400) {
        super.init(nibName: nil, bundle: nil)
        self.masterViewController = masterViewController
        self.contextViewControllers = [overlayViewController]
        self.initialHeight = initialHeight
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //
//    public override class func prepareForInterfaceBuilder() {
//        super.prepareForInterfaceBuilder()
//        let bundle = Bundle(for: Self.self)
//        let view = UINib(nibName: "BottomSheetController", bundle: bundle).instantiate(withOwner: self) as! BottomSheetController
////        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
//
//        return view
//    }
//
//    loadView
    
    // MARK: - UIViewController methods
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
            case "overlay": contextViewControllers.insert(segue.destination, at: 0)
            default: break
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupComposition()
        bottomSheet.delegate = self
        
        if let controller = masterViewController {
            showMaster(with: controller)
        }
        if let controller = contextViewControllers.first {
            showBottomSheet(with: controller)
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        changeLayoutIfNeeded()
    }
}

// MARK: - Public interface
public extension BottomSheetController {
    func changeLayoutIfNeeded() {
        let activateRegular = isRegularSizeClass
        NSLayoutConstraint.deactivate(activateRegular ? compactConstraints : regularConstraints)
        NSLayoutConstraint.activate(activateRegular ? regularConstraints : compactConstraints)
        updateSafeAreaInsets()
    }
    
    func updateSafeAreaInsets() {
        if isRegularSizeClass {
            masterViewController?.additionalSafeAreaInsets = .init(top: 0, left: 320 + 16 + 16, bottom: 0, right: 0)
        } else {
            masterViewController?.additionalSafeAreaInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func showMaster(with viewController: UIViewController) {
        if let master = masterViewController {
            master.willMove(toParent: nil)
            master.view.removeFromSuperview()
            master.removeFromParent()
        }
        addChild(viewController)
        masterViewController = viewController
        masterContainer.embedIn(view: viewController.view)
        viewController.didMove(toParent: self)
    }
    
    func showBottomSheet(with viewController: UIViewController) {
        pushContext(viewController: viewController)
    }
    
    func pushContext(viewController: UIViewController) {
        contextViewControllers.append(viewController)
        addChild(viewController)
        setOffset(offset: .specific(offset: 0)) { _ in
            self.bottomSheet.embedIn(view: viewController.view, bottomPriority: .defaultLow - 10, maxHeight: self.contentFrameView.heightAnchor)
            self.setOffset(offset: .specific(offset: self.initialHeight))
        }
        viewController.didMove(toParent: self)
        setOverrideTraitCollection(UITraitCollection(horizontalSizeClass: .compact), forChild: viewController)
    }
    
    func popContext() {
        guard !contextViewControllers.isEmpty else { return }
        let controller = contextViewControllers.popLast()
        setOffset(offset: .specific(offset: 0)) { _ in
            controller?.willMove(toParent: nil)
            controller?.view.removeFromSuperview()
            controller?.removeFromParent()
            if let previousController = self.contextViewControllers.last {
                self.bottomSheet.embedIn(view: previousController.view, bottomPriority: .defaultLow - 10, maxHeight: self.contentFrameView.heightAnchor)
            }
        }
    }
}

// MARK: - Layout definition
private extension BottomSheetController {
    func setupComposition() {
        view.addSubview(contentFrameView)
        view.addSubview(masterContainer)
        view.addSubview(bottomSheet)
        createContentViewLayout()
        createMasterContainer()
        createBottomSheetLayout()
        view.sendSubviewToBack(masterContainer)
        view.sendSubviewToBack(contentFrameView)
    }
    
    func createContentViewLayout() {
        let contentView = contentFrameView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func createMasterContainer() {
        let masterView = masterContainer
        masterView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(masterView)
        NSLayoutConstraint.activate([
            masterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            masterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            masterView.topAnchor.constraint(equalTo: view.topAnchor),
            masterView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func createBottomSheetLayout() {
        let sheet = bottomSheet
        sheet.translatesAutoresizingMaskIntoConstraints = false
        regularConstraints = [
            sheet.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            sheet.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            sheet.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            sheet.widthAnchor.constraint(equalToConstant: 320)
        ]
        let bottomSheetOffset = view.bottomAnchor.constraint(equalTo: sheet.topAnchor, constant: initialHeight)
        self.bottomSheetOffsetConstraint = bottomSheetOffset
        let heightConstraint = sheet.heightAnchor.constraint(equalTo: contentFrameView.heightAnchor)
        heightConstraint.priority = .defaultLow
        compactConstraints = [
            sheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSheetOffset,
            heightConstraint,
            sheet.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor)
        ]
        changeLayoutIfNeeded()
    }
}

// MARK: BottomSheetPositionDelegate
extension BottomSheetController: BottomSheetPositionDelegate {
    // Computed properties
    internal var delegate: BottomSheetDelegateBase? {
        contextViewControllers.first?.asBottomSheetdelegate
    }
    
    internal var offsets: [BottomSheetOffset] {
        delegate?.offsets ?? BottomSheetDefaultAnchorPoint.allCases.map(\.offset)
    }
    
    var corrdinateSystem: UIView { view }
    
    internal func constant(for offset: BottomSheetOffset) -> CGFloat {
        let constant: CGFloat = {
            switch offset {
            case let .specific(offset): return offset
            case let .relative(percentage, offsettedBy):
                return (maxContentHeight * percentage) + offsettedBy
            }
        }()
        if let maxHeight = bottomSheet.presentingView?.frame.height, constant > maxHeight {
            return maxHeight
        }
        return constant
    }
    
    func setHeight(constant: CGFloat) {
        guard let constraint = bottomSheetOffsetConstraint else {
            initialHeight = constant
            return
        }
        constraint.constant = constant
    }
    
    public func setOffset(offset: BottomSheetOffset, animated: Bool = true, velocity: CGFloat = 0, completion: ((Bool) -> Void)? = nil) {
        let closure = {
            self.setHeight(constant: self.constant(for: offset))
            self.view.layoutIfNeeded()
        }
        guard animated else {
            closure()
            completion?(false)
            return
        }
        var distance = constant(for: offset) - currentHeight
        distance = distance == 0 ? 1 : distance
        UIView.animate(
            withDuration: 0.7,
            delay: 0,
            usingSpringWithDamping: velocity == 0 ? 1 : 0.7,
            initialSpringVelocity: distance == 0 ? velocity : velocity / distance,
            options: .allowUserInteraction,
            animations: closure,
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
        return index != nil ? offsets[index!] : .specific(offset: initialHeight)
    }
}

