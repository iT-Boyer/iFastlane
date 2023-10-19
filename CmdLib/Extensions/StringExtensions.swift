//
//  StringExtensions.swift
//  CmdLib
//
//  Created by boyer on 2022/3/2.
//

import Foundation
import CommonCrypto

//https://www.jianshu.com/p/4d9c8840e74c
public extension String {
    /* ################################################################## */
    /**
     - returns: the String, as an MD5 hash.
     */
    var md5: String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)

        let hash = NSMutableString()

        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }

        result.deallocate()
        return hash as String
    }
    //  返回字符串的全拼首字母
    var quanpinyin:String{
        let str = CFStringCreateMutableCopy(nil, 0, self as CFString)
        CFStringTransform(str, nil, kCFStringTransformToLatin, false)
        CFStringTransform(str, nil, kCFStringTransformStripCombiningMarks, false)
        return str! as String
    }
    var pinyin:String{
        var py = ""
        for x in (self.quanpinyin as String).components(separatedBy:" ") {
            py += PYFirst(string:x)
        }
        return py
    }
    
    //  获取拼音首字母，支持取一句话中每字拼音首字母
    func PYFirst(string:String?, _ allFirst:Bool=false)->String{
            var py="#"
            if let s = string {
                if s == "" {
                    return py
                }
                let str = CFStringCreateMutableCopy(nil, 0, s as CFString)
                CFStringTransform(str, nil, kCFStringTransformToLatin, false)
                CFStringTransform(str, nil, kCFStringTransformStripCombiningMarks, false)
                py = ""
                if allFirst {
                    for x in (str! as String).components(separatedBy:" ") {
                        py += PYFirst(string:x)
                    }
                } else {
                    py  = (str! as NSString).substring(to: 1).uppercased()
                }
            }
            return py
        }
}
