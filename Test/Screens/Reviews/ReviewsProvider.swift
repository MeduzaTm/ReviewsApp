import Foundation

/// Класс для загрузки отзывов.
final class ReviewsProvider {
    
    private let bundle: Bundle
    private let urlSession = URLSession(configuration: .default)
    
    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }
    
}

// MARK: - Internal

extension ReviewsProvider {
    
    typealias GetReviewsResult = Result<Data, GetReviewsError>
    
    enum GetReviewsError: Error {
        
        case badURL
        case badData(Error)
        case invalidResponse
        
    }
    
    func getReviews(offset: Int = 0, completion: @escaping (GetReviewsResult) -> Void) {
        guard let url = bundle.url(forResource: "getReviews.response", withExtension: "json") else {
            return completion(.failure(.badURL))
        }
        
        // Симулируем сетевой запрос - не менять
        usleep(.random(in: 100_000...1_000_000))
        
        do {
            let data = try Data(contentsOf: url)
            completion(.success(data))
        } catch {
            completion(.failure(.badData(error)))
        }
    }
    
    func getImages(from urlString: String, completion: @escaping (GetReviewsResult) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.badURL))
            print("bad url")
            return
        }
        
        let task = urlSession.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.badData(error)))
                print("error")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            completion(.success(data))
        }
        task.resume()
    }
}
