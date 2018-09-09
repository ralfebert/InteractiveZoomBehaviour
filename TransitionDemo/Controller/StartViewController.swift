import UIKit

class StartViewController: UIViewController {

    @IBOutlet var orangeView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func handleViewTap(_: UITapGestureRecognizer) {
        let controller = ContentViewController()
        self.present(controller, animated: true, completion: nil)
    }
}
