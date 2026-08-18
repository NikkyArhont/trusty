import 'package:flutter/material.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

class AppOnboardingWidget extends StatefulWidget {
  const AppOnboardingWidget({super.key, this.returnToProfile = false});

  final bool returnToProfile;

  static const routeName = 'AppOnboarding';
  static const routePath = '/appOnboarding';

  @override
  State<AppOnboardingWidget> createState() => _AppOnboardingWidgetState();
}

class _AppOnboardingWidgetState extends State<AppOnboardingWidget> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    'assets/images/onboarding1.png',
    'assets/images/onboarding2.png',
    'assets/images/onboarding3.png',
    'assets/images/onboarding4.png',
  ];

  void _finish() {
    FFAppState().firstTime = false;
    if (widget.returnToProfile) {
      context.goNamed(UserProfileWidget.routeName);
      return;
    }

    if (loggedIn) {
      context.goNamed(InitpageWidget.routeName);
    } else {
      context.goNamed(LoginWidget.routeName);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primary,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _slides.length,
            onPageChanged: (value) => setState(() => _page = value),
            itemBuilder: (context, index) {
              if (index == 0) {
                return ColoredBox(
                  color: const Color(0xFF204FD8),
                  child: SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxHeight < 680;
                        final contentWidth = (constraints.maxWidth - 48).clamp(
                          0.0,
                          420.0,
                        );
                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                            24,
                            compact ? 44 : 72,
                            24,
                            114,
                          ),
                          child: Center(
                            child: SizedBox(
                              width: contentWidth,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: SizedBox(
                                      width: contentWidth,
                                      child: Text(
                                        'Отзыв\nможно купить.\n\nРекомендацию -\nнет.',
                                        textAlign: TextAlign.left,
                                        softWrap: true,
                                        style: theme.headlineLarge.copyWith(
                                          color: Colors.white,
                                          fontSize: compact ? 32 : 40,
                                          fontWeight: FontWeight.w800,
                                          height: 1.08,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 24,
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          _slides[index],
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.contain,
                                          alignment: Alignment.topCenter,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }

              if (index == 1) {
                return ColoredBox(
                  color: const Color(0xFF204FD8),
                  child: SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxHeight < 680;
                        final contentWidth = (constraints.maxWidth - 48).clamp(
                          0.0,
                          420.0,
                        );
                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                            24,
                            compact ? 44 : 72,
                            24,
                            114,
                          ),
                          child: Center(
                            child: SizedBox(
                              width: contentWidth,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: SizedBox(
                                      width: contentWidth,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Здесь рекомендуют реальные люди.',
                                            textAlign: TextAlign.left,
                                            softWrap: true,
                                            style: theme.headlineLarge.copyWith(
                                              color: Colors.white,
                                              fontSize: compact ? 30 : 38,
                                              fontWeight: FontWeight.w800,
                                              height: 1.08,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          Text(
                                            'Смотри, какие услуги рекомендуют твои знакомые.',
                                            textAlign: TextAlign.left,
                                            softWrap: true,
                                            style: theme.bodyLarge.copyWith(
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                              fontSize: compact ? 15 : 17,
                                              fontWeight: FontWeight.w500,
                                              height: 1.28,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 24,
                                      ),
                                      child: Image.asset(
                                        _slides[index],
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.contain,
                                        alignment: Alignment.topCenter,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }

              if (index == 2) {
                return ColoredBox(
                  color: const Color(0xFF204FD8),
                  child: SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxHeight < 680;
                        final contentWidth = (constraints.maxWidth - 48).clamp(
                          0.0,
                          420.0,
                        );
                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                            24,
                            compact ? 44 : 72,
                            24,
                            114,
                          ),
                          child: Center(
                            child: SizedBox(
                              width: contentWidth,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: SizedBox(
                                      width: contentWidth,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Твои рекомендации работают на доверие',
                                            textAlign: TextAlign.left,
                                            softWrap: true,
                                            style: theme.headlineLarge.copyWith(
                                              color: Colors.white,
                                              fontSize: compact ? 30 : 38,
                                              fontWeight: FontWeight.w800,
                                              height: 1.08,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          Text(
                                            'Их увидят только те люди, у которых есть твой номер телефона в контактах.',
                                            textAlign: TextAlign.left,
                                            softWrap: true,
                                            style: theme.bodyLarge.copyWith(
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                              fontSize: compact ? 15 : 17,
                                              fontWeight: FontWeight.w500,
                                              height: 1.28,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 24,
                                      ),
                                      child: Image.asset(
                                        _slides[index],
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.contain,
                                        alignment: Alignment.topCenter,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }

              if (index == 3) {
                return ColoredBox(
                  color: const Color(0xFF204FD8),
                  child: SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxHeight < 680;
                        final contentWidth = (constraints.maxWidth - 48).clamp(
                          0.0,
                          420.0,
                        );
                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                            24,
                            compact ? 44 : 72,
                            24,
                            114,
                          ),
                          child: Center(
                            child: SizedBox(
                              width: contentWidth,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: SizedBox(
                                      width: contentWidth,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Добро пожаловать в Сарафан',
                                            textAlign: TextAlign.left,
                                            softWrap: true,
                                            style: theme.headlineLarge.copyWith(
                                              color: Colors.white,
                                              fontSize: compact ? 30 : 38,
                                              fontWeight: FontWeight.w800,
                                              height: 1.08,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          Text(
                                            'Хорошее не рекламируют. Его советуют.',
                                            textAlign: TextAlign.left,
                                            softWrap: true,
                                            style: theme.bodyLarge.copyWith(
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                              fontSize: compact ? 15 : 17,
                                              fontWeight: FontWeight.w500,
                                              height: 1.28,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 24,
                                      ),
                                      child: Image.asset(
                                        _slides[index],
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.contain,
                                        alignment: Alignment.topCenter,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 72, 24, 112),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Image.asset(_slides[index], fit: BoxFit.contain),
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _finish,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Пропустить'),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: index == _page ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index == _page
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 54),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          if (_page == _slides.length - 1) {
                            _finish();
                          } else {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.primary,
                          minimumSize: const Size.fromHeight(54),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _page == _slides.length - 1 ? 'Начать' : 'Далее',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
