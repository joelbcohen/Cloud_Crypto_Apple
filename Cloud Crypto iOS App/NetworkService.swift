//
//  NetworkService.swift
//  Cloud Crypto iOS App
//

import Foundation

actor NetworkService {

    enum NetworkError: Error {
        case invalidURL
        case invalidResponse
        case httpError(statusCode: Int, message: String?)
        case decodingError(Error)
        case encodingError(Error)
        case noData
        case timeout
    }

    private let baseURL = "https://fusio.callista.io"
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    private func performRequest<T: Decodable>(
        endpoint: String,
        method: String = "POST",
        body: Data? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        print("📡 Request: \(method) \(url)")
        if let body = body, let bodyString = String(data: body, encoding: .utf8) {
            print("📤 Body: \(bodyString)")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        print("📥 Response: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Data: \(responseString)")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8)
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, message: message)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("❌ Decoding error: \(error)")
            throw NetworkError.decodingError(error)
        }
    }

    func registerDevice(_ request: RegistrationRequest) async throws -> RegistrationResponse {
        let encoder = JSONEncoder()
        let body = try encoder.encode(request)
        return try await performRequest(endpoint: "/public/crypto/register", method: "POST", body: body)
    }

    func deregisterDevice(_ request: DeregistrationRequest) async throws -> DeregistrationResponse {
        let encoder = JSONEncoder()
        let body = try encoder.encode(request)
        return try await performRequest(endpoint: "/public/crypto/deregister", method: "POST", body: body)
    }

    func getAccountSummary(_ request: AccountSummaryRequest) async throws -> AccountSummaryResponse {
        let encoder = JSONEncoder()
        let body = try encoder.encode(request)
        return try await performRequest(endpoint: "/public/crypto/account_summary", method: "POST", body: body)
    }

    func executeTransfer(_ request: TransferRequest) async throws -> TransferResponse {
        let encoder = JSONEncoder()
        let body = try encoder.encode(request)
        return try await performRequest(endpoint: "/public/crypto/transfer", method: "POST", body: body)
    }

    func getNetworkStatus() async throws -> NetworkStatusResponse {
        return try await performRequest(endpoint: "/public/crypto/network_status", method: "GET", body: nil)
    }
}
