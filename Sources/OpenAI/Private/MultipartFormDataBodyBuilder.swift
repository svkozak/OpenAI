//
//  MultipartFormDataBodyBuilder.swift
//
//
//  Created by Sergii Kryvoblotskyi on 02/04/2023.
//

import Foundation

final class MultipartFormDataBodyBuilder {
        
    let boundary: String
    let entries: [MultipartFormDataEntry]
    
    init(boundary: String, entries: [MultipartFormDataEntry]) {
        self.boundary = boundary
        self.entries = entries
    }
    
    func build() -> Data {
        var httpData = entries
            .map { $0.makeBodyData(boundary: boundary) }
            .reduce(Data(), +)
        httpData.append("--\(boundary)--\r\n")
        return httpData
    }
}

private extension MultipartFormDataEntry {
    
    func makeBodyData(boundary: String) -> Data {
        var body = Data()
        switch self {
        case .file(let paramName, let fileName, let fileData, let contentType):
            if let fileName, let fileData {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n")
                body.append("Content-Type: \(contentType)\r\n\r\n")
                body.append(fileData)
                body.append("\r\n")
            }
        case .fileArray(let paramName, let fileNames, let fileDataArray, let contentType):
            if !fileDataArray.isEmpty {
                for (index, fileData) in fileDataArray.enumerated() {
                  body.append("--\(boundary)\r\n")

                  // Get appropriate filename for this index
                  let fileName: String
                  if let fileNames = fileNames, index < fileNames.count {
                    fileName = fileNames[index]
                  } else {
                    fileName = "image\(index).png"
                  }

                  body.append("Content-Disposition: form-data; name=\"\(paramName)[]\"; filename=\"\(fileName)\"\r\n")
                  body.append("Content-Type: \(contentType)\r\n\r\n")
                  body.append(fileData)
                  body.append("\r\n")
                }
            }
        case .string(let paramName, let value):
            if let value {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(paramName)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
        }
        return body
    }
}

extension Data {
    
    mutating func append(_ string: String) {
        let data = string.data(
            using: String.Encoding.utf8,
            allowLossyConversion: true)
        append(data!)
    }
}
