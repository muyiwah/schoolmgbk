import 'package:schmgtsystem/deepseek/deepseek2222/exammodel.dart';

Exam examdata = Exam(teacherId: '',
  examType: 'examType',
  className: 'className',
  subject: 'subject',
  term: 'term',
  academicYear: 'academicYear',
  duration: Duration(seconds: 90),
  questions: [
    Question(
      correctOptionId: 'option 1',
      options: [Option(text: 'text'), Option(text: 'optioin 1')],
      questionText: 'this is the question',
  deltaJson: []  ),
    Question(
      correctOptionId: 'option 12',
      options: [Option(text: 'text'), Option(text: 'option 12')],
      questionText: 'this is the question',
   deltaJson: []   ),
    Question(
      correctOptionId: 'option 12',
      options: [Option(text: 'text'), Option(text: 'option 12')],
      questionText: 'this is the question',
   deltaJson: []   ),
  ],
);
