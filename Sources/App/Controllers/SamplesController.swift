//
//  SamplesController.swift
//  AppAttestationServer
//
//  Created by Peter Kurzok on 16.01.25.
//

import Vapor

struct SamplesController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let samples = routes.grouped("samples")
        samples.get(use: all)
    }

    func all(req: Request) async throws -> [Sample] {
        return Sample.mockList
    }
}
