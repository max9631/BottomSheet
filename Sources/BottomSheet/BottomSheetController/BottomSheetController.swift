
import UIKit

public protocol BottomSheetControllerDelegate {
    func bottomSheetWillChangeContext(to viewController: UIViewController)
    func bottomSheetDidChangeContext(to viewController: UIViewController)
    func bottomSheetDidChangeHeight(to height: CGFloat)
}

open class BottomSheetController: UIViewController {
    // MARK: - Contained view controllers
    public var masterViewController: UIViewController?
    public var contextViewControllers: [UIViewController] = []
    public var visibleContextViewController: UIViewController? { contextViewControllers.last }
    
    // MARK: - BottomSheet subviews
    // Position
    public lazy var position: BottomSheetPosition = { BottomSheetPosition(embed: bottomSheet, in: self) }()
    
    // Helper Views
    public var bottomSheet: ContainerView = ContainerView()
    var masterContainer: ContainerView = ContainerView()
    var contentFrameView: UIView = UIView()
    
    // Computed properties
    var maxContentHeight: CGFloat { contentFrameView.frame.height }
    var isRegularSizeClass: Bool { traitCollection.horizontalSizeClass == .regular }
    
    // Gestures
    var gestureRouter: BottomSheetGestureRouter = .init()
    
    // MARK: - Initializers
    public init(masterViewController: UIViewController, overlayViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        showMaster(with: masterViewController)
        showBottomSheet(with: overlayViewController, at: .specific(offset: .zero), animated: false)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - UIViewController methods
    open override func loadView() {
        super.loadView()
        if (storyboard != nil) {
            performSegue(withIdentifier: "master", sender: self)
            performSegue(withIdentifier: "overlay", sender: self)
        }
    }
    
    open override func performSegue(withIdentifier identifier: String, sender: Any?) {
        super.performSegue(withIdentifier: identifier, sender: sender)
    }
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case "master": showMaster(with: segue.destination)
            case "overlay": showBottomSheet(with: segue.destination, at: .specific(offset: .zero), animated: false)
            default: break
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        bottomSheet.backgroundColor = .systemBackground
        gestureRouter.delegate = self
        setupComposition()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        changeLayoutIfNeeded()
    }
}
