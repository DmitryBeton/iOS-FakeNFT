import UIKit

final class ImageLoader {
    static let shared = ImageLoader()

    private let cache = NSCache<NSString, UIImage>()
    private var runningTasks: [UUID: URLSessionDataTask] = [:]
    private let lock = NSLock()

    @discardableResult
    func load(_ url: URL, completion: @escaping (UIImage?) -> Void) -> UUID? {
        let key = url.absoluteString as NSString

        if let cached = cache.object(forKey: key) {
            completion(cached)
            return nil
        }

        let uuid = UUID()
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else { return }

            var image: UIImage?
            if let data = data {
                image = UIImage(data: data)
            }

            if let image {
                self.cache.setObject(image, forKey: key)
            }

            DispatchQueue.main.async { completion(image) }

            self.lock.lock()
            self.runningTasks.removeValue(forKey: uuid)
            self.lock.unlock()
        }

        lock.lock()
        runningTasks[uuid] = task
        lock.unlock()

        task.resume()
        return uuid
    }

    func cancel(_ uuid: UUID) {
        lock.lock()
        let task = runningTasks[uuid]
        runningTasks.removeValue(forKey: uuid)
        lock.unlock()

        task?.cancel()
    }
}

