//
//  ChatQuery.swift
//  
//
//  Created by Sergii Kryvoblotskyi on 02/04/2023.
//

import Foundation

// See more https://platform.openai.com/docs/guides/text-generation/json-mode
public struct ResponseFormat: Codable, Equatable {
    public static let jsonObject = ResponseFormat(type: .jsonObject)
    public static let text = ResponseFormat(type: .text)
    
    public let type: Self.ResponseFormatType
    
    public enum ResponseFormatType: String, Codable, Equatable {
        case jsonObject = "json_object"
        case text
    }
}

public struct ChatContentItem: Codable, Equatable {
    public enum ContentType: String, Codable, Equatable {
        case text
        case image
    }
    
    public let type: ContentType
    public let text: String?
    public let imageUrl: String?
    
    // Ensure proper initialization based on type
    public init(text: String) {
        self.type = .text
        self.text = text
        self.imageUrl = nil
    }
    
    public init(imageUrl: String) {
        self.type = .image
        self.text = nil
        self.imageUrl = imageUrl
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case text
        case imageUrl = "image_url"
    }
}

public struct Chat: Codable, Equatable {
    public let role: Role
    /// The contents of the message. `content` is required for all messages except assistant messages with function calls.
    public let content: [ChatContentItem]?
    /// The name of the author of this message. `name` is required if role is `function`, and it should be the name of the function whose response is in the `content`. May contain a-z, A-Z, 0-9, and underscores, with a maximum length of 64 characters.
    public let name: String?
    public let functionCall: ChatFunctionCall?
    
    public enum Role: String, Codable, Equatable {
        case system
        case assistant
        case user
        case function
    }
    
    enum CodingKeys: String, CodingKey {
        case role
        case content
        case name
        case functionCall = "function_call"
    }
    
    public init(role: Role, content: [ChatContentItem]? = nil, name: String? = nil, functionCall: ChatFunctionCall? = nil) {
        self.role = role
        self.content = content
        self.name = name
        self.functionCall = functionCall
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(role, forKey: .role)
        
        if let name = name {
            try container.encode(name, forKey: .name)
        }
        
        if let functionCall = functionCall {
            try container.encode(functionCall, forKey: .functionCall)
        }
        
        // Should add 'nil' to 'content' property for function calling response
        // See https://openai.com/blog/function-calling-and-other-api-updates
        if content != nil || (role == .assistant && functionCall != nil) {
            try container.encode(content, forKey: .content)
        }
    }
}



//public struct Chat: Codable, Equatable {
//    public let role: Role
//    /// The contents of the message. `content` is required for all messages except assistant messages with function calls.
//    public let content: String?
//    /// The name of the author of this message. `name` is required if role is `function`, and it should be the name of the function whose response is in the `content`. May contain a-z, A-Z, 0-9, and underscores, with a maximum length of 64 characters.
//    public let name: String?
//    public let functionCall: ChatFunctionCall?
//    
//    public enum Role: String, Codable, Equatable {
//        case system
//        case assistant
//        case user
//        case function
//    }
//    
//    enum CodingKeys: String, CodingKey {
//        case role
//        case content
//        case name
//        case functionCall = "function_call"
//    }
//    
//    public init(role: Role, content: String? = nil, name: String? = nil, functionCall: ChatFunctionCall? = nil) {
//        self.role = role
//        self.content = content
//        self.name = name
//        self.functionCall = functionCall
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(role, forKey: .role)
//
//        if let name = name {
//            try container.encode(name, forKey: .name)
//        }
//
//        if let functionCall = functionCall {
//            try container.encode(functionCall, forKey: .functionCall)
//        }
//
//        // Should add 'nil' to 'content' property for function calling response
//        // See https://openai.com/blog/function-calling-and-other-api-updates
//        if content != nil || (role == .assistant && functionCall != nil) {
//            try container.encode(content, forKey: .content)
//        }
//    }
//}

public struct ChatFunctionCall: Codable, Equatable {
    /// The name of the function to call.
    public let name: String?
    /// The arguments to call the function with, as generated by the model in JSON format. Note that the model does not always generate valid JSON, and may hallucinate parameters not defined by your function schema. Validate the arguments in your code before calling your function.
    public let arguments: String?

    public init(name: String?, arguments: String?) {
        self.name = name
        self.arguments = arguments
    }
}


/// See the [guide](/docs/guides/gpt/function-calling) for examples, and the [JSON Schema reference](https://json-schema.org/understanding-json-schema/) for documentation about the format.
public struct JSONSchema: Codable, Equatable {
    public let type: JSONType
    public let properties: [String: Property]?
    public let required: [String]?
    public let pattern: String?
    public let const: String?
    public let enumValues: [String]?
    public let multipleOf: Int?
    public let minimum: Int?
    public let maximum: Int?
    
    private enum CodingKeys: String, CodingKey {
        case type, properties, required, pattern, const
        case enumValues = "enum"
        case multipleOf, minimum, maximum
    }
    
    public struct Property: Codable, Equatable {
        public let type: JSONType
        public let description: String?
        public let format: String?
        public let items: Items?
        public let required: [String]?
        public let pattern: String?
        public let const: String?
        public let enumValues: [String]?
        public let multipleOf: Int?
        public let minimum: Double?
        public let maximum: Double?
        public let minItems: Int?
        public let maxItems: Int?
        public let uniqueItems: Bool?

        private enum CodingKeys: String, CodingKey {
            case type, description, format, items, required, pattern, const
            case enumValues = "enum"
            case multipleOf, minimum, maximum
            case minItems, maxItems, uniqueItems
        }
        
        public init(type: JSONType, description: String? = nil, format: String? = nil, items: Items? = nil, required: [String]? = nil, pattern: String? = nil, const: String? = nil, enumValues: [String]? = nil, multipleOf: Int? = nil, minimum: Double? = nil, maximum: Double? = nil, minItems: Int? = nil, maxItems: Int? = nil, uniqueItems: Bool? = nil) {
            self.type = type
            self.description = description
            self.format = format
            self.items = items
            self.required = required
            self.pattern = pattern
            self.const = const
            self.enumValues = enumValues
            self.multipleOf = multipleOf
            self.minimum = minimum
            self.maximum = maximum
            self.minItems = minItems
            self.maxItems = maxItems
            self.uniqueItems = uniqueItems
        }
    }

    public enum JSONType: String, Codable {
        case integer = "integer"
        case string = "string"
        case boolean = "boolean"
        case array = "array"
        case object = "object"
        case number = "number"
        case `null` = "null"
    }

    public struct Items: Codable, Equatable {
        public let type: JSONType
        public let properties: [String: Property]?
        public let pattern: String?
        public let const: String?
        public let enumValues: [String]?
        public let multipleOf: Int?
        public let minimum: Double?
        public let maximum: Double?
        public let minItems: Int?
        public let maxItems: Int?
        public let uniqueItems: Bool?

        private enum CodingKeys: String, CodingKey {
            case type, properties, pattern, const
            case enumValues = "enum"
            case multipleOf, minimum, maximum, minItems, maxItems, uniqueItems
        }
        
        public init(type: JSONType, properties: [String : Property]? = nil, pattern: String? = nil, const: String? = nil, enumValues: [String]? = nil, multipleOf: Int? = nil, minimum: Double? = nil, maximum: Double? = nil, minItems: Int? = nil, maxItems: Int? = nil, uniqueItems: Bool? = nil) {
            self.type = type
            self.properties = properties
            self.pattern = pattern
            self.const = const
            self.enumValues = enumValues
            self.multipleOf = multipleOf
            self.minimum = minimum
            self.maximum = maximum
            self.minItems = minItems
            self.maxItems = maxItems
            self.uniqueItems = uniqueItems
        }
    }
    
    public init(type: JSONType, properties: [String : Property]? = nil, required: [String]? = nil, pattern: String? = nil, const: String? = nil, enumValues: [String]? = nil, multipleOf: Int? = nil, minimum: Int? = nil, maximum: Int? = nil) {
        self.type = type
        self.properties = properties
        self.required = required
        self.pattern = pattern
        self.const = const
        self.enumValues = enumValues
        self.multipleOf = multipleOf
        self.minimum = minimum
        self.maximum = maximum
    }
}

public struct ChatFunctionDeclaration: Codable, Equatable {
    /// The name of the function to be called. Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum length of 64.
    public let name: String
    
    /// The description of what the function does.
    public let description: String
    
    /// The parameters the functions accepts, described as a JSON Schema object.
    public let parameters: JSONSchema
  
    public init(name: String, description: String, parameters: JSONSchema) {
      self.name = name
      self.description = description
      self.parameters = parameters
    }
}

public struct ChatQueryFunctionCall: Codable, Equatable {
    /// The name of the function to call.
    public let name: String?
    /// The arguments to call the function with, as generated by the model in JSON format. Note that the model does not always generate valid JSON, and may hallucinate parameters not defined by your function schema. Validate the arguments in your code before calling your function.
    public let arguments: String?
}

public struct ChatQuery: Equatable, Codable, Streamable {
    /// ID of the model to use. Currently, only gpt-3.5-turbo and gpt-3.5-turbo-0301 are supported.
    public let model: Model
    /// An object specifying the format that the model must output.
    public let responseFormat: ResponseFormat?
    /// The messages to generate chat completions for
    public let messages: [Chat]
    /// A list of functions the model may generate JSON inputs for.
    public let functions: [ChatFunctionDeclaration]?
    /// Controls how the model responds to function calls. "none" means the model does not call a function, and responds to the end-user. "auto" means the model can pick between and end-user or calling a function. Specifying a particular function via `{"name": "my_function"}` forces the model to call that function. "none" is the default when no functions are present. "auto" is the default if functions are present.
    public let functionCall: FunctionCall?
    /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and  We generally recommend altering this or top_p but not both.
    public let temperature: Double?
    /// An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
    public let topP: Double?
    /// How many chat completion choices to generate for each input message.
    public let n: Int?
    /// Up to 4 sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence.
    public let stop: [String]?
    /// The maximum number of tokens to generate in the completion.
    public let maxTokens: Int?
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
    public let presencePenalty: Double?
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
    public let frequencyPenalty: Double?
    /// Modify the likelihood of specified tokens appearing in the completion.
    public let logitBias: [String:Int]?
    /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
    public let user: String?
    
    var stream: Bool = false

    public enum FunctionCall: Codable, Equatable {
        case none
        case auto
        case function(String)
        
        enum CodingKeys: String, CodingKey {
            case none = "none"
            case auto = "auto"
            case function = "name"
        }
        
        public func encode(to encoder: Encoder) throws {
            switch self {
            case .none:
                var container = encoder.singleValueContainer()
                try container.encode(CodingKeys.none.rawValue)
            case .auto:
                var container = encoder.singleValueContainer()
                try container.encode(CodingKeys.auto.rawValue)
            case .function(let name):
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(name, forKey: .function)
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case functions
        case functionCall = "function_call"
        case temperature
        case topP = "top_p"
        case n
        case stream
        case stop
        case maxTokens = "max_tokens"
        case presencePenalty = "presence_penalty"
        case frequencyPenalty = "frequency_penalty"
        case logitBias = "logit_bias"
        case user
        case responseFormat = "response_format"
    }
    
    public init(model: Model, messages: [Chat], responseFormat: ResponseFormat? = nil, functions: [ChatFunctionDeclaration]? = nil, functionCall: FunctionCall? = nil, temperature: Double? = nil, topP: Double? = nil, n: Int? = nil, stop: [String]? = nil, maxTokens: Int? = nil, presencePenalty: Double? = nil, frequencyPenalty: Double? = nil, logitBias: [String : Int]? = nil, user: String? = nil, stream: Bool = false) {
        self.model = model
        self.messages = messages
        self.functions = functions
        self.functionCall = functionCall
        self.temperature = temperature
        self.topP = topP
        self.n = n
        self.responseFormat = responseFormat
        self.stop = stop
        self.maxTokens = maxTokens
        self.presencePenalty = presencePenalty
        self.frequencyPenalty = frequencyPenalty
        self.logitBias = logitBias
        self.user = user
        self.stream = stream
    }
}
