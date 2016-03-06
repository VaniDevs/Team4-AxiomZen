
import Foundation


extension String {

    var isPhoneNumber: Bool {
        let checkingTypes = NSTextCheckingType.PhoneNumber.rawValue
        guard let detector = try? NSDataDetector(types: checkingTypes) else { return false }
        let inputRange = NSMakeRange(0, self.characters.count)
        let matches = detector.matchesInString(self, options: [], range: inputRange)
        guard let result = matches.first else { return false }
        return result.resultType == .PhoneNumber
            && result.range.location == inputRange.location
            && result.range.length == inputRange.length
    }
}