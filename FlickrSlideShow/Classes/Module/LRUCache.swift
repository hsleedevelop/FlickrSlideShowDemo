//
//  LRUCache.swift
//  FlickrSlideShow
//
//  refer: https://github.com/yysskk/MemoryCache
//
//  Created by HS Lee on 01/05/2019.
//  Copyright © 2019 HS Lee. All rights reserved.
//

import Foundation
import UIKit

class LRUCache<K, V> where K: Hashable {
    struct Entry {
        let key: K
        let value: V
        let cost: Int
    }
    
    //MARK: * properties --------------------
    private var hashTable = [K: DoublyLinkedList<Entry>.Node]()
    private let list = DoublyLinkedList<Entry>()
    private let lock = NSLock()
    
    var totalCostLimit: Int = 0 {
        didSet { synchronize() }
    }
    
    var countLimit: Int = 0 {
        didSet { synchronize() }
    }
    
    private(set) var totalCost = 0
    
    var count: Int {
        return hashTable.count
    }

    //MARK: * Initialize --------------------

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(removeAll), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func set(_ value: V, for key: K, cost: Int = 0, identifier: String) {
        lock.lock()
        defer { lock.unlock() }
        
        if let node = hashTable[key] {
            _remove(node, for: key)
        }

        //print("identifier=\(identifier)")
        let cache = Entry(key: key, value: value, cost: cost)
        hashTable[key] = list.append(cache, identifier: identifier)
        totalCost += cost
        synchronize()
    }
    
    func value(for key: K) -> V? {
        lock.lock()
        defer { lock.unlock() }
        
        guard let node = hashTable[key] else { return nil }
        
        list.remove(node)   //최근 사용에 반영
        list.append(node)
        
        //print("\(self)")
        return node.value.value
    }

    //MARK: * Main Logic --------------------
    
    private func _remove(_ node: DoublyLinkedList<Entry>.Node, for key: K) {
        //print("_remove=\(key)")
        list.remove(node)
        totalCost -= node.value.cost
        hashTable.removeValue(forKey: key)
    }
    
    @objc func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        
        hashTable = [:]
        list.removeAll()
        totalCost = 0
    }
    
    private func synchronize() {
        if totalCostLimit > 0 {
            synchronize(while: { totalCostLimit < totalCost })
        }
        if countLimit > 0 {
            synchronize(while: { countLimit < count })
        }
    }
    
    private func synchronize(while condition: () -> Bool) {
        guard condition(), let node = list.tail else { return }
        
        _remove(node, for: node.value.key)
        synchronize(while: condition)
    }
}

extension LRUCache: CustomStringConvertible {
    var description: String {
        return "LRUCache(\(self.count)) \n" + self.list.description
    }
}
