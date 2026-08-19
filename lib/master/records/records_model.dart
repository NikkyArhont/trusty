import '/flutter_flow/flutter_flow_util.dart';
import '/global_comp/menu/menu_widget.dart';
import 'records_widget.dart' show RecordsWidget;
import 'package:flutter/material.dart';

class RecordsModel extends FlutterFlowModel<RecordsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for menu component.
  late MenuModel menuModel;

  @override
  void initState(BuildContext context) {
    menuModel = createModel(context, () => MenuModel());
  }

  @override
  void dispose() {
    menuModel.dispose();
  }
}
