import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class VisitHistoryWidget extends StatelessWidget {
  const VisitHistoryWidget({super.key, this.chatId});

  final String? chatId;

  static String routeName = 'VisitHistory';
  static String routePath = '/visitHistory';

  @override
  Widget build(BuildContext context) {
    final id = chatId?.trim() ?? '';
    if (id.isEmpty) {
      final currentRef = currentUserReference;
      if (currentRef == null) {
        return const _HistoryScaffold(
          child: _HistoryMessage(
            icon: Icons.lock_outline_rounded,
            title: 'История недоступна',
            subtitle: 'Войдите в аккаунт, чтобы увидеть посещения.',
          ),
        );
      }

      return _HistoryScaffold(
        subtitle: 'Все ваши завершённые визиты',
        child: _RecordsHistory(
          stream: queryRecordsRecord(
            queryBuilder: (query) =>
                query.where('client', isEqualTo: currentRef),
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _HistoryScaffold(
            child: _HistoryMessage(
              icon: Icons.error_outline_rounded,
              title: 'Не удалось загрузить историю',
              subtitle: 'Проверьте подключение и попробуйте снова.',
            ),
          );
        }
        if (!snapshot.hasData) {
          return const _HistoryScaffold(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data?.data();
        final clientRef = data?['client'] as DocumentReference?;
        final masterRef = data?['master'] as DocumentReference?;
        final currentRef = currentUserReference;
        final isClient = currentRef != null && currentRef == clientRef;
        final isMaster = currentRef != null && currentRef == masterRef;

        if (clientRef == null ||
            masterRef == null ||
            (!isClient && !isMaster)) {
          return const _HistoryScaffold(
            child: _HistoryMessage(
              icon: Icons.lock_outline_rounded,
              title: 'История недоступна',
              subtitle: 'Посещения видны только участникам этого чата.',
            ),
          );
        }

        var otherName = '';
        if (isClient) {
          otherName = (data?['masterName'] as String? ?? '').trim();
        } else {
          otherName = (data?['clientName'] as String? ?? '').trim();
        }
        final subtitle = isClient
            ? 'Ваши визиты к ${otherName.isEmpty ? 'мастеру' : otherName}'
            : 'Визиты клиента ${otherName.isEmpty ? '' : otherName}'.trim();

        return _HistoryScaffold(
          subtitle: subtitle,
          child: _RecordsHistory(
            stream: queryRecordsRecord(
              queryBuilder: (query) => query
                  .where('master', isEqualTo: masterRef)
                  .where('client', isEqualTo: clientRef),
            ),
          ),
        );
      },
    );
  }
}

class _RecordsHistory extends StatelessWidget {
  const _RecordsHistory({required this.stream});

  final Stream<List<RecordsRecord>> stream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RecordsRecord>>(
      stream: stream,
      builder: (context, recordsSnapshot) {
        if (recordsSnapshot.hasError) {
          return const _HistoryMessage(
            icon: Icons.error_outline_rounded,
            title: 'Не удалось загрузить посещения',
            subtitle: 'Проверьте подключение и попробуйте снова.',
          );
        }
        if (!recordsSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final records =
            recordsSnapshot.data!
                .where((record) => record.status == RecordStatus.complite)
                .toList()
              ..sort(
                (a, b) =>
                    (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)),
              );

        if (records.isEmpty) {
          return const _HistoryMessage(
            icon: Icons.history_rounded,
            title: 'Посещений пока нет',
            subtitle: 'Завершённые визиты появятся здесь.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: records.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _VisitCard(
            key: ValueKey(records[index].reference.path),
            record: records[index],
          ),
        );
      },
    );
  }
}

class _HistoryScaffold extends StatelessWidget {
  const _HistoryScaffold({required this.child, this.subtitle});

  final Widget child;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Назад',
                    onPressed: context.safePop,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'История посещений',
                          style: FlutterFlowTheme.of(context).titleLarge,
                        ),
                        if (subtitle?.isNotEmpty == true)
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FlutterFlowTheme.of(context).bodySmall
                                .override(
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).secondaryText,
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: FlutterFlowTheme.of(context).divider),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _VisitCard extends StatefulWidget {
  const _VisitCard({super.key, required this.record});

  final RecordsRecord record;

  @override
  State<_VisitCard> createState() => _VisitCardState();
}

class _VisitCardState extends State<_VisitCard> {
  late final Future<ServiceRecord?> _serviceFuture;

  @override
  void initState() {
    super.initState();
    _serviceFuture = widget.record.service == null
        ? Future.value(null)
        : ServiceRecord.getDocumentOnce(
            widget.record.service!,
          ).then((service) => service, onError: (_) => null);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ServiceRecord?>(
      future: _serviceFuture,
      builder: (context, snapshot) {
        final service = snapshot.data;
        final title = service?.title.trim().isNotEmpty == true
            ? service!.title.trim()
            : 'Услуга';
        final date = widget.record.date;
        final dateLabel = date == null
            ? 'Дата не указана'
            : dateTimeFormat('d MMMM y, HH:mm', date, locale: 'ru');

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: FlutterFlowTheme.of(context).divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(
                    context,
                  ).primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: FlutterFlowTheme.of(context).primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: FlutterFlowTheme.of(context).titleSmall),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            dateLabel,
                            style: FlutterFlowTheme.of(context).bodySmall
                                .override(
                                  color: FlutterFlowTheme.of(
                                    context,
                                  ).secondaryText,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 52,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
