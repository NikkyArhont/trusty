import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleStorageKey = '__locale_key__';

class FFLocalizations {
  FFLocalizations(this.locale);

  final Locale locale;

  static FFLocalizations of(BuildContext context) =>
      Localizations.of<FFLocalizations>(context, FFLocalizations)!;

  static List<String> languages() => ['ru', 'en'];

  static late SharedPreferences _prefs;
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();
  static Future storeLocale(String locale) =>
      _prefs.setString(_kLocaleStorageKey, locale);
  static Locale? getStoredLocale() {
    final locale = _prefs.getString(_kLocaleStorageKey);
    return locale != null && locale.isNotEmpty ? createLocale(locale) : null;
  }

  String get languageCode => locale.toString();
  String? get languageShortCode =>
      _languagesWithShortCode.contains(locale.toString())
          ? '${locale.toString()}_short'
          : null;
  int get languageIndex => languages().contains(languageCode)
      ? languages().indexOf(languageCode)
      : 0;

  String getText(String key) =>
      (kTranslationsMap[key] ?? {})[locale.toString()] ?? '';

  String getVariableText({
    String? ruText = '',
    String? enText = '',
  }) =>
      [ruText, enText][languageIndex] ?? '';

  static const Set<String> _languagesWithShortCode = {
    'ar',
    'az',
    'ca',
    'cs',
    'da',
    'de',
    'dv',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'gr',
    'he',
    'hi',
    'hu',
    'it',
    'km',
    'ku',
    'mn',
    'ms',
    'no',
    'pt',
    'ro',
    'ru',
    'rw',
    'sv',
    'th',
    'uk',
    'vi',
  };
}

/// Used if the locale is not supported by GlobalMaterialLocalizations.
class FallbackMaterialLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      SynchronousFuture<MaterialLocalizations>(
        const DefaultMaterialLocalizations(),
      );

  @override
  bool shouldReload(FallbackMaterialLocalizationDelegate old) => false;
}

/// Used if the locale is not supported by GlobalCupertinoLocalizations.
class FallbackCupertinoLocalizationDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(
        const DefaultCupertinoLocalizations(),
      );

  @override
  bool shouldReload(FallbackCupertinoLocalizationDelegate old) => false;
}

class FFLocalizationsDelegate extends LocalizationsDelegate<FFLocalizations> {
  const FFLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<FFLocalizations> load(Locale locale) =>
      SynchronousFuture<FFLocalizations>(FFLocalizations(locale));

  @override
  bool shouldReload(FFLocalizationsDelegate old) => false;
}

Locale createLocale(String language) => language.contains('_')
    ? Locale.fromSubtags(
        languageCode: language.split('_').first,
        scriptCode: language.split('_').last,
      )
    : Locale(language);

bool _isSupportedLocale(Locale locale) {
  final language = locale.toString();
  return FFLocalizations.languages().contains(
    language.endsWith('_')
        ? language.substring(0, language.length - 1)
        : language,
  );
}

final kTranslationsMap = <Map<String, Map<String, String>>>[
  // Login
  {
    'rhoo2u3p': {
      'ru': 'Welcome to TrustCircle',
      'en': '',
    },
    'i120lxs3': {
      'ru': 'Discover services through the people you trust most.',
      'en': '',
    },
    'uredhshz': {
      'ru': 'Номер телефона',
      'en': '',
    },
    'yaaqdndz': {
      'ru': '+7',
      'en': '',
    },
    '3dm94sj1': {
      'ru': 'Мы пришлем вам код для авторизации',
      'en': '',
    },
    'moqlchjs': {
      'ru': 'JD',
      'en': '',
    },
    'apqpdg02': {
      'ru': 'AS',
      'en': '',
    },
    '09tjtig8': {
      'ru': 'MK',
      'en': '',
    },
    'y883xwld': {
      'ru': '12',
      'en': '',
    },
    'd7pbamho': {
      'ru':
          'Join 1,200+ people finding trusted specialists in their inner circle.',
      'en': '',
    },
    'llyucx8t': {
      'ru': 'By continuing, you agree to our',
      'en': '',
    },
    '47qz8tk0': {
      'ru': 'Terms of Service',
      'en': '',
    },
    '8ufg79q1': {
      'ru': '&',
      'en': '',
    },
    'qlj5rnm2': {
      'ru': 'Privacy Policy',
      'en': '',
    },
    'pyczccca': {
      'ru': 'Продолжить',
      'en': '',
    },
  },
  // main
  {
    '6ef5ecez': {
      'ru': 'Trusty',
      'en': '',
    },
    '5za4bwk8': {
      'ru': 'Recommendations you trust',
      'en': '',
    },
    'bm0k963u': {
      'ru': 'Поиск услуг...',
      'en': '',
    },
    'of2007qn': {
      'ru': 'Все',
      'en': '',
    },
  },
  // Search
  {
    '78vel1nk': {
      'ru': 'Поиск услуг...',
      'en': '',
    },
    '6mio2rsv': {
      'ru': 'Очистить',
      'en': '',
    },
    '1hsgtllu': {
      'ru': 'Все',
      'en': '',
    },
    'erpbucl0': {
      'ru': 'История поиска',
      'en': '',
    },
    'sgi0zc0m': {
      'ru': 'Очистить',
      'en': '',
    },
    'xzz5cq7c': {
      'ru': ' Посмотреть результаты на карте',
      'en': '',
    },
  },
  // Categories
  {
    'ie0h3he9': {
      'ru': 'Categories',
      'en': '',
    },
    'u9f422n4': {
      'ru': 'Find trusted experts by category',
      'en': '',
    },
    '1qkaxwga': {
      'ru': 'Beauty',
      'en': '',
    },
    '2djkv0pq': {
      'ru': '124 services',
      'en': '',
    },
    'o923sczk': {
      'ru': 'Health',
      'en': '',
    },
    'vf6tr0jv': {
      'ru': '86 services',
      'en': '',
    },
    '9gau2dqi': {
      'ru': 'Home',
      'en': '',
    },
    'tyvb95wb': {
      'ru': '210 services',
      'en': '',
    },
    'tz26akih': {
      'ru': 'Pets',
      'en': '',
    },
    'njsntfv3': {
      'ru': '45 services',
      'en': '',
    },
    'q3mk1s45': {
      'ru': 'Education',
      'en': '',
    },
    'q6eurd9a': {
      'ru': '67 services',
      'en': '',
    },
    '7t05k6d9': {
      'ru': 'Repair',
      'en': '',
    },
    'd0txbhe4': {
      'ru': '112 services',
      'en': '',
    },
    'gddtgxvn': {
      'ru': 'Events',
      'en': '',
    },
    'hxf4cqqo': {
      'ru': '34 services',
      'en': '',
    },
    '0b0ramcu': {
      'ru': 'Legal',
      'en': '',
    },
    'v7joq1o1': {
      'ru': '29 services',
      'en': '',
    },
    'sbqibbcs': {
      'ru': 'Most Trusted Today',
      'en': '',
    },
    'ssph1y19': {
      'ru': 'Dental Care',
      'en': '',
    },
    'e8xvei1h': {
      'ru': '98%',
      'en': '',
    },
    'nfjoqzsp': {
      'ru': 'Recommended by 12 friends',
      'en': '',
    },
    '48fkkbah': {
      'ru': '+9 others',
      'en': '',
    },
  },
  // Favorites
  {
    'auge734r': {
      'ru': 'Избранное',
      'en': '',
    },
  },
  // ServiceDetail
  {
    'zksodwlb': {
      'ru': 'Перейти в профиль',
      'en': '',
    },
    'et46gnxj': {
      'ru': 'Social Trust',
      'en': '',
    },
    '4i4hb62t': {
      'ru': 'Recommended by 12 people',
      'en': '',
    },
    '92ybfn60': {
      'ru': '3 Contacts',
      'en': '',
    },
    'ilr2znv7': {
      'ru': 'Contact',
      'en': '',
    },
    'o255lgwn': {
      'ru': 'I visited',
      'en': '',
    },
    'agpx2kyu': {
      'ru': 'Recommend to Circle',
      'en': '',
    },
  },
  // UserProfile
  {
    '1qf95kwx': {
      'ru': 'Создать профиль мастера',
      'en': '',
    },
    '1inecjjt': {
      'ru':
          'Создавайте свой услуги и получайте больше заявок по рекомендациям от пользователей',
      'en': '',
    },
    '8j2krl5l': {
      'ru': 'Recent Visits',
      'en': '',
    },
    '0vrzdt65': {
      'ru': 'View All',
      'en': '',
    },
    '9k807g8s': {
      'ru': 'Account Settings',
      'en': '',
    },
    'xeegqtsd': {
      'ru': 'Notifications',
      'en': '',
    },
    'mm6k5bsd': {
      'ru': 'Saved Specialists',
      'en': '',
    },
    'qw0xsmd4': {
      'ru': 'Invite Friends',
      'en': '',
    },
    'm5jp3ix0': {
      'ru': 'Support & Help',
      'en': '',
    },
  },
  // SpecialistDashboard
  {
    'ms588699': {
      'ru': 'Панель',
      'en': '',
    },
    'xhclap64': {
      'ru': 'Network Reach',
      'en': '',
    },
    'fruc1nxh': {
      'ru': 'Monthly Recommendations',
      'en': '',
    },
    '8zhzfoeg': {
      'ru': 'My Services',
      'en': '',
    },
    '4nwcz0lg': {
      'ru': 'Add New',
      'en': '',
    },
    'uh8ukhin': {
      'ru': 'Quick Actions',
      'en': '',
    },
    'd5dbixsc': {
      'ru': 'Edit Specialist Profile',
      'en': '',
    },
    '1y7dswkx': {
      'ru': 'Archived Services',
      'en': '',
    },
    'bmiabt4i': {
      'ru': 'Share Booking Link',
      'en': '',
    },
    '55g0q9gl': {
      'ru': 'Switch to Client Mode',
      'en': '',
    },
    'eozakv5a': {
      'ru': 'Browse and book other services',
      'en': '',
    },
  },
  // recordPageClient
  {
    'h6p8h33h': {
      'ru': 'Certified Specialist',
      'en': '',
    },
    '55h32fio': {
      'ru': 'Ожидаем подтверждения от мастера',
      'en': '',
    },
    'o2i1e6l0': {
      'ru':
          'Когда мастер подтвердит запись, здесь появится дополнительная информация',
      'en': '',
    },
    'y794wibd': {
      'ru': 'Контакты',
      'en': '',
    },
    'nbkyfex5': {
      'ru': 'Отменить запись',
      'en': '',
    },
    'sn3tia7r': {
      'ru': 'Confirm your visit',
      'en': '',
    },
    'aje49qg4': {
      'ru':
          'Help your contacts find trusted specialists by sharing your experience.',
      'en': '',
    },
    'uzag11r2': {
      'ru': 'I visited this specialist',
      'en': '',
    },
    'wnpbmppk': {
      'ru': 'I recommend this specialist',
      'en': '',
    },
    'i5s1yrix': {
      'ru': 'Share more details',
      'en': '',
    },
    '0z0h72zp': {
      'ru': 'Leave a short comment (optional)',
      'en': '',
    },
    'da4eqoaw': {
      'ru': 'Your recommendation will be visible to your contacts.',
      'en': '',
    },
    'z78kn659': {
      'ru': 'Cancel',
      'en': '',
    },
  },
  // editService
  {
    '2pk8dxf8': {
      'ru': 'Например: массаж',
      'en': '',
    },
    'vy2pxy4r': {
      'ru': 'Изменить',
      'en': '',
    },
    '9y8yc414': {
      'ru': 'Например: Красная 144',
      'en': '',
    },
    't2ke2vuu': {
      'ru': 'Например: спины, шеи и пр.',
      'en': '',
    },
    'dgiq8hvh': {
      'ru': 'за услугу',
      'en': '',
    },
    'q0i5gr7z': {
      'ru': 'в минутах',
      'en': '',
    },
    'qw80udrw': {
      'ru': 'Additional Services',
      'en': '',
    },
    'rw7rr4g5': {
      'ru': 'Enable extra add-ons for this service',
      'en': '',
    },
    't7hzxc2l': {
      'ru': 'Сохранить изменения',
      'en': '',
    },
    'ajv2evw0': {
      'ru': 'Удалить услугу',
      'en': '',
    },
    'uokub5fi': {
      'ru': 'Создать услугу',
      'en': '',
    },
  },
  // sms
  {
    '2ytlj0wi': {
      'ru': 'СМС-код',
      'en': '',
    },
    'z7s2r5z2': {
      'ru': 'Мы отправили код на',
      'en': '',
    },
    'h58pggii': {
      'ru': 'Отправить повторно через',
      'en': '',
    },
    'bfhhunv5': {
      'ru': '00:48',
      'en': '',
    },
    'igud3czq': {
      'ru': 'Изменить номер телефона',
      'en': '',
    },
    'q467ct16': {
      'ru': 'Продолжить',
      'en': '',
    },
  },
  // records
  {
    'jfsw63vl': {
      'ru': 'Записи',
      'en': '',
    },
    'gnoanfnv': {
      'ru': 'Запросы',
      'en': '',
    },
    'da9kktub': {
      'ru': 'Расписание',
      'en': '',
    },
    'ugli50ot': {
      'ru': 'Pending Requests',
      'en': '',
    },
    '66z7kkwf': {
      'ru': 'Upcoming Visits',
      'en': '',
    },
  },
  // myServices
  {
    'w21i75dq': {
      'ru': 'Мои услуги',
      'en': '',
    },
    'cj35joe3': {
      'ru': 'Вы можете добавить до 5 услуг в свой профиль. ',
      'en': '',
    },
    'ml7tjxuu': {
      'ru': 'Создать новую услугу',
      'en': '',
    },
  },
  // chooseLocationCity
  {
    'c4xq9wb4': {
      'ru': 'Выберите свой город',
      'en': '',
    },
    'ie17ultr': {
      'ru': 'Чтобы найти услуги и клиентов рядом с Вами',
      'en': '',
    },
    'xamu0jwy': {
      'ru': 'Введите название',
      'en': '',
    },
    'hfwzvn2l': {
      'ru': 'Подтвердить',
      'en': '',
    },
  },
  // EditProfile
  {
    'pf0e32i2': {
      'ru': 'Редактировать',
      'en': '',
    },
    '8dhm9ity': {
      'ru': 'Имя',
      'en': '',
    },
    'hdt8ivaj': {
      'ru': 'О себе',
      'en': '',
    },
    '5fm06avj': {
      'ru': 'Переключить тему',
      'en': '',
    },
    '73ja9kd1': {
      'ru': 'Allow others to see your recommendation weight',
      'en': '',
    },
    'dhpmn30l': {
      'ru': 'Синхронизировать контакты',
      'en': '',
    },
    'tyy0ss41': {
      'ru': 'Find friends to see their recommendations',
      'en': '',
    },
    '2xjjlkj0': {
      'ru': 'Управление аккаунтом',
      'en': '',
    },
    'z5v9zc0a': {
      'ru': 'Visit History',
      'en': '',
    },
    '1yguwjbh': {
      'ru': 'Выйти',
      'en': '',
    },
    'z7rso59u': {
      'ru': 'Удалить аккаунт',
      'en': '',
    },
    'hiy7hqd5': {
      'ru': 'Это действие нельзя отменить',
      'en': '',
    },
  },
  // SearchResult
  {
    'gpfqo0lp': {
      'ru': 'Карта',
      'en': '',
    },
    'nbdslzq7': {
      'ru': 'Список',
      'en': '',
    },
  },
  // EditProfileMaster
  {
    '0xrybang': {
      'ru': 'Профиль мастера',
      'en': '',
    },
    'usmerrp4': {
      'ru': 'Название',
      'en': '',
    },
    'x6pqju0g': {
      'ru': 'Описание',
      'en': '',
    },
    'jvo3hc0r': {
      'ru':
          'Выбранный адрес и категория будут предустановлены ко всем Вашим услугам. \nНо вы всегда можете их изменить при создании услуг',
      'en': '',
    },
    'v5prgqlh': {
      'ru': 'Изменить',
      'en': '',
    },
    '4fyt8tg9': {
      'ru': 'Сохранить',
      'en': '',
    },
  },
  // masterPage
  {
    '8lihgkbi': {
      'ru': 'Semen & 2 other contacts recommend',
      'en': '',
    },
    'iz458npx': {
      'ru': 'High trust score based on your social circle',
      'en': '',
    },
    'nol6k5x3': {
      'ru': 'Услуги',
      'en': '',
    },
    '5wo798cj': {
      'ru': 'Filter',
      'en': '',
    },
    'r2v4ytku': {
      'ru': 'Response time',
      'en': '',
    },
    'lawnsui4': {
      'ru': '~15 mins',
      'en': '',
    },
    's7jmheux': {
      'ru': 'Contact Specialist',
      'en': '',
    },
  },
  // recordPageMaster
  {
    'uzsowjzi': {
      'ru': 'Запись',
      'en': '',
    },
    'tixrebhr': {
      'ru': 'Клиент',
      'en': '',
    },
    'kc0n4r96': {
      'ru': 'Услуга',
      'en': '',
    },
    'ui7n1sr3': {
      'ru': 'Клиент ждет подтверждения',
      'en': '',
    },
    'bjgcuhqb': {
      'ru': 'Согласуйте с клиентом и выберите дату оказания услуги',
      'en': '',
    },
    '4tl4bbzl': {
      'ru': 'Выбранное время:',
      'en': '',
    },
    'dv4879am': {
      'ru': 'Выбрать дату',
      'en': '',
    },
    'wue3q6u6': {
      'ru': 'Контакты',
      'en': '',
    },
    'p550d5wr': {
      'ru': 'Подтвердить запись',
      'en': '',
    },
    'zxlm7xkx': {
      'ru': 'Отменить запись',
      'en': '',
    },
    'j74og9am': {
      'ru': 'Confirm your visit',
      'en': '',
    },
    'jlpnmsy5': {
      'ru':
          'Help your contacts find trusted specialists by sharing your experience.',
      'en': '',
    },
    '5yf4qywj': {
      'ru': 'I visited this specialist',
      'en': '',
    },
    '2xbicr2i': {
      'ru': 'I recommend this specialist',
      'en': '',
    },
    'nvdco5j7': {
      'ru': 'Share more details',
      'en': '',
    },
    '0190s11a': {
      'ru': 'Leave a short comment (optional)',
      'en': '',
    },
    's2o31er2': {
      'ru': 'Your recommendation will be visible to your contacts.',
      'en': '',
    },
    'sw919g47': {
      'ru': 'Cancel',
      'en': '',
    },
  },
  // SearchInput
  {
    'wy7vqevc': {
      'ru': 'Search services...',
      'en': '',
    },
  },
  // ServiceCardExtra
  {
    'vxmkzs8n': {
      'ru': '+2 more services',
      'en': '',
    },
  },
  // ServiceCardClient
  {
    'yxlz56k4': {
      'ru': '•',
      'en': '',
    },
    '1bo9kc55': {
      'ru': ' 98%',
      'en': '',
    },
    '345ywele': {
      'ru': '13',
      'en': '',
    },
  },
  // VisitItem
  {
    '7m1usi4s': {
      'ru': 'Completed',
      'en': '',
    },
  },
  // menu
  {
    '7auwom16': {
      'ru': 'Панель',
      'en': '',
    },
    '1sts2fs0': {
      'ru': 'Мои услуги',
      'en': '',
    },
    'w34zbn3q': {
      'ru': 'Записи',
      'en': '',
    },
    'j9tiuuk9': {
      'ru': 'Профиль',
      'en': '',
    },
    'zrgx6a00': {
      'ru': 'Главная',
      'en': '',
    },
    'bxvure6x': {
      'ru': 'Поиск',
      'en': '',
    },
    'ilmtj8go': {
      'ru': 'Избранное',
      'en': '',
    },
    'ihylkvry': {
      'ru': 'Профиль',
      'en': '',
    },
  },
  // AppointmentCard
  {
    'y92l5fkh': {
      'ru': 'JD',
      'en': '',
    },
  },
  // SpecialistServiceCard
  {
    '19y85y6g': {
      'ru': '•',
      'en': '',
    },
    't6dd83p0': {
      'ru': '12 Recs',
      'en': '',
    },
    'oup3y74t': {
      'ru': '24 Clients',
      'en': '',
    },
    '048gzdbj': {
      'ru': 'Удалить',
      'en': '',
    },
    'h1eckqjc': {
      'ru': 'Редактировать',
      'en': '',
    },
  },
  // currentLocation
  {
    'aauulvwl': {
      'ru': 'Местоположение',
      'en': '',
    },
  },
  // uploadMedia
  {
    'wxllapno': {
      'ru': 'Камера',
      'en': '',
    },
    'qujpa0e5': {
      'ru': 'Галерея',
      'en': '',
    },
  },
  // noFavorite
  {
    'uc2ocjhr': {
      'ru': 'Здесь пока пусто =(',
      'en': '',
    },
    '68s46vss': {
      'ru': 'Сохраните первую услугу себе в избраное',
      'en': '',
    },
  },
  // saveServChange
  {
    'rxkx5udy': {
      'ru': 'Изменения сохранены',
      'en': '',
    },
    'audoqkgm': {
      'ru': 'Услуга создана',
      'en': '',
    },
    '7iln8vsd': {
      'ru': 'Хорошо',
      'en': '',
    },
  },
  // createVocab
  {
    'e55rke39': {
      'ru': 'create list city',
      'en': '',
    },
  },
  // noService
  {
    '1gduukvi': {
      'ru': 'Здесь пока пусто =(',
      'en': '',
    },
    'k9q5yztn': {
      'ru': 'Создайте свою первую услугу',
      'en': '',
    },
  },
  // SpecialistServiceCardMap
  {
    'ckzmreej': {
      'ru': '•',
      'en': '',
    },
    '7ghk9fw8': {
      'ru': '12 Recs',
      'en': '',
    },
    'hborns68': {
      'ru': '24 Clients',
      'en': '',
    },
  },
  // noSetLoc
  {
    'ufp94dlt': {
      'ru': 'Не удается определить местоположение',
      'en': '',
    },
    'kh9dczy5': {
      'ru':
          'Убедитесь что геолокация включена на устройстве, или попробуйте повторить позднее',
      'en': '',
    },
    '9oojginv': {
      'ru': 'Хорошо',
      'en': '',
    },
  },
  // delServ
  {
    'r9urwors': {
      'ru': 'Уверены что хотите удалить услугу?',
      'en': '',
    },
    '3e8ao5bu': {
      'ru': 'Это дейстие нельзя отменить',
      'en': '',
    },
    '4gjsf3pk': {
      'ru': 'Отмена',
      'en': '',
    },
    'j6t4dpxe': {
      'ru': 'Да, удалить',
      'en': '',
    },
  },
  // noSetLocCopy
  {
    'dihgho8l': {
      'ru': 'Не удается определить местоположение',
      'en': '',
    },
    '4aj6oubc': {
      'ru':
          'Убедитесь что геолокация включена на устройстве, или попробуйте повторить позднее',
      'en': '',
    },
    'prbq7l6i': {
      'ru': 'Хорошо',
      'en': '',
    },
  },
  // noSetLocCopyCopy
  {
    'hypauy6c': {
      'ru': 'Не удается определить местоположение',
      'en': '',
    },
    'tuxl5n7t': {
      'ru':
          'Убедитесь что геолокация включена на устройстве, или попробуйте повторить позднее',
      'en': '',
    },
    'xh00xsmo': {
      'ru': 'Хорошо',
      'en': '',
    },
  },
  // contact_avatars
  {
    'z2ppj88b': {
      'ru': 'JD',
      'en': '',
    },
    '6n40evke': {
      'ru': 'AS',
      'en': '',
    },
    '6j66kmhj': {
      'ru': 'MK',
      'en': '',
    },
  },
  // serviceCardBig
  {
    'egijd7bc': {
      'ru': 'Recommended by 48 people',
      'en': '',
    },
    '7cyqb1tx': {
      'ru': 'Book Session',
      'en': '',
    },
  },
  // phoneCall
  {
    'kqzi00sa': {
      'ru': 'Позвонить',
      'en': '',
    },
    't84giho8': {
      'ru': 'Скопировать',
      'en': '',
    },
  },
  // Miscellaneous
  {
    'xu6gj5aj': {
      'ru': 'TextField',
      'en': '',
    },
    'afgjavvu': {
      'ru': 'Мои услуги',
      'en': '',
    },
    'ebtxirtj': {
      'ru': 'Save and Confirm',
      'en': '',
    },
    'f822pv36': {
      'ru': '',
      'en': '',
    },
    'i37q67wq': {
      'ru': '',
      'en': '',
    },
    '4zwadiak': {
      'ru': '',
      'en': '',
    },
    'v6s7y3jk': {
      'ru': '',
      'en': '',
    },
    'rrh82y07': {
      'ru': '',
      'en': '',
    },
    'mxef7836': {
      'ru': '',
      'en': '',
    },
    'bt92jgbd': {
      'ru': '',
      'en': '',
    },
    'fm4np5i6': {
      'ru': '',
      'en': '',
    },
    'q2g9onuo': {
      'ru': '',
      'en': '',
    },
    'vqd1ld64': {
      'ru': '',
      'en': '',
    },
    'sduvtigo': {
      'ru': '',
      'en': '',
    },
    '9qhhgani': {
      'ru': '',
      'en': '',
    },
    'uqhej351': {
      'ru': '',
      'en': '',
    },
    '7fidm1wk': {
      'ru': '',
      'en': '',
    },
    's6w3803q': {
      'ru': '',
      'en': '',
    },
    'ymitbhkw': {
      'ru': '',
      'en': '',
    },
    'gzula4a7': {
      'ru': '',
      'en': '',
    },
    'kpgc0e10': {
      'ru': '',
      'en': '',
    },
    'c0ndrbrb': {
      'ru': '',
      'en': '',
    },
    'lzux66j8': {
      'ru': '',
      'en': '',
    },
    'h5qgdg5t': {
      'ru': '',
      'en': '',
    },
    'astl1q7w': {
      'ru': '',
      'en': '',
    },
    'cdj1l3ux': {
      'ru': '',
      'en': '',
    },
    'xnnlj448': {
      'ru': '',
      'en': '',
    },
    'mep203v8': {
      'ru': '',
      'en': '',
    },
    '1xhmqm9g': {
      'ru': '',
      'en': '',
    },
    'tftg1if5': {
      'ru': '',
      'en': '',
    },
    'xdcwv6yo': {
      'ru': '',
      'en': '',
    },
  },
].reduce((a, b) => a..addAll(b));
