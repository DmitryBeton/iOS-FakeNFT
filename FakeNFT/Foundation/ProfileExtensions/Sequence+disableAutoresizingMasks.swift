import UIKit

extension Sequence where Element == UIView {
    
    func disableAutoresizingMasks() {
        forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
}
