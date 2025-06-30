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
    
    func getReviews(offset: Int = 0) async throws -> Data {
            guard let url = bundle.url(forResource: "getReviews.response", withExtension: "json") else {
                throw GetReviewsError.badURL
            }
            
            // Симулируем сетевой запрос - не менять
            try await Task.sleep(nanoseconds: UInt64.random(in: 100_000_000...1_000_000_000))
            
            do {
                return try Data(contentsOf: url)
            } catch {
                throw GetReviewsError.badData(error)
            }
        }
        
        func getImages(from urlString: String) async throws -> Data {
            guard let url = URL(string: urlString) else {
                throw GetReviewsError.badURL
            }
            
            let (data, response) = try await urlSession.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw GetReviewsError.invalidResponse
            }
            
            return data
        }
}
