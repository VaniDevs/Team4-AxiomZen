import UIKit

class PhotoCell : UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    var photoURL: NSURL? {
        didSet {
            if let photoURL = photoURL {
                imageView.setSecureImage(withURL: photoURL)
            } else {
                clearImage()
            }
        }
    }

    func clearImage() {
        imageView.cancelImageRequest()
        imageView.image = nil
    }

    // MARK: UICollectionReusableView

    override func prepareForReuse() {
        super.prepareForReuse()

        clearImage()
    }

}