  import UIKit


internal class Button : UIButton {
    struct Settings {
        static let cornerRadius: CGFloat = 5
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = Settings.cornerRadius
        layer.masksToBounds = true
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            guard let bgColor = backgroundColor else {
                setBackgroundImage(nil, forState: .Normal)
                setBackgroundImage(nil, forState: .Highlighted)
                return
            }
            let normal = UIImage.imageWithColor(bgColor, size: bounds.size, cornerRadius: layer.cornerRadius)
            let selected = UIImage.imageWithColor(bgColor.darkerColor(), size: bounds.size, cornerRadius: layer.cornerRadius)
            setBackgroundImage(normal, forState: .Normal)
            setBackgroundImage(selected, forState: .Highlighted)
        }
    }
}