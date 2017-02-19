//
//  UIImage+Extension.swift
//  Swiften
//
//  Created by Cator Vee on 5/25/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation

// TODO: 支持GIF动画

// MARK: Data

extension UIImage {
  public var data: Data? {
    switch contentType {
    case .jpeg:
      return UIImageJPEGRepresentation(self, 1)
    case .png:
      return UIImagePNGRepresentation(self)
    //case .GIF:
    //  return UIImageAnimatedGIFRepresentation(self)
    default:
      return nil
    }
  }
}

// MARK: Content Type

extension UIImage {
  fileprivate struct AssociatedKey {
    static var contentType: Int = 0
  }
  
  public enum ContentType: Int {
    case unknown = 0, png, jpeg, gif, tiff, webp
    
    public var mimeType: String {
      switch self {
      case .jpeg: return "image/jpeg"
      case .png:  return "image/png"
      case .gif:  return "image/gif"
      case .tiff: return "image/tiff"
      case .webp: return "image/webp"
      default:    return ""
      }
    }
    
    public var extendName: String {
      switch self {
      case .jpeg: return ".jpg"
      case .png:  return ".png"
      case .gif:  return ".gif"
      case .tiff: return ".tiff"
      case .webp: return ".webp"
      default:    return ""
      }
    }
    
    
    public static func contentType(mimeType: String?) -> ContentType {
      guard let mime = mimeType else { return .unknown }
      switch mime {
      case "image/jpeg": return .jpeg
      case "image/png":  return .png
      case "image/gif":  return .gif
      case "image/tiff": return .tiff
      case "image/webp": return .webp
      default:           return .unknown
      }
    }
    
    public static func contentTypeWithImageData(_ imageData: Data?) -> ContentType {
      guard let data = imageData else { return .unknown }
      
      var c = [UInt32](repeating: 0, count: 1)
      (data as NSData).getBytes(&c, length: 1)
      
      switch (c[0]) {
      case 0xFF:
        return .jpeg
      case 0x89:
        return .png
      case 0x47:
        return .gif
      case 0x49, 0x4D:
        return .tiff
      case 0x52:
        // R as RIFF for WEBP
        if data.count >= 12 {
          let startIndex = data.index(data.startIndex, offsetBy: 8)
          let endIndex = data.index(startIndex, offsetBy: 4)
          if let type = String(data: data.subdata(in: startIndex..<endIndex), encoding: .ascii) {
            if type.hasPrefix("RIFF") && type.hasSuffix("WEBP") {
              return .webp
            }
          }
        }
      default:
        break
      }
      return .unknown
    }
  }
  
  public var contentType: ContentType {
    get {
      let value = objc_getAssociatedObject(self, &AssociatedKey.contentType) as? Int ?? 0
      if value == 0 {
        var result: ContentType
        //if let _ = UIImageAnimatedGIFRepresentation(self) {
        //result = .gif
        //} else
        if let _ = UIImageJPEGRepresentation(self, 1) {
          result = .jpeg
        } else if let _ = UIImagePNGRepresentation(self) {
          result = .png
        } else {
          result = .unknown
        }
        objc_setAssociatedObject(self, &AssociatedKey.contentType, result.rawValue, .OBJC_ASSOCIATION_RETAIN)
        return result
      }
      return ContentType(rawValue: value) ?? .unknown
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKey.contentType, newValue.rawValue, .OBJC_ASSOCIATION_RETAIN)
    }
  }
  
  convenience init?(data: Data, contentType: ContentType) {
    self.init(data: data)
    self.contentType = contentType
  }
}
