//
//  YCEnum.swift
//  YourChoice
//
//  Created by Venkat Kurapati on 19/02/2017.
//  Copyright © 2017 Kurapati. All rights reserved.
//

import Foundation

enum TableViewState: Int {
    case loading = 0
    case empty = 1
    case populated = 2
}

enum PollsType: Int {
    case myPolls = 0
    case allPolls = 1
}

enum VoteState {
    case disabled
    case pending
    case cast(Int)
}
