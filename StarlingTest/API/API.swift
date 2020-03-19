//
//  API.swift
//  StarlingTest
//
//  Created by asdfgh1 on 19/03/2020.
//  Copyright © 2020 Roman Shevtsov. All rights reserved.
//

import Foundation

protocol APIProvider: AnyObject {
    func request<E: Endpoint>(_ endpoint: E, completion: @escaping (Result<E.Response, Error>) -> Void)
}

enum APIError: Error {
    case statusCodeNotSuccess
    case noResponseBody
}

final class API: APIProvider {
    private let urlSession: URLSession
    private let baseURL: URL
    private let accessToken: String

    init(
        urlSession: URLSession = .shared,
        baseURL: URL = Configuration.apiBaseURL,
        accessToken: String = Configuration.apiAccessToken
    ) {
        self.urlSession = urlSession
        self.baseURL = baseURL
        self.accessToken = accessToken
    }

    func request<E: Endpoint>(
        _ endpoint: E,
        completion: @escaping (Result<E.Response, Error>) -> Void
    ) {
        do {
            let request = try endpoint.urlRequest(withBaseURL: baseURL, accessToken: accessToken)
            urlSession.dataTask(
                with: request,
                completionHandler: { (data, response, error) in
                    do {
                        if let error = error {
                            throw error
                        }
                        guard response?.isHttpStatusCodeSuccessful == true else {
                            throw APIError.statusCodeNotSuccess
                        }
                        guard let data = data else {
                            throw APIError.noResponseBody
                        }
                        let response = try JSONDecoder().decode(E.Response.self, from: data)
                        completion(.success(response))
                    } catch {
                        completion(.failure(error))
                    }
                }
            ).resume()
        } catch {
            completion(.failure(error))
        }
    }
}

private enum Constant {
    static let authorizationKey = "Authorization"
    static let bearerValue = "Bearer"
}

extension Endpoint {
    func urlRequest(
        withBaseURL baseURL: URL,
        accessToken: String
    ) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(urlPath)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        if let requestBody = requestBody {
            let requestBodyData = try JSONEncoder().encode(requestBody)
            urlRequest.httpBody = requestBodyData
        }
        urlRequest.setValue("\(Constant.bearerValue) \(accessToken)", forHTTPHeaderField: Constant.authorizationKey)
        return urlRequest
    }
}

private extension URLResponse {
    var isHttpStatusCodeSuccessful: Bool {
        guard let httpURLResponse = self as? HTTPURLResponse else {
            return false
        }
        return (200...299).contains(httpURLResponse.statusCode)
    }
}
