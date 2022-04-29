// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:thaartransport/utils/firebase.dart';

// class FeedBack extends StatefulWidget {
//   const FeedBack({Key? key}) : super(key: key);

//   @override
//   State<FeedBack> createState() => _FeedBackState();
// }

// class _FeedBackState extends State<FeedBack> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<QuerySnapshot>(
//           stream: feedbackRef.snapshots(),
//           builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//             return ListView.builder(
//               itemCount: snapshot.data!.docs.length,
//               itemBuilder: (context, index) {
//               return StreamBuilder<QuerySnapshot>(
//                   stream: usersRef
//                       .where('id', isEqualTo: snapshot.data[index][''])
//                       .snapshots(),
//                   builder: (context, AsyncSnapshot<QuerySnapshot> snapshot1) {
//                     return ListView.builder(itemBuilder: (context, index) {});
//                   });
//             });
//           }),
//     );
//   }
// }
