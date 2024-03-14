//
//  TriviaQuestions.swift
//  Trivia
//
//  Created by Juan Matias on 3/12/24.
//

import Foundation

class TriviaQuestions {
    func fetchTriviaQuestions(completion: @escaping ([TriviaQuestion]?) -> Void) {
        let urlString = "https://opentdb.com/api.php?amount=10&category=12&difficulty=easy&type=multiple"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                let result = try JSONDecoder().decode(TriviaApiResponse.self, from: data)
                let questions = result.results.map { result -> TriviaQuestion in
                    let correctAnswer = result.correct_answer
                    var answers = result.incorrect_answers
                    answers.append(correctAnswer)
                    answers.shuffle()

                    return TriviaQuestion(
                        category: result.category.decodedString(),
                        question: result.question.decodedString(),
                        answers: answers.map { $0.decodedString() },
                        correctAnswerIndex: answers.firstIndex(of: correctAnswer) ?? 0
                    )
                }
                completion(questions)
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
}

struct TriviaApiResponse: Codable {
    let results: [QuestionData]
}

struct QuestionData: Codable {
    let category: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

extension String {
    func decodedString() -> String {
        let replaced = self.replacingOccurrences(of: "&#039;", with: "'")
                       .replacingOccurrences(of: "&quot;", with: "\"")
                       .replacingOccurrences(of: "&eacute;", with: "é")
                       .replacingOccurrences(of: "&amp;", with: "&")
                       .replacingOccurrences(of: "&Uuml;", with: "Ü")
        // Add more HTML entities decoding if needed
        return replaced
    }
}
