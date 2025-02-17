//
//  AttestationRequest.swift
//  AppAttestationServer
//
//  Created by Peter Kurzok on 17.02.25.
//

import Vapor

struct AttestationRequest: Content {
    let attestation: Data
    let keyID: Data
    let challengeID: UUID
}
