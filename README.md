# AppAttestation-Sample-Server
AppAttestation Sample Implementation of a Vapor Server

[Matching iOS Client Example](https://github.com/pkurzok/AppAttestation-Sample-Client)

## How to use this repo
This repo contains a sample Vapor Server that serves some sample data over a REST endpoint. 

On the main branch, communications of this endpoint is "secured" by an API token. On the 3 other branches, you can see variations of the same app that demonstrate different security concepts, including Device Identification Validation, App Attestation, and Firebase's App Check.

## Useful Links
[Apple's Documentation](https://developer.apple.com/documentation/devicecheck) 

[WWDC '21 - Mitigate fraud with App Attest and DeviceCheck](https://developer.apple.com/videos/play/wwdc2021/10244)

[WWDC '17 Privacy and Your Apps](https://devstreaming-cdn.apple.com/videos/wwdc/2017/702lyr2y2j09fro222/702/702_hd_privacy_and_your_apps.mp4?dl=1)

[Ian Sampson's server side AppAttest validation Library](https://github.com/iansampson/AppAttest)

[Oliver Binns' Demo inlcuding Slides from his NSLondon Talk](https://github.com/Oliver-Binns/app-attest)

[Matt Nelson-White's article on App Attestation with insides on server side validation](https://dev.to/mnelsonwhite/implementing-apples-device-check-app-attest-protocol-4p2g)
