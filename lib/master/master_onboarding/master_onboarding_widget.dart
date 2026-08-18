import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'master_onboarding_model.dart';
export 'master_onboarding_model.dart';

class MasterOnboardingWidget extends StatefulWidget {
  const MasterOnboardingWidget({super.key, this.returnToProfile = false});

  final bool returnToProfile;

  static String routeName = 'MasterOnboarding';
  static String routePath = '/masterOnboarding';

  @override
  State<MasterOnboardingWidget> createState() => _MasterOnboardingWidgetState();
}

class _MasterOnboardingWidgetState extends State<MasterOnboardingWidget> {
  late MasterOnboardingModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const _slides = [
    _MasterOnboardingSlide(
      image: 'assets/images/onboardMaster1.png',
      title: 'Отзыв можно купить. Рекомендацию - нет.',
      subtitle:
          'Ваши клиенты выбирают вас за качество работы, а не за колличество купленных отзывов.',
    ),
    _MasterOnboardingSlide(
      image: 'assets/images/onboardMaster2.png',
      title: 'Перестаньте конкурировать с рекламными бюджетами.',
      subtitle: 'Пусть за вас говорят ваши клиенты.',
    ),
    _MasterOnboardingSlide(
      image: 'assets/images/onboardMaster3.png',
      title: 'Каждый клиент открывает доступ к новым клиентам.',
      subtitle: 'Ваш профиль увидят люди, которые доверяют вашим клиентам.',
    ),
    _MasterOnboardingSlide(
      image: 'assets/images/onboardMaster4.png',
      title: 'Постройте свой цифровой Сарафан.',
      subtitle:
          'Собирайте рекомендации и развивайте сеть доверия вокруг своего бизнеса.',
    ),
  ];

  bool _masterProfileCompleted(MasterDataStruct? masterData) {
    if (masterData == null) {
      return false;
    }
    return masterData.title.trim().isNotEmpty &&
        masterData.descrip.trim().isNotEmpty &&
        masterData.initCat.trim().isNotEmpty &&
        masterData.mainPhoto.trim().isNotEmpty &&
        masterData.hasMainAdres() &&
        masterData.mainAdres.title.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MasterOnboardingModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await currentUserReference?.update(
      createUserRecordData(
        masterData: createMasterDataStruct(
          onboardingCompleted: true,
          clearUnsetFields: false,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (widget.returnToProfile) {
      context.goNamed(UserProfileWidget.routeName);
      return;
    }

    if (_masterProfileCompleted(currentUserDocument?.masterData)) {
      context.goNamed(SpecialistDashboardWidget.routeName);
      return;
    }

    context.goNamed(
      EditProfileMasterWidget.routeName,
      queryParameters: {
        'setupMode': serializeParam(true, ParamType.bool),
      }.withoutNulls,
    );
  }

  Future<void> _goNext() async {
    final isLastSlide = _model.currentSlide == _slides.length - 1;
    if (isLastSlide) {
      await _finish();
      return;
    }

    await _model.pageViewController?.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Widget _buildSlide(BuildContext context, _MasterOnboardingSlide slide) {
    final theme = FlutterFlowTheme.of(context);

    return ColoredBox(
      color: const Color(0xFF183EAE),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 680;
            final contentWidth = (constraints.maxWidth - 48).clamp(0.0, 420.0);
            return Padding(
              padding: EdgeInsets.fromLTRB(24, compact ? 44 : 72, 24, 114),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                slide.title,
                                textAlign: TextAlign.left,
                                softWrap: true,
                                style: theme.headlineLarge.copyWith(
                                  color: Colors.white,
                                  fontSize: slide.subtitle == null
                                      ? (compact ? 32 : 40)
                                      : (compact ? 30 : 38),
                                  fontWeight: FontWeight.w800,
                                  height: 1.08,
                                ),
                              ),
                              if (slide.subtitle != null) ...[
                                const SizedBox(height: 14),
                                Text(
                                  slide.subtitle!,
                                  textAlign: TextAlign.left,
                                  softWrap: true,
                                  style: theme.bodyLarge.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: compact ? 15 : 17,
                                    fontWeight: FontWeight.w500,
                                    height: 1.28,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Image.asset(
                            slide.image,
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

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final masterProfileCompleted = _masterProfileCompleted(
      currentUserDocument?.masterData,
    );

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFF183EAE),
      body: Stack(
        children: [
          PageView.builder(
            controller: _model.pageViewController,
            onPageChanged: (index) {
              _model.currentSlide = index;
              safeSetState(() {});
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) =>
                _buildSlide(context, _slides[index]),
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
                        width: index == _model.currentSlide ? 24.0 : 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: index == _model.currentSlide
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 54.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _goNext,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.primary,
                          minimumSize: const Size.fromHeight(54.0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 14.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Text(
                          _model.currentSlide == _slides.length - 1
                              ? masterProfileCompleted
                                    ? 'Продолжить'
                                    : 'Заполнить профиль'
                              : 'Далее',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16.0,
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

class _MasterOnboardingSlide {
  const _MasterOnboardingSlide({
    required this.image,
    required this.title,
    this.subtitle,
  });

  final String image;
  final String title;
  final String? subtitle;
}
