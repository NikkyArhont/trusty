import '/auth/firebase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/components/service_item_widget.dart';
import '/components/stat_card_widget.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/global_comp/menu/menu_widget.dart';
import 'dart:ui';
import 'specialist_dashboard_widget.dart' show SpecialistDashboardWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SpecialistDashboardModel
    extends FlutterFlowModel<SpecialistDashboardWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for StatCard component.
  late StatCardModel statCardModel1;
  // Model for StatCard component.
  late StatCardModel statCardModel2;
  // Model for StatCard component.
  late StatCardModel statCardModel3;
  // Model for StatCard component.
  late StatCardModel statCardModel4;
  // Model for ServiceItem component.
  late ServiceItemModel serviceItemModel1;
  // Model for ServiceItem component.
  late ServiceItemModel serviceItemModel2;
  // Model for ServiceItem component.
  late ServiceItemModel serviceItemModel3;
  // Model for menu component.
  late MenuModel menuModel;

  @override
  void initState(BuildContext context) {
    statCardModel1 = createModel(context, () => StatCardModel());
    statCardModel2 = createModel(context, () => StatCardModel());
    statCardModel3 = createModel(context, () => StatCardModel());
    statCardModel4 = createModel(context, () => StatCardModel());
    serviceItemModel1 = createModel(context, () => ServiceItemModel());
    serviceItemModel2 = createModel(context, () => ServiceItemModel());
    serviceItemModel3 = createModel(context, () => ServiceItemModel());
    menuModel = createModel(context, () => MenuModel());
  }

  @override
  void dispose() {
    statCardModel1.dispose();
    statCardModel2.dispose();
    statCardModel3.dispose();
    statCardModel4.dispose();
    serviceItemModel1.dispose();
    serviceItemModel2.dispose();
    serviceItemModel3.dispose();
    menuModel.dispose();
  }
}
