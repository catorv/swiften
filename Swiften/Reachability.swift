//
//  Reachability.swift
//  Swiften
//
//  Created by Cator Vee on 5/25/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import SystemConfiguration
import Foundation

func reachabilityCallback(reachability: SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutablePointer<Void>) {
    let reachability = Unmanaged<Reachability>.fromOpaque(COpaquePointer(info)).takeUnretainedValue()

    dispatch_async(dispatch_get_main_queue()) {
        reachability.reachabilityChanged(flags)
    }
}

public class Reachability: CustomStringConvertible {

    public typealias NetworkReachable = (Reachability) -> ()
    public typealias NetworkUnreachable = (Reachability) -> ()

    public enum NetworkStatus: CustomStringConvertible {

        case notReachable, reachableViaWiFi, reachableViaWWAN

        public var description: String {
            switch self {
            case .reachableViaWWAN:
                return "WWAN"
            case .reachableViaWiFi:
                return "WiFi"
            case .notReachable:
                return "NoConnection"
            }
        }
    }

    // MARK: - Properties
    
    public var reachableOnWWAN: Bool
    
    public var currentReachabilityStatus: NetworkStatus {
        if isReachable() {
            if isReachableViaWiFi() {
                return .reachableViaWiFi
            }
            if isRunningOnDevice {
                return .reachableViaWWAN
            }
        }
        return .notReachable
    }

    private var reachabilityFlags: SCNetworkReachabilityFlags {
        guard let reachabilityRef = reachabilityRef else { return SCNetworkReachabilityFlags() }

        var flags = SCNetworkReachabilityFlags()
        let gotFlags = withUnsafeMutablePointer(&flags) {
            SCNetworkReachabilityGetFlags(reachabilityRef, UnsafeMutablePointer($0))
        }

        if gotFlags {
            return flags
        } else {
            return SCNetworkReachabilityFlags()
        }
    }

    private let isRunningOnDevice: Bool = {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            return false
        #else
            return true
        #endif
    }()

    private var notifierRunning = false
    private var reachabilityRef: SCNetworkReachability?
    private var previousFlags: SCNetworkReachabilityFlags?
    
    // MARK: - Statics
    
    public static var networkStatus: NetworkStatus {
        return Reachability.reachabilityForInternetConnection()?.currentReachabilityStatus ?? .notReachable
    }
    
    public static func isReachable() -> Bool {
        return Reachability.reachabilityForInternetConnection()?.isReachable() == true
    }
    
    public static func isReachableViaWWAN() -> Bool {
        return Reachability.reachabilityForInternetConnection()?.isReachableViaWWAN() == true
    }
    
    public static func isReachableViaWiFi() -> Bool {
        return Reachability.reachabilityForInternetConnection()?.isReachableViaWiFi() == true
    }

    // MARK: - Initialisation methods

    required public init(reachabilityRef: SCNetworkReachability) {
        reachableOnWWAN = true
        self.reachabilityRef = reachabilityRef
    }

    public convenience init?(hostname: String) {
        let nodename = (hostname as NSString).UTF8String
        guard let ref = SCNetworkReachabilityCreateWithName(nil, nodename) else { return nil }
        self.init(reachabilityRef: ref)
    }

    public class func reachabilityForInternetConnection() -> Reachability? {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let ref = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else { return nil }

        return Reachability(reachabilityRef: ref)
    }

    // MARK: - Notifier methods
    
    public func startNotifier() -> Bool {
        guard !notifierRunning else { return true }
        guard let reachabilityRef = reachabilityRef else { return false }

        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = UnsafeMutablePointer(Unmanaged.passUnretained(self).toOpaque())

        if SCNetworkReachabilitySetCallback(reachabilityRef, reachabilityCallback, &context) {
            if SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode) {
                notifierRunning = true
                return true
            }
        }

        stopNotifier()
        return false
    }

    public func stopNotifier() {
        defer { notifierRunning = false }
        guard let reachabilityRef = reachabilityRef else { return }
        SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }

    // MARK: - Connection test methods
    
    public func isReachable() -> Bool {
        let flags = reachabilityFlags
        return isReachableWithFlags(flags)
    }

    public func isReachableViaWWAN() -> Bool {
        let flags = reachabilityFlags
        
        // Check we're not on the simulator, we're REACHABLE and check we're on WWAN
        return isRunningOnDevice && isReachable(flags) && isOnWWAN(flags)
    }

    public func isReachableViaWiFi() -> Bool {
        let flags = reachabilityFlags
        
        // Check we're reachable
        if !isReachable(flags) {
            return false
        }

        // Must be on WiFi if reachable but not on an iOS device (i.e. simulator)
        if !isRunningOnDevice {
            return true
        }

        // Check we're NOT on WWAN
        return !isOnWWAN(flags)
    }

    // MARK: - *** Private methods ***
    private func reachabilityChanged(flags: SCNetworkReachabilityFlags) {
        guard previousFlags != flags else { return }

        Log.info("Reachability: \(string(forFlags: flags))")
        Notifications.reachabilityChanged.post(self)

        previousFlags = flags
    }

    private func isReachableWithFlags(flags: SCNetworkReachabilityFlags) -> Bool {

        if !isReachable(flags) {
            return false
        }

        if isConnectionRequiredOrTransient(flags) {
            return false
        }

        if isRunningOnDevice {
            if isOnWWAN(flags) && !reachableOnWWAN {
                // We don't want to connect when on 3G.
                return false
            }
        }

        return true
    }

    // WWAN may be available, but not active until a connection has been established.
    // WiFi may require a connection for VPN on Demand.
    private func isConnectionRequired() -> Bool {
        return connectionRequired()
    }

    private func connectionRequired() -> Bool {
        let flags = reachabilityFlags
        return isConnectionRequired(flags)
    }

    // Dynamic, on demand connection?
    private func isConnectionOnDemand() -> Bool {
        let flags = reachabilityFlags
        return isConnectionRequired(flags) && isConnectionOnTrafficOrDemand(flags)
    }

    // Is user intervention required?
    private func isInterventionRequired() -> Bool {
        let flags = reachabilityFlags
        return isConnectionRequired(flags) && isInterventionRequired(flags)
    }

    private func isOnWWAN(flags: SCNetworkReachabilityFlags) -> Bool {
        #if os(iOS)
            return flags.contains(.IsWWAN)
        #else
            return false
        #endif
    }
    private func isReachable(flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.Reachable)
    }
    private func isConnectionRequired(flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.ConnectionRequired)
    }
    private func isInterventionRequired(flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.InterventionRequired)
    }
    private func isConnectionOnTraffic(flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.ConnectionOnTraffic)
    }
    private func isConnectionOnDemand(flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.ConnectionOnDemand)
    }
    func isConnectionOnTrafficOrDemand(flags: SCNetworkReachabilityFlags) -> Bool {
        return !flags.intersect([.ConnectionOnTraffic, .ConnectionOnDemand]).isEmpty
    }
    private func isTransientConnection(flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.TransientConnection)
    }
    private func isLocalAddress(flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.IsLocalAddress)
    }
    private func isDirect(flags: SCNetworkReachabilityFlags) -> Bool {
        return flags.contains(.IsDirect)
    }
    private func isConnectionRequiredOrTransient(flags: SCNetworkReachabilityFlags) -> Bool {
        let testcase: SCNetworkReachabilityFlags = [.ConnectionRequired, .TransientConnection]
        return flags.intersect(testcase) == testcase
    }

    private func string(forFlags flags: SCNetworkReachabilityFlags) -> String {
        var W: String
        if isRunningOnDevice {
            W = isOnWWAN(flags) ? "W" : "-"
        } else {
            W = "X"
        }
        let R = isReachable(flags) ? "R" : "-"
        let c = isConnectionRequired(flags) ? "c" : "-"
        let t = isTransientConnection(flags) ? "t" : "-"
        let i = isInterventionRequired(flags) ? "i" : "-"
        let C = isConnectionOnTraffic(flags) ? "C" : "-"
        let D = isConnectionOnDemand(flags) ? "D" : "-"
        let l = isLocalAddress(flags) ? "l" : "-"
        let d = isDirect(flags) ? "d" : "-"

        return "\(W)\(R) \(c)\(t)\(i)\(C)\(D)\(l)\(d)"
    }

    public var description: String {
        return string(forFlags: reachabilityFlags)
    }

    deinit {
        stopNotifier()
        reachabilityRef = nil
    }
}