//
//  AssertionRequest.swift
//  AppAttestationServer
//
//  Created by Peter Kurzok on 17.02.25.
//

import Vapor

struct AssertionRequest: Content {
    let assertion: Data
    let keyID: Data
    let challengeID: UUID
    let clientData: Data
}
