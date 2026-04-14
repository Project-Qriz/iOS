import UIKit

public protocol AdService: AnyObject {
    func loadInterstitialAd()
    func showInterstitialAd(from viewController: UIViewController, completion: @escaping () -> Void)
}
