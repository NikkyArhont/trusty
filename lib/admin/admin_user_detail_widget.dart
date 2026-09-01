import '/backend/admin/admin_users_service.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/support/support_chat_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/global_comp/app_page_header/app_page_header.dart';
import '/init/sync_contacts.dart';
import '/user/chat/chat_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminUserDetailWidget extends StatefulWidget {
  const AdminUserDetailWidget({
    super.key,
    required this.userId,
    this.initialView = 'client',
  });

  final String userId;
  final String initialView;

  static String routeName = 'AdminUserDetail';
  static String routePath = '/adminUserDetail';

  @override
  State<AdminUserDetailWidget> createState() => _AdminUserDetailWidgetState();
}

class _AdminUserDetailWidgetState extends State<AdminUserDetailWidget> {
  late bool _masterView;
  late Future<AdminUserInfo?> _userFuture;
  bool _openingSupportChat = false;

  @override
  void initState() {
    super.initState();
    _masterView = widget.initialView == 'master';
    _userFuture = _loadUser();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    await syncContacts();
    if (mounted) setState(() {});
  }

  Future<void> _openSupportChat(AdminUserInfo user) async {
    if (_openingSupportChat || user.id == currentUserUid) return;
    setState(() => _openingSupportChat = true);
    try {
      final chatId = await ensureSupportChatForUser(user.id);
      if (!mounted) return;
      context.pushNamed(
        ChatWidget.routeName,
        queryParameters: {
          'chatId': serializeParam(chatId, ParamType.String),
        }.withoutNulls,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось открыть чат поддержки')),
        );
      }
    } finally {
      if (mounted) setState(() => _openingSupportChat = false);
    }
  }

  Future<AdminUserInfo?> _loadUser({bool force = false}) async {
    final cached = AdminUsersService.instance.findCached(widget.userId);
    if (!force && cached != null) return cached;
    final users = await AdminUsersService.instance.load(force: force);
    for (final user in users) {
      if (user.id == widget.userId) return user;
    }
    return null;
  }

  Future<void> _reload() async {
    final future = _loadUser(force: true);
    setState(() => _userFuture = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: FutureBuilder<AdminUserInfo?>(
          future: _userFuture,
          builder: (context, snapshot) {
            final user = snapshot.data;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: AppPageHeader(
                    title: _masterView ? 'Профиль мастера' : 'Профиль клиента',
                    showBack: true,
                    padding: EdgeInsets.zero,
                    actions: [
                      IconButton(
                        tooltip: 'Обновить',
                        onPressed: _reload,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (snapshot.connectionState == ConnectionState.waiting)
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: theme.primary),
                    ),
                  )
                else if (snapshot.hasError || user == null)
                  Expanded(
                    child: _DetailState(
                      title: 'Пользователь не найден',
                      subtitle: 'Обновите данные и попробуйте ещё раз.',
                      onRetry: _reload,
                    ),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _reload,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                        children: [
                          _IdentityCard(user: user, masterView: _masterView),
                          if (user.id != currentUserUid) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _openingSupportChat
                                    ? null
                                    : () => _openSupportChat(user),
                                icon: _openingSupportChat
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.support_agent_rounded),
                                label: const Text('Написать пользователю'),
                              ),
                            ),
                          ],
                          if (user.masterStarted) ...[
                            const SizedBox(height: 12),
                            _ProfileSwitch(
                              masterView: _masterView,
                              onChanged: (value) {
                                setState(() => _masterView = value);
                              },
                            ),
                          ],
                          const SizedBox(height: 12),
                          if (_masterView)
                            _MasterDetails(user: user)
                          else
                            _ClientDetails(user: user),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.user, required this.masterView});

  final AdminUserInfo user;
  final bool masterView;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final name = masterView && user.master.title.isNotEmpty
        ? user.master.title
        : user.displayName;
    final contactName = _contactName(user);
    final photo = masterView && user.master.photo.isNotEmpty
        ? user.master.photo
        : user.photo;
    return _SectionCard(
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.primary.withValues(alpha: 0.1),
            ),
            child: photo.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: photo,
                    fit: BoxFit.cover,
                    memCacheWidth: 216,
                    memCacheHeight: 216,
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.person_rounded, size: 32),
                  )
                : Icon(Icons.person_rounded, size: 32, color: theme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contactName ?? name,
                  style: theme.titleLarge.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (user.phone.isNotEmpty)
                  Text(
                    user.phone,
                    style: theme.bodyMedium.override(
                      color: theme.secondaryText,
                    ),
                  ),
                if (contactName != null)
                  Text(
                    masterView && user.master.title.isNotEmpty
                        ? 'Мастер: ${user.master.title}'
                        : 'В Сарафане: ${user.displayName}',
                    style: theme.bodySmall.override(color: theme.secondaryText),
                  ),
                Text(
                  !user.pushNotificationsEnabled
                      ? 'Push-уведомления выключены пользователем'
                      : user.hasActiveDevice
                      ? 'Push-уведомления включены'
                      : 'Push-уведомления недоступны',
                  style: theme.labelSmall.override(
                    color: user.pushNotificationsEnabled && user.hasActiveDevice
                        ? theme.primary
                        : theme.error,
                  ),
                ),
              ].divide(const SizedBox(height: 4)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSwitch extends StatelessWidget {
  const _ProfileSwitch({required this.masterView, required this.onChanged});

  final bool masterView;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    Widget button(String label, bool value) => Expanded(
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: masterView == value
                ? theme.secondaryBackground
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: masterView == value
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.bodyMedium.override(
              fontWeight: masterView == value
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.divider),
      ),
      child: Row(children: [button('Клиент', false), button('Мастер', true)]),
    );
  }
}

class _ClientDetails extends StatelessWidget {
  const _ClientDetails({required this.user});

  final AdminUserInfo user;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _SectionCard(
        title: 'Информация',
        child: Column(
          children: [
            _InfoRow(label: 'Имя', value: user.displayName),
            _InfoRow(label: 'Телефон', value: user.phone),
            _InfoRow(label: 'Почта', value: user.email),
            _InfoRow(label: 'Город', value: user.clientCity),
            _InfoRow(
              label: 'Дата регистрации',
              value: _formatDate(user.createdAt),
            ),
            _InfoRow(
              label: 'Последняя активность',
              value: user.lastActiveAt == null
                  ? 'Ещё не зафиксирована'
                  : _formatDate(user.lastActiveAt),
            ),
            if (user.bio.isNotEmpty) _InfoRow(label: 'О себе', value: user.bio),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _RegistrationStages(user: user),
    ],
  );
}

class _MasterDetails extends StatelessWidget {
  const _MasterDetails({required this.user});

  final AdminUserInfo user;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _SectionCard(
        title: 'Профиль мастера',
        child: Column(
          children: [
            _InfoRow(label: 'Название', value: user.master.title),
            _InfoRow(label: 'Город', value: user.master.city),
            _InfoRow(
              label: 'Категория',
              value: _categoryTitle(user.master.categoryKey),
            ),
            _InfoRow(label: 'Описание', value: user.master.description),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _RegistrationStages(user: user),
      const SizedBox(height: 12),
      _ServicesSection(services: user.services),
    ],
  );
}

class _RegistrationStages extends StatelessWidget {
  const _RegistrationStages({required this.user});

  final AdminUserInfo user;

  @override
  Widget build(BuildContext context) => _SectionCard(
    title: 'Этапы',
    child: Column(
      children: [
        _StageRow(
          done: user.registrationComplete,
          label: user.registrationComplete
              ? 'Регистрация завершена'
              : 'Регистрация не завершена',
        ),
        _StageRow(
          done: user.hasClientCity,
          label: user.hasClientCity
              ? 'Город клиента указан'
              : 'Город клиента не указан',
        ),
        _StageRow(
          done: user.masterStarted,
          label: user.masterStarted
              ? 'Создание профиля мастера начато'
              : 'Профиль мастера не создавался',
        ),
        if (user.masterStarted) ...[
          _StageRow(
            done: user.masterComplete,
            label: user.masterComplete
                ? 'Профиль мастера заполнен'
                : 'Профиль мастера не завершён',
          ),
          _StageRow(
            done: user.hasMasterCity,
            label: user.hasMasterCity
                ? 'Город мастера указан'
                : 'Город мастера не указан',
          ),
          _StageRow(
            done: user.hasServices,
            label: user.hasServices
                ? 'Созданы услуги: ${user.services.length}'
                : 'Услуги не созданы',
          ),
        ],
      ].divide(const SizedBox(height: 10)),
    ),
  );
}

class _StageRow extends StatelessWidget {
  const _StageRow({required this.done, required this.label});

  final bool done;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final color = done ? theme.primary : theme.error;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          done ? Icons.check_circle_rounded : Icons.error_outline_rounded,
          size: 21,
          color: color,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: theme.bodyMedium.override(
              color: done ? theme.primaryText : color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({required this.services});

  final List<AdminServiceInfo> services;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return _SectionCard(
      title: 'Услуги (${services.length})',
      child: services.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.design_services_outlined, color: theme.error),
                  const SizedBox(width: 10),
                  Text(
                    'Услуги не созданы',
                    style: theme.bodyMedium.override(color: theme.error),
                  ),
                ],
              ),
            )
          : Column(
              children: services
                  .map((service) => _AdminServiceCard(service: service))
                  .toList()
                  .divide(const SizedBox(height: 10)),
            ),
    );
  }
}

class _AdminServiceCard extends StatelessWidget {
  const _AdminServiceCard({required this.service});

  final AdminServiceInfo service;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final status = _serviceStatus(service.status, theme);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: service.image.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: service.image,
                    fit: BoxFit.cover,
                    memCacheWidth: 174,
                    memCacheHeight: 174,
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.design_services_rounded),
                  )
                : const Icon(Icons.design_services_rounded),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: theme.bodyMedium.override(fontWeight: FontWeight.w700),
                ),
                Text(
                  [
                    if (service.price > 0) formatPrice(service.price),
                    if (service.categoryKey.isNotEmpty)
                      _categoryTitle(service.categoryKey),
                  ].join(' · '),
                  style: theme.bodySmall.override(color: theme.secondaryText),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.label,
                    style: theme.labelSmall.override(
                      color: status.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (service.moderationReason.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    service.moderationReason,
                    style: theme.labelSmall.override(color: theme.error),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: theme.titleMedium.override(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
          ],
          child,
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.bodySmall.override(color: theme.secondaryText),
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isNotEmpty ? value : 'Не указано',
              style: theme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailState extends StatelessWidget {
  const _DetailState({
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  final String title;
  final String subtitle;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.person_off_outlined, size: 46),
        const SizedBox(height: 12),
        Text(title, style: FlutterFlowTheme.of(context).titleMedium),
        const SizedBox(height: 6),
        Text(subtitle),
        const SizedBox(height: 12),
        FilledButton(onPressed: onRetry, child: const Text('Повторить')),
      ],
    ),
  );
}

({String label, Color color}) _serviceStatus(
  String status,
  FlutterFlowTheme theme,
) => switch (status) {
  'show' => (label: 'Опубликована', color: const Color(0xFF16803C)),
  'onModerate' => (label: 'На модерации', color: const Color(0xFFE07A00)),
  'denied' => (label: 'Отклонена', color: theme.error),
  'arhive' => (label: 'В архиве', color: theme.secondaryText),
  _ => (label: 'Статус не указан', color: theme.secondaryText),
};

String _categoryTitle(String key) {
  if (key.trim().isEmpty) return '';
  for (final category in FFAppState().presetCategory) {
    if (category.key == key) return category.titleRU;
  }
  return key;
}

String _formatDate(DateTime? date) {
  if (date == null) return 'Не указано';
  return dateTimeFormat('d MMM y, HH:mm', date.toLocal(), locale: 'ru');
}

String? _contactName(AdminUserInfo user) {
  final name = contactNameForPhone(user.phone)?.trim() ?? '';
  return name.isEmpty ? null : name;
}
