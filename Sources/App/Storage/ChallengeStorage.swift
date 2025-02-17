//
//  ChallengeStorage.swift
//  AppAttestationServer
//
//  Created by Peter Kurzok on 17.02.25.
//

import Crypto
import Foundation
import Vapor

// MARK: - ChallengeStorage

class ChallengeStorage {

    static let shared = ChallengeStorage()

    private var challenges: [UUID: Data] = [:]
    private init() {}

    func createChallenge() -> Challenge {
        let id = UUID()
        let challenge = Data(AES.GCM.Nonce())

        challenges[id] = challenge

        return .init(id: id, data: challenge)
    }

    func challenge(for id: UUID) -> Data? {
        challenges[id]
    }
}

extension Application {
    var challengeStorage: ChallengeStorage {
        .shared
    }
}
