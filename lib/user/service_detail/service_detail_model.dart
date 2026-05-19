import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/contact_recommendation_widget.dart';
import '/flutter_flow/flutter_flow_expanded_image_view.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/global_comp/nav_back/nav_back_widget.dart';
import 'dart:ui';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'service_detail_widget.dart' show ServiceDetailWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ServiceDetailModel extends FlutterFlowModel<ServiceDetailWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;
  // Model for navBack component.
  late NavBackModel navBackModel;
  // Model for ContactRecommendation component.
  late ContactRecommendationModel contactRecommendationModel1;
  // Model for ContactRecommendation component.
  late ContactRecommendationModel contactRecommendationModel2;
  // Model for ContactRecommendation component.
  late ContactRecommendationModel contactRecommendationModel3;

  @override
  void initState(BuildContext context) {
    navBackModel = createModel(context, () => NavBackModel());
    contactRecommendationModel1 =
        createModel(context, () => ContactRecommendationModel());
    contactRecommendationModel2 =
        createModel(context, () => ContactRecommendationModel());
    contactRecommendationModel3 =
        createModel(context, () => ContactRecommendationModel());
  }

  @override
  void dispose() {
    navBackModel.dispose();
    contactRecommendationModel1.dispose();
    contactRecommendationModel2.dispose();
    contactRecommendationModel3.dispose();
  }
}
