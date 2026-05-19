import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/backend/schema/structs/index.dart';
import '/components/form_label_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/global_comp/nav_back/nav_back_widget.dart';
import '/global_comp/upload_media/upload_media_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'edit_profile_master_widget.dart' show EditProfileMasterWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EditProfileMasterModel extends FlutterFlowModel<EditProfileMasterWidget> {
  ///  Local state fields for this page.

  PlaceStruct? initPlace;
  void updateInitPlaceStruct(Function(PlaceStruct) updateFn) {
    updateFn(initPlace ??= PlaceStruct());
  }

  CategoriesStruct? initCat;
  void updateInitCatStruct(Function(CategoriesStruct) updateFn) {
    updateFn(initCat ??= CategoriesStruct());
  }

  ///  State fields for stateful widgets in this page.

  // Model for navBack component.
  late NavBackModel navBackModel;
  // Stores action output result for [Bottom Sheet - uploadMedia] action in Icon widget.
  FFUploadedFile? setPhpto;
  bool isDataUploading_uploadDataPhotoMaster = false;
  FFUploadedFile uploadedLocalFile_uploadDataPhotoMaster =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataPhotoMaster = '';

  // State field(s) for name widget.
  FocusNode? nameFocusNode;
  TextEditingController? nameTextController;
  String? Function(BuildContext, String?)? nameTextControllerValidator;
  // State field(s) for bio widget.
  FocusNode? bioFocusNode;
  TextEditingController? bioTextController;
  String? Function(BuildContext, String?)? bioTextControllerValidator;
  // Model for FormLabel component.
  late FormLabelModel formLabelModel1;
  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController;

  // Model for FormLabel component.
  late FormLabelModel formLabelModel2;

  @override
  void initState(BuildContext context) {
    navBackModel = createModel(context, () => NavBackModel());
    formLabelModel1 = createModel(context, () => FormLabelModel());
    formLabelModel2 = createModel(context, () => FormLabelModel());
  }

  @override
  void dispose() {
    navBackModel.dispose();
    nameFocusNode?.dispose();
    nameTextController?.dispose();

    bioFocusNode?.dispose();
    bioTextController?.dispose();

    formLabelModel1.dispose();
    expandableExpandableController.dispose();
    formLabelModel2.dispose();
  }
}
