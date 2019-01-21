//
//  TransactionChain.swift
//  VetChat
//
//  Created by Vitali Kurlovich on 11/28/18.
//  Copyright © 2018 SIA Mystic Moments. All rights reserved.
//

import Foundation

struct TransactionChain: Codable, Equatable {
    let chain: [Transaction]

    init(transaction: Transaction) {
        self.init(chain: [transaction])
    }

    private init(chain: [Transaction]) {
        self.chain = chain
    }

    var id: String {
        return chain.first!.id
    }

    var state: Transaction.State {
        return chain.last!.state
    }

    var transaction: Transaction {
        return chain.last!
    }
}

extension TransactionChain {
    enum TransactionChainError: Error {
        case notEqualIdError
        case incorrectCreationTimeError
        case duplicatedTransactionError
        case invalidTransactionStateError
    }

    func append(_ transaction: Transaction) throws -> TransactionChain {
        guard let last = chain.last else {
            return TransactionChain(chain: [transaction])
        }

        if last.id != transaction.id {
            throw TransactionChainError.notEqualIdError
        }

        if last == transaction {
            throw TransactionChainError.duplicatedTransactionError
        }

        if last.created > transaction.created {
            throw TransactionChainError.incorrectCreationTimeError
        }

        switch last.state {
        case .inprogress:
            if transaction.state == .inprogress {
                throw TransactionChainError.invalidTransactionStateError
            }
            break

        case .finished, .failed:
            throw TransactionChainError.invalidTransactionStateError
        }

        var currentChain = chain
        currentChain.append(transaction)

        return TransactionChain(chain: currentChain)
    }
}
