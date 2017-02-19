//
//  Data+Extension.swift
//  Swiften
//
//  Created by Cator Vee on 18/02/2017.
//  Copyright © 2017 Cator Vee. All rights reserved.
//

import Foundation
import CommonCrypto

extension Data {
  
  public var hexString: String {
    var bytes = [UInt8](repeating: 0, count: count)
    copyBytes(to: &bytes, count: count)
    let hexBytes = bytes.map { String(format: "%02hhx", $0) }
    return hexBytes.joined(separator: "")
  }
  
  public var md5: Data {
    var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
    CC_MD5((self as NSData).bytes, CC_LONG(self.count), &digest)
    return Data(bytes: digest)
  }
  
  public var sha1: Data {
    var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
    CC_SHA1((self as NSData).bytes, CC_LONG(self.count), &digest)
    return Data(bytes: digest)
  }
  
}
