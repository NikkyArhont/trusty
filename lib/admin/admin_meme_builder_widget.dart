import 'dart:typed_data';
import 'dart:ui' as ui;

import '/backend/support/support_chat_service.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/global_comp/app_page_header/app_page_header.dart';
import '/master/service_invite_share/save_story_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminMemeBuilderWidget extends StatefulWidget {
  const AdminMemeBuilderWidget({super.key});

  static String routeName = 'AdminMemeBuilder';
  static String routePath = '/adminMemeBuilder';

  @override
  State<AdminMemeBuilderWidget> createState() => _AdminMemeBuilderWidgetState();
}

class _AdminMemeBuilderWidgetState extends State<AdminMemeBuilderWidget> {
  final _previewKey = GlobalKey();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _cityController = TextEditingController();
  final _priceController = TextEditingController();
  final _contactController = TextEditingController();

  Uint8List? _imageBytes;
  bool _selectingImage = false;
  bool _saving = false;

  List<TextEditingController> get _controllers => [
    _titleController,
    _descriptionController,
    _categoryController,
    _cityController,
    _priceController,
    _contactController,
  ];

  @override
  void initState() {
    super.initState();
    for (final controller in _controllers) {
      controller.addListener(_refreshPreview);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller
        ..removeListener(_refreshPreview)
        ..dispose();
    }
    super.dispose();
  }

  void _refreshPreview() {
    if (mounted) setState(() {});
  }

  Future<void> _chooseImage() async {
    if (_selectingImage) return;
    setState(() => _selectingImage = true);
    try {
      final selected = await selectMediaWithSourceBottomSheet(
        context: context,
        allowPhoto: true,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 92,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        textColor: FlutterFlowTheme.of(context).primaryText,
      );
      final bytes = selected?.firstOrNull?.bytes;
      if (bytes == null || bytes.isEmpty || !mounted) return;
      await precacheImage(MemoryImage(bytes), context);
      setState(() => _imageBytes = bytes);
    } catch (error) {
      if (kDebugMode) print('Admin creative image selection failed: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось открыть изображение')),
        );
      }
    } finally {
      if (mounted) setState(() => _selectingImage = false);
    }
  }

  Future<Uint8List> _renderCreative() async {
    FocusManager.instance.primaryFocus?.unfocus();
    await WidgetsBinding.instance.endOfFrame;
    final boundary =
        _previewKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) throw StateError('Предпросмотр ещё не готов');
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData?.buffer.asUint8List();
    if (bytes == null) throw StateError('Не удалось создать изображение');
    return bytes;
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_imageBytes == null || _titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавьте фотографию и название услуги')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final bytes = await _renderCreative();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await saveStoryImage(bytes, 'sarafan_service_$timestamp.png');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              kIsWeb ? 'Картинка скачана' : 'Картинка сохранена в галерею',
            ),
          ),
        );
      }
    } catch (error) {
      if (kDebugMode) print('Admin creative saving failed: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось сохранить картинку')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    if (!isCurrentSupportAdmin) {
      return Scaffold(
        backgroundColor: theme.primaryBackground,
        body: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: AppPageHeader(
                  title: 'Конструктор мемов',
                  showBack: true,
                  padding: EdgeInsets.zero,
                ),
              ),
              const Expanded(
                child: Center(child: Text('Доступно только администратору')),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: AppPageHeader(
                title: 'Конструктор мемов',
                showBack: true,
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Заполните карточку',
                            style: theme.titleMedium.override(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _selectingImage ? null : _chooseImage,
                            icon: _selectingImage
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.primary,
                                    ),
                                  )
                                : const Icon(Icons.add_photo_alternate_rounded),
                            label: Text(
                              _imageBytes == null
                                  ? 'Загрузить фотографию'
                                  : 'Заменить фотографию',
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _CreativeField(
                            controller: _titleController,
                            label: 'Заголовок',
                            hint: 'Например, Мужская стрижка',
                            maxLength: 60,
                          ),
                          _CreativeField(
                            controller: _descriptionController,
                            label: 'Описание',
                            hint: 'Коротко опишите услугу',
                            maxLength: 150,
                            maxLines: 3,
                          ),
                          _CreativeField(
                            controller: _categoryController,
                            label: 'Категория',
                            hint: 'Например, Красота и здоровье',
                            maxLength: 55,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _CreativeField(
                                  controller: _cityController,
                                  label: 'Город',
                                  hint: 'Краснодар',
                                  maxLength: 45,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _CreativeField(
                                  controller: _priceController,
                                  label: 'Цена',
                                  hint: '2 000',
                                  maxLength: 9,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                              ),
                            ],
                          ),
                          _CreativeField(
                            controller: _contactController,
                            label: 'Кто это в контактах',
                            hint: 'Например, Антон Барбер',
                            maxLength: 55,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Предпросмотр',
                                style: theme.titleMedium.override(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '1080 × 2200',
                                style: theme.bodySmall.override(
                                  color: theme.secondaryText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AspectRatio(
                            aspectRatio: 27 / 55,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: RepaintBoundary(
                                key: _previewKey,
                                child: _ServiceCreative(
                                  imageBytes: _imageBytes,
                                  title: _titleController.text.trim(),
                                  description: _descriptionController.text
                                      .trim(),
                                  category: _categoryController.text.trim(),
                                  city: _cityController.text.trim(),
                                  price: _priceController.text.trim(),
                                  contactName: _contactController.text.trim(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _saving ? null : _save,
                            icon: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.download_rounded),
                            label: Text(
                              _saving ? 'Сохраняем...' : 'Сохранить картинку',
                            ),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(54),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreativeField extends StatelessWidget {
  const _CreativeField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.maxLength,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLength;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}

class _ServiceCreative extends StatelessWidget {
  const _ServiceCreative({
    required this.imageBytes,
    required this.title,
    required this.description,
    required this.category,
    required this.city,
    required this.price,
    required this.contactName,
  });

  final Uint8List? imageBytes;
  final String title;
  final String description;
  final String category;
  final String city;
  final String price;
  final String contactName;

  String get _formattedPrice {
    final value = int.tryParse(price.replaceAll(RegExp(r'\D'), ''));
    return value == null ? 'Цена не указана' : formatPrice(value);
  }

  String get _contactLabel => contactName.isEmpty
      ? 'Мастер есть у вас в контактах'
      : '$contactName есть у вас в контактах';

  double get _contactFontSize {
    if (_contactLabel.length > 68) return 10.5;
    if (_contactLabel.length > 42) return 11.5;
    return 13.5;
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 360,
    height: 2200 / 3,
    child: Material(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 300,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageBytes != null)
                  Image.memory(imageBytes!, fit: BoxFit.cover)
                else
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFF1F5F9),
                          Color(0xFFE8EEFF),
                          Color(0xFFF8FAFC),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_rounded,
                      color: Color(0xFF98A2B3),
                      size: 62,
                    ),
                  ),
                Positioned(
                  left: 16,
                  top: 16,
                  child: _MockHeaderButton(
                    icon: Icons.arrow_back_rounded,
                    foreground: const Color(0xFF101828),
                    background: Colors.white,
                    border: const Color(0xFF98A2B3),
                  ),
                ),
                const Positioned(
                  right: 16,
                  top: 16,
                  child: _MockHeaderButton(
                    icon: Icons.favorite_rounded,
                    foreground: Color(0xFF667085),
                    background: Color(0xFFD0D5DD),
                  ),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CarouselDot(active: true),
                      _CarouselDot(),
                      _CarouselDot(),
                      _CarouselDot(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(19, 16, 19, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty ? 'Название услуги' : title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF101828),
                      fontSize: 25,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    description.isEmpty
                        ? 'Здесь появится описание услуги'
                        : description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF667085),
                      fontSize: 15.5,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.payment_rounded,
                        color: Color(0xFF101828),
                        size: 17,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _formattedPrice,
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFF101828),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.isEmpty ? 'Категория услуги' : category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFF667085),
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    city.isEmpty ? 'Город не указан' : city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFF101828),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    height: 60,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F9F0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFA6E5C1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.contact_phone_rounded,
                          color: Color(0xFF20B96B),
                          size: 21,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            _contactLabel,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.jetBrainsMono(
                              color: const Color(0xFF101828),
                              fontSize: _contactFontSize,
                              height: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Row(
                    children: [
                      Expanded(
                        child: _MetricPreview(
                          color: Color(0xFF2C64E8),
                          icon: Icons.thumb_up_alt_rounded,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _MetricPreview(
                          color: Color(0xFF9A18D1),
                          icon: Icons.people_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 82,
            padding: const EdgeInsets.fromLTRB(24, 13, 24, 13),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE4E7EC))),
            ),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Время ответа',
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFF667085),
                        fontSize: 11.5,
                      ),
                    ),
                    Text(
                      '~15 минут',
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFF27AE60),
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C64E8),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 9),
                        Text(
                          'Написать',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _MockHeaderButton extends StatelessWidget {
  const _MockHeaderButton({
    required this.icon,
    required this.foreground,
    required this.background,
    this.border,
  });

  final IconData icon;
  final Color foreground;
  final Color background;
  final Color? border;

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(12),
      border: border == null ? null : Border.all(color: border!),
    ),
    child: Icon(icon, color: foreground, size: 25),
  );
}

class _CarouselDot extends StatelessWidget {
  const _CarouselDot({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) => Container(
    width: 8,
    height: 8,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    decoration: BoxDecoration(
      color: active ? const Color(0xFF2C64E8) : const Color(0xFF667085),
      shape: BoxShape.circle,
    ),
  );
}

class _MetricPreview extends StatelessWidget {
  const _MetricPreview({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    height: 43,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 7),
        Text(
          '1',
          style: GoogleFonts.jetBrainsMono(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
