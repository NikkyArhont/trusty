import '/backend/backend.dart';
import '/components/serv_status_widget.dart';
import '/flutter_flow/flutter_flow_expanded_image_view.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/master/del_serv/del_serv_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'specialist_service_card_widget.dart' show SpecialistServiceCardWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SpecialistServiceCardModel
    extends FlutterFlowModel<SpecialistServiceCardWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for servStatus component.
  late ServStatusModel servStatusModel;

  @override
  void initState(BuildContext context) {
    servStatusModel = createModel(context, () => ServStatusModel());
  }

  @override
  void dispose() {
    servStatusModel.dispose();
  }
}
