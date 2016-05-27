//
//  String+Extension.swift
//  Swiften
//
//  Created by Cator Vee on 5/23/16.
//  Copyright © 2016 Cator Vee. All rights reserved.
//

import Foundation
import CommonCrypto

// MARK: Length
extension String {
    /// 字符串长度
    public var length: Int { return self.characters.count }
}

// MARK: URL encode/decode

extension String {
    /// URL编码
    public var urlEncoded: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet()) ?? self
    }
    
    public var urlEncodingWithQueryAllowedCharacters: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) ?? self
    }

    /// URL解码
    public var urlDecoded: String {
        return self.stringByRemovingPercentEncoding ?? self
    }
}

// MARK: Digest

extension String {
    public var md5: String {
        let data = self.data
        var digest = [UInt8](count:Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        CC_MD5(data.bytes, CC_LONG(data.length), &digest)
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joinWithSeparator("")
    }
    
    public var sha1: String {
        let data = self.data
        var digest = [UInt8](count:Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joinWithSeparator("")
    }
}

// MARK: Base64

extension String {
    /// Base64编码
    public var base64Encoded: String {
        return data.base64EncodedStringWithOptions([])
    }
    
    /// Base64解码
    public var base64Decoded: String {
        return NSData(base64EncodedString: self, options: [])?.string ?? ""
    }
}

// MARK: Get the size of the text

extension String {
    /// 计算制定字体大小的文字显示尺寸（系统默认字体）
    public func size(fontSize fontSize: CGFloat, width: CGFloat = CGFloat.max) -> CGSize {
        return size(font: UIFont.systemFontOfSize(fontSize), width: width)
    }
    
    /// 计算制定字体的文字显示尺寸
    public func size(font font: UIFont, width: CGFloat = CGFloat.max) -> CGSize {
        let size = CGSizeMake(width, CGFloat.max)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping
        let attributes = [
            NSFontAttributeName: font,
            NSParagraphStyleAttributeName: paragraphStyle.copy()
        ]

        return (self as NSString).boundingRectWithSize(size, options: .UsesLineFragmentOrigin, attributes: attributes, context: nil).size
    }
}

// MARK: Substring

extension String {
    public func substring(fromIndex: Int, _ toIndex: Int = Int.max) -> String? {
        let len = self.length
        var start: Int
        var end: Int
        if fromIndex < 0 {
            start = 0
            end = len + fromIndex
        } else {
            start = fromIndex
            if toIndex < 0 {
                end = len + toIndex
            } else {
                end = min(toIndex, len)
            }
        }
        
        if start > end {
            return nil
        }
        
        return self[start..<end]
    }
    
    public subscript(range: Range<Int>) -> String? {
        let len = self.length
        if range.startIndex >= len || range.endIndex < 0 {
            return nil
        }
        
        let startIndex = self.startIndex.advancedBy(max(0, range.startIndex))
        let endIndex = self.startIndex.advancedBy(min(len, range.endIndex))
        
        return self[startIndex..<endIndex]
    }
    
    public subscript(index: Int) -> Character? {
        if index < 0 || index >= self.length {
            return nil
        }
        return self[self.startIndex.advancedBy(index)]
    }
}

// MARK: Trim

extension String {
    /// 删除前后空白符（包含空格、Tab、回车、换行符）
    public var trimmed: String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}

// MARK: Localized String

extension String {
    public var localizedString: String {
        return NSLocalizedString(self, comment: "")
    }
}