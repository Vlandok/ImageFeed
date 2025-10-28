import UIKit

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func willDisplayRow(at indexPath: IndexPath)
    func didSelectRow(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath)
    func numberOfRows() -> Int
    func item(at indexPath: IndexPath) -> ImagesListItemUiModel?
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    private let imagesService: ImagesListService
    private let router: ImagesListRouter
    private let dateFormatter: DateFormatter
    private var items: [ImagesListItemUiModel] = []
    private var observer: NSObjectProtocol?
    
    init(imagesService: ImagesListService, router: ImagesListRouter, dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()) {
        self.imagesService = imagesService
        self.router = router
        self.dateFormatter = dateFormatter
    }
    
    deinit {
        if let observer { NotificationCenter.default.removeObserver(observer) }
    }
    
    func viewDidLoad() {
        items = mapPhotosToItems(imagesService.photos)
        view?.reloadData()
        
        observer = NotificationCenter.default.addObserver(forName: ImagesListServiceImpl.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            let oldCount = self.items.count
            let newPhotos = self.imagesService.photos
            let newCount = newPhotos.count
            guard newCount > oldCount else {
                self.items = self.mapPhotosToItems(newPhotos)
                self.view?.reloadData()
                return
            }
            
            self.items = self.mapPhotosToItems(newPhotos)
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            self.view?.insertRows(at: indexPaths)
        }
        
        if imagesService.photos.isEmpty {
            imagesService.fetchPhotosNextPage()
        }
    }
    
    func willDisplayRow(at indexPath: IndexPath) {
        if indexPath.row + 1 == items.count {
            imagesService.fetchPhotosNextPage()
        }
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        guard items.indices.contains(indexPath.row), let url = items[indexPath.row].largeURL else { return }
        router.navigateToSingleImage(url: url)
    }
    
    func didTapLike(at indexPath: IndexPath) {
        guard items.indices.contains(indexPath.row) else { return }
        let photo = imagesService.photos[indexPath.row]
        imagesService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.items[indexPath.row] = self.mapPhotoToItem(self.imagesService.photos[indexPath.row])
                self.view?.reloadRows(at: [indexPath])
            case .failure:
                break
            }
        }
    }
    
    func numberOfRows() -> Int {
        return items.count
    }
    
    func item(at indexPath: IndexPath) -> ImagesListItemUiModel? {
        guard items.indices.contains(indexPath.row) else { return nil }
        return items[indexPath.row]
    }
    
    private func mapPhotosToItems(_ photos: [Photo]) -> [ImagesListItemUiModel] {
        photos.map(mapPhotoToItem)
    }
    
    private func mapPhotoToItem(_ photo: Photo) -> ImagesListItemUiModel {
        let dateText: String
        if let createdAt = photo.createdAt {
            dateText = dateFormatter.string(from: createdAt)
        } else {
            dateText = ""
        }
        return ImagesListItemUiModel(
            id: photo.id,
            thumbURL: URL(string: photo.thumbImageURL),
            largeURL: URL(string: photo.largeImageURL),
            dateText: dateText,
            size: photo.size,
            isLiked: photo.isLiked
        )
    }
}
