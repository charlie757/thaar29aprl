import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:is_first_run/is_first_run.dart';
import 'package:new_version/new_version.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/NEW/homepage.dart';
import 'package:thaartransport/admin/transportpanel.dart';
import 'package:thaartransport/auth/login.dart';
import 'package:thaartransport/components/life_cycle_event_handler.dart';
import 'package:thaartransport/screens/mainsceen/gettingstarted.dart';
import 'package:thaartransport/services/notificationhandling.dart';
import 'package:thaartransport/utils/config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/providers.dart';
import 'package:thaartransport/widget/rateapp.dart';

import 'services/userservice.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', //id
    'High Importance Notifications', // name
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Config.initFirebase();
  await AndroidAlarmManager.initialize();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // FirebaseMessaging.onMessageOpenedApp;

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
  runApp(const MyApp());
  firstRun = await IsFirstRun.isFirstRun();
}

bool firstRun = false;

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.cubeGrid
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.3)
    ..userInteractions = false
    ..boxShadow = <BoxShadow>[]
    ..dismissOnTap = false;
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void versionCheck() async {
    final NewVersion newVersion =
        NewVersion(androidId: 'thaar.app.thaartransport');
    final status = await newVersion.getVersionStatus();
    newVersion.showUpdateDialog(
        context: context,
        versionStatus: status!,
        dialogText: "Please update your app from" +
            status.localVersion +
            " to " +
            "${status.storeVersion} version",
        dismissButtonText: "Skip",
        dialogTitle: "UPDATE!!",
        dismissAction: () {
          Navigator.pop(context);
        },
        updateButtonText: "Let's update");
    print("device: ${status.localVersion}");
    print("store: ${status.storeVersion}");
  }

  @override
  void initState() {
    super.initState();
    // versionCheck();
    // NotificationHandling().handleMessaging(context);
    WidgetsBinding.instance!.addObserver(
      LifecycleEventHandler(
        detachedCallBack: () => UserService().setUserStatus(false),
        resumeCallBack: () => UserService().setUserStatus(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: providers,
        child: RateAppInitWidget((rateMyApp) => OverlaySupport.global(
            child: GetMaterialApp(
                builder: EasyLoading.init(),
                title: Constants.appName,
                debugShowCheckedModeBanner: false,
                theme: Constants.lightTheme,
                home: MainPage()))));
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    print(firstRun);
    // CurrentUserProvider currentUserProvider =
    //     Provider.of<CurrentUserProvider>(context);
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasData) {
            return const HomePage();
          } else {
            return firstRun ? GettingStarted() : EnterNumber();
          }
        });
  }
}
