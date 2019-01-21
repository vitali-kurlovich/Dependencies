//
//  ExecutionQueue.swift
//  VetChat
//
//  Created by Vitali Kurlovich on 12/1/18.
//  Copyright © 2018 SIA Mystic Moments. All rights reserved.
//

import Foundation

class ExecutionQueue<DataType> {
    typealias CompletionHandler = (_ data: DataType, _ error: Error?) -> Void

    private var queue = [Task]()

    var isEmpty: Bool {
        return queue.isEmpty
    }

    func append(completion: @escaping CompletionHandler) {
        let task = Task(completion: completion)
        queue.append(task)
    }

    func execute(_ data: DataType, error: Error?, clearQueue: Bool = true) {
        let queue = self.queue
        if clearQueue {
            self.queue.removeAll()
        }

        queue.forEach { task in
            task.execute(data, error: error)
        }
    }

    private
    class Task {
        private
        var completion: CompletionHandler

        init(completion: @escaping CompletionHandler) {
            self.completion = completion
        }

        func execute(_ data: DataType, error: Error?) {
            completion(data, error)
        }
    }
}
