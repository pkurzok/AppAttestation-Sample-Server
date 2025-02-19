//
//  SamplesController.swift
//  AppAttestationServer
//
//  Created by Peter Kurzok on 16.01.25.
//

import Vapor

struct SamplesController: RouteCollection {
    let appAttestService: AppAttestService

    func boot(routes: any RoutesBuilder) throws {
        let samples = routes.grouped(TokenAuthenticator())
        samples.get("samples", use: all)
        samples.post("asserted-samples", use: assertedSamples)
    }

    func all(req: Request) async throws -> [Sample] {
        return Sample.mockList
    }

    func assertedSamples(req: Request) async throws -> [Sample] {

        let assertionRq = try req.content.decode(SamplesRequest.self).assertionRequest

        let isValid = try appAttestService.validate(
            assertionRq.assertion,
            clientData: assertionRq.clientData,
            challengeID: assertionRq.challengeID,
            keyID: assertionRq.keyID
        )

        return isValid ? Sample.mockList : []
    }
}
