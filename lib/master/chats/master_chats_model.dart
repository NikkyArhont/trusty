import '/flutter_flow/flutter_flow_model.dart';
import '/global_comp/menu/menu_model.dart';
import 'master_chats_widget.dart' show MasterChatsWidget;
import 'package:flutter/material.dart';

class MasterChatsModel extends FlutterFlowModel<MasterChatsWidget> {
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
