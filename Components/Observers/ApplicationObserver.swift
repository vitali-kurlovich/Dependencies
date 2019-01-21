//
// Created by Vitalii Nevgadailov on 2018-11-01.
// Copyright (c) 2018 SIA Mystic Moments. All rights reserved.
//

import UIKit

class ApplicationObserver {
    var willEnterForeground: (() -> Void)? {
        didSet {
            if willEnterForeground != nil {
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(handleWillEnterForeground),
                    name: UIApplication.willEnterForegroundNotification,
                    object: nil
                )
            } else {
                NotificationCenter.default.removeObserver(
                    self,
                    name: UIApplication.willEnterForegroundNotification,
                    object: nil
                )
            }
        }
    }

    var didEnterBackground: (() -> Void)? {
        didSet {
            if didEnterBackground != nil {
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(handleDidEnterBackground),
                    name: UIApplication.didEnterBackgroundNotification,
                    object: nil
                )
            } else {
                NotificationCenter.default.removeObserver(
                    self,
                    name: UIApplication.didEnterBackgroundNotification,
                    object: nil
                )
            }
        }
    }

    var didBecomeActive: (() -> Void)? {
        didSet {
            if didBecomeActive != nil {
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(handleDidBecomeActive),
                    name: UIApplication.didBecomeActiveNotification,
                    object: nil
                )
            } else {
                NotificationCenter.default.removeObserver(
                    self,
                    name: UIApplication.didBecomeActiveNotification,
                    object: nil
                )
            }
        }
    }
}

extension ApplicationObserver {
    @objc
    private func handleWillEnterForeground() {
        willEnterForeground?()
    }

    @objc
    private func handleDidBecomeActive() {
        didBecomeActive?()
    }

    @objc
    private func handleDidEnterBackground() {
        didEnterBackground?()
    }
}
