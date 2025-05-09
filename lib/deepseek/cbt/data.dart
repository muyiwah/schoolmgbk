import 'package:schmgtsystem/deepseek/cbt/model/exam.dart';

List<Question> mathQuestions = [
  Question(
    text: "What is the value of π (pi) rounded to two decimal places?",
    type: QuestionType.multipleChoice,
    options: ["3.14", "3.16", "3.12", "3.18"],
    correctAnswer: "3.14",
    points: 1,
  ),
  Question(
    text: "Solve for x: 2x + 5 = 15",
    type: QuestionType.multipleChoice,
    options: ["5", "7", "10", "12"],
    correctAnswer: "5",
    points: 2,
  ),
  Question(
    text: "What is the area of a rectangle with length 8cm and width 5cm?",
    type: QuestionType.multipleChoice,
    options: ["13 cm²", "26 cm²", "40 cm²", "45 cm²"],
    correctAnswer: "40 cm²",
    points: 1,
  ),
  Question(
    text: "The sum of angles in a triangle is 180 degrees.",
    type: QuestionType.trueFalse,
    options: ["True", "False"],
    correctAnswer: "True",
    points: 1,
  ),
  Question(
    text: "Explain the Pythagorean theorem in your own words.",
    type: QuestionType.shortAnswer,
    options: [],
    correctAnswer:
        "In a right-angled triangle, the square of the hypotenuse is equal to the sum of the squares of the other two sides.",
    points: 3,
  ),
];

List<Question> scienceQuestions = [
  Question(
    text: "Which gas do plants absorb during photosynthesis?",
    type: QuestionType.multipleChoice,
    options: ["Oxygen", "Carbon dioxide", "Nitrogen", "Hydrogen"],
    correctAnswer: "Carbon dioxide",
    points: 1,
  ),
  Question(
    text: "The human body has 206 bones.",
    type: QuestionType.trueFalse,
    options: ["True", "False"],
    correctAnswer: "True",
    points: 1,
  ),
  Question(
    text: "What is the chemical symbol for gold?",
    type: QuestionType.multipleChoice,
    options: ["Go", "Gd", "Au", "Ag"],
    correctAnswer: "Au",
    points: 1,
  ),
  Question(
    text: "Describe Newton's First Law of Motion.",
    type: QuestionType.shortAnswer,
    options: [],
    correctAnswer:
        "An object at rest stays at rest and an object in motion stays in motion with the same speed and in the same direction unless acted upon by an unbalanced force.",
    points: 2,
  ),
  Question(
    text: "Which planet is known as the Red Planet?",
    type: QuestionType.multipleChoice,
    options: ["Venus", "Mars", "Jupiter", "Saturn"],
    correctAnswer: "Mars",
    points: 1,
  ),
];
List<Question> englishQuestions = [
  Question(
    text: "Which of these is a proper noun?",
    type: QuestionType.multipleChoice,
    options: ["city", "London", "animal", "happiness"],
    correctAnswer: "London",
    points: 1,
  ),
  Question(
    text: "The past tense of 'go' is 'went'.",
    type: QuestionType.trueFalse,
    options: ["True", "False"],
    correctAnswer: "True",
    points: 1,
  ),
  Question(
    text:
        "Which word is an adjective in this sentence: 'The quick brown fox jumps over the lazy dog'?",
    type: QuestionType.multipleChoice,
    options: ["quick", "fox", "jumps", "dog"],
    correctAnswer: "quick",
    points: 1,
  ),
  Question(
    text: "Define what a metaphor is and give an example.",
    type: QuestionType.shortAnswer,
    options: [],
    correctAnswer:
        "A metaphor is a figure of speech that directly compares two unlike things without using 'like' or 'as'. Example: 'The classroom was a zoo.'",
    points: 3,
  ),
  Question(
    text: "Which of these is a conjunction?",
    type: QuestionType.multipleChoice,
    options: ["run", "beautiful", "and", "quickly"],
    correctAnswer: "and",
    points: 1,
  ),
];
List<Question> historyQuestions = [
  Question(
    text: "In which year did World War II end?",
    type: QuestionType.multipleChoice,
    options: ["1943", "1945", "1947", "1950"],
    correctAnswer: "1945",
    points: 1,
  ),
  Question(
    text: "The Declaration of Independence was signed in 1776.",
    type: QuestionType.trueFalse,
    options: ["True", "False"],
    correctAnswer: "True",
    points: 1,
  ),
  Question(
    text: "Who was the first president of the United States?",
    type: QuestionType.multipleChoice,
    options: [
      "Thomas Jefferson",
      "John Adams",
      "George Washington",
      "Abraham Lincoln",
    ],
    correctAnswer: "George Washington",
    points: 1,
  ),
  Question(
    text: "Explain the significance of the Industrial Revolution.",
    type: QuestionType.shortAnswer,
    options: [],
    correctAnswer:
        "The Industrial Revolution marked a shift from agrarian economies to industrialized ones, introducing mechanized manufacturing and transforming social and economic structures.",
    points: 3,
  ),
  Question(
    text: "Which ancient civilization built the pyramids?",
    type: QuestionType.multipleChoice,
    options: ["Greeks", "Romans", "Egyptians", "Mayans"],
    correctAnswer: "Egyptians",
    points: 1,
  ),
];
List<Question> computerScienceQuestions = [
  Question(
    text: "What does CPU stand for?",
    type: QuestionType.multipleChoice,
    options: [
      "Central Processing Unit",
      "Computer Processing Unit",
      "Central Process Unit",
      "Computer Primary Unit",
    ],
    correctAnswer: "Central Processing Unit",
    points: 1,
  ),
  Question(
    text: "HTML is a programming language.",
    type: QuestionType.trueFalse,
    options: ["True", "False"],
    correctAnswer: "False",
    points: 1,
  ),
  Question(
    text: "Which of these is NOT a valid programming language?",
    type: QuestionType.multipleChoice,
    options: ["Python", "Java", "C++", "HTML"],
    correctAnswer: "HTML",
    points: 1,
  ),
  Question(
    text: "Explain the difference between RAM and ROM.",
    type: QuestionType.shortAnswer,
    options: [],
    correctAnswer:
        "RAM (Random Access Memory) is volatile memory used for temporary data storage while the computer is running. ROM (Read-Only Memory) is non-volatile memory that stores permanent instructions for the computer.",
    points: 2,
  ),
  Question(
    text: "What is the binary representation of the decimal number 10?",
    type: QuestionType.multipleChoice,
    options: ["1010", "1100", "1001", "1110"],
    correctAnswer: "1010",
    points: 2,
  ),
];
List<Exam> dummyExams = [
  Exam(
    title: "Mathematics Midterm Exam",
    description: "Basic arithmetic and algebra concepts",
    startDate: DateTime.now(),
    endDate: DateTime.now().add(Duration(days: 7)),
    durationMinutes: 60,
    creatorId: "teacher1",
    questions: mathQuestions,
  ),
  Exam(
    title: "Science Quarterly Test",
    description: "General science knowledge assessment",
    startDate: DateTime.now(),
    endDate: DateTime.now().add(Duration(days: 14)),
    durationMinutes: 45,
    creatorId: "teacher2",
    questions: scienceQuestions,
  ),
  Exam(
    title: "English Language Proficiency",
    description: "Grammar and vocabulary evaluation",
    startDate: DateTime.now().add(Duration(days: 1)),
    endDate: DateTime.now().add(Duration(days: 21)),
    durationMinutes: 50,
    creatorId: "teacher3",
    questions: englishQuestions,
  ),
  Exam(
    title: "World History Quiz",
    description: "Important historical events and figures",
    startDate: DateTime.now().subtract(Duration(days: 1)),
    endDate: DateTime.now().add(Duration(days: 10)),
    durationMinutes: 30,
    creatorId: "teacher1",
    questions: historyQuestions,
  ),
  Exam(
    title: "Computer Science Fundamentals",
    description: "Basic computing concepts",
    startDate: DateTime.now(),
    endDate: DateTime.now().add(Duration(days: 30)),
    durationMinutes: 40,
    creatorId: "teacher4",
    questions: computerScienceQuestions,
  ),
];

