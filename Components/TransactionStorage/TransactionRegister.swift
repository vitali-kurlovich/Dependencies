//
//  TransactionStorage.swift
//  VetChat
//
//  Created by Vitali Kurlovich on 11/28/18.
//  Copyright © 2018 SIA Mystic Moments. All rights reserved.
//

import Foundation

final
class TransactionRegister {
    typealias Storage = PersistentStorage<[String: TransactionChain]>

    private
    let storage: PersistentKeyValueStorage<String, TransactionChain>

    init(storage: Storage) {
        self.storage =
            PersistentKeyValueStorage<String, TransactionChain>(storage: storage)
    }

    @discardableResult
    func synchronize() -> Bool {
        return storage.synchronize()
    }
}

extension TransactionRegister {
    @discardableResult
    func append(_ transaction: Transaction) -> Bool {
        let id = transaction.id

        guard let transactions = storage[id] else {
            storage[id] = TransactionChain(transaction: transaction)
            #if DEBUG
                debugPrint(transaction)
            #endif
            return true
        }

        guard let transactionsChain = try? transactions.append(transaction) else {
            return false
        }

        #if DEBUG
            debugPrint(transaction)
        #endif

        storage[id] = transactionsChain
        return true
    }
}

extension TransactionRegister {
    subscript(id: String) -> Transaction? {
        guard let transactions = storage[id] else {
            return nil
        }
        return transactions.transaction
    }

    subscript(uuid: UUID) -> Transaction? {
        for transactionChain in storage {
            for transaction in transactionChain.value.chain {
                if transaction.uuid == uuid {
                    return transaction
                }
            }
        }
        return nil
    }
}

extension TransactionRegister {
    func removeTransactions(by state: Transaction.State) {
        var idsForRemove = [String]()
        idsForRemove.reserveCapacity(storage.count)
        for chain in storage {
            if chain.value.state == state {
                idsForRemove.append(chain.key)
            }
        }

        for key in idsForRemove {
            storage[key] = nil
        }
    }

    func removeFinishedTransactions() {
        removeTransactions(by: .finished)
    }

    func removeFailedTransaction() {
        removeTransactions(by: .failed)
    }
}

extension TransactionRegister {
    func contains(states: [Transaction.State]) -> Bool {
        return storage.contains { (_: String, value: TransactionChain) -> Bool in
            states.contains(value.state)
        }
    }

    func contains(state: Transaction.State) -> Bool {
        return storage.contains { (_: String, value: TransactionChain) -> Bool in
            state == value.state
        }
    }

    func contains(id: String) -> Bool {
        return storage[id] != nil
    }
}

extension TransactionRegister {
    var transactions: [Transaction] {
        var transactions = storage.compactMap { (_: String, value: TransactionChain) -> Transaction? in
            return value.transaction
        }

        transactions.sort { (first, second) -> Bool in
            return first.created < second.created
        }
        return transactions
    }

    func transactions(state: Transaction.State) -> [Transaction] {
        return transactions(states: [state])
    }

    func transactions(states: [Transaction.State]) -> [Transaction] {
        var transactions = storage.compactMap { (_: String, value: TransactionChain) -> Transaction? in
            guard states.contains(value.state) else {
                return nil
            }
            return value.transaction
        }

        transactions.sort { (first, second) -> Bool in
            return first.created < second.created
        }
        return transactions
    }
}

extension TransactionRegister {
    var history: [Transaction] {
        var transactions = [Transaction]()
        transactions.reserveCapacity(storage.count * 2)
        for chain in storage {
            for transaction in chain.value.chain {
                transactions.append(transaction)
            }
        }

        transactions.sort { (first, second) -> Bool in
            return first.created < second.created
        }

        return transactions
    }
}
