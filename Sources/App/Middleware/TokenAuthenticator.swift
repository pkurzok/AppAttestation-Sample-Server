//
//  File.swift
//  AppAttestationServer
//
//  Created by Peter Kurzok on 16.01.25.
//

import Vapor

struct TokenAuthenticator: AsyncRequestAuthenticator {
    func authenticate(request: Vapor.Request) async throws {
        if request.headers.first(name: "apiKey") != "HighlySecretAPIKey" {
            throw Abort(.unauthorized)
        }
    }
}
