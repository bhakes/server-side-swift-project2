//
//  Poll.swift
//  App
//
//  Created by Benjamin Hakes on 11/30/19.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite

struct Poll: Content, SQLiteUUIDModel, Migration, Codable {
    var title: String
    var option1Text: String
    var option2Text: String
    var votes1: Int
    var votes2: Int
    var id: UUID?
}
