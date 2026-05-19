import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/global_comp/nav_back/nav_back_widget.dart';
import '/user/service_card_client/service_card_client_widget.dart';
import '/user/specialist_service_card_map/specialist_service_card_map_widget.dart';
import 'dart:ui';
import '/flutter_flow/permissions_util.dart';
import '/index.dart';
import 'search_result_widget.dart' show SearchResultWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';

class SearchResultModel extends FlutterFlowModel<SearchResultWidget> {
  ///  Local state fields for this page.

  bool searchActive = false;

  bool listOrMap = true;

  LatLng? setLoc;

  ServiceRecord? choosenServ;

  ///  State fields for stateful widgets in this page.

  // Model for navBack component.
  late NavBackModel navBackModel1;
  // State field(s) for GoogleMap widget.
  LatLng? googleMapsCenter;
  final googleMapsController = Completer<GoogleMapController>();
  // Model for navBack component.
  late NavBackModel navBackModel2;
  // Model for SpecialistServiceCardMap component.
  late SpecialistServiceCardMapModel specialistServiceCardMapModel;

  @override
  void initState(BuildContext context) {
    navBackModel1 = createModel(context, () => NavBackModel());
    navBackModel2 = createModel(context, () => NavBackModel());
    specialistServiceCardMapModel =
        createModel(context, () => SpecialistServiceCardMapModel());
  }

  @override
  void dispose() {
    navBackModel1.dispose();
    navBackModel2.dispose();
    specialistServiceCardMapModel.dispose();
  }
}
