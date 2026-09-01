import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/global_comp/nav_back/nav_back_widget.dart';

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.actions = const <Widget>[],
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 12),
    this.backgroundColor,
  });

  final String title;
  final bool showBack;
  final List<Widget> actions;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      color: backgroundColor ?? theme.primaryBackground,
      padding: padding,
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            if (showBack) ...[const NavBackWidget(), const SizedBox(width: 12)],
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.headlineMedium.override(
                  color: theme.primaryText,
                  fontWeight: FontWeight.w700,
                  lineHeight: 1,
                ),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
            if (actions.isNotEmpty) ...[const SizedBox(width: 8), ...actions],
          ],
        ),
      ),
    );
  }
}
