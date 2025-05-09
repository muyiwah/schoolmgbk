// // services/database_service.dart


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:schmgtsystem/deepseek/keep/models/fees.dart';
// import 'package:schmgtsystem/deepseek/keep/models/school.dart';
// import 'package:schmgtsystem/deepseek/keep/models/students.dart';

// class DatabaseService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Students collection reference
//   final CollectionReference studentsCollection = FirebaseFirestore.instance
//       .collection('students');

//   // Fees collection reference
//   final CollectionReference feesCollection = FirebaseFirestore.instance
//       .collection('fees');

//   // Stream of all students
//   Stream<List<Student>> studentsStream() {
//     return studentsCollection.snapshots().map(_studentListFromSnapshot);
//   }

//   // Stream of students with outstanding fees
//   Stream<List<Student>> debtorsStream() {
//     return studentsCollection
//         .where('outstandingFees', isGreaterThan: 0)
//         .snapshots()
//         .map(_studentListFromSnapshot);
//   }

//   // Get current fee structure
//   Future<FeeStructure> getFeeStructure() async {
//     DocumentSnapshot snapshot = await feesCollection.doc('current').get();
//     return FeeStructure.fromMap(snapshot.data() as Map<String, dynamic>,'');
//   }

//   // Update fee structure
//   Future<void> updateFeeStructure(FeeStructure feeStructure) {
//     return feesCollection.doc('current').set(feeStructure.toMap());
//   }

//   // Helper function to convert snapshot to Student list
//   List<Student> _studentListFromSnapshot(QuerySnapshot snapshot) {
//     return snapshot.docs.map((doc) {
//       return Student(
//         id: doc.id,
//         name: doc['name'],
//         grade: doc['grade'],
//         outstandingFees: doc['outstandingFees'], parentName: '', parentPhone: '',
//         // other fields...
//       );
//     }).toList();
//   }


//   // Additional methods for DatabaseService
//   Future<School> getSchoolInfo() async {
//     DocumentSnapshot snapshot =
//         await _firestore.collection('school').doc('info').get();
//     return School.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id);
//   }

//   Future<void> updateSchoolInfo(School school) async {
//     await _firestore.collection('school').doc('info').set(school.toMap());
//   }

//   Future<List<Payment>> getStudentPayments(String studentId) async {
//     QuerySnapshot snapshot =
//         await _firestore
//             .collection('payments')
//             .where('studentId', isEqualTo: studentId)
//             .orderBy('date', descending: true)
//             .get();

//     return snapshot.docs.map((doc) {
//       return Payment.fromMap(doc.data() as Map<String, dynamic>, doc.id);
//     }).toList();
//   }

//   Future<void> recordPayment(Payment payment) async {
//     // Add payment record
//     await _firestore.collection('payments').add(payment.toMap());

//     // Update student's outstanding fees
//     DocumentReference studentRef = _firestore
//         .collection('students')
//         .doc(payment.studentId);
//     await _firestore.runTransaction((transaction) async {
//       DocumentSnapshot snapshot = await transaction.get(studentRef);
//       if (snapshot.exists) {
//         double currentDebt =
//             (snapshot.data() as Map<String, dynamic>)['outstandingFees'] ?? 0;
//         double newDebt = currentDebt - payment.amount;
//         transaction.update(studentRef, {'outstandingFees': newDebt});
//       }
//     });
//   }
// }


