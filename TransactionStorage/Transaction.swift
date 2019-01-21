//
//  Transaction.swift
//  VetChat
//
//  Created by Vitali Kurlovich on 11/28/18.
//  Copyright © 2018 SIA Mystic Moments. All rights reserved.
//

import Foundation

struct Transaction: Codable, Equatable {
    enum State: Int, Codable {
        case inprogress
        case finished
        case failed
    }

    let id: String
    let uuid: UUID
    let created: Date
    let state: State

    init(id: String = UUID().uuidString, state: State = .inprogress, created: Date = Date()) {
        self.id = id
        self.created = created
        uuid = UUID()
        self.state = state
    }
}

extension Transaction {
    func setState(state: State, created: Date = Date()) -> Transaction {
        return Transaction(id: id, state: state, created: created)
    }
}
