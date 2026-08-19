import 'package:collection/collection.dart';

enum Menu {
  main,
  profile,
  favorite,
  cabinet,
  chats,
  search,
  dashboard,
  myService,
  masterChats,
  records,
}

enum ServiceStatus { onModerate, show, arhive, denied }

enum RecordStatus { newRec, confirmed, denied, complite }

extension FFEnumExtensions<T extends Enum> on T {
  String serialize() => name;
}

extension FFEnumListExtensions<T extends Enum> on Iterable<T> {
  T? deserialize(String? value) =>
      firstWhereOrNull((e) => e.serialize() == value);
}

T? deserializeEnum<T>(String? value) {
  switch (T) {
    case (Menu):
      return Menu.values.deserialize(value) as T?;
    case (ServiceStatus):
      return ServiceStatus.values.deserialize(value) as T?;
    case (RecordStatus):
      return RecordStatus.values.deserialize(value) as T?;
    default:
      return null;
  }
}
