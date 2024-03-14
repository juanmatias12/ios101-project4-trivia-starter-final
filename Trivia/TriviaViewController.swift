import UIKit


struct TriviaQuestion {
    var category: String
    var question: String
    var answers: [String]
    var correctAnswerIndex: Int
}

class TriviaViewController: UIViewController {
    
    
    @IBOutlet weak var QuestionLabel: UILabel!
    @IBOutlet var AnswerButtons: [UIButton]!
    @IBOutlet weak var questionInfo: UILabel!
    
    var questions: [TriviaQuestion] = []
    var currentQuestionIndex = 0
    var score = 0
    
    let triviaQuestionsService = TriviaQuestions()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAndDisplayQuestions()
    }
    
    func fetchAndDisplayQuestions() {
        triviaQuestionsService.fetchTriviaQuestions { [weak self] questions in
            DispatchQueue.main.async {
                if let questions = questions, !questions.isEmpty {
                    self?.questions = questions
                    self?.currentQuestionIndex = 0
                    self?.score = 0
                    self?.displayCurrentQuestion()
                } else {
                    // Handle the error or empty state
                    print("Failed to fetch questions or no questions available.")
                }
            }
        }
    }
    
    @IBAction func answerButtonTapped(_ sender: UIButton) {
        guard currentQuestionIndex < questions.count else { return }
        
        let currentQuestion = questions[currentQuestionIndex]
        let correctAnswer = currentQuestion.answers[currentQuestion.correctAnswerIndex]
        
        if sender.titleLabel?.text == correctAnswer {
            score += 1
            showAlert(withTitle: "Correct!", message: "The answer is \(correctAnswer).")
        } else {
            showAlert(withTitle: "Wrong!", message: "The answer is \(correctAnswer).")
        }
        
    }
    
    func loadNextQuestion() {
        currentQuestionIndex += 1
        if currentQuestionIndex < questions.count {
            displayCurrentQuestion()
        } else {
            let alert = UIAlertController(title: "End of Quiz", message: "Your score: \(score)/\(questions.count)", preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart", style: .default) { [weak self] _ in
                self?.fetchAndDisplayQuestions()
            }
            alert.addAction(restartAction)
            present(alert, animated: true)
        }
    }
    
    func displayCurrentQuestion() {
        if currentQuestionIndex < questions.count {
            let currentQuestion = questions[currentQuestionIndex]
            QuestionLabel.text = currentQuestion.question
            questionInfo.text = "Question: \(currentQuestionIndex + 1)/\(questions.count) \n \(currentQuestion.category)"
            for (index, button) in AnswerButtons.enumerated() {
                button.setTitle(currentQuestion.answers[index], for: .normal)
            }
        }
    }
    private func showAlert(withTitle title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let nextAction = UIAlertAction(title: "Next", style: .default) { [weak self] _ in self?.loadNextQuestion() }
            alert.addAction(nextAction)
            present(alert, animated: true)
        }
    }

