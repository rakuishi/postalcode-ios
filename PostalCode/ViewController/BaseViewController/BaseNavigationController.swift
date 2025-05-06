//
//  BaseNavigationController.swift
//  PostalCode
//
//  Created by Koichiro OCHIISHI on 2025/05/05.
//  Copyright © 2025 OCHIISHI Koichiro. All rights reserved.
//

import UIKit
import GoogleMobileAds
import AppTrackingTransparency

class BaseNavigationController: UINavigationController {

    private var bannerView: BannerView!
    private var loadingView: UIView!
    private var indicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.tintColor = Color.primary
        tabBarController?.tabBar.tintColor = Color.primary

        setupLoadingView()
        setupBannerView()
        requestTrackingAuthorizationIfPossible()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        loadingView.frame = loadingViewFrame()
        indicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        bannerView.frame = adViewFrame()
    }

    deinit {
        bannerView = nil
    }

    // MARK: - Loading

    private func setupLoadingView() {
        loadingView = UIView(frame: loadingViewFrame())
        loadingView.alpha = 0
        view.addSubview(loadingView)

        indicator = UIActivityIndicatorView(style: .medium)
        indicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        indicator.startAnimating()
        loadingView.addSubview(indicator)
    }

    func startLoading() {
        UIView.animate(withDuration: 0.2) {
            self.loadingView.alpha = 1
        }
    }

    func stopLoading() {
        UIView.animate(withDuration: 0.2) {
            self.loadingView.alpha = 0
        }
    }

    private func loadingViewFrame() -> CGRect {
        let bounds = UIScreen.main.bounds
        let safeAreaInsets = getSafeAreaInsets()
        let statusBarHeight = safeAreaInsets.top
        let y = statusBarHeight + navigationBar.frame.size.height + 1

        return CGRect(x: 0, y: y, width: bounds.width, height: bounds.height - y - 49)
    }

    // MARK: - BannerView

    private func setupBannerView() {
        bannerView = BannerView(frame: adViewFrame())
        bannerView.adUnitID = "ca-app-pub-9983442877454265/2956248829"
        bannerView.rootViewController = self
        view.addSubview(bannerView)
        bannerView.load(Request())
    }

    private func adViewFrame() -> CGRect {
        let bounds = UIScreen.main.bounds
        let safeAreaInsets = getSafeAreaInsets()

        let ratio = min(bounds.width / 320, 1.5)
        let width = 320 * ratio
        let height = 50 * ratio
        let x = (bounds.width - width) / 2
        let y = tabBarController != nil
            ? bounds.height - safeAreaInsets.bottom - 49 - height
            : bounds.height - safeAreaInsets.bottom - height

        return CGRect(x: x, y: y, width: width, height: height)
    }

    // MARK: - AppTrackingTransparency

    private func requestTrackingAuthorizationIfPossible() {
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            Task {
                await ATTrackingManager.requestTrackingAuthorization()
            }
        }
    }

    // MARK: - Safe Area Insets

    private func getSafeAreaInsets() -> UIEdgeInsets {
        guard let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first else {
            return .zero
        }
        return window.safeAreaInsets
    }
}
