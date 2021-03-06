//
//  KeyChainUtils.swift
//  Addressable
//
//  Created by https://github.com/dagostini/DAKeychain

import Foundation

let userBasicAuthToken = "userBasicAuthToken"
let userData = "userApplicationData"
let userMobileClientIdentity = "userMobileClientIdentity"

open class KeyChainServiceUtil {
    open var loggingEnabled = false

    private init() {}
    public static let shared = KeyChainServiceUtil()

    open subscript(key: String) -> String? {
        get {
            return load(withKey: key)
        } set {
            DispatchQueue.global().sync(flags: .barrier) { [weak self] in
                self?.save(newValue, forKey: key)
            }
        }
    }

    private func save(_ string: String?, forKey key: String) {
        let query = keychainQuery(withKey: key)
        let objectData: Data? = string?.data(using: .utf8, allowLossyConversion: false)

        if SecItemCopyMatching(query, nil) == noErr {
            if let dictData = objectData {
                let status = SecItemUpdate(query, NSDictionary(dictionary: [kSecValueData: dictData]))
                logPrint("Update status: ", status)
            } else {
                let status = SecItemDelete(query)
                logPrint("Delete status: ", status)
            }
        } else {
            if let dictData = objectData {
                query.setValue(dictData, forKey: kSecValueData as String)
                let status = SecItemAdd(query, nil)
                logPrint("Update status: ", status)
            }
        }
    }

    private func load(withKey key: String) -> String? {
        let query = keychainQuery(withKey: key)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnData as String)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnAttributes as String)

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query, &result)

        guard
            let resultsDict = result as? NSDictionary,
            let resultsData = resultsDict.value(forKey: kSecValueData as String) as? Data,
            status == noErr
        else {
            return nil
        }
        return String(data: resultsData, encoding: .utf8)
    }

    private func keychainQuery(withKey key: String) -> NSMutableDictionary {
        let result = NSMutableDictionary()
        result.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        result.setValue(key, forKey: kSecAttrService as String)
        result.setValue(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, forKey: kSecAttrAccessible as String)
        return result
    }

    func clearAll() {
        let secItemClasses = [kSecClassGenericPassword]
        for itemClass in secItemClasses {
            let spec: NSDictionary = [kSecClass: itemClass]
            SecItemDelete(spec)
        }
    }

    private func logPrint(_ items: Any...) {
        if loggingEnabled {
            print(items)
        }
    }
}
