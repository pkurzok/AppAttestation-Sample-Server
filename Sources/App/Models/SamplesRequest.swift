//
//  SamplesRequest.swift
//  AppAttestationServer
//
//  Created by Peter Kurzok on 18.02.25.
//

import Vapor

struct SamplesRequest: Content {
    let assertionRequest: AssertionRequest
}
