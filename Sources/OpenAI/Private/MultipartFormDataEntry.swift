//
//  MultipartFormDataEntry.swift
//
//
//  Created by Sergii Kryvoblotskyi on 02/04/2023.
//

import Foundation

enum MultipartFormDataEntry {

  case file(paramName: String, fileName: String?, fileData: Data?, contentType: String)
  case
    fileArray(paramName: String, fileNames: [String]?, fileDataArray: [Data], contentType: String)
  case
    string(paramName: String, value: Any?)
}
