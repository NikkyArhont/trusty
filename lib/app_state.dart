import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/api_requests/api_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csv/csv.dart';
import 'package:synchronized/synchronized.dart';
import 'flutter_flow/flutter_flow_util.dart';

List<CategoriesStruct> _buildPresetCategories() => [
  createCategoriesStruct(key: 'health', titleRU: 'Здоровье'),
  createCategoriesStruct(key: 'beauty', titleRU: 'Красота'),
  createCategoriesStruct(key: 'animals', titleRU: 'Животные'),
  createCategoriesStruct(key: 'build', titleRU: 'Строительство'),
  createCategoriesStruct(key: 'repair', titleRU: 'Ремонт'),
  createCategoriesStruct(key: 'home', titleRU: 'Дом и быт'),
  createCategoriesStruct(key: 'auto', titleRU: 'Авто'),
  createCategoriesStruct(key: 'education', titleRU: 'Обучение'),
  createCategoriesStruct(key: 'it_digital', titleRU: 'IT и цифровые услуги'),
  createCategoriesStruct(key: 'photo_video', titleRU: 'Фото и видео'),
  createCategoriesStruct(key: 'legal', titleRU: 'Юридические услуги'),
  createCategoriesStruct(
    key: 'accounting_finance',
    titleRU: 'Бухгалтерия и финансы',
  ),
  createCategoriesStruct(key: 'events', titleRU: 'Мероприятия'),
  createCategoriesStruct(key: 'sport_fitness', titleRU: 'Спорт и фитнес'),
  createCategoriesStruct(key: 'psychology', titleRU: 'Психология'),
  createCategoriesStruct(
    key: 'moving_transport',
    titleRU: 'Переезды и перевозки',
  ),
  createCategoriesStruct(key: 'garden', titleRU: 'Сад и участок'),
  createCategoriesStruct(key: 'business', titleRU: 'Бизнес-услуги'),
];

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    secureStorage = FlutterSecureStorage();
    await _safeInitAsync(() async {
      _firstTime = await secureStorage.getBool('ff_firstTime') ?? _firstTime;
    });
    await _safeInitAsync(() async {
      _specialistMode =
          await secureStorage.getBool('ff_specialistMode') ?? _specialistMode;
    });
    await _safeInitAsync(() async {
      _presetCategory = _buildPresetCategories();
      await secureStorage.setStringList(
        'ff_presetCategory',
        _presetCategory.map((category) => category.serialize()).toList(),
      );
    });
    await _safeInitAsync(() async {
      if (await secureStorage.read(key: 'ff_globalFilter') != null) {
        try {
          final serializedData =
              await secureStorage.getString('ff_globalFilter') ?? '{}';
          _globalFilter = GlobalFilterStruct.fromSerializableMap(
            jsonDecode(serializedData),
          );
        } catch (e) {
          print("Can't decode persisted data type. Error: $e.");
        }
      }
    });
    await _safeInitAsync(() async {
      _geo = await secureStorage.getString('ff_geo') ?? _geo;
    });
    await _safeInitAsync(() async {
      _listRUCities =
          (await secureStorage.getStringList('ff_listRUCities'))
              ?.map((x) {
                try {
                  return PlaceStruct.fromSerializableMap(jsonDecode(x));
                } catch (e) {
                  print("Can't decode persisted data type. Error: $e.");
                  return null;
                }
              })
              .withoutNulls
              .toList() ??
          _listRUCities;
    });
    await _safeInitAsync(() async {
      _listCityVocab =
          await secureStorage.getString('ff_listCityVocab') ?? _listCityVocab;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late FlutterSecureStorage secureStorage;

  bool _firstTime = true;
  bool get firstTime => _firstTime;
  set firstTime(bool value) {
    _firstTime = value;
    secureStorage.setBool('ff_firstTime', value);
  }

  void deleteFirstTime() {
    secureStorage.delete(key: 'ff_firstTime');
  }

  bool _specialistMode = false;
  bool get specialistMode => _specialistMode;
  set specialistMode(bool value) {
    _specialistMode = value;
    secureStorage.setBool('ff_specialistMode', value);
  }

  void deleteSpecialistMode() {
    secureStorage.delete(key: 'ff_specialistMode');
  }

  List<CategoriesStruct> _presetCategory = _buildPresetCategories();
  List<CategoriesStruct> get presetCategory => _presetCategory;
  set presetCategory(List<CategoriesStruct> value) {
    _presetCategory = value;
    secureStorage.setStringList(
      'ff_presetCategory',
      value.map((x) => x.serialize()).toList(),
    );
  }

  void deletePresetCategory() {
    secureStorage.delete(key: 'ff_presetCategory');
  }

  void addToPresetCategory(CategoriesStruct value) {
    presetCategory.add(value);
    secureStorage.setStringList(
      'ff_presetCategory',
      _presetCategory.map((x) => x.serialize()).toList(),
    );
  }

  void removeFromPresetCategory(CategoriesStruct value) {
    presetCategory.remove(value);
    secureStorage.setStringList(
      'ff_presetCategory',
      _presetCategory.map((x) => x.serialize()).toList(),
    );
  }

  void removeAtIndexFromPresetCategory(int index) {
    presetCategory.removeAt(index);
    secureStorage.setStringList(
      'ff_presetCategory',
      _presetCategory.map((x) => x.serialize()).toList(),
    );
  }

  void updatePresetCategoryAtIndex(
    int index,
    CategoriesStruct Function(CategoriesStruct) updateFn,
  ) {
    presetCategory[index] = updateFn(_presetCategory[index]);
    secureStorage.setStringList(
      'ff_presetCategory',
      _presetCategory.map((x) => x.serialize()).toList(),
    );
  }

  void insertAtIndexInPresetCategory(int index, CategoriesStruct value) {
    presetCategory.insert(index, value);
    secureStorage.setStringList(
      'ff_presetCategory',
      _presetCategory.map((x) => x.serialize()).toList(),
    );
  }

  GlobalFilterStruct _globalFilter = GlobalFilterStruct();
  GlobalFilterStruct get globalFilter => _globalFilter;
  set globalFilter(GlobalFilterStruct value) {
    _globalFilter = value;
    secureStorage.setString('ff_globalFilter', value.serialize());
  }

  void deleteGlobalFilter() {
    secureStorage.delete(key: 'ff_globalFilter');
  }

  void updateGlobalFilterStruct(Function(GlobalFilterStruct) updateFn) {
    updateFn(_globalFilter);
    secureStorage.setString('ff_globalFilter', _globalFilter.serialize());
  }

  PlaceStruct? _tempServiceAddress;
  PlaceStruct? get tempServiceAddress => _tempServiceAddress;
  set tempServiceAddress(PlaceStruct? value) {
    _tempServiceAddress = value;
  }

  void updateTempServiceAddressStruct(Function(PlaceStruct) updateFn) {
    updateFn(_tempServiceAddress ??= PlaceStruct());
  }

  List<String> _previosSearch = [];
  List<String> get previosSearch => _previosSearch;
  set previosSearch(List<String> value) {
    _previosSearch = value;
  }

  void addToPreviosSearch(String value) {
    previosSearch.add(value);
  }

  void removeFromPreviosSearch(String value) {
    previosSearch.remove(value);
  }

  void removeAtIndexFromPreviosSearch(int index) {
    previosSearch.removeAt(index);
  }

  void updatePreviosSearchAtIndex(int index, String Function(String) updateFn) {
    previosSearch[index] = updateFn(_previosSearch[index]);
  }

  void insertAtIndexInPreviosSearch(int index, String value) {
    previosSearch.insert(index, value);
  }

  String _geo = 'AIzaSyDT7xqBZZ0vakT3CGNYrQoRijsLsbW6nTU';
  String get geo => _geo;
  set geo(String value) {
    _geo = value;
    secureStorage.setString('ff_geo', value);
  }

  void deleteGeo() {
    secureStorage.delete(key: 'ff_geo');
  }

  List<PlaceStruct> _listRUCities = [];
  List<PlaceStruct> get listRUCities => _listRUCities;
  set listRUCities(List<PlaceStruct> value) {
    _listRUCities = value;
    secureStorage.setStringList(
      'ff_listRUCities',
      value.map((x) => x.serialize()).toList(),
    );
  }

  void deleteListRUCities() {
    secureStorage.delete(key: 'ff_listRUCities');
  }

  void addToListRUCities(PlaceStruct value) {
    listRUCities.add(value);
    secureStorage.setStringList(
      'ff_listRUCities',
      _listRUCities.map((x) => x.serialize()).toList(),
    );
  }

  void removeFromListRUCities(PlaceStruct value) {
    listRUCities.remove(value);
    secureStorage.setStringList(
      'ff_listRUCities',
      _listRUCities.map((x) => x.serialize()).toList(),
    );
  }

  void removeAtIndexFromListRUCities(int index) {
    listRUCities.removeAt(index);
    secureStorage.setStringList(
      'ff_listRUCities',
      _listRUCities.map((x) => x.serialize()).toList(),
    );
  }

  void updateListRUCitiesAtIndex(
    int index,
    PlaceStruct Function(PlaceStruct) updateFn,
  ) {
    listRUCities[index] = updateFn(_listRUCities[index]);
    secureStorage.setStringList(
      'ff_listRUCities',
      _listRUCities.map((x) => x.serialize()).toList(),
    );
  }

  void insertAtIndexInListRUCities(int index, PlaceStruct value) {
    listRUCities.insert(index, value);
    secureStorage.setStringList(
      'ff_listRUCities',
      _listRUCities.map((x) => x.serialize()).toList(),
    );
  }

  String _listCityVocab =
      '[{\"coords\":{\"lat\":\"53.71667\",\"lon\":\"91.41667\"},\"district\":\"Сибирский\",\"name\":\"Абакан\",\"population\":184769,\"subject\":\"Хакасия\"},{\"coords\":{\"lat\":\"47.1\",\"lon\":\"39.41667\"},\"district\":\"Южный\",\"name\":\"Азов\",\"population\":81924,\"subject\":\"Ростовская область\"},{\"coords\":{\"lat\":\"47.26667\",\"lon\":\"39.86667\"},\"district\":\"Южный\",\"name\":\"Аксай\",\"population\":48372,\"subject\":\"Ростовская область\"},{\"coords\":{\"lat\":\"56.39361\",\"lon\":\"38.715\"},\"district\":\"Центральный\",\"name\":\"Александров\",\"population\":57053,\"subject\":\"Владимирская область\"},{\"coords\":{\"lat\":\"54.5\",\"lon\":\"37.06667\"},\"district\":\"Центральный\",\"name\":\"Алексин\",\"population\":60842,\"subject\":\"Тульская область\"},{\"coords\":{\"lat\":\"54.9\",\"lon\":\"52.3\"},\"district\":\"Приволжский\",\"name\":\"Альметьевск\",\"population\":163512,\"subject\":\"Татарстан\"},{\"coords\":{\"lat\":\"44.893857\",\"lon\":\"37.317481\"},\"district\":\"Южный\",\"name\":\"Анапа\",\"population\":81863,\"subject\":\"Краснодарский край\"},{\"coords\":{\"lat\":\"52.56667\",\"lon\":\"103.91667\"},\"district\":\"Сибирский\",\"name\":\"Ангарск\",\"population\":221296,\"subject\":\"Иркутская область\"},{\"coords\":{\"lat\":\"56.08333\",\"lon\":\"86.03333\"},\"district\":\"Сибирский\",\"name\":\"Анжеро-Судженск\",\"population\":66583,\"subject\":\"Кемеровская область\"},{\"coords\":{\"lat\":\"67.5675\",\"lon\":\"33.39333\"},\"district\":\"Северо-Западный\",\"name\":\"Апатиты\",\"population\":49647,\"subject\":\"Мурманская область\"},{\"coords\":{\"lat\":\"44.46083\",\"lon\":\"39.74056\"},\"district\":\"Южный\",\"name\":\"Апшеронск\",\"population\":40289,\"subject\":\"Краснодарский край\"},{\"coords\":{\"lat\":\"43.292095\",\"lon\":\"45.876622\"},\"district\":\"Северо-Кавказский\",\"name\":\"Аргун\",\"population\":41622,\"subject\":\"Чечня\"},{\"coords\":{\"lat\":\"55.38333\",\"lon\":\"43.8\"},\"district\":\"Приволжский\",\"name\":\"Арзамас\",\"population\":104908,\"subject\":\"Нижегородская область\"},{\"coords\":{\"lat\":\"44.99464\",\"lon\":\"41.12946\"},\"district\":\"Южный\",\"name\":\"Армавир\",\"population\":187177,\"subject\":\"Краснодарский край\"},{\"coords\":{\"lat\":\"44.16667\",\"lon\":\"133.26667\"},\"district\":\"Дальневосточный\",\"name\":\"Арсеньев\",\"population\":47937,\"subject\":\"Приморский край\"},{\"coords\":{\"lat\":\"43.35\",\"lon\":\"132.18333\"},\"district\":\"Дальневосточный\",\"name\":\"Артём\",\"population\":109556,\"subject\":\"Приморский край\"},{\"coords\":{\"lat\":\"64.55\",\"lon\":\"40.53333\"},\"district\":\"Северо-Западный\",\"name\":\"Архангельск\",\"population\":301199,\"subject\":\"Архангельская область\"},{\"coords\":{\"lat\":\"57.01027679\",\"lon\":\"61.45639038\"},\"district\":\"Уральский\",\"name\":\"Асбест\",\"population\":57317,\"subject\":\"Свердловская область\"},{\"coords\":{\"lat\":\"46.33333\",\"lon\":\"48.03333\"},\"district\":\"Южный\",\"name\":\"Астрахань\",\"population\":475629,\"subject\":\"Астраханская область\"},{\"coords\":{\"lat\":\"56.26667\",\"lon\":\"90.5\"},\"district\":\"Сибирский\",\"name\":\"Ачинск\",\"population\":100621,\"subject\":\"Красноярский край\"},{\"coords\":{\"lat\":\"52.03333\",\"lon\":\"47.78333\"},\"district\":\"Приволжский\",\"name\":\"Балаково\",\"population\":184466,\"subject\":\"Саратовская область\"},{\"coords\":{\"lat\":\"56.48083\",\"lon\":\"43.54028\"},\"district\":\"Приволжский\",\"name\":\"Балахна\",\"population\":48569,\"subject\":\"Нижегородская область\"},{\"coords\":{\"lat\":\"55.8\",\"lon\":\"37.93333\"},\"district\":\"Центральный\",\"name\":\"Балашиха\",\"population\":520962,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"51.55\",\"lon\":\"43.16667\"},\"district\":\"Приволжский\",\"name\":\"Балашов\",\"population\":74057,\"subject\":\"Саратовская область\"},{\"coords\":{\"lat\":\"53.347361\",\"lon\":\"83.77833\"},\"district\":\"Сибирский\",\"name\":\"Барнаул\",\"population\":630877,\"subject\":\"Алтайский край\"},{\"coords\":{\"lat\":\"47.13333\",\"lon\":\"39.75\"},\"district\":\"Южный\",\"name\":\"Батайск\",\"population\":126988,\"subject\":\"Ростовская область\"},{\"coords\":{\"lat\":\"48.17472\",\"lon\":\"40.79306\"},\"district\":\"Южный\",\"name\":\"Белая Калитва\",\"population\":40448,\"subject\":\"Ростовская область\"},{\"coords\":{\"lat\":\"50.6\",\"lon\":\"36.6\"},\"district\":\"Центральный\",\"name\":\"Белгород\",\"population\":339978,\"subject\":\"Белгородская область\"},{\"coords\":{\"lat\":\"54.1\",\"lon\":\"54.13333\"},\"district\":\"Приволжский\",\"name\":\"Белебей\",\"population\":59195,\"subject\":\"Башкортостан\"},{\"coords\":{\"lat\":\"54.416666666667\",\"lon\":\"86.3\"},\"district\":\"Сибирский\",\"name\":\"Белово\",\"population\":68542,\"subject\":\"Кемеровская область\"},{\"coords\":{\"lat\":\"50.91667\",\"lon\":\"128.48333\"},\"district\":\"Дальневосточный\",\"name\":\"Белогорск\",\"population\":61440,\"subject\":\"Амурская область\"},{\"coords\":{\"lat\":\"53.96667\",\"lon\":\"58.4\"},\"district\":\"Приволжский\",\"name\":\"Белорецк\",\"population\":64525,\"subject\":\"Башкортостан\"},{\"coords\":{\"lat\":\"44.76667\",\"lon\":\"39.86667\"},\"district\":\"Южный\",\"name\":\"Белореченск\",\"population\":55870,\"subject\":\"Краснодарский край\"},{\"coords\":{\"lat\":\"54.75\",\"lon\":\"83.1\"},\"district\":\"Сибирский\",\"name\":\"Бердск\",\"population\":102850,\"subject\":\"Новосибирская область\"},{\"coords\":{\"lat\":\"59.40806\",\"lon\":\"56.80528\"},\"district\":\"Приволжский\",\"name\":\"Березники\",\"population\":138069,\"subject\":\"Пермский край\"},{\"coords\":{\"lat\":\"55.66667\",\"lon\":\"86.25\"},\"district\":\"Сибирский\",\"name\":\"Берёзовский\",\"population\":44932,\"subject\":\"Кемеровская область\"},{\"coords\":{\"lat\":\"56.9\",\"lon\":\"60.8\"},\"district\":\"Уральский\",\"name\":\"Берёзовский\",\"population\":59698,\"subject\":\"Свердловская область\"},{\"coords\":{\"lat\":\"52.51667\",\"lon\":\"85.16667\"},\"district\":\"Сибирский\",\"name\":\"Бийск\",\"population\":183852,\"subject\":\"Алтайский край\"},{\"coords\":{\"lat\":\"48.78333\",\"lon\":\"132.93333\"},\"district\":\"Дальневосточный\",\"name\":\"Биробиджан\",\"population\":70064,\"subject\":\"Еврейская АО\"},{\"coords\":{\"lat\":\"55.41667\",\"lon\":\"55.53333\"},\"district\":\"Приволжский\",\"name\":\"Бирск\",\"population\":44295,\"subject\":\"Башкортостан\"},{\"coords\":{\"lat\":\"50.25778\",\"lon\":\"127.53639\"},\"district\":\"Дальневосточный\",\"name\":\"Благовещенск\",\"population\":241437,\"subject\":\"Амурская область\"},{\"coords\":{\"lat\":\"43.11667\",\"lon\":\"132.35\"},\"district\":\"Дальневосточный\",\"name\":\"Большой Камень\",\"population\":41825,\"subject\":\"Приморский край\"},{\"coords\":{\"lat\":\"56.36028\",\"lon\":\"44.05917\"},\"district\":\"Приволжский\",\"name\":\"Бор\",\"population\":78372,\"subject\":\"Нижегородская область\"},{\"coords\":{\"lat\":\"51.36667\",\"lon\":\"42.08333\"},\"district\":\"Центральный\",\"name\":\"Борисоглебск\",\"population\":60687,\"subject\":\"Воронежская область\"},{\"coords\":{\"lat\":\"58.38694\",\"lon\":\"33.91139\"},\"district\":\"Северо-Западный\",\"name\":\"Боровичи\",\"population\":47883,\"subject\":\"Новгородская область\"},{\"coords\":{\"lat\":\"56.152\",\"lon\":\"101.633\"},\"district\":\"Сибирский\",\"name\":\"Братск\",\"population\":224071,\"subject\":\"Иркутская область\"},{\"coords\":{\"lat\":\"53.25\",\"lon\":\"34.36667\"},\"district\":\"Центральный\",\"name\":\"Брянск\",\"population\":379152,\"subject\":\"Брянская область\"},{\"coords\":{\"lat\":\"54.53333\",\"lon\":\"52.78333\"},\"district\":\"Приволжский\",\"name\":\"Бугульма\",\"population\":81677,\"subject\":\"Татарстан\"},{\"coords\":{\"lat\":\"53.61667\",\"lon\":\"52.41667\"},\"district\":\"Приволжский\",\"name\":\"Бугуруслан\",\"population\":43593,\"subject\":\"Оренбургская область\"},{\"coords\":{\"lat\":\"44.79\",\"lon\":\"44.14\"},\"district\":\"Северо-Кавказский\",\"name\":\"Будённовск\",\"population\":58103,\"subject\":\"Ставропольский край\"},{\"coords\":{\"lat\":\"52.76667\",\"lon\":\"52.26667\"},\"district\":\"Приволжский\",\"name\":\"Бузулук\",\"population\":88341,\"subject\":\"Оренбургская область\"},{\"coords\":{\"lat\":\"42.81667\",\"lon\":\"47.11667\"},\"district\":\"Северо-Кавказский\",\"name\":\"Буйнакск\",\"population\":68121,\"subject\":\"Дагестан\"},{\"coords\":{\"lat\":\"56.35\",\"lon\":\"30.51667\"},\"district\":\"Северо-Западный\",\"name\":\"Великие Луки\",\"population\":86711,\"subject\":\"Псковская область\"},{\"coords\":{\"lat\":\"58.525\",\"lon\":\"31.275\"},\"district\":\"Северо-Западный\",\"name\":\"Великий Новгород\",\"population\":224286,\"subject\":\"Новгородская область\"},{\"coords\":{\"lat\":\"56.966666666667\",\"lon\":\"60.583333333333\"},\"district\":\"Уральский\",\"name\":\"Верхняя Пышма\",\"population\":71335,\"subject\":\"Свердловская область\"},{\"coords\":{\"lat\":\"58.05\",\"lon\":\"60.55\"},\"district\":\"Уральский\",\"name\":\"Верхняя Салда\",\"population\":41034,\"subject\":\"Свердловская область\"},{\"coords\":{\"lat\":\"55.55\",\"lon\":\"37.7\"},\"district\":\"Центральный\",\"name\":\"Видное\",\"population\":101490,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"43.116666666667\",\"lon\":\"131.9\"},\"district\":\"Дальневосточный\",\"name\":\"Владивосток\",\"population\":603519,\"subject\":\"Приморский край\"},{\"coords\":{\"lat\":\"43.01667\",\"lon\":\"44.683315\"},\"district\":\"Северо-Кавказский\",\"name\":\"Владикавказ\",\"population\":295830,\"subject\":\"Северная Осетия\"},{\"coords\":{\"lat\":\"56.13333\",\"lon\":\"40.41667\"},\"district\":\"Центральный\",\"name\":\"Владимир\",\"population\":349951,\"subject\":\"Владимирская область\"},{\"coords\":{\"lat\":\"48.71167\",\"lon\":\"44.51389\"},\"district\":\"Южный\",\"name\":\"Волгоград\",\"population\":1028036,\"subject\":\"Волгоградская область\"},{\"coords\":{\"lat\":\"47.54\",\"lon\":\"42.20722\"},\"district\":\"Южный\",\"name\":\"Волгодонск\",\"population\":168048,\"subject\":\"Ростовская область\"},{\"coords\":{\"lat\":\"55.86667\",\"lon\":\"48.35\"},\"district\":\"Приволжский\",\"name\":\"Волжск\",\"population\":53013,\"subject\":\"Марий Эл\"},{\"coords\":{\"lat\":\"48.783333333333\",\"lon\":\"44.766666666667\"},\"district\":\"Южный\",\"name\":\"Волжский\",\"population\":321479,\"subject\":\"Волгоградская область\"},{\"coords\":{\"lat\":\"59.216666666667\",\"lon\":\"39.9\"},\"district\":\"Северо-Западный\",\"name\":\"Вологда\",\"population\":313944,\"subject\":\"Вологодская область\"},{\"coords\":{\"lat\":\"52.05\",\"lon\":\"47.38333\"},\"district\":\"Приволжский\",\"name\":\"Вольск\",\"population\":55035,\"subject\":\"Саратовская область\"},{\"coords\":{\"lat\":\"67.5\",\"lon\":\"64.03333\"},\"district\":\"Северо-Западный\",\"name\":\"Воркута\",\"population\":56985,\"subject\":\"Коми\"},{\"coords\":{\"lat\":\"51.67167\",\"lon\":\"39.21056\"},\"district\":\"Центральный\",\"name\":\"Воронеж\",\"population\":1057681,\"subject\":\"Воронежская область\"},{\"coords\":{\"lat\":\"55.32333\",\"lon\":\"38.68056\"},\"district\":\"Центральный\",\"name\":\"Воскресенск\",\"population\":95495,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"57.05\",\"lon\":\"54\"},\"district\":\"Приволжский\",\"name\":\"Воткинск\",\"population\":97471,\"subject\":\"Удмуртия\"},{\"coords\":{\"lat\":\"60.021321\",\"lon\":\"30.654084\"},\"district\":\"Северо-Западный\",\"name\":\"Всеволожск\",\"population\":79038,\"subject\":\"Ленинградская область\"},{\"coords\":{\"lat\":\"60.710496\",\"lon\":\"28.749781\"},\"district\":\"Северо-Западный\",\"name\":\"Выборг\",\"population\":72530,\"subject\":\"Ленинградская область\"},{\"coords\":{\"lat\":\"55.31944\",\"lon\":\"42.17306\"},\"district\":\"Приволжский\",\"name\":\"Выкса\",\"population\":45240,\"subject\":\"Нижегородская область\"},{\"coords\":{\"lat\":\"57.58333\",\"lon\":\"34.56667\"},\"district\":\"Центральный\",\"name\":\"Вышний Волочёк\",\"population\":45830,\"subject\":\"Тверская область\"},{\"coords\":{\"lat\":\"55.21028\",\"lon\":\"34.285\"},\"district\":\"Центральный\",\"name\":\"Вязьма\",\"population\":51950,\"subject\":\"Смоленская область\"},{\"coords\":{\"lat\":\"59.56841\",\"lon\":\"30.122892\"},\"district\":\"Северо-Западный\",\"name\":\"Гатчина\",\"population\":94377,\"subject\":\"Ленинградская область\"},{\"coords\":{\"lat\":\"44.560999\",\"lon\":\"38.076949\"},\"district\":\"Южный\",\"name\":\"Геленджик\",\"population\":80204,\"subject\":\"Краснодарский край\"},{\"coords\":{\"lat\":\"44.15\",\"lon\":\"43.46667\"},\"district\":\"Северо-Кавказский\",\"name\":\"Георгиевск\",\"population\":63221,\"subject\":\"Ставропольский край\"},{\"coords\":{\"lat\":\"58.14083\",\"lon\":\"52.67417\"},\"district\":\"Приволжский\",\"name\":\"Глазов\",\"population\":87762,\"subject\":\"Удмуртия\"},{\"coords\":{\"lat\":\"51.96\",\"lon\":\"85.96\"},\"district\":\"Сибирский\",\"name\":\"Горно-Алтайск\",\"population\":65342,\"subject\":\"Алтай\"},{\"coords\":{\"lat\":\"44.633284\",\"lon\":\"39.133287\"},\"district\":\"Южный\",\"name\":\"Горячий Ключ\",\"population\":40903,\"subject\":\"Краснодарский край\"},{\"coords\":{\"lat\":\"43.31667\",\"lon\":\"45.7\"},\"district\":\"Северо-Кавказский\",\"name\":\"Грозный\",\"population\":328533,\"subject\":\"Чечня\"},{\"coords\":{\"lat\":\"52.5\",\"lon\":\"39.93333\"},\"district\":\"Центральный\",\"name\":\"Грязи\",\"population\":43908,\"subject\":\"Липецкая область\"},{\"coords\":{\"lat\":\"51.28333\",\"lon\":\"37.55\"},\"district\":\"Центральный\",\"name\":\"Губкин\",\"population\":85225,\"subject\":\"Белгородская область\"},{\"coords\":{\"lat\":\"43.34861\",\"lon\":\"46.09611\"},\"district\":\"Северо-Кавказский\",\"name\":\"Гудермес\",\"population\":64376,\"subject\":\"Чечня\"},{\"coords\":{\"lat\":\"48.05\",\"lon\":\"39.93333\"},\"district\":\"Южный\",\"name\":\"Гуково\",\"population\":60361,\"subject\":\"Ростовская область\"},{\"coords\":{\"lat\":\"55.61667\",\"lon\":\"40.65\"},\"district\":\"Центральный\",\"name\":\"Гусь-Хрустальный\",\"population\":51552,\"subject\":\"Владимирская область\"},{\"coords\":{\"lat\":\"42.069825\",\"lon\":\"48.295025\"},\"district\":\"Северо-Кавказский\",\"name\":\"Дербент\",\"population\":124953,\"subject\":\"Дагестан\"},{\"coords\":{\"lat\":\"56.23333\",\"lon\":\"43.45\"},\"district\":\"Приволжский\",\"name\":\"Дзержинск\",\"population\":218630,\"subject\":\"Нижегородская область\"},{\"coords\":{\"lat\":\"55.63333\",\"lon\":\"37.85\"},\"district\":\"Центральный\",\"name\":\"Дзержинский\",\"population\":57918,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"54.23333\",\"lon\":\"49.58333\"},\"district\":\"Приволжский\",\"name\":\"Димитровград\",\"population\":110968,\"subject\":\"Ульяновская область\"},{\"coords\":{\"lat\":\"56.34667\",\"lon\":\"37.52167\"},\"district\":\"Центральный\",\"name\":\"Дмитров\",\"population\":65574,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"55.93333\",\"lon\":\"37.5\"},\"district\":\"Центральный\",\"name\":\"Долгопрудный\",\"population\":120907,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"55.44389\",\"lon\":\"37.75806\"},\"district\":\"Центральный\",\"name\":\"Домодедово\",\"population\":152404,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"48.33694\",\"lon\":\"39.945\"},\"district\":\"Южный\",\"name\":\"Донецк\",\"population\":46623,\"subject\":\"Ростовская область\"},{\"coords\":{\"lat\":\"53.96667\",\"lon\":\"38.31667\"},\"district\":\"Центральный\",\"name\":\"Донской\",\"population\":63837,\"subject\":\"Тульская область\"},{\"coords\":{\"lat\":\"56.75\",\"lon\":\"37.15\"},\"district\":\"Центральный\",\"name\":\"Дубна\",\"population\":74183,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"45.2\",\"lon\":\"33.35833\"},\"district\":\"Южный\",\"name\":\"Евпатория\",\"population\":107877,\"subject\":\"Крым\"},{\"coords\":{\"lat\":\"55.38333\",\"lon\":\"39.03361\"},\"district\":\"Центральный\",\"name\":\"Егорьевск\",\"population\":71686,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"46.71056\",\"lon\":\"38.27778\"},\"district\":\"Южный\",\"name\":\"Ейск\",\"population\":82943,\"subject\":\"Краснодарский край\"},{\"coords\":{\"lat\":\"56.83333\",\"lon\":\"60.58333\"},\"district\":\"Уральский\",\"name\":\"Екатеринбург\",\"population\":1544376,\"subject\":\"Свердловская область\"},{\"coords\":{\"lat\":\"55.76667\",\"lon\":\"52.03333\"},\"district\":\"Приволжский\",\"name\":\"Елабуга\",\"population\":73630,\"subject\":\"Татарстан\"},{\"coords\":{\"lat\":\"52.61667\",\"lon\":\"38.46667\"},\"district\":\"Центральный\",\"name\":\"Елец\",\"population\":99875,\"subject\":\"Липецкая область\"},{\"coords\":{\"lat\":\"44.04306\",\"lon\":\"42.86417\"},\"district\":\"Северо-Кавказский\",\"name\":\"Ессентуки\",\"population\":119658,\"subject\":\"Ставропольский край\"},{\"coords\":{\"lat\":\"56.25\",\"lon\":\"93.53333\"},\"district\":\"Сибирский\",\"name\":\"Железногорск\",\"population\":82723,\"subject\":\"Красноярский край\"},{\"coords\":{\"lat\":\"52.339174\",\"lon\":\"35.351582\"},\"district\":\"Центральный\",\"name\":\"Железногорск\",\"population\":97038,\"subject\":\"Курская область\"},{\"coords\":{\"lat\":\"53.4\",\"lon\":\"49.5\"},\"district\":\"Приволжский\",\"name\":\"Жигулёвск\",\"population\":50466,\"subject\":\"Самарская область\"},{\"coords\":{\"lat\":\"55.60111\",\"lon\":\"38.11611\"},\"district\":\"Центральный\",\"name\":\"Жуковский\",\"population\":111222,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"53.2\",\"lon\":\"45.16667\"},\"district\":\"Приволжский\",\"name\":\"Заречный\",\"population\":58510,\"subject\":\"Пензенская область\"},{\"coords\":{\"lat\":\"53.7\",\"lon\":\"84.91667\"},\"district\":\"Сибирский\",\"name\":\"Заринск\",\"population\":41272,\"subject\":\"Алтайский край\"},{\"coords\":{\"lat\":\"56.1\",\"lon\":\"94.58333\"},\"district\":\"Сибирский\",\"name\":\"Зеленогорск\",\"population\":54279,\"subject\":\"Красноярский край\"},{\"coords\":{\"lat\":\"55.997917\",\"lon\":\"37.190417\"},\"district\":\"Центральный\",\"name\":\"Зеленоград\",\"population\":256775,\"subject\":\"Москва\"},{\"coords\":{\"lat\":\"55.85\",\"lon\":\"48.51667\"},\"district\":\"Приволжский\",\"name\":\"Зеленодольск\",\"population\":99137,\"subject\":\"Татарстан\"},{\"coords\":{\"lat\":\"55.16667\",\"lon\":\"59.66667\"},\"district\":\"Уральский\",\"name\":\"Златоуст\",\"population\":161774,\"subject\":\"Челябинская область\"},{\"coords\":{\"lat\":\"56.99667\",\"lon\":\"40.98194\"},\"district\":\"Центральный\",\"name\":\"Иваново\",\"population\":361644,\"subject\":\"Ивановская область\"},{\"coords\":{\"lat\":\"55.97\",\"lon\":\"37.92\"},\"district\":\"Центральный\",\"name\":\"Ивантеевка\",\"population\":82827,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"56.85306\",\"lon\":\"53.21222\"},\"district\":\"Приволжский\",\"name\":\"Ижевск\",\"population\":623472,\"subject\":\"Удмуртия\"},{\"coords\":{\"lat\":\"42.56667\",\"lon\":\"47.86667\"},\"district\":\"Северо-Кавказский\",\"name\":\"Избербаш\",\"population\":55996,\"subject\":\"Дагестан\"},{\"coords\":{\"lat\":\"52.28333\",\"lon\":\"104.3\"},\"district\":\"Сибирский\",\"name\":\"Иркутск\",\"population\":617264,\"subject\":\"Иркутская область\"},{\"coords\":{\"lat\":\"54.63333\",\"lon\":\"83.3\"},\"district\":\"Сибирский\",\"name\":\"Искитим\",\"population\":57147,\"subject\":\"Новосибирская область\"},{\"coords\":{\"lat\":\"56.11667\",\"lon\":\"69.5\"},\"district\":\"Уральский\",\"name\":\"Ишим\",\"population\":67614,\"subject\":\"Тюменская область\"},{\"coords\":{\"lat\":\"53.45444\",\"lon\":\"56.04389\"},\"district\":\"Приволжский\",\"name\":\"Ишимбай\",\"population\":64041,\"subject\":\"Башкортостан\"},{\"coords\":{\"lat\":\"56.632777777778\",\"lon\":\"47.895833333333\"},\"district\":\"Приволжский\",\"name\":\"Йошкар-Ола\",\"population\":281248,\"subject\":\"Марий Эл\"},{\"coords\":{\"lat\":\"55.79083\",\"lon\":\"49.11444\"},\"district\":\"Приволжский\",\"name\":\"Казань\",\"population\":1308660,\"subject\":\"Татарстан\"},{\"coords\":{\"lat\":\"54.71667\",\"lon\":\"20.5\"},\"district\":\"Северо-Западный\",\"name\":\"Калининград\",\"population\":490449,\"subject\":\"Калининградская область\"},{\"coords\":{\"lat\":\"54.53333\",\"lon\":\"36.26667\"},\"district\":\"Центральный\",\"name\":\"Калуга\",\"population\":337058,\"subject\":\"Калужская область\"},{\"coords\":{\"lat\":\"56.4\",\"lon\":\"61.93333\"},\"district\":\"Уральский\",\"name\":\"Каменск-Уральский\",\"population\":164192,\"subject\":\"Свердловская область\"},{\"coords\":{\"lat\":\"48.31667\",\"lon\":\"40.26667\"},\"district\":\"Южный\",\"name\":\"Каменск-Шахтинский\",\"population\":86365,\"subject\":\"Ростовская область\"},{\"coords\":{\"lat\":\"50.08333\",\"lon\":\"45.4\"},\"district\":\"Южный\",\"name\":\"Камышин\",\"population\":107927,\"subject\":\"Волгоградская область\"},{\"coords\":{\"lat\":\"55.50694\",\"lon\":\"47.49139\"},\"district\":\"Приволжский\",\"name\":\"Канаш\",\"population\":44354,\"subject\":\"Чувашия\"},{\"coords\":{\"lat\":\"56.2\",\"lon\":\"95.7\"},\"district\":\"Сибирский\",\"name\":\"Канск\",\"population\":86816,\"subject\":\"Красноярский край\"},{\"coords\":{\"lat\":\"43.306285\",\"lon\":\"44.909763\"},\"district\":\"Северо-Кавказский\",\"name\":\"Карабулак\",\"population\":43037,\"subject\":\"Ингушетия\"},{\"coords\":{\"lat\":\"42.88333\",\"lon\":\"47.63333\"},\"district\":\"Северо-Кавказский\",\"name\":\"Каспийск\",\"population\":121140,\"subject\":\"Дагестан\"},{\"coords\":{\"lat\":\"54.83333\",\"lon\":\"38.15\"},\"district\":\"Центральный\",\"name\":\"Кашира\",\"population\":45922,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"55.35417\",\"lon\":\"86.08972\"},\"district\":\"Сибирский\",\"name\":\"Кемерово\",\"population\":557119,\"subject\":\"Кемеровская область\"},{\"coords\":{\"lat\":\"45.33861\",\"lon\":\"36.46806\"},\"district\":\"Южный\",\"name\":\"Керчь\",\"population\":154621,\"subject\":\"Крым\"},{\"coords\":{\"lat\":\"43.850245\",\"lon\":\"46.71698\"},\"district\":\"Северо-Кавказский\",\"name\":\"Кизляр\",\"population\":49999,\"subject\":\"Дагестан\"},{\"coords\":{\"lat\":\"56.86667\",\"lon\":\"37.35\"},\"district\":\"Центральный\",\"name\":\"Кимры\",\"population\":40875,\"subject\":\"Тверская область\"},{\"coords\":{\"lat\":\"59.378053\",\"lon\":\"28.601209\"},\"district\":\"Северо-Западный\",\"name\":\"Кингисепп\",\"population\":49716,\"subject\":\"Ленинградская область\"},{\"coords\":{\"lat\":\"57.45\",\"lon\":\"42.15\"},\"district\":\"Центральный\",\"name\":\"Кинешма\",\"population\":77694,\"subject\":\"Ивановская область\"},{\"coords\":{\"lat\":\"59.449695\",\"lon\":\"32.008716\"},\"district\":\"Северо-Западный\",\"name\":\"Кириши\",\"population\":51028,\"subject\":\"Ленинградская область\"},{\"coords\":{\"lat\":\"58.6\",\"lon\":\"49.65\"},\"district\":\"Приволжский\",\"name\":\"Киров\",\"population\":468212,\"subject\":\"Кировская область\"},{\"coords\":{\"lat\":\"58.55\",\"lon\":\"50.01667\"},\"district\":\"Приволжский\",\"name\":\"Кирово-Чепецк\",\"population\":66651,\"subject\":\"Кировская область\"},{\"coords\":{\"lat\":\"53.98333\",\"lon\":\"86.7\"},\"district\":\"Сибирский\",\"name\":\"Киселёвск\",\"population\":83431,\"subject\":\"Кемеровская область\"},{\"coords\":{\"lat\":\"43.90333\",\"lon\":\"42.72444\"},\"district\":\"Северо-Кавказский\",\"name\":\"Кисловодск\",\"population\":127521,\"subject\":\"Ставропольский край\"},{\"coords\":{\"lat\":\"56.33389\",\"lon\":\"36.7125\"},\"district\":\"Центральный\",\"name\":\"Клин\",\"population\":88511,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"52.75278\",\"lon\":\"32.23611\"},\"district\":\"Центральный\",\"name\":\"Клинцы\",\"population\":63059,\"subject\":\"Брянская область\"},{\"coords\":{\"lat\":\"56.36056\",\"lon\":\"41.31972\"},\"district\":\"Центральный\",\"name\":\"Ковров\",\"population\":132417,\"subject\":\"Владимирская область\"},{\"coords\":{\"lat\":\"62.26667\",\"lon\":\"74.48333\"},\"district\":\"Уральский\",\"name\":\"Когалым\",\"population\":61441,\"subject\":\"Ханты-Мансийский АО\"},{\"coords\":{\"lat\":\"55.09389\",\"lon\":\"38.76806\"},\"district\":\"Центральный\",\"name\":\"Коломна\",\"population\":134850,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"59.75\",\"lon\":\"30.6\"},\"district\":\"Северо-Западный\",\"name\":\"Колпино\",\"population\":142108,\"subject\":\"Санкт-Петербург\"},{\"coords\":{\"lat\":\"50.55\",\"lon\":\"137\"},\"district\":\"Дальневосточный\",\"name\":\"Комсомольск-на-Амуре\",\"population\":238505,\"subject\":\"Хабаровский край\"},{\"coords\":{\"lat\":\"55.1\",\"lon\":\"61.61667\"},\"district\":\"Уральский\",\"name\":\"Копейск\",\"population\":147806,\"subject\":\"Челябинская область\"},{\"coords\":{\"lat\":\"45.46667\",\"lon\":\"39.45\"},\"district\":\"Южный\",\"name\":\"Кореновск\",\"population\":41826,\"subject\":\"Краснодарский край\"},{\"coords\":{\"lat\":\"55.91667\",\"lon\":\"37.81667\"},\"district\":\"Центральный\",\"name\":\"Королёв\",\"population\":228095,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"57.76667\",\"lon\":\"40.93333\"},\"district\":\"Центральный\",\"name\":\"Кострома\",\"population\":267481,\"subject\":\"Костромская область\"},{\"coords\":{\"lat\":\"55.6625\",\"lon\":\"37.86722\"},\"district\":\"Центральный\",\"name\":\"Котельники\",\"population\":63728,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"61.25\",\"lon\":\"46.65\"},\"district\":\"Северо-Западный\",\"name\":\"Котлас\",\"population\":56093,\"subject\":\"Архангельская область\"},{\"coords\":{\"lat\":\"55.81667\",\"lon\":\"37.33333\"},\"district\":\"Центральный\",\"name\":\"Красногорск\",\"population\":187634,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"45.03333\",\"lon\":\"38.98333\"},\"district\":\"Южный\",\"name\":\"Краснодар\",\"population\":1099344,\"subject\":\"Краснодарский край\"},{\"coords\":{\"lat\":\"59.733745\",\"lon\":\"30.086205\"},\"district\":\"Северо-Западный\",\"name\":\"Красное Село\",\"population\":56533,\"subject\":\"Санкт-Петербург\"},{\"coords\":{\"lat\":\"55.6\",\"lon\":\"37.03333\"},\"district\":\"Центральный\",\"name\":\"Краснознаменск\",\"population\":43868,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"50.1\",\"lon\":\"118.03333\"},\"district\":\"Сибирский\",\"name\":\"Краснокаменск\",\"population\":51137,\"subject\":\"Забайкальский край\"},{\"coords\":{\"lat\":\"58.08333\",\"lon\":\"55.75\"},\"district\":\"Приволжский\",\"name\":\"Краснокамск\",\"population\":48778,\"subject\":\"Пермский край\"},{\"coords\":{\"lat\":\"59.76667\",\"lon\":\"60.2\"},\"district\":\"Уральский\",\"name\":\"Краснотурьинск\",\"population\":55875,\"subject\":\"Свердловская область\"},{\"coords\":{\"lat\":\"56.012083\",\"lon\":\"92.871295\"},\"district\":\"Сибирский\",\"name\":\"Красноярск\",\"population\":1187771,\"subject\":\"Красноярский край\"},{\"coords\":{\"lat\":\"60\",\"lon\":\"29.76667\"},\"district\":\"Северо-Западный\",\"name\":\"Кронштадт\",\"population\":44399,\"subject\":\"Санкт-Петербург\"},{\"coords\":{\"lat\":\"45.43333\",\"lon\":\"40.56667\"},\"district\":\"Южный\",\"name\":\"Кропоткин\",\"population\":75858,\"subject\":\"Краснодарский край\"},{\"coords\":{\"lat\":\"44.93333\",\"lon\":\"38\"},\"district\":\"Южный\",\"name\":\"Крымск\",\"population\":54597,\"subject\":\"Краснодарский край\"},{\"coords\":{\"lat\":\"56.15167\",\"lon\":\"44.19556\"},\"district\":\"Приволжский\",\"name\":\"Кстово\",\"population\":63646,\"subject\":\"Нижегородская область\"},{\"coords\":{\"lat\":\"59.908489\",\"lon\":\"30.513569\"},\"district\":\"Северо-Западный\",\"name\":\"Кудрово\",\"population\":60791,\"subject\":\"Ленинградская область\"},{\"coords\":{\"lat\":\"53.11667\",\"lon\":\"46.6\"},\"district\":\"Приволжский\",\"name\":\"Кузнецк\",\"population\":78390,\"subject\":\"Пензенская область\"},{\"coords\":{\"lat\":\"55.45028\",\"lon\":\"78.3075\"},\"district\":\"Сибирский\",\"name\":\"Куйбышев\",\"population\":41946,\"subject\":\"Новосибирская область\"},{\"coords\":{\"lat\":\"52.76667\",\"lon\":\"55.78333\"},\"district\":\"Приволжский\",\"name\":\"Кумертау\",\"population\":57949,\"subject\":\"Башкортостан\"},{\"coords\":{\"lat\":\"57.43333\",\"lon\":\"56.93333\"},\"district\":\"Приволжский\",\"name\":\"Кунгур\",\"population\":62673,\"subject\":\"Пермский край\"},{\"coords\":{\"lat\":\"55.44083\",\"lon\":\"65.34111\"},\"district\":\"Уральский\",\"name\":\"Курган\",\"population\":310911,\"subject\":\"Курганская область\"},{\"coords\":{\"lat\":\"44.88333\",\"lon\":\"40.6\"},\"district\":\"Южный\",\"name\":\"Курганинск\",\"population\":47305,\"subject\":\"Краснодарский край\"},{\"coords\":{\"lat\":\"51.71667\",\"lon\":\"36.18333\"},\"district\":\"Центральный\",\"name\":\"Курск\",\"population\":440052,\"subject\":\"Курская область\"},{\"coords\":{\"lat\":\"51.66667\",\"lon\":\"35.65\"},\"district\":\"Центральный\",\"name\":\"Курчатов\",\"population\":40318,\"subject\":\"Курская область\"},{\"coords\":{\"lat\":\"51.7\",\"lon\":\"94.36667\"},\"district\":\"Сибирский\",\"name\":\"Кызыл\",\"population\":125241,\"subject\":\"Тыва\"},{\"coords\":{\"lat\":\"44.633338\",\"lon\":\"40.733311\"},\"district\":\"Южный\",\"name\":\"Лабинск\",\"population\":57428,\"subject\":\"Краснодарский край\"},{\"coords\":{\"lat\":\"61.25\",\"lon\":\"75.16667\"},\"district\":\"Уральский\",\"name\":\"Лангепас\",\"population\":42701,\"subject\":\"Ханты-Мансийский АО\"},{\"coords\":{\"lat\":\"54.5988694\",\"lon\":\"52.4422722\"},\"district\":\"Приволжский\",\"name\":\"Лениногорск\",\"population\":60993,\"subject\":\"Татарстан\"},{\"coords\":{\"lat\":\"54.65\",\"lon\":\"86.16667\"},\"district\":\"Сибирский\",\"name\":\"Ленинск-Кузнецкий\",\"population\":92244,\"subject\":\"Кемеровская область\"},{\"coords\":{\"lat\":\"58.63333\",\"lon\":\"59.78333\"},\"district\":\"Уральский\",\"name\":\"Лесной\",\"population\":48261,\"subject\":\"Свердловская область\"},{\"coords\":{\"lat\":\"58.23333\",\"lon\":\"92.48333\"},\"district\":\"Сибирский\",\"name\":\"Лесосибирск\",\"population\":55730,\"subject\":\"Красноярский край\"},{\"coords\":{\"lat\":\"52.425306\",\"lon\":\"37.608306\"},\"district\":\"Центральный\",\"name\":\"Ливны\",\"population\":43549,\"subject\":\"Орловская область\"},{\"coords\":{\"lat\":\"52.61667\",\"lon\":\"39.6\"},\"district\":\"Центральный\",\"name\":\"Липецк\",\"population\":496403,\"subject\":\"Липецкая область\"},{\"coords\":{\"lat\":\"50.98222\",\"lon\":\"39.49944\"},\"district\":\"Центральный\",\"name\":\"Лиски\",\"population\":54147,\"subject\":\"Воронежская область\"},{\"coords\":{\"lat\":\"56.01194\",\"lon\":\"37.47444\"},\"district\":\"Центральный\",\"name\":\"Лобня\",\"population\":82764,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"58.1003806\",\"lon\":\"57.8043278\"},\"district\":\"Приволжский\",\"name\":\"Лысьва\",\"population\":53855,\"subject\":\"Пермский край\"},{\"coords\":{\"lat\":\"55.58361\",\"lon\":\"37.90556\"},\"district\":\"Центральный\",\"name\":\"Лыткарино\",\"population\":65212,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"55.68139\",\"lon\":\"37.89389\"},\"district\":\"Центральный\",\"name\":\"Люберцы\",\"population\":224195,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"61.61667\",\"lon\":\"72.16667\"},\"district\":\"Уральский\",\"name\":\"Лянтор\",\"population\":40977,\"subject\":\"Ханты-Мансийский АО\"},{\"coords\":{\"lat\":\"59.56667\",\"lon\":\"150.8\"},\"district\":\"Дальневосточный\",\"name\":\"Магадан\",\"population\":90757,\"subject\":\"Магаданская область\"},{\"coords\":{\"lat\":\"53.38333\",\"lon\":\"59.03333\"},\"district\":\"Уральский\",\"name\":\"Магнитогорск\",\"population\":410594,\"subject\":\"Челябинская область\"},{\"coords\":{\"lat\":\"44.611\",\"lon\":\"40.111\"},\"district\":\"Южный\",\"name\":\"Майкоп\",\"population\":143385,\"subject\":\"Адыгея\"},{\"coords\":{\"lat\":\"55\",\"lon\":\"36.46667\"},\"district\":\"Центральный\",\"name\":\"Малоярославец\",\"population\":41836,\"subject\":\"Калужская область\"},{\"coords\":{\"lat\":\"56.21667\",\"lon\":\"87.75\"},\"district\":\"Сибирский\",\"name\":\"Мариинск\",\"population\":40779,\"subject\":\"Кемеровская область\"},{\"coords\":{\"lat\":\"42.98333\",\"lon\":\"47.5\"},\"district\":\"Северо-Кавказский\",\"name\":\"Махачкала\",\"population\":623254,\"subject\":\"Дагестан\"},{\"coords\":{\"lat\":\"61.033055555556\",\"lon\":\"76.109722222222\"},\"district\":\"Уральский\",\"name\":\"Мегион\",\"population\":52887,\"subject\":\"Ханты-Мансийский АО\"},{\"coords\":{\"lat\":\"53.68333\",\"lon\":\"88.05\"},\"district\":\"Сибирский\",\"name\":\"Междуреченск\",\"population\":96174,\"subject\":\"Кемеровская область\"},{\"coords\":{\"lat\":\"52.95\",\"lon\":\"55.93333\"},\"district\":\"Приволжский\",\"name\":\"Мелеуз\",\"population\":56505,\"subject\":\"Башкортостан\"},{\"coords\":{\"lat\":\"55.05\",\"lon\":\"60.1\"},\"district\":\"Уральский\",\"name\":\"Миасс\",\"population\":147995,\"subject\":\"Челябинская область\"},{\"coords\":{\"lat\":\"44.20083\",\"lon\":\"43.1125\"},\"district\":\"Северо-Кавказский\",\"name\":\"Минеральные Воды\",\"population\":70485,\"subject\":\"Ставропольский край\"},{\"coords\":{\"lat\":\"53.7\",\"lon\":\"91.68333\"},\"district\":\"Сибирский\",\"name\":\"Минусинск\",\"population\":70089,\"subject\":\"Красноярский край\"},{\"coords\":{\"lat\":\"50.06667\",\"lon\":\"43.23333\"},\"district\":\"Южный\",\"name\":\"Михайловка\",\"population\":56031,\"subject\":\"Волгоградская область\"},{\"coords\":{\"lat\":\"45.130012\",\"lon\":\"42.027487\"},\"district\":\"Северо-Кавказский\",\"name\":\"Михайловск\",\"population\":114133,\"subject\":\"Ставропольский край\"},{\"coords\":{\"lat\":\"52.89222\",\"lon\":\"40.49278\"},\"district\":\"Центральный\",\"name\":\"Мичуринск\",\"population\":90451,\"subject\":\"Тамбовская область\"},{\"coords\":{\"lat\":\"56.45\",\"lon\":\"52.21667\"},\"district\":\"Приволжский\",\"name\":\"Можга\",\"population\":44345,\"subject\":\"Удмуртия\"},{\"coords\":{\"lat\":\"55.755833333333\",\"lon\":\"37.617777777778\"},\"district\":\"Центральный\",\"name\":\"Москва\",\"population\":13010112,\"subject\":\"Москва\"},{\"coords\":{\"lat\":\"55.6\",\"lon\":\"37.35\"},\"district\":\"Центральный\",\"name\":\"Московский\",\"population\":65417,\"subject\":\"Москва\"},{\"coords\":{\"lat\":\"60.051284\",\"lon\":\"30.438578\"},\"district\":\"Северо-Западный\",\"name\":\"Мурино\",\"population\":89083,\"subject\":\"Ленинградская область\"},{\"coords\":{\"lat\":\"68.96667\",\"lon\":\"33.08333\"},\"district\":\"Северо-Западный\",\"name\":\"Мурманск\",\"population\":270384,\"subject\":\"Мурманская область\"},{\"coords\":{\"lat\":\"55.5725\",\"lon\":\"42.05139\"},\"district\":\"Центральный\",\"name\":\"Муром\",\"population\":107497,\"subject\":\"Владимирская область\"},{\"coords\":{\"lat\":\"53.7\",\"lon\":\"87.81667\"},\"district\":\"Сибирский\",\"name\":\"Мыски\",\"population\":40109,\"subject\":\"Кемеровская область\"},{\"coords\":{\"lat\":\"55.91667\",\"lon\":\"37.73333\"},\"district\":\"Центральный\",\"name\":\"Мытищи\",\"population\":255429,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"55.7\",\"lon\":\"52.33333\"},\"district\":\"Приволжский\",\"name\":\"Набережные Челны\",\"population\":548434,\"subject\":\"Татарстан\"},{\"coords\":{\"lat\":\"65.53333\",\"lon\":\"72.51667\"},\"district\":\"Уральский\",\"name\":\"Надым\",\"population\":45973,\"subject\":\"Ямало-Ненецкий АО\"},{\"coords\":{\"lat\":\"56.00639\",\"lon\":\"90.39139\"},\"district\":\"Сибирский\",\"name\":\"Назарово\",\"population\":45333,\"subject\":\"Красноярский край\"},{\"coords\":{\"lat\":\"43.21667\",\"lon\":\"44.76667\"},\"district\":\"Северо-Кавказский\",\"name\":\"Назрань\",\"population\":122350,\"subject\":\"Ингушетия\"},{\"coords\":{\"lat\":\"43.485259\",\"lon\":\"43.607072\"},\"district\":\"Северо-Кавказский\",\"name\":\"Нальчик\",\"population\":247054,\"subject\":\"Кабардино-Балкария\"},{\"coords\":{\"lat\":\"55.38333\",\"lon\":\"36.73333\"},\"district\":\"Центральный\",\"name\":\"Наро-Фоминск\",\"population\":71121,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"42.81667\",\"lon\":\"132.88333\"},\"district\":\"Дальневосточный\",\"name\":\"Находка\",\"population\":139931,\"subject\":\"Приморский край\"},{\"coords\":{\"lat\":\"44.63333\",\"lon\":\"41.93333\"},\"district\":\"Северо-Кавказский\",\"name\":\"Невинномысск\",\"population\":117562,\"subject\":\"Ставропольский край\"},{\"coords\":{\"lat\":\"56.65833\",\"lon\":\"124.725\"},\"district\":\"Дальневосточный\",\"name\":\"Нерюнгри\",\"population\":53409,\"subject\":\"Якутия\"},{\"coords\":{\"lat\":\"56.08889\",\"lon\":\"54.24639\"},\"district\":\"Приволжский\",\"name\":\"Нефтекамск\",\"population\":131942,\"subject\":\"Башкортостан\"},{\"coords\":{\"lat\":\"61.1\",\"lon\":\"72.6\"},\"district\":\"Уральский\",\"name\":\"Нефтеюганск\",\"population\":124732,\"subject\":\"Ханты-Мансийский АО\"},{\"coords\":{\"lat\":\"60.93389\",\"lon\":\"76.58111\"},\"district\":\"Уральский\",\"name\":\"Нижневартовск\",\"population\":283256,\"subject\":\"Ханты-Мансийский АО\"},{\"coords\":{\"lat\":\"55.63333\",\"lon\":\"51.81667\"},\"district\":\"Приволжский\",\"name\":\"Нижнекамск\",\"population\":241479,\"subject\":\"Татарстан\"},{\"coords\":{\"lat\":\"56.32694\",\"lon\":\"44.0075\"},\"district\":\"Приволжский\",\"name\":\"Нижний Новгород\",\"population\":1226076,\"subject\":\"Нижегородская область\"},{\"coords\":{\"lat\":\"57.91667\",\"lon\":\"59.96667\"},\"district\":\"Уральский\",\"name\":\"Нижний Тагил\",\"population\":338966,\"subject\":\"Свердловская область\"},{\"coords\":{\"lat\":\"53.4\",\"lon\":\"83.93333\"},\"district\":\"Сибирский\",\"name\":\"Новоалтайск\",\"population\":73049,\"subject\":\"Алтайский край\"},{\"coords\":{\"lat\":\"53.73333\",\"lon\":\"87.08333\"},\"district\":\"Сибирский\",\"name\":\"Новокузнецк\",\"population\":537480,\"subject\":\"Кемеровская область\"},{\"coords\":{\"lat\":\"53.1\",\"lon\":\"49.91667\"},\"district\":\"Приволжский\",\"name\":\"Новокуйбышевск\",\"population\":98306,\"subject\":\"Самарская область\"},{\"coords\":{\"lat\":\"54.03333\",\"lon\":\"38.26667\"},\"district\":\"Центральный\",\"name\":\"Новомосковск\",\"population\":119697,\"subject\":\"Тульская область\"},{\"coords\":{\"lat\":\"44.71667\",\"lon\":\"37.76667\"},\"district\":\"Южный\",\"name\":\"Новороссийск\",\"population\":262293,\"subject\":\"Краснодарский край\"},{\"coords\":{\"lat\":\"55.01667\",\"lon\":\"82.91667\"},\"district\":\"Сибирский\",\"name\":\"Новосибирск\",\"population\":1633595,\"subject\":\"Новосибирская область\"},{\"coords\":{\"lat\":\"51.20667\",\"lon\":\"58.32806\"},\"district\":\"Приволжский\",\"name\":\"Новотроицк\",\"population\":75960,\"subject\":\"Оренбургская область\"},{\"coords\":{\"lat\":\"57.25\",\"lon\":\"60.08333\"},\"district\":\"Уральский\",\"name\":\"Новоуральск\",\"population\":78479,\"subject\":\"Свердловская область\"},{\"coords\":{\"lat\":\"56.12194\",\"lon\":\"47.4925\"},\"district\":\"Приволжский\",\"name\":\"Новочебоксарск\",\"population\":120375,\"subject\":\"Чувашия\"},{\"coords\":{\"lat\":\"47.43583\",\"lon\":\"40.09861\"},\"district\":\"Южный\",\"name\":\"Новочеркасск\",\"population\":163674,\"subject\":\"Ростовская область\"},{\"coords\":{\"lat\":\"47.76667\",\"lon\":\"39.91667\"},\"district\":\"Южный\",\"name\":\"Новошахтинск\",\"population\":103480,\"subject\":\"Ростовская область\"},{\"coords\":{\"lat\":\"66.08472\",\"lon\":\"76.67889\"},\"district\":\"Уральский\",\"name\":\"Новый Уренгой\",\"population\":107251,\"subject\":\"Ямало-Ненецкий АО\"},{\"coords\":{\"lat\":\"55.85\",\"lon\":\"38.43333\"},\"district\":\"Центральный\",\"name\":\"Ногинск\",\"population\":103891,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"69.33333\",\"lon\":\"88.21667\"},\"district\":\"Сибирский\",\"name\":\"Норильск\",\"population\":174453,\"subject\":\"Красноярский край\"},{\"coords\":{\"lat\":\"63.20167\",\"lon\":\"75.45167\"},\"district\":\"Уральский\",\"name\":\"Ноябрьск\",\"population\":100188,\"subject\":\"Ямало-Ненецкий АО\"},{\"coords\":{\"lat\":\"62.13333\",\"lon\":\"65.38333\"},\"district\":\"Уральский\",\"name\":\"Нягань\",\"population\":63034,\"subject\":\"Ханты-Мансийский АО\"},{\"coords\":{\"lat\":\"55.1\",\"lon\":\"36.61667\"},\"district\":\"Центральный\",\"name\":\"Обнинск\",\"population\":125376,\"subject\":\"Калужская область\"},{\"coords\":{\"lat\":\"55.67333\",\"lon\":\"37.27333\"},\"district\":\"Центральный\",\"name\":\"Одинцово\",\"population\":180530,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"55.75\",\"lon\":\"60.71667\"},\"district\":\"Уральский\",\"name\":\"Озёрск\",\"population\":76896,\"subject\":\"Челябинская область\"},{\"coords\":{\"lat\":\"54.48333\",\"lon\":\"53.48333\"},\"district\":\"Приволжский\",\"name\":\"Октябрьский\",\"population\":115557,\"subject\":\"Башкортостан\"},{\"coords\":{\"lat\":\"54.96667\",\"lon\":\"73.38333\"},\"district\":\"Сибирский\",\"name\":\"Омск\",\"population\":1125695,\"subject\":\"Омская область\"},{\"coords\":{\"lat\":\"51.76667\",\"lon\":\"55.1\"},\"district\":\"Приволжский\",\"name\":\"Оренбург\",\"population\":543654,\"subject\":\"Оренбургская область\"},{\"coords\":{\"lat\":\"55.8\",\"lon\":\"38.96667\"},\"district\":\"Центральный\",\"name\":\"Орехово-Зуево\",\"population\":105745,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"51.2\",\"lon\":\"58.61667\"},\"district\":\"Приволжский\",\"name\":\"Орск\",\"population\":189195,\"subject\":\"Оренбургская область\"},{\"coords\":{\"lat\":\"52.96667\",\"lon\":\"36.08333\"},\"district\":\"Центральный\",\"name\":\"Орёл\",\"population\":303169,\"subject\":\"Орловская область\"},{\"coords\":{\"lat\":\"53.61667\",\"lon\":\"87.33333\"},\"district\":\"Сибирский\",\"name\":\"Осинники\",\"population\":40367,\"subject\":\"Кемеровская область\"},{\"coords\":{\"lat\":\"53.36667\",\"lon\":\"51.35\"},\"district\":\"Приволжский\",\"name\":\"Отрадный\",\"population\":46984,\"subject\":\"Самарская область\"},{\"coords\":{\"lat\":\"55.96194\",\"lon\":\"43.09\"},\"district\":\"Приволжский\",\"name\":\"Павлово\",\"population\":57116,\"subject\":\"Нижегородская область\"},{\"coords\":{\"lat\":\"55.78333\",\"lon\":\"38.65\"},\"district\":\"Центральный\",\"name\":\"Павловский Посад\",\"population\":65098,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"53.2\",\"lon\":\"45\"},\"district\":\"Приволжский\",\"name\":\"Пенза\",\"population\":501109,\"subject\":\"Пензенская область\"},{\"coords\":{\"lat\":\"56.91667\",\"lon\":\"59.95\"},\"district\":\"Уральский\",\"name\":\"Первоуральск\",\"population\":114450,\"subject\":\"Свердловская область\"},{\"coords\":{\"lat\":\"58.01389\",\"lon\":\"56.24889\"},\"district\":\"Приволжский\",\"name\":\"Пермь\",\"population\":1034002,\"subject\":\"Пермский край\"},{\"coords\":{\"lat\":\"59.88333\",\"lon\":\"29.9\"},\"district\":\"Северо-Западный\",\"name\":\"Петергоф\",\"population\":80814,\"subject\":\"Санкт-Петербург\"},{\"coords\":{\"lat\":\"61.79611\",\"lon\":\"34.34917\"},\"district\":\"Северо-Западный\",\"name\":\"Петрозаводск\",\"population\":234897,\"subject\":\"Карелия\"},{\"coords\":{\"lat\":\"53.01667\",\"lon\":\"158.65\"},\"district\":\"Дальневосточный\",\"name\":\"Петропавловск-Камчатский\",\"population\":164900,\"subject\":\"Камчатский край\"},{\"coords\":{\"lat\":\"55.42972\",\"lon\":\"37.54444\"},\"district\":\"Центральный\",\"name\":\"Подольск\",\"population\":314934,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"56.45\",\"lon\":\"60.18333\"},\"district\":\"Уральский\",\"name\":\"Полевской\",\"population\":55182,\"subject\":\"Свердловская область\"},{\"coords\":{\"lat\":\"53.88333\",\"lon\":\"86.71667\"},\"district\":\"Сибирский\",\"name\":\"Прокопьевск\",\"population\":177819,\"subject\":\"Кемеровская область\"},{\"coords\":{\"lat\":\"43.750055\",\"lon\":\"44.033333\"},\"district\":\"Северо-Кавказский\",\"name\":\"Прохладный\",\"population\":59938,\"subject\":\"Кабардино-Балкария\"},{\"coords\":{\"lat\":\"57.81667\",\"lon\":\"28.33333\"},\"district\":\"Северо-Западный\",\"name\":\"Псков\",\"population\":193082,\"subject\":\"Псковская область\"},{\"coords\":{\"lat\":\"52.01667\",\"lon\":\"48.8\"},\"district\":\"Приволжский\",\"name\":\"Пугачёв\",\"population\":40127,\"subject\":\"Саратовская область\"},{\"coords\":{\"lat\":\"59.71667\",\"lon\":\"30.41667\"},\"district\":\"Северо-Западный\",\"name\":\"Пушкин\",\"population\":107223,\"subject\":\"Санкт-Петербург\"},{\"coords\":{\"lat\":\"56.01667\",\"lon\":\"37.85\"},\"district\":\"Центральный\",\"name\":\"Пушкино\",\"population\":110868,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"60.75\",\"lon\":\"72.78333\"},\"district\":\"Уральский\",\"name\":\"Пыть-Ях\",\"population\":40180,\"subject\":\"Ханты-Мансийский АО\"},{\"coords\":{\"lat\":\"44.0499664\",\"lon\":\"43.0600548\"},\"district\":\"Северо-Кавказский\",\"name\":\"Пятигорск\",\"population\":146473,\"subject\":\"Ставропольский край\"},{\"coords\":{\"lat\":\"62.13333\",\"lon\":\"77.46667\"},\"district\":\"Уральский\",\"name\":\"Радужный\",\"population\":43577,\"subject\":\"Ханты-Мансийский АО\"},{\"coords\":{\"lat\":\"55.56667\",\"lon\":\"38.21667\"},\"district\":\"Центральный\",\"name\":\"Раменское\",\"population\":114537,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"52.66667\",\"lon\":\"41.88333\"},\"district\":\"Центральный\",\"name\":\"Рассказово\",\"population\":47644,\"subject\":\"Тамбовская область\"},{\"coords\":{\"lat\":\"56.8\",\"lon\":\"59.91667\"},\"district\":\"Уральский\",\"name\":\"Ревда\",\"population\":60200,\"subject\":\"Свердловская область\"},{\"coords\":{\"lat\":\"55.760611\",\"lon\":\"37.855194\"},\"district\":\"Центральный\",\"name\":\"Реутов\",\"population\":113871,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"56.26556\",\"lon\":\"34.3275\"},\"district\":\"Центральный\",\"name\":\"Ржев\",\"population\":55757,\"subject\":\"Тверская область\"},{\"coords\":{\"lat\":\"53.949166666667\",\"lon\":\"32.856944444444\"},\"district\":\"Центральный\",\"name\":\"Рославль\",\"population\":45416,\"subject\":\"Смоленская область\"},{\"coords\":{\"lat\":\"50.2\",\"lon\":\"39.58333\"},\"district\":\"Центральный\",\"name\":\"Россошь\",\"population\":60879,\"subject\":\"Воронежская область\"},{\"coords\":{\"lat\":\"47.24056\",\"lon\":\"39.71056\"},\"district\":\"Южный\",\"name\":\"Ростов-на-Дону\",\"population\":1142162,\"subject\":\"Ростовская область\"},{\"coords\":{\"lat\":\"51.52722\",\"lon\":\"81.218806\"},\"district\":\"Сибирский\",\"name\":\"Рубцовск\",\"population\":126834,\"subject\":\"Алтайский край\"},{\"coords\":{\"lat\":\"54.06667\",\"lon\":\"44.95\"},\"district\":\"Приволжский\",\"name\":\"Рузаевка\",\"population\":42989,\"subject\":\"Мордовия\"},{\"coords\":{\"lat\":\"58.05\",\"lon\":\"38.83333\"},\"district\":\"Центральный\",\"name\":\"Рыбинск\",\"population\":177295,\"subject\":\"Ярославская область\"},{\"coords\":{\"lat\":\"54.61667\",\"lon\":\"39.71667\"},\"district\":\"Центральный\",\"name\":\"Рязань\",\"population\":528599,\"subject\":\"Рязанская область\"},{\"coords\":{\"lat\":\"53.36667\",\"lon\":\"55.93333\"},\"district\":\"Приволжский\",\"name\":\"Салават\",\"population\":148575,\"subject\":\"Башкортостан\"},{\"coords\":{\"lat\":\"66.53333\",\"lon\":\"66.63333\"},\"district\":\"Уральский\",\"name\":\"Салехард\",\"population\":47910,\"subject\":\"Ямало-Ненецкий АО\"},{\"coords\":{\"lat\":\"46.48333\",\"lon\":\"41.53333\"},\"district\":\"Южный\",\"name\":\"Сальск\",\"population\":57937,\"subject\":\"Ростовская область\"},{\"coords\":{\"lat\":\"53.18333\",\"lon\":\"50.11667\"},\"district\":\"Приволжский\",\"name\":\"Самара\",\"population\":1173299,\"subject\":\"Самарская область\"},{\"coords\":{\"lat\":\"59.95\",\"lon\":\"30.31667\"},\"district\":\"Северо-Западный\",\"name\":\"Санкт-Петербург\",\"population\":5601911,\"subject\":\"Санкт-Петербург\"},{\"coords\":{\"lat\":\"54.18333\",\"lon\":\"45.18333\"},\"district\":\"Приволжский\",\"name\":\"Саранск\",\"population\":314871,\"subject\":\"Мордовия\"},{\"coords\":{\"lat\":\"56.46667\",\"lon\":\"53.8\"},\"district\":\"Приволжский\",\"name\":\"Сарапул\",\"population\":91115,\"subject\":\"Удмуртия\"},{\"coords\":{\"lat\":\"51.53333\",\"lon\":\"46\"},\"district\":\"Приволжский\",\"name\":\"Саратов\",\"population\":901361,\"subject\":\"Саратовская область\"},{\"coords\":{\"lat\":\"54.93333\",\"lon\":\"43.31667\"},\"district\":\"Приволжский\",\"name\":\"Саров\",\"population\":93357,\"subject\":\"Нижегородская область\"},{\"coords\":{\"lat\":\"55.05\",\"lon\":\"59.05\"},\"district\":\"Уральский\",\"name\":\"Сатка\",\"population\":42597,\"subject\":\"Челябинская область\"},{\"coords\":{\"lat\":\"53.1\",\"lon\":\"91.4\"},\"district\":\"Сибирский\",\"name\":\"Саяногорск\",\"population\":44872,\"subject\":\"Хакасия\"},{\"coords\":{\"lat\":\"51.38333\",\"lon\":\"128.13333\"},\"district\":\"Дальневосточный\",\"name\":\"Свободный\",\"population\":48517,\"subject\":\"Амурская область\"},{\"coords\":{\"lat\":\"44.6\",\"lon\":\"33.53333\"},\"district\":\"Южный\",\"name\":\"Севастополь\",\"population\":547820,\"subject\":\"Севастополь\"},{\"coords\":{\"lat\":\"64.56667\",\"lon\":\"39.85\"},\"district\":\"Северо-Западный\",\"name\":\"Северодвинск\",\"population\":157213,\"subject\":\"Архангельская область\"},{\"coords\":{\"lat\":\"69.06917\",\"lon\":\"33.41667\"},\"district\":\"Северо-Западный\",\"name\":\"Североморск\",\"population\":43327,\"subject\":\"Мурманская область\"},{\"coords\":{\"lat\":\"56.6\",\"lon\":\"84.85\"},\"district\":\"Сибирский\",\"name\":\"Северск\",\"population\":106648,\"subject\":\"Томская область\"},{\"coords\":{\"lat\":\"56.3\",\"lon\":\"38.13333\"},\"district\":\"Центральный\",\"name\":\"Сергиев Посад\",\"population\":101756,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"59.58333\",\"lon\":\"60.56667\"},\"district\":\"Уральский\",\"name\":\"Серов\",\"population\":94211,\"subject\":\"Свердловская область\"},{\"coords\":{\"lat\":\"54.91667\",\"lon\":\"37.4\"},\"district\":\"Центральный\",\"name\":\"Серпухов\",\"population\":133793,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"60.141613\",\"lon\":\"30.211879\"},\"district\":\"Северо-Западный\",\"name\":\"Сертолово\",\"population\":68241,\"subject\":\"Ленинградская область\"},{\"coords\":{\"lat\":\"60.1\",\"lon\":\"29.96667\"},\"district\":\"Северо-Западный\",\"name\":\"Сестрорецк\",\"population\":45192,\"subject\":\"Санкт-Петербург\"},{\"coords\":{\"lat\":\"52.7\",\"lon\":\"58.65\"},\"district\":\"Приволжский\",\"name\":\"Сибай\",\"population\":56514,\"subject\":\"Башкортостан\"},{\"coords\":{\"lat\":\"44.94806\",\"lon\":\"34.10417\"},\"district\":\"Южный\",\"name\":\"Симферополь\",\"population\":340540,\"subject\":\"Крым\"},{\"coords\":{\"lat\":\"45.25861\",\"lon\":\"38.12472\"},\"district\":\"Южный\",\"name\":\"Славянск-на-Кубани\",\"population\":62985,\"subject\":\"Краснодарский край\"},{\"coords\":{\"lat\":\"54.78278\",\"lon\":\"32.04528\"},\"district\":\"Центральный\",\"name\":\"Смоленск\",\"population\":316570,\"subject\":\"Смоленская область\"},{\"coords\":{\"lat\":\"56.08333\",\"lon\":\"60.73333\"},\"district\":\"Уральский\",\"name\":\"Снежинск\",\"population\":50619,\"subject\":\"Челябинская область\"},{\"coords\":{\"lat\":\"59.63333\",\"lon\":\"56.76667\"},\"district\":\"Приволжский\",\"name\":\"Соликамск\",\"population\":89473,\"subject\":\"Пермский край\"},{\"coords\":{\"lat\":\"56.185114\",\"lon\":\"36.977618\"},\"district\":\"Центральный\",\"name\":\"Солнечногорск\",\"population\":48413,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"56.13333\",\"lon\":\"93.36667\"},\"district\":\"Сибирский\",\"name\":\"Сосновоборск\",\"population\":40442,\"subject\":\"Красноярский край\"},{\"coords\":{\"lat\":\"59.9\",\"lon\":\"29.08611\"},\"district\":\"Северо-Западный\",\"name\":\"Сосновый Бор\",\"population\":65367,\"subject\":\"Ленинградская область\"},{\"coords\":{\"lat\":\"43.58528\",\"lon\":\"39.72028\"},\"district\":\"Южный\",\"name\":\"Сочи\",\"population\":466078,\"subject\":\"Краснодарский край\"},{\"coords\":{\"lat\":\"45.03333\",\"lon\":\"41.96667\"},\"district\":\"Северо-Кавказский\",\"name\":\"Ставрополь\",\"population\":547443,\"subject\":\"Ставропольский край\"},{\"coords\":{\"lat\":\"51.29806\",\"lon\":\"37.835\"},\"district\":\"Центральный\",\"name\":\"Старый Оскол\",\"population\":221676,\"subject\":\"Белгородская область\"},{\"coords\":{\"lat\":\"53.63333\",\"lon\":\"55.95\"},\"district\":\"Приволжский\",\"name\":\"Стерлитамак\",\"population\":277410,\"subject\":\"Башкортостан\"},{\"coords\":{\"lat\":\"54.88694\",\"lon\":\"38.07722\"},\"district\":\"Центральный\",\"name\":\"Ступино\",\"population\":64412,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"43.313475\",\"lon\":\"45.051581\"},\"district\":\"Северо-Кавказский\",\"name\":\"Сунжа\",\"population\":62078,\"subject\":\"Ингушетия\"},{\"coords\":{\"lat\":\"61.25\",\"lon\":\"73.43333\"},\"district\":\"Уральский\",\"name\":\"Сургут\",\"population\":396443,\"subject\":\"Ханты-Мансийский АО\"},{\"coords\":{\"lat\":\"53.16667\",\"lon\":\"48.46667\"},\"district\":\"Приволжский\",\"name\":\"Сызрань\",\"population\":165725,\"subject\":\"Самарская область\"},{\"coords\":{\"lat\":\"61.66667\",\"lon\":\"50.81667\"},\"district\":\"Северо-Западный\",\"name\":\"Сыктывкар\",\"population\":220580,\"subject\":\"Коми\"},{\"coords\":{\"lat\":\"47.23917\",\"lon\":\"38.88333\"},\"district\":\"Южный\",\"name\":\"Таганрог\",\"population\":245120,\"subject\":\"Ростовская область\"},{\"coords\":{\"lat\":\"52.71667\",\"lon\":\"41.43333\"},\"district\":\"Центральный\",\"name\":\"Тамбов\",\"population\":261803,\"subject\":\"Тамбовская область\"},{\"coords\":{\"lat\":\"56.8578278\",\"lon\":\"35.9219278\"},\"district\":\"Центральный\",\"name\":\"Тверь\",\"population\":416219,\"subject\":\"Тверская область\"},{\"coords\":{\"lat\":\"45.26667\",\"lon\":\"37.38333\"},\"district\":\"Южный\",\"name\":\"Темрюк\",\"population\":41608,\"subject\":\"Краснодарский край\"},{\"coords\":{\"lat\":\"45.61667\",\"lon\":\"38.93333\"},\"district\":\"Южный\",\"name\":\"Тимашёвск\",\"population\":51858,\"subject\":\"Краснодарский край\"},{\"coords\":{\"lat\":\"59.644213\",\"lon\":\"33.542105\"},\"district\":\"Северо-Западный\",\"name\":\"Тихвин\",\"population\":55415,\"subject\":\"Ленинградская область\"},{\"coords\":{\"lat\":\"45.85\",\"lon\":\"40.11667\"},\"district\":\"Южный\",\"name\":\"Тихорецк\",\"population\":55686,\"subject\":\"Краснодарский край\"},{\"coords\":{\"lat\":\"58.19528\",\"lon\":\"68.25806\"},\"district\":\"Уральский\",\"name\":\"Тобольск\",\"population\":100352,\"subject\":\"Тюменская область\"},{\"coords\":{\"lat\":\"53.516666666667\",\"lon\":\"49.416666666667\"},\"district\":\"Приволжский\",\"name\":\"Тольятти\",\"population\":684709,\"subject\":\"Самарская область\"},{\"coords\":{\"lat\":\"56.48861\",\"lon\":\"84.95222\"},\"district\":\"Сибирский\",\"name\":\"Томск\",\"population\":556478,\"subject\":\"Томская область\"},{\"coords\":{\"lat\":\"57.03333\",\"lon\":\"34.96667\"},\"district\":\"Центральный\",\"name\":\"Торжок\",\"population\":41116,\"subject\":\"Тверская область\"},{\"coords\":{\"lat\":\"55.467\",\"lon\":\"37.3\"},\"district\":\"Центральный\",\"name\":\"Троицк\",\"population\":65043,\"subject\":\"Москва\"},{\"coords\":{\"lat\":\"54.08333\",\"lon\":\"61.56667\"},\"district\":\"Уральский\",\"name\":\"Троицк\",\"population\":70301,\"subject\":\"Челябинская область\"},{\"coords\":{\"lat\":\"44.100016\",\"lon\":\"39.083223\"},\"district\":\"Южный\",\"name\":\"Туапсе\",\"population\":61571,\"subject\":\"Краснодарский край\"},{\"coords\":{\"lat\":\"54.6\",\"lon\":\"53.7\"},\"district\":\"Приволжский\",\"name\":\"Туймазы\",\"population\":68349,\"subject\":\"Башкортостан\"},{\"coords\":{\"lat\":\"54.2\",\"lon\":\"37.61667\"},\"district\":\"Центральный\",\"name\":\"Тула\",\"population\":473622,\"subject\":\"Тульская область\"},{\"coords\":{\"lat\":\"57.15\",\"lon\":\"65.53333\"},\"district\":\"Уральский\",\"name\":\"Тюмень\",\"population\":847488,\"subject\":\"Тюменская область\"},{\"coords\":{\"lat\":\"53.9791417\",\"lon\":\"38.1600833\"},\"district\":\"Центральный\",\"name\":\"Узловая\",\"population\":49427,\"subject\":\"Тульская область\"},{\"coords\":{\"lat\":\"51.83333\",\"lon\":\"107.61667\"},\"district\":\"Сибирский\",\"name\":\"Улан-Удэ\",\"population\":437565,\"subject\":\"Бурятия\"},{\"coords\":{\"lat\":\"54.316666666667\",\"lon\":\"48.366666666667\"},\"district\":\"Приволжский\",\"name\":\"Ульяновск\",\"population\":617352,\"subject\":\"Ульяновская область\"},{\"coords\":{\"lat\":\"60.13333\",\"lon\":\"64.78333\"},\"district\":\"Уральский\",\"name\":\"Урай\",\"population\":41315,\"subject\":\"Ханты-Мансийский АО\"},{\"coords\":{\"lat\":\"43.129123\",\"lon\":\"45.54167\"},\"district\":\"Северо-Кавказский\",\"name\":\"Урус-Мартан\",\"population\":63449,\"subject\":\"Чечня\"},{\"coords\":{\"lat\":\"52.75\",\"lon\":\"103.65\"},\"district\":\"Сибирский\",\"name\":\"Усолье-Сибирское\",\"population\":74762,\"subject\":\"Иркутская область\"},{\"coords\":{\"lat\":\"43.8\",\"lon\":\"131.95\"},\"district\":\"Дальневосточный\",\"name\":\"Уссурийск\",\"population\":180393,\"subject\":\"Приморский край\"},{\"coords\":{\"lat\":\"58\",\"lon\":\"102.66667\"},\"district\":\"Сибирский\",\"name\":\"Усть-Илимск\",\"population\":79570,\"subject\":\"Иркутская область\"},{\"coords\":{\"lat\":\"45.21528\",\"lon\":\"39.68944\"},\"district\":\"Южный\",\"name\":\"Усть-Лабинск\",\"population\":40158,\"subject\":\"Краснодарский край\"},{\"coords\":{\"lat\":\"54.73333\",\"lon\":\"55.96667\"},\"district\":\"Приволжский\",\"name\":\"Уфа\",\"population\":1144809,\"subject\":\"Башкортостан\"},{\"coords\":{\"lat\":\"63.56667\",\"lon\":\"53.7\"},\"district\":\"Северо-Западный\",\"name\":\"Ухта\",\"population\":79899,\"subject\":\"Коми\"},{\"coords\":{\"lat\":\"45.04889\",\"lon\":\"35.37917\"},\"district\":\"Южный\",\"name\":\"Феодосия\",\"population\":66293,\"subject\":\"Крым\"},{\"coords\":{\"lat\":\"55.95\",\"lon\":\"38.05\"},\"district\":\"Центральный\",\"name\":\"Фрязино\",\"population\":60580,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"48.48333\",\"lon\":\"135.06667\"},\"district\":\"Дальневосточный\",\"name\":\"Хабаровск\",\"population\":617441,\"subject\":\"Хабаровский край\"},{\"coords\":{\"lat\":\"61\",\"lon\":\"69\"},\"district\":\"Уральский\",\"name\":\"Ханты-Мансийск\",\"population\":107473,\"subject\":\"Ханты-Мансийский АО\"},{\"coords\":{\"lat\":\"43.249937\",\"lon\":\"46.583247\"},\"district\":\"Северо-Кавказский\",\"name\":\"Хасавюрт\",\"population\":155144,\"subject\":\"Дагестан\"},{\"coords\":{\"lat\":\"55.88917\",\"lon\":\"37.445\"},\"district\":\"Центральный\",\"name\":\"Химки\",\"population\":257128,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"56.773291\",\"lon\":\"54.140386\"},\"district\":\"Приволжский\",\"name\":\"Чайковский\",\"population\":75837,\"subject\":\"Пермский край\"},{\"coords\":{\"lat\":\"52.98333\",\"lon\":\"49.71667\"},\"district\":\"Приволжский\",\"name\":\"Чапаевск\",\"population\":70228,\"subject\":\"Самарская область\"},{\"coords\":{\"lat\":\"54.97778\",\"lon\":\"60.37\"},\"district\":\"Уральский\",\"name\":\"Чебаркуль\",\"population\":44693,\"subject\":\"Челябинская область\"},{\"coords\":{\"lat\":\"56.11667\",\"lon\":\"47.23333\"},\"district\":\"Приволжский\",\"name\":\"Чебоксары\",\"population\":497807,\"subject\":\"Чувашия\"},{\"coords\":{\"lat\":\"55.15\",\"lon\":\"61.4\"},\"district\":\"Уральский\",\"name\":\"Челябинск\",\"population\":1189525,\"subject\":\"Челябинская область\"},{\"coords\":{\"lat\":\"53.15\",\"lon\":\"103.06667\"},\"district\":\"Сибирский\",\"name\":\"Черемхово\",\"population\":53958,\"subject\":\"Иркутская область\"},{\"coords\":{\"lat\":\"59.11667\",\"lon\":\"37.9\"},\"district\":\"Северо-Западный\",\"name\":\"Череповец\",\"population\":305185,\"subject\":\"Вологодская область\"},{\"coords\":{\"lat\":\"44.213888\",\"lon\":\"42.04431\"},\"district\":\"Северо-Кавказский\",\"name\":\"Черкесск\",\"population\":113226,\"subject\":\"Карачаево-Черкесия\"},{\"coords\":{\"lat\":\"53.81667\",\"lon\":\"91.28333\"},\"district\":\"Сибирский\",\"name\":\"Черногорск\",\"population\":75745,\"subject\":\"Хакасия\"},{\"coords\":{\"lat\":\"55.145\",\"lon\":\"37.45556\"},\"district\":\"Центральный\",\"name\":\"Чехов\",\"population\":89025,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"55.36667\",\"lon\":\"50.63333\"},\"district\":\"Приволжский\",\"name\":\"Чистополь\",\"population\":58815,\"subject\":\"Татарстан\"},{\"coords\":{\"lat\":\"52.03333\",\"lon\":\"113.5\"},\"district\":\"Сибирский\",\"name\":\"Чита\",\"population\":334427,\"subject\":\"Забайкальский край\"},{\"coords\":{\"lat\":\"58.28333\",\"lon\":\"57.81667\"},\"district\":\"Приволжский\",\"name\":\"Чусовой\",\"population\":45471,\"subject\":\"Пермский край\"},{\"coords\":{\"lat\":\"56.08333\",\"lon\":\"63.63333\"},\"district\":\"Уральский\",\"name\":\"Шадринск\",\"population\":68609,\"subject\":\"Курганская область\"},{\"coords\":{\"lat\":\"43.145\",\"lon\":\"45.903847\"},\"district\":\"Северо-Кавказский\",\"name\":\"Шали\",\"population\":55054,\"subject\":\"Чечня\"},{\"coords\":{\"lat\":\"47.7122111\",\"lon\":\"40.2083694\"},\"district\":\"Южный\",\"name\":\"Шахты\",\"population\":226452,\"subject\":\"Ростовская область\"},{\"coords\":{\"lat\":\"52.2\",\"lon\":\"104.1\"},\"district\":\"Сибирский\",\"name\":\"Шелехов\",\"population\":41998,\"subject\":\"Иркутская область\"},{\"coords\":{\"lat\":\"56.85\",\"lon\":\"41.36667\"},\"district\":\"Центральный\",\"name\":\"Шуя\",\"population\":55225,\"subject\":\"Ивановская область\"},{\"coords\":{\"lat\":\"55.5\",\"lon\":\"37.56667\"},\"district\":\"Центральный\",\"name\":\"Щербинка\",\"population\":56531,\"subject\":\"Москва\"},{\"coords\":{\"lat\":\"54\",\"lon\":\"37.51667\"},\"district\":\"Центральный\",\"name\":\"Щёкино\",\"population\":55109,\"subject\":\"Тульская область\"},{\"coords\":{\"lat\":\"55.91667\",\"lon\":\"38\"},\"district\":\"Центральный\",\"name\":\"Щёлково\",\"population\":134211,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"55.8\",\"lon\":\"38.45\"},\"district\":\"Центральный\",\"name\":\"Электросталь\",\"population\":146403,\"subject\":\"Московская область\"},{\"coords\":{\"lat\":\"46.31667\",\"lon\":\"44.26667\"},\"district\":\"Южный\",\"name\":\"Элиста\",\"population\":102583,\"subject\":\"Калмыкия\"},{\"coords\":{\"lat\":\"51.46667\",\"lon\":\"46.11667\"},\"district\":\"Приволжский\",\"name\":\"Энгельс\",\"population\":225428,\"subject\":\"Саратовская область\"},{\"coords\":{\"lat\":\"46.95\",\"lon\":\"142.73333\"},\"district\":\"Дальневосточный\",\"name\":\"Южно-Сахалинск\",\"population\":181587,\"subject\":\"Сахалинская область\"},{\"coords\":{\"lat\":\"55.73333\",\"lon\":\"84.9\"},\"district\":\"Сибирский\",\"name\":\"Юрга\",\"population\":79693,\"subject\":\"Кемеровская область\"},{\"coords\":{\"lat\":\"62.027222222222\",\"lon\":\"129.73194444444\"},\"district\":\"Дальневосточный\",\"name\":\"Якутск\",\"population\":355443,\"subject\":\"Якутия\"},{\"coords\":{\"lat\":\"44.49944\",\"lon\":\"34.15528\"},\"district\":\"Южный\",\"name\":\"Ялта\",\"population\":74652,\"subject\":\"Крым\"},{\"coords\":{\"lat\":\"57.61667\",\"lon\":\"39.85\"},\"district\":\"Центральный\",\"name\":\"Ярославль\",\"population\":577279,\"subject\":\"Ярославская область\"},{\"coords\":{\"lat\":\"55.06667\",\"lon\":\"32.68333\"},\"district\":\"Центральный\",\"name\":\"Ярцево\",\"population\":41452,\"subject\":\"Смоленская область\"}]';
  String get listCityVocab => _listCityVocab;
  set listCityVocab(String value) {
    _listCityVocab = value;
    secureStorage.setString('ff_listCityVocab', value);
  }

  void deleteListCityVocab() {
    secureStorage.delete(key: 'ff_listCityVocab');
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}

extension FlutterSecureStorageExtensions on FlutterSecureStorage {
  static final _lock = Lock();

  Future<void> writeSync({required String key, String? value}) async =>
      await _lock.synchronized(() async {
        await write(key: key, value: value);
      });

  void remove(String key) => delete(key: key);

  Future<String?> getString(String key) async => await read(key: key);
  Future<void> setString(String key, String value) async =>
      await writeSync(key: key, value: value);

  Future<bool?> getBool(String key) async => (await read(key: key)) == 'true';
  Future<void> setBool(String key, bool value) async =>
      await writeSync(key: key, value: value.toString());

  Future<int?> getInt(String key) async =>
      int.tryParse(await read(key: key) ?? '');
  Future<void> setInt(String key, int value) async =>
      await writeSync(key: key, value: value.toString());

  Future<double?> getDouble(String key) async =>
      double.tryParse(await read(key: key) ?? '');
  Future<void> setDouble(String key, double value) async =>
      await writeSync(key: key, value: value.toString());

  Future<List<String>?> getStringList(String key) async =>
      await read(key: key).then((result) {
        if (result == null || result.isEmpty) {
          return null;
        }
        return CsvToListConverter()
            .convert(result)
            .first
            .map((e) => e.toString())
            .toList();
      });
  Future<void> setStringList(String key, List<String> value) async =>
      await writeSync(key: key, value: ListToCsvConverter().convert([value]));
}
