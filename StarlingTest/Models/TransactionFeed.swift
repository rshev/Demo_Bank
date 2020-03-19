//
//  TransactionFeed.swift
//  StarlingTest
//
//  Created by asdfgh1 on 19/03/2020.
//  Copyright © 2020 Roman Shevtsov. All rights reserved.
//

import Foundation

struct TransactionFeed: Codable {
    var feedItems: [FeedItem]
}

struct FeedItem: Codable {
    var amount: CurrencyAndAmount
}
