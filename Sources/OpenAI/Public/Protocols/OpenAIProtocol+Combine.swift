//
//  OpenAIProtocol+Combine.swift
//
//
//  Created by Sergii Kryvoblotskyi on 03/04/2023.
//

#if canImport(Combine)

  import Combine

  @available(iOS 13.0, *)
  @available(tvOS 13.0, *)
  @available(macOS 10.15, *)
  @available(watchOS 6.0, *)
  extension OpenAIProtocol {

    public func images(query: ImagesQuery) -> AnyPublisher<ImagesResult, Error> {
      Future<ImagesResult, Error> {
        images(query: query, completion: $0)
      }
      .eraseToAnyPublisher()
    }

    public func imageEdits(query: ImageEditsQuery) -> AnyPublisher<ImagesResult, Error> {
      Future<ImagesResult, Error> {
        imageEdits(query: query, completion: $0)
      }
      .eraseToAnyPublisher()
    }

    public func imageVariations(query: ImageVariationsQuery) -> AnyPublisher<ImagesResult, Error> {
      Future<ImagesResult, Error> {
        imageVariations(query: query, completion: $0)
      }
      .eraseToAnyPublisher()
    }

    public func embeddings(query: EmbeddingsQuery) -> AnyPublisher<EmbeddingsResult, Error> {
      Future<EmbeddingsResult, Error> {
        embeddings(query: query, completion: $0)
      }
      .eraseToAnyPublisher()
    }

    public func chats(query: ChatQuery) -> AnyPublisher<ChatResult, Error> {
      Future<ChatResult, Error> {
        chats(query: query, completion: $0)
      }
      .eraseToAnyPublisher()
    }

    public func chatsStream(query: ChatQuery) -> AnyPublisher<
      Result<ChatStreamResult, Error>, Error
    > {
      let progress = PassthroughSubject<Result<ChatStreamResult, Error>, Error>()
      chatsStream(query: query) { result in
        progress.send(result)
      } completion: { error in
        if let error {
          progress.send(completion: .failure(error))
        } else {
          progress.send(completion: .finished)
        }
      }
      return progress.eraseToAnyPublisher()
    }

    public func edits(query: EditsQuery) -> AnyPublisher<EditsResult, Error> {
      Future<EditsResult, Error> {
        edits(query: query, completion: $0)
      }
      .eraseToAnyPublisher()
    }

    public func model(query: ModelQuery) -> AnyPublisher<ModelResult, Error> {
      Future<ModelResult, Error> {
        model(query: query, completion: $0)
      }
      .eraseToAnyPublisher()
    }

    public func models() -> AnyPublisher<ModelsResult, Error> {
      Future<ModelsResult, Error> {
        models(completion: $0)
      }
      .eraseToAnyPublisher()
    }

    public func moderations(query: ModerationsQuery) -> AnyPublisher<ModerationsResult, Error> {
      Future<ModerationsResult, Error> {
        moderations(query: query, completion: $0)
      }
      .eraseToAnyPublisher()
    }

    public func audioTranscriptions(query: AudioTranscriptionQuery) -> AnyPublisher<
      AudioTranscriptionResult, Error
    > {
      Future<AudioTranscriptionResult, Error> {
        audioTranscriptions(query: query, completion: $0)
      }
      .eraseToAnyPublisher()
    }

    public func audioTranslations(query: AudioTranslationQuery) -> AnyPublisher<
      AudioTranslationResult, Error
    > {
      Future<AudioTranslationResult, Error> {
        audioTranslations(query: query, completion: $0)
      }
      .eraseToAnyPublisher()
    }
  }

#endif
