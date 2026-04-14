//
//  AdServiceImpl.swift
//  QRIZ
//
//  Created by 김세훈 on 4/14/26.
//

import UIKit
import QRIZUtils
import GoogleMobileAds

final class AdServiceImpl: NSObject, AdService {

    private var interstitialAd: InterstitialAd?
    private var adCompletion: (() -> Void)?

    private var adUnitID: String {
        Bundle.main.object(forInfoDictionaryKey: "GADInterstitialAdUnitID") as? String ?? ""
    }

    func loadInterstitialAd() {
        let request = Request()
        InterstitialAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            guard let self else { return }
            if let error {
                print("⚠️ [AdService] 광고 로드 실패: \(error.localizedDescription)")
                return
            }
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
            print("✅ [AdService] 광고 로드 완료")
        }
    }

    func showInterstitialAd(from viewController: UIViewController, completion: @escaping () -> Void) {
        guard let ad = interstitialAd else {
            print("⚠️ [AdService] 광고 미준비 — 스킵")
            completion()
            return
        }
        interstitialAd = nil
        adCompletion = completion
        ad.present(from: viewController)
    }
}

// MARK: - FullScreenContentDelegate

extension AdServiceImpl: FullScreenContentDelegate {

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        adCompletion?()
        adCompletion = nil
        loadInterstitialAd()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("⚠️ [AdService] 광고 노출 실패: \(error.localizedDescription)")
        adCompletion?()
        adCompletion = nil
    }
}
