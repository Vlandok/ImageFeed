import UIKit

protocol ImagesListRouter: AnyObject {
    func navigateToSingleImage(url: URL)
}

final class ImagesListRouterImpl: ImagesListRouter {
    private weak var sourceViewController: UIViewController?
    
    init(sourceViewController: UIViewController) {
        self.sourceViewController = sourceViewController
    }
    
    func navigateToSingleImage(url: URL) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SingleImageViewController") as? SingleImageViewController else {
            if let imagesVC = sourceViewController as? ImagesListViewController {
                imagesVC.performSegue(withIdentifier: "ShowSingleImage", sender: IndexPath(row: 0, section: 0))
            }
            return
        }
        vc.modalPresentationStyle = .fullScreen
        vc.fullImageURL = url
        sourceViewController?.present(vc, animated: true)
    }
}


