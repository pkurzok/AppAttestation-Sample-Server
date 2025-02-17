//
//  Challenge.swift
//  AppAttestationServer
//
//  Created by Peter Kurzok on 17.02.25.
//
import Vapor

struct Challenge: Content {
    let id: UUID
    let data: Data
}
