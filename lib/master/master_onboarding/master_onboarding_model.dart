import '/flutter_flow/flutter_flow_util.dart';
import 'master_onboarding_widget.dart' show MasterOnboardingWidget;
import 'package:flutter/material.dart';

class MasterOnboardingModel extends FlutterFlowModel<MasterOnboardingWidget> {
  PageController? pageViewController;
  int currentSlide = 0;

  @override
  void initState(BuildContext context) {
    pageViewController = PageController();
  }

  @override
  void dispose() {
    pageViewController?.dispose();
  }
}
