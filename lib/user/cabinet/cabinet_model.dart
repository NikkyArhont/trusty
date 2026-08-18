import '/flutter_flow/flutter_flow_model.dart';
import '/global_comp/menu/menu_model.dart';
import 'cabinet_widget.dart' show CabinetWidget;
import 'package:flutter/material.dart';

class CabinetModel extends FlutterFlowModel<CabinetWidget> {
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
