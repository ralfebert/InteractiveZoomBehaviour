import UIKit

class ZoomBehaviour : NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning {

    var originView : UIView
    weak var originViewController : UIViewController?
    var controllerToPresent : () -> (UIViewController)

    var dragRange : ClosedRange<CGFloat> = 0 ... 0

    init(originView : UIView, originViewController : UIViewController, controllerToPresent : @escaping () -> (UIViewController)) {
        self.originView = originView
        self.originViewController = originViewController
        self.controllerToPresent = controllerToPresent
        self.dragRange = 0 ... (originViewController.view.frame.size.height - self.originView.center.y)
        super.init()

        self.originView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:))))
    }

    func presentController() {
        let controller = controllerToPresent()
        controller.transitioningDelegate = self
        originViewController?.present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Gesture recognizers

    @IBAction func handlePan(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            self.presentController()
        }

        let translation = recognizer.translation(in: self.originView)
        let progress = dragRange.clampedFraction(value: translation.y)

        self.animator?.fractionComplete = progress
        
        if recognizer.state == .ended {
            let complete = progress > 0.5
            self.animator?.isReversed = !complete
            self.animator?.startAnimation()
        }

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

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
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
                for i in 1...2 {
                    toView.transform = CGAffineTransform(rotationAngle: .pi * CGFloat(i))
                }
            }

        case .dismiss:
            containerView.insertSubview(toView, belowSubview: fromView)

            animator.addAnimations {
                fromView.frame = originFrame
                for i in 1...2 {
                    fromView.transform = CGAffineTransform(rotationAngle: .pi * CGFloat(i))
                }
            }

        }

        animator.addCompletion { (pos) in
            self.animator = nil
            transitionContext.completeTransition(pos == .end)
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
    
    // MARK: - UIViewControllerInteractiveTransitioning
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        let _ = self.interruptibleAnimator(using: transitionContext)
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
