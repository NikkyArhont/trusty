import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

Future<void> showContactsGuideDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (_) => const _ContactsGuideDialog(),
);

class _ContactsGuideDialog extends StatefulWidget {
  const _ContactsGuideDialog();

  @override
  State<_ContactsGuideDialog> createState() => _ContactsGuideDialogState();
}

class _ContactsGuideDialogState extends State<_ContactsGuideDialog> {
  final _controller = PageController();
  int _page = 0;

  static const _steps = <_ContactsGuideStep>[
    _ContactsGuideStep(
      icon: Icons.phone_android_rounded,
      title: 'Сарафан читает контакты на устройстве',
      body:
          'После вашего разрешения приложение читает имена и номера из телефонной книги прямо на этом устройстве.',
      visual: _DeviceContactsPreview(),
    ),
    _ContactsGuideStep(
      icon: Icons.lock_outline_rounded,
      title: 'Имена остаются на телефоне',
      body:
          'Телефонная книга не публикуется. Сарафан сопоставляет номера безопасно, а знакомых показывает так, как они записаны именно у вас.',
      visual: _PrivateMatchingPreview(),
    ),
    _ContactsGuideStep(
      icon: Icons.sync_rounded,
      title: 'Изменили контакт — синхронизируйте снова',
      body:
          'Переименуйте человека в телефонной книге, затем нажмите «Синхронизировать контакты». Сарафан снова прочитает книгу и покажет новое имя.',
      visual: _RenamedContactPreview(),
    ),
    _ContactsGuideStep(
      icon: Icons.airplanemode_active_rounded,
      title: 'Работает даже в авиарежиме',
      body:
          'Кнопка синхронизации прочитает новое имя из памяти телефона даже без интернета. Сеть понадобится только для загрузки новых рекомендаций и данных мастеров.',
      visual: _OfflinePreview(),
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
    final isLastPage = _page == _steps.length - 1;

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
                        'Как работают контакты',
                        style: theme.titleLarge.override(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Закрыть',
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
                        _ContactsGuidePage(step: _steps[index]),
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
                          if (isLastPage) {
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
                        child: Text(isLastPage ? 'Понятно' : 'Далее'),
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

class _ContactsGuideStep {
  const _ContactsGuideStep({
    required this.icon,
    required this.title,
    required this.body,
    required this.visual,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget visual;
}

class _ContactsGuidePage extends StatelessWidget {
  const _ContactsGuidePage({required this.step});

  final _ContactsGuideStep step;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(step.icon, color: theme.primary, size: 29),
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

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.divider),
      ),
      child: child,
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.name, required this.phone, this.highlight});

  final String name;
  final String phone;
  final Color? highlight;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: (highlight ?? theme.primary).withValues(alpha: 0.12),
          child: Icon(Icons.person_rounded, color: highlight ?? theme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(phone, style: theme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeviceContactsPreview extends StatelessWidget {
  const _DeviceContactsPreview();

  @override
  Widget build(BuildContext context) => const _PreviewCard(
    child: Column(
      children: [
        _ContactRow(name: 'Анна', phone: '+7 999 123-45-67'),
        SizedBox(height: 14),
        _ContactRow(name: 'Дмитрий', phone: '+7 918 555-20-20'),
      ],
    ),
  );
}

class _PrivateMatchingPreview extends StatelessWidget {
  const _PrivateMatchingPreview();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return _PreviewCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const _PreviewIcon(icon: Icons.contacts_rounded, label: 'Контакты'),
          Icon(Icons.arrow_forward_rounded, color: theme.secondaryText),
          const _PreviewIcon(icon: Icons.shield_rounded, label: 'Безопасно'),
          Icon(Icons.arrow_forward_rounded, color: theme.secondaryText),
          const _PreviewIcon(
            icon: Icons.recommend_rounded,
            label: 'Рекомендации',
          ),
        ],
      ),
    );
  }
}

class _PreviewIcon extends StatelessWidget {
  const _PreviewIcon({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.primary, size: 30),
        const SizedBox(height: 6),
        Text(label, style: theme.bodySmall),
      ],
    );
  }
}

class _RenamedContactPreview extends StatelessWidget {
  const _RenamedContactPreview();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return _PreviewCard(
      child: Column(
        children: [
          const _ContactRow(name: 'Анна', phone: 'Было в телефонной книге'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Icon(Icons.arrow_downward_rounded, color: theme.primary),
          ),
          _ContactRow(
            name: 'Анна — стилист',
            phone: 'Так будет показано в Сарафане',
            highlight: theme.success,
          ),
        ],
      ),
    );
  }
}

class _OfflinePreview extends StatelessWidget {
  const _OfflinePreview();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return _PreviewCard(
      child: Column(
        children: [
          Icon(
            Icons.airplanemode_active_rounded,
            color: theme.primary,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            'Телефонная книга → Сарафан',
            style: theme.titleMedium.override(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Имя обновляется локально',
            style: theme.bodySmall.override(color: theme.secondaryText),
          ),
        ],
      ),
    );
  }
}
