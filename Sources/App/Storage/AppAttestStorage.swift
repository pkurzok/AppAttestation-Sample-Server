//
//  AppAttestStorage.swift
//  AppAttestationServer
//
//  Created by Peter Kurzok on 17.02.25.
//

import AppAttest
import Vapor

// MARK: - AppAttestStorage

class AppAttestStorage {

    static let shared = AppAttestStorage()

    private var attestations: [Data: AppAttest.AttestationResult] = [:]
    private var assertions: [Data: AppAttest.AssertionResult] = [:]

    private init() {}

    func store(attestation: AppAttest.AttestationResult, for keyId: Data) {
        attestations[keyId] = attestation
    }

    func attestation(for keyId: Data) -> AppAttest.AttestationResult? {
        attestations[keyId]
    }

    func store(assertion: AppAttest.AssertionResult, for keyId: Data) {
        assertions[keyId] = assertion
    }

    func assertion(for keyId: Data) -> AppAttest.AssertionResult? {
        assertions[keyId]
    }
}

extension Application {
    var appAttestStorage: AppAttestStorage {
        .shared
    }
}
