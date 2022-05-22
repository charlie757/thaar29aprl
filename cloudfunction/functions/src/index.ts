import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

exports.sendNotifications = functions.firestore.
    document("thaarbidsdata/{thaarbiddata}").
    onCreate(async (snapshot, context) => {
      try {
        const notificationdocument = snapshot.data();
        // const uid = context.params.user;
        const bidid = notificationdocument.bidid;
        const notificationuser = notificationdocument.notificationuser;

        const postid = notificationdocument.loadid;
        const userDoc = await admin.firestore().collection("thaarusers").
            doc(bidid).get();
        const Tokens = userDoc.data();
        let fcmToken;
        if (Tokens) {
          fcmToken = Tokens.firebasetoken;
        }

        const notificationuserDoc = await admin.firestore().
            collection("thaarusers").doc(notificationuser).get();

        const usernamedata = notificationuserDoc.data();
        let username;
        if (usernamedata) {
          username = usernamedata.username;
        }

        const postDoc = await admin.firestore().collection("thaarorderdata").
            doc(postid).get();
        const postdata = postDoc.data();
        let sourcelocation;
        let destinationlocation;
        if (postdata) {
          sourcelocation = postdata.sourcelocation;
          destinationlocation = postdata.destinationlocation;
        }

        const truckDoc = await admin.firestore().collection("thaartruckdata").
            doc(notificationdocument.truckid).collection("changeslorry").
            where("truckposttime", "==", notificationdocument.truckposttime).
            get();
        let trucknumber;
        truckDoc.forEach((element) => {
          trucknumber = element.get("lorrynumber");
        });

        const notificationMessage = "response on from "+""+sourcelocation+"" +
            " To "+
            ""+""+destinationlocation +" load with the "+ "Truck number "+
            trucknumber+ " and bidding amount is "+""+
            notificationdocument.rate;
        const notificationTitle = username + " response on your bid\n";
        const message = {
          "notification": {
            title: notificationTitle,
            body: notificationMessage,
          },
          "token": fcmToken,
        };
        admin.messaging().send(message);
      } catch (error) {
        console.log(error);
      }
    });

exports.updatesendNotifications = functions.firestore.
    document("thaarbidsdata/{thaarbiddata}").
    onUpdate(async (snapshot, context) => {
      try {
        const notificationdocument = snapshot.after.data();
        // const uid = context.params.user;
        const bidid = notificationdocument.bidid;
        const notificationuser = notificationdocument.notificationuser;

        const postid = notificationdocument.loadid;
        const userDoc = await admin.firestore().collection("thaarusers").
            doc(bidid).get();
        const Tokens = userDoc.data();
        let fcmToken;
        if (Tokens) {
          fcmToken = Tokens.firebasetoken;
        }

        const notificationuserDoc = await admin.firestore().
            collection("thaarusers").doc(notificationuser).get();

        const usernamedata = notificationuserDoc.data();
        let username;
        if (usernamedata) {
          username = usernamedata.username;
        }

        const postDoc = await admin.firestore().collection("thaarorderdata").
            doc(postid).get();
        const postdata = postDoc.data();
        let sourcelocation;
        let destinationlocation;
        if (postdata) {
          sourcelocation = postdata.sourcelocation;
          destinationlocation = postdata.destinationlocation;
        }

        const truckDoc = await admin.firestore().
            collection("thaartruckdata").
            doc(notificationdocument.truckid).collection("changeslorry").
            where("truckposttime", "==", notificationdocument.truckposttime).
            get();
        let trucknumber;
        truckDoc.forEach((element) => {
          trucknumber = element.get("lorrynumber");
        });
        const notificationMessage = notificationdocument.bidresponse+"\n"+
        "response on from "+""+sourcelocation+"" +" To "+
        ""+""+destinationlocation +" load with the "+ "Truck number "+
        trucknumber+ " and bidding amount is "+""+
        notificationdocument.rate;
        const notificationTitle = username + " response on your bid\n\n";
        const message = {
          "notification": {
            title: notificationTitle,
            body: notificationMessage,
          },
          "token": fcmToken,
        };
        admin.messaging().send(message);
      } catch (error) {
        console.log(error);
      }
    });
