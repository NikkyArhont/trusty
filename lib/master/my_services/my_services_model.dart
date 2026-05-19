import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/global_comp/menu/menu_widget.dart';
import '/master/no_service/no_service_widget.dart';
import '/master/specialist_service_card/specialist_service_card_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'my_services_widget.dart' show MyServicesWidget;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyServicesModel extends FlutterFlowModel<MyServicesWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for menu component.
  late MenuModel menuModel;

  @override
  void initState(BuildContext context) {
    menuModel = createModel(context, () => MenuModel());
  }

  @override
  void dispose() {
    menuModel.dispose();
  }
}
