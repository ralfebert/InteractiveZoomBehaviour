import UIKit

class ZoomBehaviour : NSObject {

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
        originViewController?.present(controller, animated: true, completion: nil)
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
