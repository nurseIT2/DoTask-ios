import Foundation
struct Task: Identifiable, Codable {
    var id: String
    var title: String
    var details: String
    var completed: Bool

    init(id: String = UUID().uuidString, title: String, details: String, completed: Bool = false) {
        self.id = id
        self.title = title
        self.details = details
        self.completed = completed
    }

    init?(snapshot: [String: Any], id: String) {
        guard let title = snapshot["title"] as? String,
              let details = snapshot["details"] as? String,
              let completed = snapshot["completed"] as? Bool else {
            return nil
        }
        self.id = id
        self.title = title
        self.details = details
        self.completed = completed
    }

    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "details": details,
            "completed": completed
        ]
    }
}
