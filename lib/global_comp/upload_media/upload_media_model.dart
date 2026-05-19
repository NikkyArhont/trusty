import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import 'upload_media_widget.dart' show UploadMediaWidget;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UploadMediaModel extends FlutterFlowModel<UploadMediaWidget> {
  ///  State fields for stateful widgets in this component.

  bool isDataUploading_uploadDataPhotoServ = false;
  FFUploadedFile uploadedLocalFile_uploadDataPhotoServ =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  bool isDataUploading_uploadDataImageServ = false;
  FFUploadedFile uploadedLocalFile_uploadDataImageServ =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
