import Foundation

@Observable
class ModelData {
    var plays: [Play] = load("playData.json")
    var practices: [Practice] = load("practiceData.json")
    
    var leftHandPractices: [Practice] {
        practices.filter { $0.isLeftHand }
    }
    
    var rightHandPractices: [Practice] {
        practices.filter { !$0.isLeftHand }
    }
    
    var bothHandPractice: Play {
        plays.last!
    }
}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
