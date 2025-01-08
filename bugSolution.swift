import Combine

class NetworkManager {
    private var cancellables = Set<AnyCancellable>()

    func fetchData() -> AnyPublisher<[String], Error> {
        return Future<[String], Error> { promise in
            let cancellable = Just<Void>(())
                .delay(for: 2, scheduler: DispatchQueue.global())
                .map { Bool.random() ? ["Data 1", "Data 2", "Data 3"] : nil }
                .compactMap { $0 } // Remove nil values after map
                .handleEvents(receiveOutput: { data in
                    // Use received data
                }, receiveCompletion: { completion in
                    // Handle completion
                })
                .subscribe(on: DispatchQueue.global())
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        promise(.success(["Data 1", "Data 2", "Data 3"]))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { data in
                    promise(.success(data))
                })

            self.cancellables.insert(cancellable)
            return
        }
        .eraseToAnyPublisher()
    }

    func cancel() {
        cancellables.forEach { $0.cancel() }
    }
} 