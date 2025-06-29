/// Модель отзыва.
struct Review: Decodable {
    
    ///Аватар пользователя
    let avatarUrl: String
    /// Имя пользователя.
    let firstName: String
    /// Фамилия пользователя.
    let lastName: String
    ///Фото отзывов
    let reviewPhotos: [String]
    /// Рейтинг отзыва
    let rating: Int
    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String

}
