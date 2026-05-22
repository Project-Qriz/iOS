import UIKit

public final class PaddedLabel: UILabel {
    public var horizontalPadding: CGFloat = 8
    public var verticalPadding: CGFloat = 0

    public override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
        super.drawText(in: rect.inset(by: insets))
    }

    public override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + horizontalPadding * 2, height: size.height + verticalPadding * 2)
    }
}
