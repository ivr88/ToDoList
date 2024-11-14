import Foundation

protocol TaskAPIServiceProtocol {
    func fetchTasks(completion: @escaping ([Task]) -> Void)
}

class APIService: TaskAPIServiceProtocol {
    func fetchTasks(completion: @escaping ([Task]) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            print("Invalid URL")
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching tasks: \(error)")
                completion([])
                return
            }

            guard let data = data else {
                completion([])
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(TodoResponse.self, from: data)
                completion(decodedResponse.todos)
            } catch {
                print("Error decoding JSON: \(error)")
                completion([])
            }
        }.resume()
    }
}
