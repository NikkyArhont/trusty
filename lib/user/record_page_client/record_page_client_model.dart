import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/global_comp/nav_back/nav_back_widget.dart';
import '/global_comp/phone_call/phone_call_widget.dart';
import 'dart:ui';
import 'record_page_client_widget.dart' show RecordPageClientWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RecordPageClientModel extends FlutterFlowModel<RecordPageClientWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for navBack component.
  late NavBackModel navBackModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {
    navBackModel = createModel(context, () => NavBackModel());
  }

  @override
  void dispose() {
    navBackModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
