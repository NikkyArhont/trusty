import 'dart:ui' as ui;
import 'dart:typed_data';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/share_prompt/share_prompt_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'save_story_image.dart';

Future<void> showServiceInviteShareDialog(
  BuildContext context, {
  required ServiceRecord service,
}) => showDialog<void>(
  context: context,
  builder: (_) => _ServiceInviteShareDialog(service: service),
);

class _ServiceInviteShareDialog extends StatefulWidget {
  const _ServiceInviteShareDialog({required this.service});

  final ServiceRecord service;

  @override
  State<_ServiceInviteShareDialog> createState() =>
      _ServiceInviteShareDialogState();
}

class _ServiceInviteShareDialogState extends State<_ServiceInviteShareDialog> {
  final _storyKey = GlobalKey();
  bool _sharing = false;
  bool _saving = false;

  Future<Uint8List> _createStoryImage() async {
    await WidgetsBinding.instance.endOfFrame;
    final boundary =
        _storyKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) throw Exception('Карточка ещё не готова');
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData?.buffer.asUint8List();
    if (bytes == null) throw Exception('Не удалось создать изображение');
    return bytes;
  }

  Future<void> _copyLandingLink() async {
    await Clipboard.setData(const ClipboardData(text: sharePromptLandingUrl));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ссылка на Сарафан скопирована')),
    );
  }

  Future<void> _share(BuildContext buttonContext) async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final bytes = await _createStoryImage();

      final renderBox = buttonContext.findRenderObject() as RenderBox?;
      final origin = renderBox == null
          ? null
          : renderBox.localToGlobal(Offset.zero) & renderBox.size;
      await Share.shareXFiles(
        [
          XFile.fromData(
            bytes,
            mimeType: 'image/png',
            name: 'sarafan_${widget.service.reference.id}.png',
          ),
        ],
        text:
            'Мои услуги есть в Сарафане. Посмотреть и записаться:\n$sharePromptLandingUrl',
        subject: 'Мои услуги в Сарафане',
        sharePositionOrigin: origin,
      );
    } catch (error) {
      if (kDebugMode) print('Service story sharing failed: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось открыть меню «Поделиться»')),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _save() async {
    if (_saving || _sharing) return;
    setState(() => _saving = true);
    try {
      final bytes = await _createStoryImage();
      await saveStoryImage(bytes, 'sarafan_${widget.service.reference.id}.png');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Креатив сохранён в галерею')),
        );
      }
    } catch (error) {
      if (kDebugMode) print('Service story saving failed: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось сохранить креатив')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Material(
          color: theme.primaryBackground,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Пригласите клиентов',
                        style: theme.titleLarge.override(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _sharing || _saving
                          ? null
                          : () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AspectRatio(
                  aspectRatio: 9 / 16,
                  child: RepaintBoundary(
                    key: _storyKey,
                    child: _StoryCard(service: widget.service),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Готовая карточка для сторис и социальных сетей',
                  textAlign: TextAlign.center,
                  style: theme.bodySmall.override(color: theme.secondaryText),
                ),
                const SizedBox(height: 14),
                Builder(
                  builder: (buttonContext) => FilledButton.icon(
                    onPressed: _sharing ? null : () => _share(buttonContext),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      backgroundColor: theme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: _sharing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.ios_share_rounded),
                    label: Text(
                      _sharing ? 'Готовим карточку...' : 'Поделиться',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _sharing || _saving ? null : _save,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    foregroundColor: theme.primary,
                    side: BorderSide(
                      color: theme.primary.withValues(alpha: 0.45),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _saving
                      ? SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.primary,
                          ),
                        )
                      : const Icon(Icons.download_rounded),
                  label: Text(_saving ? 'Сохраняем...' : 'Сохранить'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _sharing || _saving ? null : _copyLandingLink,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    foregroundColor: theme.primary,
                    side: BorderSide(
                      color: theme.primary.withValues(alpha: 0.45),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.link_rounded),
                  label: const Text('Скопировать ссылку на Сарафан'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.service});

  final ServiceRecord service;

  @override
  Widget build(BuildContext context) {
    final master = currentUserDocument?.masterData;
    final masterPhoto = master?.mainPhoto.trim() ?? '';
    final masterTitle = master?.title.trim() ?? '';
    final userName = currentUserDisplayName.trim();
    final serviceImage = service.image.isNotEmpty ? service.image.first : '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (serviceImage.isNotEmpty)
            _NetworkStoryImage(
              url: serviceImage,
              fit: BoxFit.cover,
              fallback: const _StoryBackground(),
            )
          else
            const _StoryBackground(),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x33000000),
                  Color(0x22000000),
                  Color(0xE6001738),
                ],
                stops: [0, 0.42, 1],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'САРАФАН',
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Мои услуги есть\nв Сарафане',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 20,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: 42,
                              height: 42,
                              child: masterPhoto.isNotEmpty
                                  ? _NetworkStoryImage(
                                      url: masterPhoto,
                                      fit: BoxFit.cover,
                                      fallback: const _AvatarFallback(),
                                    )
                                  : const _AvatarFallback(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  masterTitle.isNotEmpty
                                      ? masterTitle
                                      : 'Мастер',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF111827),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                if (userName.isNotEmpty)
                                  Text(
                                    userName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF667085),
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            formatPrice(service.price),
                            style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryBackground extends StatelessWidget {
  const _StoryBackground();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2563EB), Color(0xFF7C3AED), Color(0xFF0EA5E9)],
      ),
    ),
    child: Center(
      child: Icon(Icons.auto_awesome_rounded, size: 84, color: Colors.white38),
    ),
  );
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: Color(0xFFE8EEFF),
    child: Icon(Icons.person_rounded, color: Color(0xFF2563EB)),
  );
}

class _NetworkStoryImage extends StatelessWidget {
  const _NetworkStoryImage({
    required this.url,
    required this.fit,
    required this.fallback,
  });

  final String url;
  final BoxFit fit;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(
        url,
        fit: fit,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      errorWidget: (_, __, ___) => fallback,
    );
  }
}
