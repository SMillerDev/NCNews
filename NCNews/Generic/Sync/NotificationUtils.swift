//
//  NotificationUtils.swift
//  NCNews
//
//  Created by Sean Molenaar on 25/02/2018.
//  Copyright © 2018 Sean Molenaar. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationUtils: Any {
    static var badgeIndicatorCount: Int {
        set(badgeCount) {
            let application = UIApplication.shared
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                center.requestAuthorization(options: [.badge, .alert, .sound]) { _, _ in }
            } else {
                application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
            }
            application.registerForRemoteNotifications()
            application.applicationIconBadgeNumber = badgeCount
        }
        get {
            let application = UIApplication.shared
            return application.applicationIconBadgeNumber
        }
    }
}
