
import UIKit

public protocol BottomSheetControllerDelegate {
    func bottomSheetWillChangeContext(to viewController: UIViewController)
    func bottomSheetDidChangeContext(to viewController: UIViewController)
    func bottomSheetDidChangeHeight(to height: CGFloat)
}

public class BottomSheetController: UIViewController {
    // MARK: - Contained view controllers
    public var masterViewController: UIViewController?
    public var contextViewControllers: [UIViewController] = []
    
    // MARK: - BottomSheet subviews
    // Constraints
    internal var regularConstraints: [NSLayoutConstraint] = []
    internal var compactConstraints: [NSLayoutConstraint] = []
    internal var bottomSheetOffsetConstraint: NSLayoutConstraint?
    
    // Helper Views
    internal var bottomSheet: ContainerView = ContainerView()
    internal var masterContainer: ContainerView = ContainerView()
    internal var contentFrameView: UIView = UIView()
    
    // MARK: - Properties
    // Public properties
    public var initialHeight: CGFloat = 400
    public var currentHeight: CGFloat { bottomSheetOffsetConstraint?.constant ?? initialHeight }
    
    // Computed properties
    internal var maxContentHeight: CGFloat { contentFrameView.frame.height }
    internal var isRegularSizeClass: Bool { traitCollection.horizontalSizeClass == .regular }
    
    // Gestures
    var gestureRouter: BottomSheetGestureRouter = .init()
    
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
        gestureRouter.delegate = self
        setupComposition()
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
