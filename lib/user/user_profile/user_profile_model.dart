import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/global_comp/menu/menu_widget.dart';
import '/global_comp/togle_mode/togle_mode_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'user_profile_widget.dart' show UserProfileWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UserProfileModel extends FlutterFlowModel<UserProfileWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for togleMode component.
  late TogleModeModel togleModeModel;
  // State field(s) for Switch widget.
  bool? switchValue;
  // Model for menu component.
  late MenuModel menuModel;

  @override
  void initState(BuildContext context) {
    togleModeModel = createModel(context, () => TogleModeModel());
    menuModel = createModel(context, () => MenuModel());
  }

  @override
  void dispose() {
    togleModeModel.dispose();
    menuModel.dispose();
  }
}
