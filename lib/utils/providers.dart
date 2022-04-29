import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:thaartransport/NEW/currentuserprovider.dart';
import 'package:thaartransport/auth/login_view_modal.dart';
import 'package:thaartransport/auth/post_view_modal.dart';
import 'package:thaartransport/auth/register_view_modal.dart';
import 'package:thaartransport/screens/profile/editprofileviewmodal.dart';
import 'package:thaartransport/screens/profile/yearsnotifiers.dart';
import 'package:thaartransport/services/connectivity.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => RegisterViewModel()),
  ChangeNotifierProvider(create: (_) => LoginViewModal()),
  ChangeNotifierProvider(create: (_) => PostsViewModel()),
  ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
  ChangeNotifierProvider(create: (_) => singleNotifier()),
  ChangeNotifierProvider(create: (_) => CurrentUserProvider()),
  ChangeNotifierProvider(create: (_) => ConnectivityProvider())
];
