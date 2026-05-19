import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'upload_media_model.dart';
export 'upload_media_model.dart';

class UploadMediaWidget extends StatefulWidget {
  const UploadMediaWidget({super.key});

  @override
  State<UploadMediaWidget> createState() => _UploadMediaWidgetState();
}

class _UploadMediaWidgetState extends State<UploadMediaWidget> {
  late UploadMediaModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UploadMediaModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            boxShadow: [
              BoxShadow(
                blurRadius: 2.0,
                color: Color(0x1A000000),
                offset: Offset(
                  0.0,
                  1.0,
                ),
                spreadRadius: 0.0,
              )
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FlutterFlowIconButton(
                      borderColor: FlutterFlowTheme.of(context).primary,
                      borderRadius: 16.0,
                      buttonSize: 80.0,
                      fillColor: FlutterFlowTheme.of(context).primaryBackground,
                      icon: Icon(
                        Icons.camera_alt,
                        color: FlutterFlowTheme.of(context).primary,
                        size: 48.0,
                      ),
                      onPressed: () async {
                        final selectedMedia = await selectMedia(
                          maxWidth: 1920.00,
                          maxHeight: 1920.00,
                          multiImage: false,
                        );
                        if (selectedMedia != null &&
                            selectedMedia.every((m) =>
                                validateFileFormat(m.storagePath, context))) {
                          safeSetState(() => _model
                              .isDataUploading_uploadDataPhotoServ = true);
                          var selectedUploadedFiles = <FFUploadedFile>[];

                          try {
                            selectedUploadedFiles = selectedMedia
                                .map((m) => FFUploadedFile(
                                      name: m.storagePath.split('/').last,
                                      bytes: m.bytes,
                                      height: m.dimensions?.height,
                                      width: m.dimensions?.width,
                                      blurHash: m.blurHash,
                                      originalFilename: m.originalFilename,
                                    ))
                                .toList();
                          } finally {
                            _model.isDataUploading_uploadDataPhotoServ = false;
                          }
                          if (selectedUploadedFiles.length ==
                              selectedMedia.length) {
                            safeSetState(() {
                              _model.uploadedLocalFile_uploadDataPhotoServ =
                                  selectedUploadedFiles.first;
                            });
                          } else {
                            safeSetState(() {});
                            return;
                          }
                        }

                        Navigator.pop(context,
                            _model.uploadedLocalFile_uploadDataPhotoServ);
                      },
                    ),
                    Text(
                      FFLocalizations.of(context).getText(
                        'wxllapno' /* Камера */,
                      ),
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontSize: 20.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .titleLarge
                                .fontStyle,
                            lineHeight: 1.3,
                          ),
                    ),
                  ].divide(SizedBox(height: 12.0)),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FlutterFlowIconButton(
                      borderColor: FlutterFlowTheme.of(context).primary,
                      borderRadius: 16.0,
                      buttonSize: 80.0,
                      fillColor: FlutterFlowTheme.of(context).primaryBackground,
                      icon: Icon(
                        Icons.image,
                        color: FlutterFlowTheme.of(context).primary,
                        size: 48.0,
                      ),
                      onPressed: () async {
                        final selectedMedia = await selectMedia(
                          maxWidth: 1920.00,
                          maxHeight: 1920.00,
                          mediaSource: MediaSource.photoGallery,
                          multiImage: false,
                        );
                        if (selectedMedia != null &&
                            selectedMedia.every((m) =>
                                validateFileFormat(m.storagePath, context))) {
                          safeSetState(() => _model
                              .isDataUploading_uploadDataImageServ = true);
                          var selectedUploadedFiles = <FFUploadedFile>[];

                          try {
                            selectedUploadedFiles = selectedMedia
                                .map((m) => FFUploadedFile(
                                      name: m.storagePath.split('/').last,
                                      bytes: m.bytes,
                                      height: m.dimensions?.height,
                                      width: m.dimensions?.width,
                                      blurHash: m.blurHash,
                                      originalFilename: m.originalFilename,
                                    ))
                                .toList();
                          } finally {
                            _model.isDataUploading_uploadDataImageServ = false;
                          }
                          if (selectedUploadedFiles.length ==
                              selectedMedia.length) {
                            safeSetState(() {
                              _model.uploadedLocalFile_uploadDataImageServ =
                                  selectedUploadedFiles.first;
                            });
                          } else {
                            safeSetState(() {});
                            return;
                          }
                        }

                        Navigator.pop(context,
                            _model.uploadedLocalFile_uploadDataImageServ);
                      },
                    ),
                    Text(
                      FFLocalizations.of(context).getText(
                        'qujpa0e5' /* Галерея */,
                      ),
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontSize: 20.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .titleLarge
                                .fontStyle,
                            lineHeight: 1.3,
                          ),
                    ),
                  ].divide(SizedBox(height: 12.0)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
