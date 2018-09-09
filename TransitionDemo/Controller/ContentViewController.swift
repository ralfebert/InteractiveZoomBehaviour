import UIKit

class ContentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func close() {
        self.dismiss(animated: true, completion: nil)
    }

}
