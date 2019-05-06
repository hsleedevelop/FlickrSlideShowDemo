//
//  DoublyLinkedList.swift
//  FlickrSlideShow
//
//  refer: https://github.com/raywenderlich/swift-algorithm-club/tree/master/Linked%20List
//
//  Created by HS Lee on 01/05/2019.
//  Copyright © 2019 HS Lee. All rights reserved.
//

import Foundation

final class DoublyLinkedList<V> {
    
    final class Node {
        
        let value: V
        weak var next: Node?
        weak var prev: Node?
        var identifier: String
        
        init (_ value: V, next: Node? = nil, prev: Node? = nil, identifier: String) {
            self.value = value
            self.next = next
            self.prev = prev
            
            self.identifier = identifier
        }
    }
    
    //MARK: * properties --------------------
    private(set) var head: Node?
    private(set) var tail: Node?
    
    var isEmpty: Bool {
        return tail == nil
    }
    
    init() {
        head = nil
        tail = nil
    }

    deinit {
        removeAll()
    }

    //MARK: * Main Logic --------------------
    
    func append(_ element: V, identifier: String) -> Node {
        let node = Node(element, identifier: identifier)
        append(node)
        return node
    }
    
    func append(_ node: Node) {
        switch head {
        case .some:
            head?.prev = node
            node.next = head
            head = node
        case .none:
            head = node
            tail = node
        }
    }
    
    func remove(_ node: Node) {
        node.next?.prev = node.prev
        node.prev?.next = node.next
        
        if node === tail {
            tail = node.prev
        }
        
        if node === head {
            head = node.next
        }
        
        node.next = nil
        node.prev = nil
    }
    
    func removeAll() {
        guard let first = head else { return }
        _removeAll(node: first)
        
        head = nil
        tail = nil
    }
    
    private func _removeAll(node: Node) {
        guard let next = node.next else { return }
        
        node.next = nil
        next.prev = nil
        
        _removeAll(node: next)
    }
    
}

extension DoublyLinkedList: CustomStringConvertible {
    var description: String {
        var string = ""
        var current = head
        while let node = current {
            string.append("[\(node.identifier)] -> ")
            current = node.next
        }
        return string + ">> end"
    }
}
