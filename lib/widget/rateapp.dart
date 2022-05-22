import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';

class RateAppInitWidget extends StatefulWidget {
  final Widget Function(RateMyApp) builder;

  const RateAppInitWidget(this.builder);

  @override
  State<RateAppInitWidget> createState() => _RateAppInitWidgetState();
}

class _RateAppInitWidgetState extends State<RateAppInitWidget> {
  RateMyApp? rateMyApp;

  static const playStoreId = 'thaar.app.thaartransport';
  @override
  Widget build(BuildContext context) {
    return RateMyAppBuilder(
        rateMyApp: RateMyApp(googlePlayIdentifier: playStoreId),
        onInitialized: (context, rateMyApp) {
          setState(() {
            this.rateMyApp = rateMyApp;
          });
        },
        builder: (context) => rateMyApp == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : widget.builder(rateMyApp!));
  }
}
