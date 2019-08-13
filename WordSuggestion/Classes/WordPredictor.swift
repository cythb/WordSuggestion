//
//  WordPredictor.swift
//  WordSuggestion
//
//  Created by Cirno MainasuK on 2019-8-12.
//

import Foundation
import RealmSwift

public class WordPredictor: NSObject {

    let regex: NSRegularExpression
    let ngramPath: NgramPath
    let realm: Realm
    var operationQueue: OperationQueue?

    public var needLoadNgramData: Bool {
        let ngram1 = realm.objects(NGram4.self)
        return ngram1.count == 0
    }

    public init(ngramPath: NgramPath, realm: Realm) {
        self.regex = try! NSRegularExpression(pattern: "\\p{L}[\\p{L}']*(?:-\\p{L}+)*", options: .caseInsensitive)
        self.ngramPath = ngramPath
        self.realm = realm
    }

}

extension WordPredictor {

    public struct NgramPath {
        public var ngram1: String
        public var ngram2: String
        public var ngram3: String
        public var ngram4: String

        public static var `default`: NgramPath? {
            let bundle = Bundle(for: WordPredictor.self)
            guard let bundleURL = bundle.resourceURL?.appendingPathComponent("Corpus.bundle"),
            let corpusBundle = Bundle(url: bundleURL) else {
                return nil
            }

            guard let ngram1Path = corpusBundle.path(forResource: "ngram1", ofType: "csv"),
            let ngram2Path = corpusBundle.path(forResource: "ngram2", ofType: "csv"),
            let ngram3Path = corpusBundle.path(forResource: "ngram3", ofType: "csv"),
            let ngram4Path = corpusBundle.path(forResource: "ngram4", ofType: "csv") else {
                return nil
            }

            return NgramPath(ngram1: ngram1Path,
                             ngram2: ngram2Path,
                             ngram3: ngram3Path,
                             ngram4: ngram4Path)
        }
    }

    public enum Error: Swift.Error {
        case loadNgramFail
    }

}

extension WordPredictor {


    public func load(completion: @escaping (Swift.Error?) -> Void) {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: ngramPath.ngram1),
        fileManager.fileExists(atPath: ngramPath.ngram2),
        fileManager.fileExists(atPath: ngramPath.ngram3),
        fileManager.fileExists(atPath: ngramPath.ngram4) else {
            completion(Error.loadNgramFail)
            return
        }

        var realm: Realm
        do {
            realm = try Realm(configuration: self.realm.configuration)
        } catch {
            completion(error)
            return
        }
        realm.beginWrite()
        realm.delete(realm.objects(NGram1.self))
        realm.delete(realm.objects(NGram2.self))
        realm.delete(realm.objects(NGram3.self))
        realm.delete(realm.objects(NGram4.self))
        do {
            try realm.commitWrite()
        } catch {
            completion(error)
            return
        }

        guard let fileReader1 = FileReader(filePath: ngramPath.ngram1),
        let fileReader2 = FileReader(filePath: ngramPath.ngram2),
        let fileReader3 = FileReader(filePath: ngramPath.ngram3),
        let fileReader4 = FileReader(filePath: ngramPath.ngram4) else {
            completion(Error.loadNgramFail)
            return
        }

        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .userInitiated)

        // Note: fileReader.enumerateLines callback is sync method

        // MARK: - ngram1
        group.enter()
        queue.async {
            var grams: [NGram1] = []
            var id = 0
            fileReader1.enumerateLines { line, stop in
                guard let items = line?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ","), items.count == 2, let freq = Double(items[1]) else {
                    assertionFailure()
                    return
                }
                let gram = NGram1()
                gram.id = id
                gram.x = items[0]
                gram.freq = freq

                grams.append(gram)
                id += 1
            }

            DispatchQueue.main.async {
                realm.beginWrite()
                realm.add(grams, update: .all)
                try? realm.commitWrite()
                group.leave()
            }
        }

        // MARK: - ngram2
        group.enter()
        queue.async {
            var grams: [NGram2] = []
            var id = 0
            fileReader2.enumerateLines { line, stop in
                guard let items = line?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ","), items.count == 3, let freq = Double(items[2]) else {
                    assertionFailure()
                    return
                }
                let gram = NGram2()
                gram.id = id
                gram.x = items[0]
                gram.y = items[1]
                gram.freq = freq
                
                grams.append(gram)
                id += 1
            }

            DispatchQueue.main.async {
                realm.beginWrite()
                realm.add(grams, update: .all)
                try? realm.commitWrite()
                group.leave()
            }
        }

        // MARK: - ngram3
        group.enter()
        queue.async {
            var grams: [NGram3] = []
            var id = 0
            fileReader3.enumerateLines { line, stop in
                guard let items = line?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ","), items.count == 3, let freq = Double(items[2]) else {
                    assertionFailure()
                    return
                }
                let gram = NGram3()
                gram.id = id
                gram.x = items[0]
                gram.y = items[1]
                gram.freq = freq

                grams.append(gram)
                id += 1
            }

            DispatchQueue.main.async {
                realm.beginWrite()
                realm.add(grams, update: .all)
                try? realm.commitWrite()
                group.leave()
            }
        }

        // MARK: - ngram4
        group.enter()
        queue.async {
            var grams: [NGram4] = []
            var id = 0
            fileReader4.enumerateLines { line, stop in
                guard let items = line?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ","), items.count == 3, let freq = Double(items[2]) else {
                    assertionFailure()
                    return
                }
                let gram = NGram4()
                gram.id = id
                gram.x = items[0]
                gram.y = items[1]
                gram.freq = freq

                grams.append(gram)
                id += 1
            }
            DispatchQueue.main.async {
                realm.beginWrite()
                realm.add(grams, update: .all)
                try? realm.commitWrite()
                group.leave()
            }
        }

        // Group notify
        group.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: {
            completion(nil)
        }))
    }

    public func suggestWords(for input: String, limit: Int = 3, completion: @escaping ([(String, Double)]) -> Void) {
        if let operationQueue = self.operationQueue {
            operationQueue.cancelAllOperations()
        }

        self.operationQueue = OperationQueue()
        operationQueue?.addOperation { [weak self] in
            guard let `self` = self else { return }
            guard let lastChar = input.last else {
                OperationQueue.main.addOperation {
                    completion([])
                }
                return
            }
            var realm: Realm
            do {
                realm = try Realm(configuration: self.realm.configuration)
            } catch {
                OperationQueue.main.addOperation {
                    completion([])
                }
                return
            }

            var lastWords: [String] = []
            let isNewWord = String(lastChar).rangeOfCharacter(from: .whitespacesAndNewlines) != nil
            let range = NSRange(location: 0, length: (input as NSString).length)
            let checkResults = self.regex.matches(in: input, options: .reportProgress, range: range)
            let start = max(checkResults.count - 4, 0)
            for i in start..<checkResults.count {
                let result = checkResults[i]
                let parsedText = (input as NSString).substring(with: result.range)
                lastWords.append(parsedText.lowercased())
            }

            let lastWord = isNewWord ? "" : lastWords.last ?? ""
            if (!isNewWord) {
                lastWords = lastWords.dropLast()    // lastWords + lastWord == input
            }

            var suggestedWords = [String: Double]()

            // 4-gram
            let results4: [NGram4] = {
                let txt = self.txt(for: .gram4, lastWords: lastWords)
                let predicate = self.predicate(forTxt: txt, lastWord: isNewWord ? nil : lastWord)
                return self.results(of: NGram4.self, realm: realm, predicate: predicate)
            }()
            self.suggestedWords(for: results4, suggestedWords: &suggestedWords)

            // 3-gram
            let results3: [NGram3] = {
                let txt = self.txt(for: .gram3, lastWords: lastWords)
                let predicate = self.predicate(forTxt: txt, lastWord: isNewWord ? nil : lastWord)
                return self.results(of: NGram3.self, realm: realm, predicate: predicate)
            }()
            self.suggestedWords(for: results3, suggestedWords: &suggestedWords)

            // 2-gram
            let results2: [NGram2] = {
                let txt = self.txt(for: .gram2, lastWords: lastWords)
                let predicate = self.predicate(forTxt: txt, lastWord: isNewWord ? nil : lastWord)
                return self.results(of: NGram2.self, realm: realm, predicate: predicate)
            }()
            self.suggestedWords(for: results2, suggestedWords: &suggestedWords)

            // 1-gram
            let results1: [NGram1] = {
                let predicate = NSPredicate(format: "x BEGINSWITH %@", lastWord)
                return self.results(of: NGram1.self, realm: realm, predicate: predicate)
            }()
            self.suggestedWords(for: results1, suggestedWords: &suggestedWords)

            let sortedWords = suggestedWords.sorted(by: { lhs, rhs -> Bool in
                return lhs.value > rhs.value
            })

            OperationQueue.main.addOperation {
                completion(sortedWords)
            }
        }   // end operationQueue.addOperation
    }

}

extension WordPredictor {

    enum Gram: CaseIterable {
        case gram1
        case gram2
        case gram3
        case gram4
    }

    // pattern
    private func txt(for gram: Gram, lastWords: [String]) -> String {
        switch gram {
        case .gram4:    return lastWords.suffix(3).joined(separator: " ")
        case .gram3:    return lastWords.suffix(2).joined(separator: " ")
        case .gram2:    return lastWords.suffix(1).joined(separator: " ")
        case .gram1:    return ""
        }
    }

    private func predicate(forTxt txt: String, lastWord: String?) -> NSPredicate {
        if let lastWord = lastWord {
            return NSPredicate(format: "x == %@ AND y BEGINSWITH %@", txt, lastWord)
        } else {
            return NSPredicate(format: "x == %@", txt)
        }
    }

    private func results<T: Object>(of type: T.Type, realm: Realm, predicate: NSPredicate, limit: Int = 3) -> [T] where T: NGramProtocol {
        return Array(realm.objects(type).filter(predicate).sorted(byKeyPath: "freq", ascending: false).prefix(limit))
    }

    private func suggestedWords<T: NGramProtocol>(for results: [T], suggestedWords: inout [String: Double]) {
        guard !results.isEmpty else {
            return
        }

        let freqSum = results.reduce(into: 0) { $0 += $1.freq }
        let weight: Double = {
            switch results.first {
            case is NGram4: return 0.6
            case is NGram3: return 0.3
            case is NGram2: return 0.08
            case is NGram1: return 0.02
            default:        return 0
            }
        }()

        for ngram in results {
            guard let y = self.y(for: ngram) else { continue }
            let freq = ngram.freq / freqSum * weight
            let currentFreq = suggestedWords[y]
            if let currentFreq = currentFreq {
                suggestedWords[y] = Double(currentFreq) + freq
            } else {
                suggestedWords[y] = freq
            }
        }

    }

    private func y<T: NGramProtocol>(for ngram: T) -> String? {
        switch ngram {
        case let gram as NGram4:     return gram.y
        case let gram as NGram3:     return gram.y
        case let gram as NGram2:     return gram.y
        case let gram as NGram1:     return gram.x
        default:                     return nil
        }
    }

}
