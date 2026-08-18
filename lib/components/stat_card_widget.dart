import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'stat_card_model.dart';
export 'stat_card_model.dart';

class StatCardWidget extends StatefulWidget {
  const StatCardWidget({
    super.key,
    this.value,
    this.label,
    this.bgColor,
    this.textColor,
    this.icon,
  });

  final double? value;
  final String? label;
  final Color? bgColor;
  final Color? textColor;
  final IconData? icon;

  @override
  State<StatCardWidget> createState() => _StatCardWidgetState();
}

class _MyWidgetState {} // Extra class declaration is not needed, but we keep structure intact.

class _StatCardWidgetState extends State<StatCardWidget> {
  late StatCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StatCardModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  String _formatValue(double? val) {
    if (val == null) return '0';
    if (val % 1 == 0) {
      return val.toInt().toString();
    }
    return val.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            widget.bgColor ?? FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: widget.bgColor != null
              ? Colors.transparent
              : FlutterFlowTheme.of(context).divider,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    _formatValue(widget.value),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FlutterFlowTheme.of(context).headlineSmall.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.bold,
                        fontStyle: FlutterFlowTheme.of(
                          context,
                        ).headlineSmall.fontStyle,
                      ),
                      color:
                          widget.textColor ??
                          FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                      fontStyle: FlutterFlowTheme.of(
                        context,
                      ).headlineSmall.fontStyle,
                    ),
                  ),
                ),
                if (widget.icon != null)
                  Icon(
                    widget.icon,
                    color:
                        widget.textColor ??
                        FlutterFlowTheme.of(context).secondaryText,
                    size: 20.0,
                  ),
              ],
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                valueOrDefault<String>(widget.label, ''),
                maxLines: 1,
                softWrap: false,
                style: FlutterFlowTheme.of(context).labelSmall.override(
                  font: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontStyle: FlutterFlowTheme.of(
                      context,
                    ).labelSmall.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 11.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                  fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                  lineHeight: 1.2,
                ),
              ),
            ),
          ].divide(SizedBox(height: 6.0)),
        ),
      ),
    );
  }
}
