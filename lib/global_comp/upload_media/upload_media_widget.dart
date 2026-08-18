import '/backend/image_processing.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'upload_media_model.dart';
export 'upload_media_model.dart';

class UploadMediaWidget extends StatefulWidget {
  const UploadMediaWidget({super.key, this.maxOutputSize = 1600});

  final int maxOutputSize;

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
    return SafeArea(
      top: false,
      child: Stack(
        children: [
          ClipRRect(
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
                    offset: Offset(0.0, 1.0),
                    spreadRadius: 0.0,
                  ),
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
                          fillColor: FlutterFlowTheme.of(
                            context,
                          ).primaryBackground,
                          icon: Icon(
                            Icons.camera_alt,
                            color: FlutterFlowTheme.of(context).primary,
                            size: 48.0,
                          ),
                          onPressed: () async {
                            safeSetState(
                              () => _model.isDataUploading_uploadDataPhotoServ =
                                  true,
                            );
                            final selectedFile =
                                await _selectAndCropServiceImage(
                                  context,
                                  MediaSource.camera,
                                  maxOutputSize: widget.maxOutputSize,
                                );
                            safeSetState(() {
                              _model.isDataUploading_uploadDataPhotoServ =
                                  false;
                              if (selectedFile != null) {
                                _model.uploadedLocalFile_uploadDataPhotoServ =
                                    selectedFile;
                              }
                            });
                            if (selectedFile != null) {
                              Navigator.pop(context, selectedFile);
                            }
                          },
                        ),
                        Text(
                          FFLocalizations.of(
                            context,
                          ).getText('wxllapno' /* Камера */),
                          style: FlutterFlowTheme.of(context).titleLarge
                              .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(
                                    context,
                                  ).titleLarge.fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: 20.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(
                                  context,
                                ).titleLarge.fontStyle,
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
                          fillColor: FlutterFlowTheme.of(
                            context,
                          ).primaryBackground,
                          icon: Icon(
                            Icons.image,
                            color: FlutterFlowTheme.of(context).primary,
                            size: 48.0,
                          ),
                          onPressed: () async {
                            safeSetState(
                              () => _model.isDataUploading_uploadDataImageServ =
                                  true,
                            );
                            final selectedFile =
                                await _selectAndCropServiceImage(
                                  context,
                                  MediaSource.photoGallery,
                                  maxOutputSize: widget.maxOutputSize,
                                );
                            safeSetState(() {
                              _model.isDataUploading_uploadDataImageServ =
                                  false;
                              if (selectedFile != null) {
                                _model.uploadedLocalFile_uploadDataImageServ =
                                    selectedFile;
                              }
                            });
                            if (selectedFile != null) {
                              Navigator.pop(context, selectedFile);
                            }
                          },
                        ),
                        Text(
                          FFLocalizations.of(
                            context,
                          ).getText('qujpa0e5' /* Галерея */),
                          style: FlutterFlowTheme.of(context).titleLarge
                              .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(
                                    context,
                                  ).titleLarge.fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: 20.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(
                                  context,
                                ).titleLarge.fontStyle,
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
          if (_model.isDataUploading_uploadDataPhotoServ ||
              _model.isDataUploading_uploadDataImageServ)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black45,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          'Обрабатываем фотографию…',
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Future<FFUploadedFile?> _selectAndCropServiceImage(
  BuildContext context,
  MediaSource mediaSource, {
  required int maxOutputSize,
}) async {
  final selectedMedia = await selectMedia(
    maxWidth: maxOutputSize.toDouble(),
    maxHeight: maxOutputSize.toDouble(),
    imageQuality: 88,
    mediaSource: mediaSource,
    multiImage: false,
  );
  if (selectedMedia == null ||
      !selectedMedia.every((m) => validateFileFormat(m.storagePath, context))) {
    return null;
  }

  final selectedFile = selectedMedia.first;
  final uploadedFile = FFUploadedFile(
    name: selectedFile.storagePath.split('/').last,
    bytes: selectedFile.bytes,
    height: selectedFile.dimensions?.height,
    width: selectedFile.dimensions?.width,
    blurHash: selectedFile.blurHash,
    originalFilename: selectedFile.originalFilename,
  );

  return _showServiceImageCropper(
    context,
    uploadedFile,
    maxOutputSize: maxOutputSize,
  );
}

Future<FFUploadedFile?> _showServiceImageCropper(
  BuildContext context,
  FFUploadedFile file, {
  required int maxOutputSize,
}) async {
  final bytes = file.bytes;
  if (bytes == null || bytes.isEmpty) {
    return file;
  }

  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final image = frame.image;
  final imageWidth = image.width.toDouble();
  final imageHeight = image.height.toDouble();
  final aspectRatio = imageWidth / imageHeight;
  final cropSize = math
      .min(MediaQuery.sizeOf(context).width - 48.0, 340.0)
      .clamp(240.0, 340.0)
      .toDouble();
  final displayWidth = aspectRatio >= 1.0 ? cropSize * aspectRatio : cropSize;
  final displayHeight = aspectRatio >= 1.0 ? cropSize : cropSize / aspectRatio;
  final controller = TransformationController(
    Matrix4.identity()..translate(
      (cropSize - displayWidth) / 2.0,
      (cropSize - displayHeight) / 2.0,
    ),
  );
  OverlayEntry? processingOverlay;

  try {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          backgroundColor: FlutterFlowTheme.of(
            dialogContext,
          ).secondaryBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Кадрирование',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(dialogContext).titleLarge.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontStyle: FlutterFlowTheme.of(
                        dialogContext,
                      ).titleLarge.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                    fontStyle: FlutterFlowTheme.of(
                      dialogContext,
                    ).titleLarge.fontStyle,
                  ),
                ),
                Text(
                  'Переместите и увеличьте фото так, чтобы нужное содержимое было в области',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(dialogContext).bodySmall.override(
                    font: GoogleFonts.jetBrainsMono(
                      fontWeight: FlutterFlowTheme.of(
                        dialogContext,
                      ).bodySmall.fontWeight,
                      fontStyle: FlutterFlowTheme.of(
                        dialogContext,
                      ).bodySmall.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(dialogContext).secondaryText,
                    letterSpacing: 0.0,
                    fontWeight: FlutterFlowTheme.of(
                      dialogContext,
                    ).bodySmall.fontWeight,
                    fontStyle: FlutterFlowTheme.of(
                      dialogContext,
                    ).bodySmall.fontStyle,
                  ),
                ),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Container(
                      width: cropSize,
                      height: cropSize,
                      color: Colors.black,
                      child: Stack(
                        children: [
                          InteractiveViewer(
                            transformationController: controller,
                            constrained: false,
                            minScale: 1.0,
                            maxScale: 4.0,
                            boundaryMargin: EdgeInsets.all(cropSize),
                            child: SizedBox(
                              width: displayWidth,
                              height: displayHeight,
                              child: Image.memory(bytes, fit: BoxFit.fill),
                            ),
                          ),
                          IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: Text('Отмена'),
                    ),
                    FFButtonWidget(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      text: 'Готово',
                      options: FFButtonOptions(
                        height: 40.0,
                        padding: EdgeInsetsDirectional.fromSTEB(
                          20.0,
                          0.0,
                          20.0,
                          0.0,
                        ),
                        iconPadding: EdgeInsetsDirectional.fromSTEB(
                          0.0,
                          0.0,
                          0.0,
                          0.0,
                        ),
                        color: FlutterFlowTheme.of(dialogContext).primary,
                        textStyle: FlutterFlowTheme.of(dialogContext).titleSmall
                            .override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(
                                  dialogContext,
                                ).titleSmall.fontStyle,
                              ),
                              color: FlutterFlowTheme.of(dialogContext).info,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(
                                dialogContext,
                              ).titleSmall.fontStyle,
                            ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ],
                ),
              ].divide(SizedBox(height: 16.0)),
            ),
          ),
        );
      },
    );

    if (confirmed != true) {
      return null;
    }

    processingOverlay = OverlayEntry(
      builder: (overlayContext) => Positioned.fill(
        child: Stack(
          children: [
            const ModalBarrier(dismissible: false, color: Colors.black54),
            Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(
                      overlayContext,
                    ).secondaryBackground,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: FlutterFlowTheme.of(overlayContext).primary,
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Загружаем фотографию…',
                        style: FlutterFlowTheme.of(overlayContext).bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(processingOverlay);
    await WidgetsBinding.instance.endOfFrame;

    final croppedBytes = await _cropImageBytes(
      image: image,
      controller: controller,
      cropSize: cropSize.toDouble(),
      displayWidth: displayWidth.toDouble(),
      displayHeight: displayHeight.toDouble(),
      maxOutputSize: maxOutputSize,
    );

    final outputSize = math
        .min(math.min(imageWidth, imageHeight), maxOutputSize.toDouble())
        .round();
    return FFUploadedFile(
      name: jpegFileName(file.name),
      bytes: croppedBytes,
      height: outputSize.toDouble(),
      width: outputSize.toDouble(),
      blurHash: file.blurHash,
      originalFilename: file.originalFilename,
    );
  } finally {
    processingOverlay?.remove();
    controller.dispose();
    image.dispose();
  }
}

Future<Uint8List> _cropImageBytes({
  required ui.Image image,
  required TransformationController controller,
  required double cropSize,
  required double displayWidth,
  required double displayHeight,
  required int maxOutputSize,
}) async {
  final matrix = controller.value;
  final scale = matrix.getMaxScaleOnAxis();
  final translationX = matrix.storage[12];
  final translationY = matrix.storage[13];
  final childLeft = (-translationX / scale).clamp(0.0, displayWidth).toDouble();
  final childTop = (-translationY / scale).clamp(0.0, displayHeight).toDouble();
  final childSize = (cropSize / scale)
      .clamp(1.0, math.min(displayWidth, displayHeight))
      .toDouble();
  final sourceLeft = (childLeft * image.width / displayWidth)
      .clamp(0.0, image.width.toDouble() - 1.0)
      .toDouble();
  final sourceTop = (childTop * image.height / displayHeight)
      .clamp(0.0, image.height.toDouble() - 1.0)
      .toDouble();
  final sourceSize =
      (childSize *
              math.min(
                image.width / displayWidth,
                image.height / displayHeight,
              ))
          .clamp(1.0, math.min(image.width.toDouble(), image.height.toDouble()))
          .toDouble();
  final safeSourceSize = math
      .min(
        sourceSize,
        math.min(
          image.width.toDouble() - sourceLeft,
          image.height.toDouble() - sourceTop,
        ),
      )
      .toDouble();

  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final paint = ui.Paint();
  final outputSize = safeSourceSize.round().clamp(1, maxOutputSize);
  canvas.drawImageRect(
    image,
    ui.Rect.fromLTWH(sourceLeft, sourceTop, safeSourceSize, safeSourceSize),
    ui.Rect.fromLTWH(0.0, 0.0, outputSize.toDouble(), outputSize.toDouble()),
    paint,
  );
  final picture = recorder.endRecording();
  final croppedImage = await picture.toImage(outputSize, outputSize);
  final byteData = await croppedImage.toByteData(
    format: ui.ImageByteFormat.rawRgba,
  );
  croppedImage.dispose();
  final rgbaBytes = byteData!.buffer.asUint8List(
    byteData.offsetInBytes,
    byteData.lengthInBytes,
  );
  return compute(
    encodeRgbaJpeg,
    RgbaImageData(bytes: rgbaBytes, width: outputSize, height: outputSize),
  );
}
