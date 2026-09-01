import 'package:cloud_firestore/cloud_firestore.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';

Future<void> syncCurrentUserChatProfile({
  String? chatId,
  String? displayName,
  String? photoUrl,
  String? masterName,
  String? masterPhoto,
}) async {
  final userRef = currentUserReference;
  final user = currentUserDocument;
  if (userRef == null || user == null) return;

  try {
    final updatedDisplayName = displayName?.trim() ?? '';
    final updatedPhotoUrl = photoUrl?.trim() ?? '';
    final updatedMasterName = masterName?.trim() ?? '';
    final updatedMasterPhoto = masterPhoto?.trim() ?? '';

    final clientName = updatedDisplayName.isNotEmpty
        ? updatedDisplayName
        : user.displayName.trim().isNotEmpty
        ? user.displayName.trim()
        : user.phoneNumber.trim();
    final clientPhoto = photoUrl != null
        ? updatedPhotoUrl
        : user.photoUrl.trim();
    final resolvedMasterName = updatedMasterName.isNotEmpty
        ? updatedMasterName
        : user.masterData.title.trim().isNotEmpty
        ? user.masterData.title.trim()
        : clientName;
    final resolvedMasterPhoto = masterPhoto != null
        ? updatedMasterPhoto
        : user.masterData.mainPhoto.trim().isNotEmpty
        ? user.masterData.mainPhoto.trim()
        : clientPhoto;

    final chats = chatId != null
        ? [
            await FirebaseFirestore.instance
                .collection('chats')
                .doc(chatId)
                .get(),
          ]
        : (await FirebaseFirestore.instance
                  .collection('chats')
                  .where('participantIds', arrayContains: userRef.id)
                  .get())
              .docs;

    final batch = FirebaseFirestore.instance.batch();
    var hasUpdates = false;

    for (final chat in chats) {
      final data = chat.data();
      if (data == null) continue;

      final updates = <String, dynamic>{};
      if (data['client'] == userRef) {
        if (data['clientName'] != clientName) {
          updates['clientName'] = clientName;
        }
        if (data['clientPhoto'] != clientPhoto) {
          updates['clientPhoto'] = clientPhoto;
        }
        if (data['clientPhone'] != user.phoneNumber) {
          updates['clientPhone'] = user.phoneNumber;
        }
      }
      if (data['master'] == userRef && data['context'] != 'support') {
        if (data['masterName'] != resolvedMasterName) {
          updates['masterName'] = resolvedMasterName;
        }
        if (data['masterPhoto'] != resolvedMasterPhoto) {
          updates['masterPhoto'] = resolvedMasterPhoto;
        }
        if (data['masterPhone'] != user.phoneNumber) {
          updates['masterPhone'] = user.phoneNumber;
        }
      }

      if (updates.isNotEmpty) {
        batch.update(chat.reference, updates);
        hasUpdates = true;
      }
    }

    if (hasUpdates) await batch.commit();
  } catch (_) {
    // A chat may disappear while synchronization is running.
  }
}
