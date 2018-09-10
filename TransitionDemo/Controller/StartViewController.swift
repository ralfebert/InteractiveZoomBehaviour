import UIKit

class ZoomBehaviour : NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {

    var originView : UIView
    weak var originViewController : UIViewController?
    var controllerToPresent : () -> (UIViewController)

    init(originView : UIView, originViewController : UIViewController, controllerToPresent : @escaping () -> (UIViewController)) {
        self.originView = originView
        self.originViewController = originViewController
        self.controllerToPresent = controllerToPresent
        super.init()

        self.originView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
    }

    @IBAction func handleTap(_: UITapGestureRecognizer) {
        let controller = controllerToPresent()
        controller.transitioningDelegate = self
        originViewController?.present(controller, animated: true, completion: nil)
    }

    // MARK: - UIViewControllerTransitioningDelegate

    enum State {
        case present
        case dismiss
    }

    var state = State.present

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animator = nil
        self.state = .present
        return self
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animator = nil
        self.state = .dismiss
        return self
    }

    // MARK: - UIViewControllerAnimatedTransitioning

    private var animator : UIViewPropertyAnimator?

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {

        if let animator = self.animator { return animator }

        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear)

        let containerView = transitionContext.containerView

        let fromViewController = transitionContext.viewController(forKey: .from)!
        let fromView = transitionContext.view(forKey: .from)!
        let fromViewFrame = transitionContext.finalFrame(for: fromViewController)

        let toViewController = transitionContext.viewController(forKey: .to)!
        let toView = transitionContext.view(forKey: .to)!
        let toViewFrame = transitionContext.finalFrame(for: toViewController)

        let originFrame = self.originView.convert(self.originView.bounds, to: containerView)

        switch state {
        case .present:
            containerView.addSubview(toView)
            toView.clipsToBounds = true
            toView.frame = originFrame

            animator.addAnimations {
                toView.frame = toViewFrame
            }

        case .dismiss:
            containerView.insertSubview(toView, belowSubview: fromView)

            animator.addAnimations {
                fromView.frame = originFrame
            }

        }

        animator.addCompletion { (_) in
            self.animator = nil
            transitionContext.completeTransition(true)
        }

        self.animator = animator
        return animator
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.interruptibleAnimator(using: transitionContext).startAnimation()
    }

}

class StartViewController: UIViewController {

    @IBOutlet var orangeView: UIView!

    var zoomBehaviour : ZoomBehaviour!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.zoomBehaviour = ZoomBehaviour(originView: self.orangeView, originViewController: self) { ContentViewController() }
    }

}
