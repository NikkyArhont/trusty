import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/components/form_label_widget.dart';
import '/flutter_flow/flutter_flow_expanded_image_view.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/global_comp/upload_media/upload_media_widget.dart';
import '/master/del_serv/del_serv_widget.dart';
import '/master/save_serv_change/save_serv_change_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'edit_service_widget.dart' show EditServiceWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class EditServiceModel extends FlutterFlowModel<EditServiceWidget> {
  ///  Local state fields for this page.

  List<FFUploadedFile> uploadPhoto = [];
  void addToUploadPhoto(FFUploadedFile item) => uploadPhoto.add(item);
  void removeFromUploadPhoto(FFUploadedFile item) => uploadPhoto.remove(item);
  void removeAtIndexFromUploadPhoto(int index) => uploadPhoto.removeAt(index);
  void insertAtIndexInUploadPhoto(int index, FFUploadedFile item) =>
      uploadPhoto.insert(index, item);
  void updateUploadPhotoAtIndex(int index, Function(FFUploadedFile) updateFn) =>
      uploadPhoto[index] = updateFn(uploadPhoto[index]);

  CategoriesStruct? choosenCat;
  void updateChoosenCatStruct(Function(CategoriesStruct) updateFn) {
    updateFn(choosenCat ??= CategoriesStruct());
  }

  PlaceStruct? adres;
  void updateAdresStruct(Function(PlaceStruct) updateFn) {
    updateFn(adres ??= PlaceStruct());
  }

  PlaceStruct? presetAdres;
  void updatePresetAdresStruct(Function(PlaceStruct) updateFn) {
    updateFn(presetAdres ??= PlaceStruct());
  }

  String? delURLImage;

  bool onCity = false;

  ///  State fields for stateful widgets in this page.

  // Model for FormLabel component.
  late FormLabelModel formLabelModel1;
  // Stores action output result for [Bottom Sheet - uploadMedia] action in IconButton widget.
  FFUploadedFile? newImage;
  // Model for FormLabel component.
  late FormLabelModel formLabelModel2;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // Model for FormLabel component.
  late FormLabelModel formLabelModel3;
  // Model for FormLabel component.
  late FormLabelModel formLabelModel4;
  // State field(s) for Switch widget.
  bool? switchValue1;
  // Model for FormLabel component.
  late FormLabelModel formLabelModel5;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // Stores action output result for [Backend Call - API (geocode)] action in IconButton widget.
  ApiCallResponse? apiResult4qi;
  // Model for FormLabel component.
  late FormLabelModel formLabelModel6;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;
  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController;

  // Model for FormLabel component.
  late FormLabelModel formLabelModel7;
  // Model for FormLabel component.
  late FormLabelModel formLabelModel8;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode4;
  TextEditingController? textController4;
  String? Function(BuildContext, String?)? textController4Validator;
  // Model for FormLabel component.
  late FormLabelModel formLabelModel9;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode5;
  TextEditingController? textController5;
  String? Function(BuildContext, String?)? textController5Validator;
  // State field(s) for Switch widget.
  bool? switchValue2;
  bool isDataUploading_uploadDataEdit = false;
  List<FFUploadedFile> uploadedLocalFiles_uploadDataEdit = [];
  List<String> uploadedFileUrls_uploadDataEdit = [];

  bool isDataUploading_uploadDataCreate = false;
  List<FFUploadedFile> uploadedLocalFiles_uploadDataCreate = [];
  List<String> uploadedFileUrls_uploadDataCreate = [];

  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  ServiceRecord? newServ;

  @override
  void initState(BuildContext context) {
    formLabelModel1 = createModel(context, () => FormLabelModel());
    formLabelModel2 = createModel(context, () => FormLabelModel());
    formLabelModel3 = createModel(context, () => FormLabelModel());
    formLabelModel4 = createModel(context, () => FormLabelModel());
    formLabelModel5 = createModel(context, () => FormLabelModel());
    formLabelModel6 = createModel(context, () => FormLabelModel());
    formLabelModel7 = createModel(context, () => FormLabelModel());
    formLabelModel8 = createModel(context, () => FormLabelModel());
    formLabelModel9 = createModel(context, () => FormLabelModel());
  }

  @override
  void dispose() {
    formLabelModel1.dispose();
    formLabelModel2.dispose();
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    formLabelModel3.dispose();
    formLabelModel4.dispose();
    formLabelModel5.dispose();
    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    formLabelModel6.dispose();
    textFieldFocusNode3?.dispose();
    textController3?.dispose();

    expandableExpandableController.dispose();
    formLabelModel7.dispose();
    formLabelModel8.dispose();
    textFieldFocusNode4?.dispose();
    textController4?.dispose();

    formLabelModel9.dispose();
    textFieldFocusNode5?.dispose();
    textController5?.dispose();
  }
}
