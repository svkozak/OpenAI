//
//  ChatResult.swift
//  
//
//  Created by Sergii Kryvoblotskyi on 02/04/2023.
//

import Foundation

public struct ChatResult: Codable, Equatable {
    
    public struct Choice: Codable, Equatable {
      
        public let index: Int
        /// Exists only if it is a complete message.
        public let message: ChatResponse
        /// Exists only if it is a complete message.
        public let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case index
            case message
            case finishReason = "finish_reason"
        }
    }
    
    public struct Usage: Codable, Equatable {
        public let promptTokens: Int
        public let completionTokens: Int
        public let totalTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
    
    public let id: String
    public let object: String
    public let created: TimeInterval
    public let model: Model
    public let choices: [Choice]
    public let usage: Usage?
    
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case created
        case model
        case choices
        case usage
    }
    
    init(id: String, object: String, created: TimeInterval, model: Model, choices: [Choice], usage: Usage) {
        self.id = id
        self.object = object
        self.created = created
        self.model = model
        self.choices = choices
        self.usage = usage
    }
}

// For use with full chat response in ChatResult
public struct ChatResponse: Codable, Equatable {
    public let role: Role
    /// The contents of the message. `content` is required for all messages except assistant messages with function calls.
    public let content: String?
    /// The name of the author of this message. `name` is required if role is `function`, and it should be the name of the function whose response is in the `content`. May contain a-z, A-Z, 0-9, and underscores, with a maximum length of 64 characters.
    public let name: String?

    public enum Role: String, Codable, Equatable {
        case system
        case assistant
    }

    enum CodingKeys: String, CodingKey {
        case role
        case content
        case name
    }

    public init(role: Role, content: String? = nil, name: String? = nil) {
        self.role = role
        self.content = content
        self.name = name
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(role, forKey: .role)

        if let name = name {
            try container.encode(name, forKey: .name)
        }

        // Should add 'nil' to 'content' property for function calling response
        // See https://openai.com/blog/function-calling-and-other-api-updates
        if content != nil || (role == .assistant) {
            try container.encode(content, forKey: .content)
        }
    }
}
