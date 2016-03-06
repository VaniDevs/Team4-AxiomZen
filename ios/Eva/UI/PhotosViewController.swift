
import UIKit
import JTSImageViewController

class PhotosViewController : UIViewController {
    struct Constants {
        static let reuseIdentifier = "cell"
    }

    struct Settings {
        static let contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        static let numberOfItemsPerRow = 2
        static let itemHorizontalSpacing: CGFloat = 10
        static let itemsVerticalSpacing: CGFloat = 10
    }

    let interactor = ProfileInteractor()

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!

    var photos: [NSURL] = []
    var photosLoaded = false

    func addPhoto() {
        let actions: [String: UIImagePickerControllerSourceType] = [
            "Photo Library": .PhotoLibrary,
            "Take Photo": .Camera,
        ]

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        for (title, type) in actions {
            if UIImagePickerController.isSourceTypeAvailable(type) {
                let action = UIAlertAction(title: title, style: .Default) { _ in
                    self.openImagePicker(withSourceType: type)
                }
                alert.addAction(action)
            }
        }

        let action = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }


    func openImagePicker(withSourceType type: UIImagePickerControllerSourceType) {
        let controller = UIImagePickerController()
        controller.allowsEditing = true
        controller.sourceType = type
        controller.delegate = self
        presentViewController(controller, animated: true, completion: nil)
    }

    func photoURLAtIndexPath(indexPath: NSIndexPath) -> NSURL? {
        let item = indexPath.item
        guard item < photos.count else { return nil }
        return photos[item]
    }

    func handlePhotosResponse(user: User, photos: [NSURL]) {
        self.photos = photos
        self.collectionView.reloadData()
    }

    func showError(error: NSError) {
        let controller = UIAlertController.controllerWithTitle("Error",
            message: "Failed to load photos: \(error.localizedDescription)")
        presentViewController(controller, animated: true, completion: nil)
    }

    func handleUploadSuccess(newPhotoURL: NSURL) {
        let index = photos.count
        photos.append(newPhotoURL)
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        collectionView.performBatchUpdates({
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }, completion: nil)
    }


    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photos"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("addPhoto"))

        collectionView.registerNib(UINib(nibName: "PhotoCell", bundle: nil),
            forCellWithReuseIdentifier: Constants.reuseIdentifier)
        collectionView.contentInset = Settings.contentInset
        collectionViewLayout.minimumInteritemSpacing = Settings.itemHorizontalSpacing
        collectionViewLayout.minimumLineSpacing = Settings.itemsVerticalSpacing
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if !photosLoaded {
            photosLoaded = true
            interactor.getUser(handlePhotosResponse, onFailure: showError)
        }
    }

}


// MARK: UICollectionViewDataSource

extension PhotosViewController : UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.reuseIdentifier,
            forIndexPath: indexPath) as! PhotoCell

        cell.photoURL = photoURLAtIndexPath(indexPath)

        return cell
    }
}

extension PhotosViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCell
        let imageInfo = JTSImageInfo()
        imageInfo.image = cell.imageView.image
        imageInfo.referenceRect = cell.imageView.frame
        imageInfo.referenceView = cell.imageView.superview
        imageInfo.referenceContentMode = .ScaleAspectFill
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: .Image, backgroundStyle: .Blurred)
        imageViewer.showFromViewController(self, transition: .FromOriginalPosition)
    }
}


// MARK: UIImagePickerControllerDelegate

extension PhotosViewController : UIImagePickerControllerDelegate {

    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismissViewControllerAnimated(true, completion: nil)

        interactor.uploadContextImage(image, onSuccess: handleUploadSuccess, onFailure: showError)
    }
}

extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var size = UIEdgeInsetsInsetRect(collectionView.bounds, Settings.contentInset).width
        size -= CGFloat(Settings.numberOfItemsPerRow - 1) * Settings.itemHorizontalSpacing
        size = size / CGFloat(Settings.numberOfItemsPerRow)
        return CGSize(width: size, height: size)
    }
}

extension PhotosViewController : UINavigationControllerDelegate {}
