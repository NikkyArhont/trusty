import '/backend/schema/enums/enums.dart';
import '/components/appointment_card_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/global_comp/menu/menu_widget.dart';
import 'dart:ui';
import 'records_widget.dart' show RecordsWidget;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RecordsModel extends FlutterFlowModel<RecordsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for AppointmentCard component.
  late AppointmentCardModel appointmentCardModel1;
  // Model for AppointmentCard component.
  late AppointmentCardModel appointmentCardModel2;
  // Model for AppointmentCard component.
  late AppointmentCardModel appointmentCardModel3;
  // Model for AppointmentCard component.
  late AppointmentCardModel appointmentCardModel4;
  // Model for menu component.
  late MenuModel menuModel;

  @override
  void initState(BuildContext context) {
    appointmentCardModel1 = createModel(context, () => AppointmentCardModel());
    appointmentCardModel2 = createModel(context, () => AppointmentCardModel());
    appointmentCardModel3 = createModel(context, () => AppointmentCardModel());
    appointmentCardModel4 = createModel(context, () => AppointmentCardModel());
    menuModel = createModel(context, () => MenuModel());
  }

  @override
  void dispose() {
    appointmentCardModel1.dispose();
    appointmentCardModel2.dispose();
    appointmentCardModel3.dispose();
    appointmentCardModel4.dispose();
    menuModel.dispose();
  }
}
