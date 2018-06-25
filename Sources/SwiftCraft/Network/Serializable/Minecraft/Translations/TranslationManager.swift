//
//  TranslationManager.swift
//  SwiftCraft iOS
//
//  Created by Noah Peeters on 26.06.18.
//  Copyright © 2018 Noah Peeters. All rights reserved.
//

import Foundation

public protocol TranslationManager {
    func string(withKey key: String, substitutions: [String]) -> String
}

public class EnglishTranslationManager: TranslationManager {
    public init() {}

    public func string(withKey key: String, substitutions: [String]) -> String {
        guard let pattern = MinecraftEnglishTranslations.patterns[key] else {
            return key
        }

        var resultString = pattern
        var index = resultString.startIndex
        var substitutionIndex = 0

        while index < resultString.endIndex {
            guard resultString[index] == "%" else {
                index = resultString.index(after: index)
                continue
            }

            var placeholderIndex = resultString.index(after: index)

            guard placeholderIndex < resultString.endIndex else {
                break
            }

            guard resultString[placeholderIndex] != "%" else {
                resultString.replaceSubrange(index...placeholderIndex, with: "%")
                index = resultString.index(after: index)
                continue
            }

            guard resultString[placeholderIndex] != "s" else {
                guard let substitution = substitutions.elementIfExists(at: substitutionIndex) else {
                    index = resultString.index(after: placeholderIndex)
                    continue
                }
                resultString.replaceSubrange(index...placeholderIndex, with: substitution)
                index = resultString.index(index, offsetBy: substitution.count)
                substitutionIndex += 1
                continue
            }

            guard let substitutionIndexString = extractIndexSubstitutionText(
                                                        in: resultString, index: &placeholderIndex) else {
                break
            }

            guard let substitutionIndex = Int(substitutionIndexString),
                let substitution = substitutions.elementIfExists(at: substitutionIndex - 1) else {
                    index = resultString.index(after: placeholderIndex)
                    continue
            }
            resultString.replaceSubrange(index...placeholderIndex, with: substitution)
            index = resultString.index(index, offsetBy: substitution.count)
        }
        return resultString
    }

    private func extractIndexSubstitutionText(in resultString: String, index: inout String.Index) -> String? {
        var substitutionIndexString = ""
        while true {
            let char = resultString[index]
            if char == "s" {
                break
            } else if char == "$" {
                index = resultString.index(after: index)
            } else {
                substitutionIndexString.append(char)
                index = resultString.index(after: index)
            }
            guard index < resultString.endIndex else {
                return nil
            }
        }
        return substitutionIndexString
    }
}

extension Array {
    fileprivate func elementIfExists(at index: Int) -> Element? {
        guard index < count, index >= 0 else {
            return nil
        }
        return self[index]
    }
}
