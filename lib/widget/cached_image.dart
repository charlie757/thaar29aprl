import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:thaartransport/widget/indicatiors.dart';

Widget cachedNetworkImage(String imgUrl) {
  return CachedNetworkImage(
    imageUrl: imgUrl,
    fit: BoxFit.cover,
    height: 200,
    width: 300,
    placeholder: (context, url) => circularProgress(context),
    errorWidget: (context, url, error) => const Center(
      child: Text(
        'Unable to load Image',
        style: TextStyle(fontSize: 10.0),
      ),
    ),
  );
}

// export const setProductsToExpired = functions.
// https.onRequest(async (request, response) => {
//   const expiredProducts = await admin.firestore()
//       .collection("orderuser")
//       .where("id", "==", "XGKiGCT7vYe5wVLmOIlGVuLueNo2")
//       .get();
//   // const batch = admin.firestore().batch();
//   expiredProducts.forEach((doc) => {
//     const id = doc.get("id");
//     admin.firestore().collection("orderuser").doc(id)
//         .update( {"expired": "true"});
//     console.log("userid"+doc.get("id"));
//   });
//   // await batch.commit();
//   console.log("time11"+admin.firestore.FieldValue.serverTimestamp());
//   response.send("200");
// });