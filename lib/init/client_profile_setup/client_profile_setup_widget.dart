import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/global_comp/upload_media/upload_media_widget.dart';
import '/index.dart';
import '/init/contacts_onboarding/contacts_onboarding_widget.dart';

class ClientProfileSetupWidget extends StatefulWidget {
  const ClientProfileSetupWidget({super.key});

  static const routeName = 'ClientProfileSetup';
  static const routePath = '/clientProfileSetup';

  @override
  State<ClientProfileSetupWidget> createState() =>
      _ClientProfileSetupWidgetState();
}

class _ClientProfileSetupWidgetState extends State<ClientProfileSetupWidget> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  Uint8List? _avatarBytes;
  bool _saving = false;

  Future<void> _chooseAvatar() async {
    final picked = await showModalBottomSheet<FFUploadedFile>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: MediaQuery.viewInsetsOf(context),
        child: const UploadMediaWidget(maxOutputSize: 640),
      ),
    );
    if (picked?.bytes != null && picked!.bytes!.isNotEmpty && mounted) {
      setState(() => _avatarBytes = picked.bytes);
    }
  }

  InputDecoration _fieldDecoration(
    FlutterFlowTheme theme, {
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.inter(color: theme.secondaryText),
      hintStyle: GoogleFonts.inter(color: theme.hint),
      filled: true,
      fillColor: theme.secondaryBackground,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primary, width: 2),
      ),
    );
  }

  Future<void> _finish({bool skip = false}) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      String? photoUrl;
      if (!skip && _avatarBytes != null && currentUserReference != null) {
        final ref = FirebaseStorage.instance.ref(
          'users/$currentUserUid/profile/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await ref.putData(
          _avatarBytes!,
          SettableMetadata(
            contentType: 'image/jpeg',
            cacheControl: 'public,max-age=31536000,immutable',
          ),
        );
        photoUrl = await ref.getDownloadURL();
      }

      if (!skip && currentUserReference != null) {
        final name = normalizeUserText(_nameController.text);
        final bio = normalizeUserText(_bioController.text);
        await currentUserReference!.update(
          createUserRecordData(
            displayName: name.isEmpty ? null : name,
            bio: bio.isEmpty ? null : bio,
            photoUrl: photoUrl,
            masterMode: false,
            clientProfileCompleted: true,
          ),
        );
      } else if (currentUserReference != null) {
        await currentUserReference!.update(
          createUserRecordData(masterMode: false, clientProfileCompleted: true),
        );
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ContactsOnboardingWidget(),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: theme.primary,
            selectionColor: theme.primary.withValues(alpha: 0.25),
            selectionHandleColor: theme.primary,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _saving ? null : () => _finish(skip: true),
                    child: const Text('Пропустить'),
                  ),
                ),
                Text(
                  'Расскажите о себе',
                  style: theme.headlineMedium.copyWith(
                    color: theme.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Эти данные помогут специалистам узнать вас.',
                  style: theme.bodyMedium.copyWith(color: theme.secondaryText),
                ),
                const SizedBox(height: 28),
                Center(
                  child: InkWell(
                    onTap: _saving ? null : _chooseAvatar,
                    borderRadius: BorderRadius.circular(64),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 58,
                          backgroundColor: theme.secondaryBackground,
                          backgroundImage: _avatarBytes == null
                              ? null
                              : MemoryImage(_avatarBytes!),
                          child: _avatarBytes == null
                              ? Icon(
                                  Icons.person_rounded,
                                  size: 54,
                                  color: theme.secondaryText,
                                )
                              : null,
                        ),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: theme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.primaryBackground,
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 19,
                            color: theme.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  cursorColor: theme.primary,
                  style: GoogleFonts.inter(
                    color: theme.primaryText,
                    fontSize: 16,
                  ),
                  decoration: _fieldDecoration(
                    theme,
                    label: 'Имя',
                    hint: 'Как к вам обращаться',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bioController,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 3,
                  maxLines: null,
                  maxLength: 200,
                  cursorColor: theme.primary,
                  style: GoogleFonts.inter(
                    color: theme.primaryText,
                    fontSize: 16,
                  ),
                  decoration: _fieldDecoration(
                    theme,
                    label: 'О себе',
                    hint: 'Несколько слов о себе',
                  ),
                ),
                const SizedBox(height: 28),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 54),
                  child: FilledButton(
                    onPressed: _saving ? null : _finish,
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.primary,
                      foregroundColor: theme.info,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Продолжить'),
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
