//
//  DispatchTimer.swift
//  VetChat
//
//  Created by Vitali Kurlovich on 11/28/18.
//  Copyright © 2018 SIA Mystic Moments. All rights reserved.
//

import Foundation

class DispatchTimer {
    let interval: TimeInterval
    let repeats: Bool
    let dispatchQueue: DispatchQueue

    init(interval: TimeInterval = TimeInterval(1),
         repeats: Bool = true,
         dispatchQueue: DispatchQueue = DispatchQueue.global()) {
        self.interval = interval
        self.repeats = repeats
        self.dispatchQueue = dispatchQueue
    }

    private(set) var started: Bool = false

    var onTimer: (() -> Void)? {
        didSet {
            if onTimer == nil {
                pause()
            }
        }
    }

    func resume() {
        started = true
        prepareTick(deadline: .now() + interval)
    }

    func pause() {
        started = false
    }

    private
    func prepareTick(deadline: DispatchTime) {
        dispatchQueue.asyncAfter(deadline: deadline) { [weak self] in
            guard let self = self, self.started else { return }

            let nextDeadline = DispatchTime.now() + self.interval
            self.onTick()
            if self.repeats {
                self.prepareTick(deadline: nextDeadline)
            } else {
                self.started = false
            }
        }
    }

    private
    func onTick() {
        onTimer?()
    }
}
