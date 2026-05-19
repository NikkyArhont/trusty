import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/contact_avatars_widget.dart';
import '/components/trust_badge_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'service_card_big_widget.dart' show ServiceCardBigWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ServiceCardBigModel extends FlutterFlowModel<ServiceCardBigWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for trust_badge component.
  late TrustBadgeModel trustBadgeModel;
  // Model for contact_avatars component.
  late ContactAvatarsModel contactAvatarsModel;

  @override
  void initState(BuildContext context) {
    trustBadgeModel = createModel(context, () => TrustBadgeModel());
    contactAvatarsModel = createModel(context, () => ContactAvatarsModel());
  }

  @override
  void dispose() {
    trustBadgeModel.dispose();
    contactAvatarsModel.dispose();
  }
}
