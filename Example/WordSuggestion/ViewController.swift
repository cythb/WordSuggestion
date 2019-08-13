//
//  ViewController.swift
//  WordSuggestion
//
//  Created by mainasuk on 08/12/2019.
//  Copyright (c) 2019 mainasuk. All rights reserved.
//

import UIKit
import RealmSwift
import WordSuggestion

class ViewController: UIViewController {

    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    let realm: Realm = {
        var config = Realm.Configuration()
        let realmName = "WordPredictor_default"
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(realmName).realm")
        config.objectTypes = [NGram1.self, NGram2.self, NGram3.self, NGram4.self]
        try? FileManager.default.createDirectory(at: config.fileURL!.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)

        return try! Realm(configuration: config)
    }()
    lazy var wordPredictor = WordPredictor(ngramPath: WordPredictor.NgramPath.default!, realm: realm)

    lazy var textView = UITextView()
    lazy var predictWordPreviewStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()

        let stackView = UIStackView(arrangedSubviews: [textView, predictWordPreviewStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])

        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        predictWordPreviewStackView.axis = .vertical
        predictWordPreviewStackView.alignment = .top
        predictWordPreviewStackView.distribution = .fill

        textView.backgroundColor = .groupTableViewBackground
        textView.delegate = self

        print("Purge realm database for debug")
        realm.beginWrite()
        realm.deleteAll()
        try? realm.commitWrite()

        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        if wordPredictor.needLoadNgramData {
            wordPredictor.load { error in
                self.activityIndicatorView.stopAnimating()
                print(error)
            }
        }

        print(realm.configuration.fileURL!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - UITextViewDelegate
extension ViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        wordPredictor.suggestWords(for: textView.text) { suggestions in
            let labels = suggestions.map { tuple -> UILabel in
                let (string, freq) = tuple
                let label = UILabel()
                label.text = "\(string) - \(freq)"
                return label
            }

            for view in self.predictWordPreviewStackView.arrangedSubviews {
                self.predictWordPreviewStackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }

            for label in labels {
                self.predictWordPreviewStackView.addArrangedSubview(label)
            }

            // add padding
            self.predictWordPreviewStackView.addArrangedSubview(UIView())
        }
    }

}

