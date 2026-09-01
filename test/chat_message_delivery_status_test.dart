import 'package:flutter_test/flutter_test.dart';
import 'package:trusty/global_comp/chat_message_status_indicator/chat_message_status_indicator.dart';

void main() {
  test('resolves sent, delivered and read in priority order', () {
    expect(
      resolveChatMessageDeliveryStatus(delivered: false, read: false),
      ChatMessageDeliveryStatus.sent,
    );
    expect(
      resolveChatMessageDeliveryStatus(delivered: true, read: false),
      ChatMessageDeliveryStatus.delivered,
    );
    expect(
      resolveChatMessageDeliveryStatus(delivered: true, read: true),
      ChatMessageDeliveryStatus.read,
    );
  });
}
