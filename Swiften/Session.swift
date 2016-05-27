//
//  Session.swift
//  Swiften
//
//  Created by Cator Vee on 5/26/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation
import CoreLocation

public class Session: LocalStorage {
    /* Tick */
    public var tick: Int {
        let result = integer(forKey: "TICK")
        setObject((result + 1) % Int.max, forKey: "TICK")
        return result
    }
    
    /* deviceId */
    public var deviceId: String {
        get {
            if let udid = string(forKey: "UDID") {
                return udid
            }
            
            let udid = UDID.UDIDString
            setObject(udid, forKey: "UDID")
            
            return udid
        }
        set { setObject(newValue, forKey: "UDID") }
    }
    
    /** uid */
    public var uid: Int {
        get { return integer(forKey: "UID") }
        set { setObject(newValue, forKey: "UID") }
    }
    
    /** authType */
    public var authType: String {
        get { return string(forKey: "AUTH_TYPE", defaultValue: "") }
        set { setObject(newValue, forKey: "AUTH_TYPE") }
    }
    
    /** token */
    public var token: String {
        get { return string(forKey: "TOKEN", defaultValue: "") }
        set { setObject(newValue, forKey: "TOKEN") }
    }
    
    /** imei */
    public var imei: String {
        get { return string(forKey: "IMEI", defaultValue: "") }
        set { setObject(newValue, forKey: "IMEI") }
    }
    
    /** Location */
    public var location: CLLocation {
        get {
            let latitude = double(forKey: "LATITUDE")
            let longitude = double(forKey: "LONGITUDE")
            return CLLocation(latitude: latitude, longitude: longitude)
        }
        set {
            begin()
            setObject(newValue.coordinate.latitude, forKey: "LATITUDE")
            setObject(newValue.coordinate.longitude, forKey: "LONGITUDE")
        }
    }
    
    /** city */
    public var city: String! {
        get { return string(forKey: "CITY", defaultValue: "") }
        set { setObject(newValue, forKey: "CITY") }
    }
}