//
//  BaseNavigationController.swift
//  PostalCode
//
//  Created by Koichiro OCHIISHI on 2025/05/05.
//  Copyright © 2025 OCHIISHI Koichiro. All rights reserved.
//

import AppTrackingTransparency
import GoogleMobileAds
import UIKit

class BaseNavigationController: UINavigationController {

    private let bannerView = BannerView(adSize: AdSizeBanner)
    private let loadingView = UIView()
    private let indicator = UIActivityIndicatorView(style: .medium)

    private var bannerWidthConstraint: NSLayoutConstraint!
    private var bannerHeightConstraint: NSLayoutConstraint!
    private var hasRequestedBanner = false
    private var hasFallenBackToStandardBanner = false

    private(set) var bannerSize: CGSize = .zero

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.tintColor = Color.primary
        tabBarController?.tabBar.tintColor = Color.primary

        setupLoadingView()
        setupBannerView()
        requestTrackingAuthorizationIfPossible()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateBannerSize()
    }

    // MARK: - Loading

    private func setupLoadingView() {
        loadingView.alpha = 0
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)

        indicator.startAnimating()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        loadingView.addSubview(indicator)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            loadingView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),

            loadingView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            loadingView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            indicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor),
        ])
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

    // MARK: - BannerView

    private func setupBannerView() {
        bannerView.adUnitID = "ca-app-pub-9983442877454265/2956248829"
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)

        bannerWidthConstraint = bannerView.widthAnchor.constraint(
            equalToConstant: cgSize(for: AdSizeBanner).width)
        bannerHeightConstraint = bannerView.heightAnchor.constraint(
            equalToConstant: cgSize(for: AdSizeBanner).height)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            bannerWidthConstraint,
            bannerHeightConstraint,
            bannerView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            bannerView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
        ])
    }

    private func updateBannerSize() {
        guard !hasFallenBackToStandardBanner else { return }

        let safeAreaInsets = view.safeAreaInsets
        let availableWidth = view.bounds.width - safeAreaInsets.left - safeAreaInsets.right
        guard availableWidth > 0 else { return }

        // GoogleMobileAds は UIScreen を基準に画面に収まるか検証するため、その幅で頭打ちにする
        let requestWidth = min(availableWidth, UIScreen.main.bounds.width)
        let adSize = currentOrientationAnchoredAdaptiveBanner(width: requestWidth)
        let size = cgSize(for: adSize)

        if bannerSize != size {
            bannerSize = size
            bannerWidthConstraint.constant = size.width
            bannerHeightConstraint.constant = size.height
            bannerView.adSize = adSize
        }

        guard !hasRequestedBanner else { return }
        hasRequestedBanner = true
        bannerView.load(Request())
    }

    // MARK: - AppTrackingTransparency

    private func requestTrackingAuthorizationIfPossible() {
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            Task {
                await ATTrackingManager.requestTrackingAuthorization()
            }
        }
    }
}

extension BaseNavigationController: BannerViewDelegate {
    /// 要求したサイズが画面に収まらないと判定された場合だけ、確実に収まる標準サイズへ一度だけ下げる
    /// no-fill や通信エラーは別のコードなので、その場合はサイズを変えない
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        guard !hasFallenBackToStandardBanner,
            let requestError = error as? RequestError, requestError.code == .invalidRequest
        else { return }

        hasFallenBackToStandardBanner = true

        let size = cgSize(for: AdSizeBanner)
        bannerSize = size
        bannerWidthConstraint.constant = size.width
        bannerHeightConstraint.constant = size.height
        bannerView.adSize = AdSizeBanner
        bannerView.load(Request())
    }
}
