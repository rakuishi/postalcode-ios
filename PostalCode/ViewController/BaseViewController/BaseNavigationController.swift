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

    private enum Banner {
        static let baseSize = CGSize(width: 320, height: 50)
        static let maxScale: CGFloat = 1.5
    }

    private let bannerView = BannerView(adSize: AdSizeBanner)
    private let loadingView = UIView()
    private let indicator = UIActivityIndicatorView(style: .medium)

    private var bannerWidthConstraint: NSLayoutConstraint!
    private var bannerHeightConstraint: NSLayoutConstraint!
    private var hasRequestedBanner = false

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
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)

        bannerWidthConstraint = bannerView.widthAnchor.constraint(
            equalToConstant: Banner.baseSize.width)
        bannerHeightConstraint = bannerView.heightAnchor.constraint(
            equalToConstant: Banner.baseSize.height)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            bannerWidthConstraint,
            bannerHeightConstraint,
            bannerView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            bannerView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
        ])
    }

    private func updateBannerSize() {
        let safeAreaInsets = view.safeAreaInsets
        let availableWidth = view.bounds.width - safeAreaInsets.left - safeAreaInsets.right
        guard availableWidth > 0 else { return }

        let ratio = min(availableWidth / Banner.baseSize.width, Banner.maxScale)
        let size = CGSize(
            width: Banner.baseSize.width * ratio, height: Banner.baseSize.height * ratio)

        if bannerWidthConstraint.constant != size.width {
            bannerWidthConstraint.constant = size.width
            bannerHeightConstraint.constant = size.height
            bannerView.adSize = adSizeFor(cgSize: size)
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
