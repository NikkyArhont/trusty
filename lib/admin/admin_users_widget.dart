import '/backend/admin/admin_users_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/global_comp/app_page_header/app_page_header.dart';
import '/init/sync_contacts.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum _UserFilter {
  all,
  guests,
  missingCity,
  incompleteRegistration,
  noServices,
}

enum _UserSort { newest, oldest, recentActivity, name }

class AdminUsersWidget extends StatefulWidget {
  const AdminUsersWidget({super.key});

  static String routeName = 'AdminUsers';
  static String routePath = '/adminUsers';

  @override
  State<AdminUsersWidget> createState() => _AdminUsersWidgetState();
}

class _AdminUsersWidgetState extends State<AdminUsersWidget> {
  late Future<List<AdminUserInfo>> _usersFuture;
  final _searchController = TextEditingController();
  _UserFilter _filter = _UserFilter.all;
  _UserSort _sort = _UserSort.newest;

  @override
  void initState() {
    super.initState();
    _usersFuture = AdminUsersService.instance.load();
    _searchController.addListener(_refreshState);
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refreshState)
      ..dispose();
    super.dispose();
  }

  void _refreshState() => setState(() {});

  Future<void> _loadContacts() async {
    await syncContacts();
    if (mounted) setState(() {});
  }

  Future<void> _reload() async {
    final future = AdminUsersService.instance.load(force: true);
    setState(() => _usersFuture = future);
    await future;
  }

  List<AdminUserInfo> _filtered(
    List<AdminUserInfo> source, {
    required bool masters,
  }) {
    final query = _searchController.text.trim().toLowerCase();
    final result = source.where((user) {
      if (masters && !user.masterStarted) return false;
      final contactName = _contactName(user)?.toLowerCase() ?? '';
      if (query.isNotEmpty &&
          !user.searchableText.contains(query) &&
          !contactName.contains(query)) {
        return false;
      }
      return switch (_filter) {
        _UserFilter.all => true,
        _UserFilter.guests => user.isGuest,
        _UserFilter.missingCity =>
          masters ? !user.hasMasterCity : !user.hasClientCity,
        _UserFilter.incompleteRegistration => !user.registrationComplete,
        _UserFilter.noServices => user.masterStarted && !user.hasServices,
      };
    }).toList();
    result.sort(
      (left, right) => switch (_sort) {
        _UserSort.newest => _dateMillis(
          right.createdAt,
        ).compareTo(_dateMillis(left.createdAt)),
        _UserSort.oldest => _dateMillis(
          left.createdAt,
        ).compareTo(_dateMillis(right.createdAt)),
        _UserSort.recentActivity => _dateMillis(
          right.lastActiveAt,
        ).compareTo(_dateMillis(left.lastActiveAt)),
        _UserSort.name => left.displayName.toLowerCase().compareTo(
          right.displayName.toLowerCase(),
        ),
      },
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                AppPageHeader(
                  title: 'Пользователи',
                  showBack: true,
                  padding: EdgeInsets.zero,
                  actions: [
                    PopupMenuButton<_UserSort>(
                      tooltip: 'Сортировка',
                      initialValue: _sort,
                      onSelected: (value) => setState(() => _sort = value),
                      icon: const Icon(Icons.sort_rounded),
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: _UserSort.newest,
                          child: Text('Сначала новые'),
                        ),
                        PopupMenuItem(
                          value: _UserSort.oldest,
                          child: Text('Сначала старые'),
                        ),
                        PopupMenuItem(
                          value: _UserSort.recentActivity,
                          child: Text('По активности'),
                        ),
                        PopupMenuItem(
                          value: _UserSort.name,
                          child: Text('По имени'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск по имени или телефону',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: _searchController.clear,
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                    filled: true,
                    fillColor: theme.secondaryBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: theme.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: theme.divider),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'Гости',
                        selected: _filter == _UserFilter.guests,
                        onTap: () =>
                            setState(() => _filter = _UserFilter.guests),
                      ),
                      _FilterChip(
                        label: 'Все',
                        selected: _filter == _UserFilter.all,
                        onTap: () => setState(() => _filter = _UserFilter.all),
                      ),
                      _FilterChip(
                        label: 'Без города',
                        selected: _filter == _UserFilter.missingCity,
                        onTap: () =>
                            setState(() => _filter = _UserFilter.missingCity),
                      ),
                      _FilterChip(
                        label: 'Регистрация не завершена',
                        selected: _filter == _UserFilter.incompleteRegistration,
                        onTap: () => setState(
                          () => _filter = _UserFilter.incompleteRegistration,
                        ),
                      ),
                      _FilterChip(
                        label: 'Мастер без услуг',
                        selected: _filter == _UserFilter.noServices,
                        onTap: () =>
                            setState(() => _filter = _UserFilter.noServices),
                      ),
                    ].divide(const SizedBox(width: 8)),
                  ),
                ),
                const SizedBox(height: 10),
                TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(text: 'Клиенты'),
                    Tab(text: 'Мастера'),
                  ],
                  labelStyle: theme.bodyLarge.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelColor: theme.secondaryText,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: FutureBuilder<List<AdminUserInfo>>(
                    future: _usersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: theme.primary,
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return _CatalogState(
                          icon: Icons.cloud_off_rounded,
                          title: 'Не удалось загрузить пользователей',
                          subtitle: 'Проверьте интернет и повторите попытку.',
                          action: _reload,
                        );
                      }
                      final users = snapshot.data ?? const <AdminUserInfo>[];
                      return TabBarView(
                        children: [
                          _UsersList(
                            users: _filtered(users, masters: false),
                            masters: false,
                            onRefresh: _reload,
                          ),
                          _UsersList(
                            users: _filtered(users, masters: true),
                            masters: true,
                            onRefresh: _reload,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UsersList extends StatelessWidget {
  const _UsersList({
    required this.users,
    required this.masters,
    required this.onRefresh,
  });

  final List<AdminUserInfo> users;
  final bool masters;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const _CatalogState(
        icon: Icons.manage_search_rounded,
        title: 'Ничего не найдено',
        subtitle: 'Измените поиск или выбранный фильтр.',
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) =>
            _UserCard(user: users[index], masterView: masters),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.masterView});

  final AdminUserInfo user;
  final bool masterView;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final name = masterView && user.master.title.isNotEmpty
        ? user.master.title
        : user.displayName;
    final contactName = _contactName(user);
    final visibleName = contactName ?? name;
    final photo = masterView && user.master.photo.isNotEmpty
        ? user.master.photo
        : user.photo;
    final city = masterView ? user.master.city : user.clientCity;
    return Material(
      color: theme.secondaryBackground,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.pushNamed(
          AdminUserDetailWidget.routeName,
          queryParameters: {
            'userId': serializeParam(user.id, ParamType.String),
            'initialView': serializeParam(
              masterView ? 'master' : 'client',
              ParamType.String,
            ),
          }.withoutNulls,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _UserAvatar(photo: photo),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visibleName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodyLarge.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (user.phone.isNotEmpty)
                      Text(
                        user.phone,
                        style: theme.bodySmall.override(
                          color: theme.secondaryText,
                        ),
                      ),
                    if (contactName != null)
                      Text(
                        masterView && user.master.title.isNotEmpty
                            ? 'Мастер: ${user.master.title}'
                            : 'В Сарафане: ${user.displayName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.labelSmall.override(
                          color: theme.secondaryText,
                        ),
                      ),
                    Text(
                      city.isNotEmpty ? city : 'Город не указан',
                      style: theme.bodySmall.override(
                        color: city.isNotEmpty
                            ? theme.secondaryText
                            : theme.error,
                      ),
                    ),
                    if (!masterView && user.masterStarted)
                      Text(
                        'Есть профиль мастера',
                        style: theme.labelSmall.override(
                          color: theme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (user.isGuest)
                          const _StatusPill(
                            label: 'Гостевой режим',
                            warning: false,
                          ),
                        if (!user.registrationComplete)
                          const _StatusPill(
                            label: 'Регистрация не завершена',
                            warning: true,
                          ),
                        if (masterView && !user.masterComplete)
                          const _StatusPill(
                            label: 'Профиль не завершён',
                            warning: true,
                          ),
                        if (masterView)
                          _StatusPill(
                            label: user.hasServices
                                ? 'Услуг: ${user.services.length}'
                                : 'Нет услуг',
                            warning: !user.hasServices,
                          ),
                        _StatusPill(
                          label: !user.pushNotificationsEnabled
                              ? 'Push выключены'
                              : user.hasActiveDevice
                              ? 'Push включены'
                              : 'Push недоступны',
                          warning:
                              !user.pushNotificationsEnabled ||
                              !user.hasActiveDevice,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.photo});

  final String photo;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: 52,
      height: 52,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: photo.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: photo,
              fit: BoxFit.cover,
              memCacheWidth: 156,
              memCacheHeight: 156,
              errorWidget: (_, __, ___) => const Icon(Icons.person_rounded),
            )
          : Icon(Icons.person_rounded, color: theme.primary),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => FilterChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onTap(),
    showCheckmark: false,
    visualDensity: VisualDensity.compact,
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, this.warning = false});

  final String label;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final color = warning ? theme.error : theme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.labelSmall.override(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CatalogState extends StatelessWidget {
  const _CatalogState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Future<void> Function()? action;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: theme.primary),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: theme.titleMedium),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(color: theme.secondaryText),
            ),
            if (action != null) ...[
              const SizedBox(height: 14),
              FilledButton(onPressed: action, child: const Text('Повторить')),
            ],
          ],
        ),
      ),
    );
  }
}

int _dateMillis(DateTime? value) => value?.millisecondsSinceEpoch ?? 0;

String? _contactName(AdminUserInfo user) {
  final name = contactNameForPhone(user.phone)?.trim() ?? '';
  return name.isEmpty ? null : name;
}
