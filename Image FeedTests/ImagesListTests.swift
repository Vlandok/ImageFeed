@testable import Image_Feed
import XCTest

final class ImagesListTests: XCTestCase {
    
    func testViewDidLoadLoadsInitialDataAndSubscribes() {
        // given
        let service = ImagesListServiceMock(photos: makePhotos(count: 2))
        let router = ImagesListRouterMock()
        let presenter = ImagesListPresenter(imagesService: service, router: router)
        let view = ImagesListViewSpy()
        presenter.view = view
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertEqual(view.reloadDataCalled, 1)
        XCTAssertEqual(presenter.numberOfRows(), 2)
    }
    
    func testNotificationInsertsOnlyDelta() {
        // given
        let service = ImagesListServiceMock(photos: makePhotos(count: 2))
        let router = ImagesListRouterMock()
        let presenter = ImagesListPresenter(imagesService: service, router: router)
        let view = ImagesListViewSpy()
        presenter.view = view
        presenter.viewDidLoad()
        
        // when
        service.photos.append(contentsOf: makePhotos(count: 3, offset: 2))
        NotificationCenter.default.post(name: ImagesListServiceImpl.didChangeNotification, object: nil)
        
        // then
        XCTAssertEqual(view.insertedIndexPaths, [IndexPath(row: 2, section: 0), IndexPath(row: 3, section: 0), IndexPath(row: 4, section: 0)])
        XCTAssertEqual(presenter.numberOfRows(), 5)
    }
    
    func testWillDisplayTriggersPagingAtEnd() {
        // given
        let service = ImagesListServiceMock(photos: makePhotos(count: 2))
        let router = ImagesListRouterMock()
        let presenter = ImagesListPresenter(imagesService: service, router: router)
        let view = ImagesListViewSpy()
        presenter.view = view
        presenter.viewDidLoad()
        
        // when
        presenter.willDisplayRow(at: IndexPath(row: 1, section: 0))
        
        // then
        XCTAssertTrue(service.fetchNextPageCalled)
    }
    
    func testDidTapLikeReloadsRowOnSuccess() {
        // given
        let service = ImagesListServiceMock(photos: makePhotos(count: 1))
        service.changeLikeResult = .success(())
        let router = ImagesListRouterMock()
        let presenter = ImagesListPresenter(imagesService: service, router: router)
        let view = ImagesListViewSpy()
        presenter.view = view
        presenter.viewDidLoad()
        
        // when
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))
        
        // then
        XCTAssertEqual(view.reloadedIndexPaths, [IndexPath(row: 0, section: 0)])
    }
    
    func testDidSelectNavigatesToSingleImage() {
        // given
        let service = ImagesListServiceMock(photos: makePhotos(count: 1))
        let router = ImagesListRouterMock()
        let presenter = ImagesListPresenter(imagesService: service, router: router)
        let view = ImagesListViewSpy()
        presenter.view = view
        presenter.viewDidLoad()
        
        // when
        presenter.didSelectRow(at: IndexPath(row: 0, section: 0))
        
        // then
        XCTAssertTrue(router.navigateCalled)
    }
}

private final class ImagesListViewSpy: ImagesListViewControllerProtocol {
    var presenter: Image_Feed.ImagesListPresenterProtocol?
    var reloadDataCalled = 0
    var insertedIndexPaths: [IndexPath] = []
    var reloadedIndexPaths: [IndexPath] = []
    
    func reloadData() { reloadDataCalled += 1 }
    func insertRows(at indexPaths: [IndexPath]) { insertedIndexPaths.append(contentsOf: indexPaths) }
    func reloadRows(at indexPaths: [IndexPath]) { reloadedIndexPaths.append(contentsOf: indexPaths) }
}

private final class ImagesListRouterMock: ImagesListRouter {
    private(set) var navigateCalled = false
    func navigateToSingleImage(url: URL) { navigateCalled = true }
}

private final class ImagesListServiceMock: ImagesListService {
    var photos: [Image_Feed.Photo]
    var fetchNextPageCalled = false
    var changeLikeResult: Result<Void, Error> = .success(())
    
    init(photos: [Image_Feed.Photo]) { self.photos = photos }
    
    func fetchPhotosNextPage() { fetchNextPageCalled = true }
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            let p = photos[index]
            photos[index] = Photo(id: p.id, size: p.size, createdAt: p.createdAt, welcomeDescription: p.welcomeDescription, thumbImageURL: p.thumbImageURL, largeImageURL: p.largeImageURL, isLiked: !p.isLiked)
        }
        completion(changeLikeResult)
    }
}

private func makePhotos(count: Int, offset: Int = 0) -> [Image_Feed.Photo] {
    return (0..<count).map { i in
        let id = "id_\(i + offset)"
        return Photo(
            id: id,
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "https://example.com/thumb_\(id).jpg",
            largeImageURL: "https://example.com/large_\(id).jpg",
            isLiked: false
        )
    }
}
