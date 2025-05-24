//
//  StreamingSession.swift
//
//
//  Created by Sergii Kryvoblotskyi on 18/04/2023.
//

import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class StreamingSession<ResultType: Codable>: NSObject, Identifiable, URLSessionDelegate,
  URLSessionDataDelegate
{

  enum StreamingError: Error {
    case unknownContent
    case emptyContent
    case streamCancelled
  }

  var onReceiveContent: ((StreamingSession, ResultType) -> Void)?
  var onProcessingError: ((StreamingSession, Error) -> Void)?
  var onComplete: ((StreamingSession, Error?) -> Void)?

  private let streamingCompletionMarker = "[DONE]"
  private let openRouterMarker = ": OPENROUTER PROCESSING"
  private let urlRequest: URLRequest
  private lazy var urlSession: URLSession = {
    let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    return session
  }()

  private var previousChunkBuffer = ""

  private var dataTask: URLSessionDataTask?

  init(urlRequest: URLRequest) {
    self.urlRequest = urlRequest
  }

  func perform() {
    self.dataTask = self.urlSession.dataTask(with: self.urlRequest)
    self.dataTask?.resume()
  }

  func cancel() {
    self.dataTask?.cancel()
  }

  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    onComplete?(self, error)
  }

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    guard let stringContent = String(data: data, encoding: .utf8) else {
      onProcessingError?(self, StreamingError.unknownContent)
      return
    }
    processJSON(from: stringContent)
  }

}

extension StreamingSession {

  private func processJSON(from stringContent: String) {
    #if DEBUG
      // print("Raw chunk received: \(stringContent.replacingOccurrences(of: "\n", with: "\\n"))")
    #endif

    // First, filter out any OpenRouter processing content
    // Some responses contained several : OPENROUTER PROCESSING markers in one chunk (esp. with reasoning)
    let cleanedContent = stringContent
      .components(separatedBy: .newlines)
      .filter { !$0.starts(with: openRouterMarker) }
      .joined(separator: "\n")
    
    // Combine with previous buffer and split by "data:"
    let jsonObjects = "\(previousChunkBuffer)\(cleanedContent)"
      .components(separatedBy: "data:")
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { $0.isEmpty == false && $0 != streamingCompletionMarker }

    previousChunkBuffer = ""

    guard jsonObjects.isEmpty == false else {
      return
    }
    jsonObjects.enumerated().forEach { (index, jsonContent) in
      guard jsonContent != streamingCompletionMarker else {
        return
      }
      guard let jsonData = jsonContent.data(using: .utf8) else {
        onProcessingError?(self, StreamingError.unknownContent)
        return
      }

      var apiError: Error? = nil
      do {
        let decoder = JSONDecoder()
        let object = try decoder.decode(ResultType.self, from: jsonData)
        onReceiveContent?(self, object)
      } catch {
        apiError = error
      }

      if let apiError = apiError {
        do {
          let decoded = try JSONDecoder().decode(APIErrorResponse.self, from: jsonData)
          onProcessingError?(self, decoded)
        } catch {
          if index == jsonObjects.count - 1 {
            previousChunkBuffer = "data: \(jsonContent)"  // Chunk ends in a partial JSON
          } else {
            onProcessingError?(self, apiError)
          }
        }
      }
    }
  }

}
