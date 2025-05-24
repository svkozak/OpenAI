//
//  ImageEditsQuery.swift
//
//
//  Created by Aled Samuel on 24/04/2023.
//

import Foundation

public struct ImageEditsQuery: Codable {
    /// The image to edit. Must be a valid PNG file, less than 4MB, and square. If mask is not provided, image must have transparency, which will be used as the mask.
    public let image: [Data]
    public let fileNames: [String]
    /// An additional image whose fully transparent areas (e.g. where alpha is zero) indicate where image should be edited. Must be a valid PNG file, less than 4MB, and have the same dimensions as image.
    public let mask: Data?
    public let maskFileName: String?
    /// A text description of the desired image(s). The maximum length is 1000 characters.
    public let prompt: String
    /// The number of images to generate. Must be between 1 and 10.
    public let n: Int?
    /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024.
    public let size: String?

    // GPT Image
    public let background: String?
    public let model: Model?
    public let quality: String?
    public let responseFormat: ImageResponseFormat?

    public init(image: [Data], fileNames: [String]? = nil, mask: Data? = nil, maskFileName: String? = nil,
      prompt: String, n: Int? = nil, size: String? = nil, background: String? = nil, model: Model? = nil, quality: String? = nil, responseFormat: ImageResponseFormat? = nil) {
      self.image = image
      // If fileNames not provided, generate default names (image1.png, image2.png, etc.)
      if let fileNames = fileNames, fileNames.count == image.count {
        self.fileNames = fileNames
      } else {
        self.fileNames = (0..<image.count).map { "image\($0).png" }
      }
      self.mask = mask
      self.maskFileName = maskFileName
      self.prompt = prompt
      self.n = n
      self.size = size
      self.background = background
      self.model = model
      self.quality = quality
      self.responseFormat = responseFormat
    }
}

extension ImageEditsQuery: MultipartFormDataBodyEncodable {
    func encode(boundary: String) -> Data {
        let bodyBuilder = MultipartFormDataBodyBuilder( boundary: boundary, entries: [
            .fileArray(
              paramName: "image", fileNames: fileNames, fileDataArray: image, contentType: "image/png"),
            .file(paramName: "mask", fileName: maskFileName, fileData: mask, contentType: "image/png"),
            .string(paramName: "prompt", value: prompt),
            .string(paramName: "n", value: n),
            .string(paramName: "size", value: size),
            .string(paramName: "background", value: background),
            .string(paramName: "model", value: model),
            .string(paramName: "quality", value: quality),
            .string(paramName: "response_format", value: responseFormat?.rawValue),
        ])
      return bodyBuilder.build()
    }
}
