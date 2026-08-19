import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'form_input_model.dart';
export 'form_input_model.dart';

class FormInputWidget extends StatefulWidget {
  const FormInputWidget({
    super.key,
    this.label,
    this.hint,
    this.value,
    this.icon,
  });

  final String? label;
  final String? hint;
  final String? value;
  final String? icon;

  @override
  State<FormInputWidget> createState() => _FormInputWidgetState();
}

class _FormInputWidgetState extends State<FormInputWidget> {
  late FormInputModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FormInputModel());

    _model.textController ??= TextEditingController(
      text: valueOrDefault<String>(widget!.value, 'Алексей Рид'),
    );
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _model.textController,
          textCapitalization: TextCapitalization.words,
          focusNode: _model.textFieldFocusNode,
          obscureText: false,
          decoration: InputDecoration(
            hintText: valueOrDefault<String>(widget!.hint, 'Введите ваше имя'),
            hintStyle: TextStyle(
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0x00000000), width: 1.0),
              borderRadius: BorderRadius.circular(16.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0x00000000), width: 1.0),
              borderRadius: BorderRadius.circular(16.0),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0x00000000), width: 1.0),
              borderRadius: BorderRadius.circular(16.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0x00000000), width: 1.0),
              borderRadius: BorderRadius.circular(16.0),
            ),
            filled: true,
            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          style: TextStyle(),
          validator: _model.textControllerValidator.asValidator(context),
        ),
      ].divide(SizedBox(height: 8.0)),
    );
  }
}
