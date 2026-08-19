import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

enum _PreviewKind { dialog, push, banner }

class _CommunicationPreview {
  const _CommunicationPreview({
    required this.kind,
    required this.name,
    required this.title,
    required this.body,
    required this.audience,
    required this.condition,
    required this.schedule,
    this.primaryAction,
    this.secondaryAction,
    this.icon = Icons.notifications_rounded,
  });

  final _PreviewKind kind;
  final String name;
  final String title;
  final String body;
  final String audience;
  final String condition;
  final String schedule;
  final String? primaryAction;
  final String? secondaryAction;
  final IconData icon;
}

const _previews = <_CommunicationPreview>[
  _CommunicationPreview(
    kind: _PreviewKind.dialog,
    name: 'Обязательное обновление',
    title: 'Доступна новая версия',
    body: 'Обновите приложение, чтобы продолжить пользоваться Сарафаном.',
    audience: 'Клиент и мастер',
    condition: 'Текущая сборка ниже minimumBuild в Remote Config.',
    schedule: 'При запуске и возвращении приложения на экран.',
    primaryAction: 'Обновить',
    icon: Icons.system_update_rounded,
  ),
  _CommunicationPreview(
    kind: _PreviewKind.dialog,
    name: 'Необязательное обновление',
    title: 'Доступна новая версия',
    body: 'В магазинах уже доступна свежая версия Сарафана.',
    audience: 'Клиент и мастер',
    condition: 'Сборка ниже latestBuild, но не ниже minimumBuild.',
    schedule: 'Один раз за сессию для каждой новой сборки.',
    primaryAction: 'Обновить',
    secondaryAction: 'Позже',
    icon: Icons.system_update_rounded,
  ),
  _CommunicationPreview(
    kind: _PreviewKind.dialog,
    name: 'Помочь проекту',
    title: 'Помогите Сарафану расти',
    body:
        'Поделитесь приложением с друзьями и в социальных сетях — так клиенты смогут находить проверенных мастеров, а мастера расширять свой сарафан связей.',
    audience: 'Клиент и мастер',
    condition:
        'Через 4 дня после регистрации/последнего показа либо по кнопке «Помочь проекту».',
    schedule: 'Повторно не чаще одного раза в 4 дня.',
    primaryAction: 'Поделиться',
    secondaryAction: 'Не сейчас',
    icon: Icons.volunteer_activism_rounded,
  ),
  _CommunicationPreview(
    kind: _PreviewKind.dialog,
    name: 'Первая услуга',
    title: 'Пригласите своих клиентов',
    body:
        'Расскажите постоянным клиентам, что теперь к вам можно записаться через Сарафан. После услуги они смогут оставить рекомендацию, которую увидят новые клиенты.',
    audience: 'Мастер',
    condition: 'Сразу после успешного создания самой первой услуги.',
    schedule: 'Один раз для аккаунта.',
    primaryAction: 'Поделиться',
    secondaryAction: 'Не сейчас',
    icon: Icons.group_add_rounded,
  ),
  _CommunicationPreview(
    kind: _PreviewKind.banner,
    name: 'Синхронизация контактов',
    title: 'Синхронизируйте контакты',
    body: 'Возможно, кто-то из ваших знакомых уже был у этого специалиста.',
    audience: 'Клиент и мастер',
    condition:
        'Нет разрешения на контакты или синхронизация ещё не выполнялась.',
    schedule: 'На экранах услуги и профиля мастера.',
    primaryAction: 'Синхронизировать',
    icon: Icons.people_outline_rounded,
  ),
  _CommunicationPreview(
    kind: _PreviewKind.push,
    name: 'Возврат клиента',
    title: 'Загляните в Сарафан',
    body: 'Возможно, появились услуги, которые вас заинтересуют.',
    audience: 'Клиент',
    condition: 'Есть FCM-токен, пользователь не является мастером.',
    schedule: 'Раз в 5 дней, случайно с 16:00 до 18:00 МСК.',
  ),
  _CommunicationPreview(
    kind: _PreviewKind.push,
    name: 'Незаполненный профиль мастера',
    title: 'Завершите профиль',
    body: 'Заполните профиль и опубликуйте свою первую услугу.',
    audience: 'Мастер',
    condition: 'Профиль мастера заполнен не полностью.',
    schedule: 'Раз в 5 дней, случайно с 16:00 до 18:00 МСК.',
  ),
  _CommunicationPreview(
    kind: _PreviewKind.push,
    name: 'Мастер без услуг',
    title: 'Опубликуйте первую услугу',
    body: 'Возможно, пользователи уже ищут именно вас.',
    audience: 'Мастер',
    condition: 'Профиль заполнен, но услуг ещё нет.',
    schedule: 'Раз в 5 дней, случайно с 16:00 до 18:00 МСК.',
  ),
  _CommunicationPreview(
    kind: _PreviewKind.push,
    name: 'Мастер с услугами',
    title: 'Вдохновитесь новыми идеями',
    body:
        'Загляните в Сарафан — возможно, идеи других мастеров помогут вам сделать свои услуги ещё привлекательнее.',
    audience: 'Мастер',
    condition: 'Профиль заполнен и существует хотя бы одна услуга.',
    schedule: 'Раз в 5 дней, случайно с 16:00 до 18:00 МСК.',
  ),
  _CommunicationPreview(
    kind: _PreviewKind.push,
    name: 'Призыв поделиться',
    title: 'Помогите Сарафану расти',
    body:
        'Поделитесь приложением с друзьями — вместе мы создаём сеть проверенных мастеров.',
    audience: 'Клиент и мастер',
    condition: 'Наступил четырёхдневный share-интервал и pushEnabled включён.',
    schedule: 'С 16:00 до 18:00 МСК; не в один день с engagement-пушем.',
  ),
  _CommunicationPreview(
    kind: _PreviewKind.push,
    name: 'Новое сообщение',
    title: 'Имя отправителя',
    body: 'Текст сообщения или «Фото».',
    audience: 'Получатель сообщения',
    condition: 'В чате появилось новое сообщение без привязанной записи.',
    schedule: 'Сразу после отправки.',
    icon: Icons.chat_bubble_rounded,
  ),
  _CommunicationPreview(
    kind: _PreviewKind.push,
    name: 'Запись подтверждена',
    title: 'Запись подтверждена',
    body: 'Мастер подтвердил вашу запись.',
    audience: 'Клиент',
    condition: 'Мастер подтвердил запрос и назначил дату.',
    schedule: 'Сразу после подтверждения.',
    icon: Icons.event_available_rounded,
  ),
  _CommunicationPreview(
    kind: _PreviewKind.push,
    name: 'Запись отменена',
    title: 'Запись отменена',
    body: 'Мастер или клиент отменил запись.',
    audience: 'Вторая сторона записи',
    condition: 'Статус записи изменён на «отменена».',
    schedule: 'Сразу после отмены.',
    icon: Icons.event_busy_rounded,
  ),
  _CommunicationPreview(
    kind: _PreviewKind.push,
    name: 'Модерация услуги',
    title: 'Услуга одобрена / отклонена',
    body: 'Ваша услуга опубликована либо указана причина отклонения.',
    audience: 'Мастер — владелец услуги',
    condition: 'Модератор принял решение по услуге.',
    schedule: 'Сразу после решения модератора.',
    icon: Icons.verified_rounded,
  ),
  _CommunicationPreview(
    kind: _PreviewKind.push,
    name: 'Результат жалобы',
    title: 'Жалоба отклонена / нарушение подтверждено',
    body: 'Показывается решение модератора и его причина.',
    audience: 'Пользователь, отправивший жалобу',
    condition: 'Модератор обработал жалобу на пользователя.',
    schedule: 'Сразу после решения модератора.',
    icon: Icons.gavel_rounded,
  ),
];

Future<void> showSystemCommunicationsPreview(BuildContext context) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const _SystemCommunicationsPreviewDialog(),
  );
}

class _SystemCommunicationsPreviewDialog extends StatefulWidget {
  const _SystemCommunicationsPreviewDialog();

  @override
  State<_SystemCommunicationsPreviewDialog> createState() =>
      _SystemCommunicationsPreviewDialogState();
}

class _SystemCommunicationsPreviewDialogState
    extends State<_SystemCommunicationsPreviewDialog> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _move(int delta) {
    final target = (_page + delta).clamp(0, _previews.length - 1);
    _controller.animateToPage(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      backgroundColor: Colors.transparent,
      child: Material(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 760),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Системные коммуникации',
                            style: theme.titleLarge,
                          ),
                          Text(
                            '${_page + 1} из ${_previews.length}',
                            style: theme.bodySmall.override(
                              color: theme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Закрыть',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _previews.length,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemBuilder: (_, index) =>
                      _PreviewPage(preview: _previews[index]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _page == 0 ? null : () => _move(-1),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (_page + 1) / _previews.length,
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    IconButton(
                      onPressed: _page == _previews.length - 1
                          ? null
                          : () => _move(1),
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewPage extends StatelessWidget {
  const _PreviewPage({required this.preview});

  final _CommunicationPreview preview;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _Tag(
                text: switch (preview.kind) {
                  _PreviewKind.dialog => 'ДИАЛОГ',
                  _PreviewKind.push => 'PUSH',
                  _PreviewKind.banner => 'ПЛАШКА',
                },
              ),
              const SizedBox(width: 8),
              const _Tag(text: 'АКТИВЕН', success: true),
            ],
          ),
          const SizedBox(height: 12),
          Text(preview.name, style: theme.titleMedium),
          const SizedBox(height: 18),
          preview.kind == _PreviewKind.push
              ? _PushMockup(preview: preview)
              : _DialogMockup(preview: preview),
          const SizedBox(height: 20),
          _InfoRow(label: 'Кому', value: preview.audience),
          _InfoRow(label: 'Условие', value: preview.condition),
          _InfoRow(label: 'Когда', value: preview.schedule),
          const SizedBox(height: 8),
          Text(
            'Предпросмотр безопасный: уведомление не отправляется, пользовательские отметки не изменяются.',
            style: theme.bodySmall.override(color: theme.secondaryText),
          ),
        ],
      ),
    );
  }
}

class _PushMockup extends StatelessWidget {
  const _PushMockup({required this.preview});
  final _CommunicationPreview preview;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.divider),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: theme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.people_alt_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Сарафан', style: theme.labelLarge)),
                    Text('сейчас', style: theme.bodySmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(preview.title, style: theme.titleSmall),
                const SizedBox(height: 3),
                Text(preview.body, style: theme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogMockup extends StatelessWidget {
  const _DialogMockup({required this.preview});
  final _CommunicationPreview preview;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.divider),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(preview.icon, color: theme.primary, size: 31),
          ),
          const SizedBox(height: 14),
          Text(
            preview.title,
            textAlign: TextAlign.center,
            style: theme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            preview.body,
            textAlign: TextAlign.center,
            style: theme.bodyMedium.override(color: theme.secondaryText),
          ),
          if (preview.primaryAction != null) ...[
            const SizedBox(height: 18),
            IgnorePointer(
              child: FilledButton(
                onPressed: () {},
                child: Text(preview.primaryAction!),
              ),
            ),
          ],
          if (preview.secondaryAction != null)
            IgnorePointer(
              child: TextButton(
                onPressed: () {},
                child: Text(preview.secondaryAction!),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: theme.labelMedium.override(color: theme.secondaryText),
            ),
          ),
          Expanded(child: Text(value, style: theme.bodyMedium)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, this.success = false});
  final String text;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final color = success ? theme.success : theme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: theme.labelSmall.override(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
