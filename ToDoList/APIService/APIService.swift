import Foundation

protocol TaskAPIServiceProtocol {
    func fetchTasks() -> [Task]
}

class APIService: TaskAPIServiceProtocol {
    
    func fetchTasks() -> [Task] {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            print("Invalid URL")
            return []
        }
        
        var tasks: [Task] = []
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching tasks: \(error)")
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(TodoResponse.self, from: data)
                tasks = decodedResponse.todos
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        task.resume()
        
        return tasks
    }
}
