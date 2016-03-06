//
//  JSONParserType.swift
//  Eva
//
//  Created by Francisco Díaz on 3/5/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

internal typealias JSONObject = AnyObject
internal typealias JSONArray = [JSONObject]
internal typealias JSONDictionary = [String: JSONObject]

internal protocol JSONParserType {
    typealias ParsedData
    func parseJSON(JSON: JSONObject) -> ParsedData?
}
