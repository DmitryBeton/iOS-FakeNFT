import Foundation

extension String {
    
    var shortURLString: String {
        guard let url = URL(string: self) else { return "" }
        return url.host()?.replacingOccurrences(of: "www.", with: "") ?? ""
    }
    
}

