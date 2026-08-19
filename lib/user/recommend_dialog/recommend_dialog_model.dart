import '/flutter_flow/flutter_flow_util.dart';
import 'recommend_dialog_widget.dart' show RecommendDialogWidget;
import 'package:flutter/material.dart';

class RecommendDialogModel extends FlutterFlowModel<RecommendDialogWidget> {
  // State fields for stateful widgets in this component.
  TextEditingController? commentController;
  String? Function(BuildContext, String?)? commentControllerValidator;

  @override
  void initState(BuildContext context) {
    commentController = TextEditingController();
  }

  @override
  void dispose() {
    commentController?.dispose();
  }
}
