import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

Future<void> showClientInviteGuideDialog(BuildContext context) =>
    showDialog<void>(
      context: context,
      builder: (_) => const _ClientInviteGuideDialog(),
    );

class _ClientInviteGuideDialog extends StatefulWidget {
  const _ClientInviteGuideDialog();

  @override
  State<_ClientInviteGuideDialog> createState() =>
      _ClientInviteGuideDialogState();
}

class _ClientInviteGuideDialogState extends State<_ClientInviteGuideDialog> {
  final _controller = PageController();
  int _page = 0;

  static const _steps = <_GuideStep>[
    _GuideStep(
      number: '1',
      icon: Icons.design_services_rounded,
      title: 'Выберите свою услугу',
      body:
          'Откройте панель мастера и найдите услугу, которой хотите поделиться с клиентами.',
      visual: _ServiceButtonPreview(),
    ),
    _GuideStep(
      number: '2',
      icon: Icons.ios_share_rounded,
      title: 'Нажмите «Пригласить клиентов»',
      body:
          'Сарафан автоматически подготовит красивую вертикальную карточку с услугой и вашим профилем.',
      visual: _StoryPreview(),
    ),
    _GuideStep(
      number: '3',
      icon: Icons.auto_awesome_rounded,
      title: 'Поделитесь в сторис',
      body:
          'Опубликуйте готовую картинку и добавьте ссылку на Сарафан, чтобы клиенты могли установить приложение.',
      visual: _ShareAppsPreview(),
    ),
    _GuideStep(
      number: '4',
      icon: Icons.verified_rounded,
      title: 'Клиенты сразу узнают вас',
      body:
          'После регистрации клиент укажет ваш номер. Все ваши услуги подсветятся для него меткой «Ваш мастер». После визита он сможет оставить первую рекомендацию.',
      visual: _HighlightedServicePreview(),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final lastPage = _page == _steps.length - 1;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 430,
          maxHeight: MediaQuery.sizeOf(context).height * 0.84,
        ),
        child: Material(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Как получить первые рекомендации',
                        style: theme.titleLarge.override(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _steps.length,
                    onPageChanged: (value) => setState(() => _page = value),
                    itemBuilder: (_, index) =>
                        _GuideStepPage(step: _steps[index]),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _steps.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: index == _page ? 22 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: index == _page ? theme.primary : theme.divider,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (_page > 0)
                      IconButton.outlined(
                        onPressed: () => _controller.previousPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        ),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    if (_page > 0) const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (lastPage) {
                            Navigator.pop(context);
                          } else {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: theme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(lastPage ? 'Понятно' : 'Далее'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideStep {
  const _GuideStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.body,
    required this.visual,
  });

  final String number;
  final IconData icon;
  final String title;
  final String body;
  final Widget visual;
}

class _GuideStepPage extends StatelessWidget {
  const _GuideStepPage({required this.step});

  final _GuideStep step;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                Center(child: Icon(step.icon, color: theme.primary, size: 28)),
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: theme.primary,
                    child: Text(
                      step.number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: theme.headlineSmall.override(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            step.body,
            textAlign: TextAlign.center,
            style: theme.bodyMedium.override(
              color: theme.secondaryText,
              lineHeight: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          step.visual,
        ],
      ),
    );
  }
}

class _ServiceButtonPreview extends StatelessWidget {
  const _ServiceButtonPreview();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.image_rounded, color: theme.primary),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ваша услуга',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 4),
                    Text('Цена и описание'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.primary.withValues(alpha: 0.4)),
            ),
            child: Text(
              'Пригласить клиентов в Сарафан',
              style: TextStyle(
                color: theme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryPreview extends StatelessWidget {
  const _StoryPreview();

  @override
  Widget build(BuildContext context) => Container(
    width: 150,
    height: 250,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2563EB), Color(0xFF7C3AED), Color(0xFF082F5B)],
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'САРАФАН',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        Spacer(),
        Text(
          'Мои услуги есть\nв Сарафане',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Ваша услуга',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ShareAppsPreview extends StatelessWidget {
  const _ShareAppsPreview();

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _AppCircle(icon: Icons.camera_alt_rounded, label: 'Сторис'),
      SizedBox(width: 22),
      _AppCircle(icon: Icons.send_rounded, label: 'Telegram'),
      SizedBox(width: 22),
      _AppCircle(icon: Icons.chat_rounded, label: 'Чаты'),
    ],
  );
}

class _AppCircle extends StatelessWidget {
  const _AppCircle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      CircleAvatar(radius: 28, child: Icon(icon)),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(fontSize: 11)),
    ],
  );
}

class _HighlightedServicePreview extends StatelessWidget {
  const _HighlightedServicePreview();

  @override
  Widget build(BuildContext context) {
    final success = FlutterFlowTheme.of(context).success;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: success, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: success,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '✓ Ваш мастер',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              CircleAvatar(child: Icon(Icons.person_rounded)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Услуга мастера',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text('Клиент сразу узнает вас'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
