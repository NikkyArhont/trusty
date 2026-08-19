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

  static List<String> languages() => ['ru'];

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

  String getText(String key) {
    final translations = kTranslationsMap[key] ?? const <String, String>{};
    final localizedText = translations[locale.toString()];
    if (localizedText != null && localizedText.isNotEmpty) {
      return localizedText;
    }
    return translations['ru'] ?? '';
  }

  String getVariableText({String? ruText = '', String? enText = ''}) {
    final localizedText = [ruText, enText][languageIndex] ?? '';
    return localizedText.isNotEmpty ? localizedText : (ruText ?? '');
  }

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
    'rhoo2u3p': {'ru': 'Добро пожаловать в Сарафан', 'en': ''},
    'i120lxs3': {
      'ru': 'Находите услуги через людей, которым доверяете.',
      'en': '',
    },
    'uredhshz': {'ru': 'Номер телефона', 'en': ''},
    'yaaqdndz': {'ru': '+7', 'en': ''},
    '3dm94sj1': {'ru': 'Мы пришлем вам код для авторизации', 'en': ''},
    'moqlchjs': {'ru': 'JD', 'en': ''},
    'apqpdg02': {'ru': 'AS', 'en': ''},
    '09tjtig8': {'ru': 'MK', 'en': ''},
    'y883xwld': {'ru': '12', 'en': ''},
    'd7pbamho': {
      'ru':
          'Присоединяйтесь к 1 200+ людям, которые находят проверенных специалистов среди рекомендаций знакомых.',
      'en': '',
    },
    'llyucx8t': {'ru': 'Продолжая, вы принимаете', 'en': ''},
    '47qz8tk0': {'ru': 'Условиями использования', 'en': ''},
    '8ufg79q1': {'ru': '&', 'en': ''},
    'qlj5rnm2': {'ru': 'Политикой конфиденциальности', 'en': ''},
    'pyczccca': {'ru': 'Продолжить', 'en': ''},
  },
  // main
  {
    '6ef5ecez': {'ru': 'Сарафан', 'en': ''},
    '5za4bwk8': {'ru': 'Рекомендации, которым вы доверяете', 'en': ''},
    'bm0k963u': {'ru': 'Поиск услуг...', 'en': ''},
    'of2007qn': {'ru': 'Все', 'en': ''},
  },
  // Search
  {
    '78vel1nk': {'ru': 'Поиск услуг...', 'en': ''},
    '6mio2rsv': {'ru': 'Очистить', 'en': ''},
    '1hsgtllu': {'ru': 'Все', 'en': ''},
    'erpbucl0': {'ru': 'История поиска', 'en': ''},
    'sgi0zc0m': {'ru': 'Очистить', 'en': ''},
    'xzz5cq7c': {'ru': ' Посмотреть результаты на карте', 'en': ''},
  },
  // Categories
  {
    'ie0h3he9': {'ru': 'Категории', 'en': ''},
    'u9f422n4': {
      'ru': 'Найдите проверенных специалистов по категории',
      'en': '',
    },
    '1qkaxwga': {'ru': 'Красота', 'en': ''},
    '2djkv0pq': {'ru': '124 услуги', 'en': ''},
    'o923sczk': {'ru': 'Здоровье', 'en': ''},
    'vf6tr0jv': {'ru': '86 услуг', 'en': ''},
    '9gau2dqi': {'ru': 'Дом', 'en': ''},
    'tyvb95wb': {'ru': '210 услуг', 'en': ''},
    'tz26akih': {'ru': 'Питомцы', 'en': ''},
    'njsntfv3': {'ru': '45 услуг', 'en': ''},
    'q3mk1s45': {'ru': 'Образование', 'en': ''},
    'q6eurd9a': {'ru': '67 услуг', 'en': ''},
    '7t05k6d9': {'ru': 'Ремонт', 'en': ''},
    'd0txbhe4': {'ru': '112 услуг', 'en': ''},
    'gddtgxvn': {'ru': 'Мероприятия', 'en': ''},
    'hxf4cqqo': {'ru': '34 услуги', 'en': ''},
    '0b0ramcu': {'ru': 'Юридические услуги', 'en': ''},
    'v7joq1o1': {'ru': '29 услуг', 'en': ''},
    'sbqibbcs': {'ru': 'Самые рекомендуемые сегодня', 'en': ''},
    'ssph1y19': {'ru': 'Стоматология', 'en': ''},
    'e8xvei1h': {'ru': '98%', 'en': ''},
    'nfjoqzsp': {'ru': 'Рекомендуют 12 друзей', 'en': ''},
    '48fkkbah': {'ru': '+ ещё 9', 'en': ''},
  },
  // Favorites
  {
    'auge734r': {'ru': 'Избранное', 'en': ''},
  },
  // ServiceDetail
  {
    'zksodwlb': {'ru': 'Перейти в профиль', 'en': ''},
    'et46gnxj': {'ru': 'Доверие окружения', 'en': ''},
    '4i4hb62t': {'ru': 'Рекомендуют 12 человек', 'en': ''},
    '92ybfn60': {'ru': '3 контакта', 'en': ''},
    'ilr2znv7': {'ru': 'Связаться', 'en': ''},
    'o255lgwn': {'ru': 'Я был у специалиста', 'en': ''},
    'agpx2kyu': {'ru': 'Порекомендовать знакомым', 'en': ''},
  },
  // UserProfile
  {
    '1qf95kwx': {'ru': 'Создать профиль мастера', 'en': ''},
    '1inecjjt': {
      'ru':
          'Создавайте свой услуги и получайте больше заявок по рекомендациям от пользователей',
      'en': '',
    },
    '8j2krl5l': {'ru': 'Недавние посещения', 'en': ''},
    '0vrzdt65': {'ru': 'Посмотреть все', 'en': ''},
    '9k807g8s': {'ru': 'Настройки аккаунта', 'en': ''},
    'xeegqtsd': {'ru': 'Уведомления', 'en': ''},
    'mm6k5bsd': {'ru': 'Сохранённые специалисты', 'en': ''},
    'qw0xsmd4': {'ru': 'Пригласить друзей', 'en': ''},
    'm5jp3ix0': {'ru': 'Поддержка и помощь', 'en': ''},
  },
  // SpecialistDashboard
  {
    'ms588699': {'ru': 'Панель', 'en': ''},
    'xhclap64': {'ru': 'Охват рекомендаций', 'en': ''},
    'fruc1nxh': {'ru': 'Рекомендации по месяцам', 'en': ''},
    '8zhzfoeg': {'ru': 'Мои услуги', 'en': ''},
    '4nwcz0lg': {'ru': 'Добавить', 'en': ''},
    'uh8ukhin': {'ru': 'Быстрые действия', 'en': ''},
    'd5dbixsc': {'ru': 'Редактировать профиль специалиста', 'en': ''},
    '1y7dswkx': {'ru': 'Архивные услуги', 'en': ''},
    'bmiabt4i': {'ru': 'Поделиться ссылкой для записи', 'en': ''},
    '55g0q9gl': {'ru': 'Перейти в режим клиента', 'en': ''},
    'eozakv5a': {'ru': 'Искать и бронировать другие услуги', 'en': ''},
  },
  // recordPageClient
  {
    'h6p8h33h': {'ru': 'Проверенный специалист', 'en': ''},
    '55h32fio': {'ru': 'Ожидаем подтверждения от мастера', 'en': ''},
    'o2i1e6l0': {
      'ru':
          'Когда мастер подтвердит запись, здесь появится дополнительная информация',
      'en': '',
    },
    'y794wibd': {'ru': 'Контакты', 'en': ''},
    'nbkyfex5': {'ru': 'Отменить запись', 'en': ''},
    'sn3tia7r': {'ru': 'Подтвердите посещение', 'en': ''},
    'aje49qg4': {
      'ru':
          'Помогите вашим контактам найти проверенных специалистов, поделившись своим опытом.',
      'en': '',
    },
    'uzag11r2': {'ru': 'Я был у этого специалиста', 'en': ''},
    'wnpbmppk': {'ru': 'Я рекомендую этого специалиста', 'en': ''},
    'i5s1yrix': {'ru': 'Расскажите подробнее', 'en': ''},
    '0z0h72zp': {
      'ru': 'Оставьте короткий комментарий (необязательно)',
      'en': '',
    },
    'da4eqoaw': {'ru': 'Вашу рекомендацию увидят ваши контакты.', 'en': ''},
    'z78kn659': {'ru': 'Отмена', 'en': ''},
  },
  // editService
  {
    '2pk8dxf8': {'ru': 'Например: массаж', 'en': ''},
    'vy2pxy4r': {'ru': 'Изменить', 'en': ''},
    '9y8yc414': {'ru': 'Например: Красная 144', 'en': ''},
    't2ke2vuu': {'ru': 'Например: спины, шеи и пр.', 'en': ''},
    'dgiq8hvh': {'ru': 'за услугу', 'en': ''},
    'q0i5gr7z': {'ru': 'в минутах', 'en': ''},
    'qw80udrw': {'ru': 'Дополнительные услуги', 'en': ''},
    'rw7rr4g5': {
      'ru': 'Добавьте дополнительные опции для этой услуги',
      'en': '',
    },
    't7hzxc2l': {'ru': 'Сохранить изменения', 'en': ''},
    'ajv2evw0': {'ru': 'Удалить услугу', 'en': ''},
    'uokub5fi': {'ru': 'Создать услугу', 'en': ''},
  },
  // sms
  {
    '2ytlj0wi': {'ru': 'СМС-код', 'en': ''},
    'z7s2r5z2': {'ru': 'Мы отправили код на', 'en': ''},
    'h58pggii': {'ru': 'Отправить повторно через', 'en': ''},
    'bfhhunv5': {'ru': '00:48', 'en': ''},
    'igud3czq': {'ru': 'Изменить номер телефона', 'en': ''},
    'q467ct16': {'ru': 'Продолжить', 'en': ''},
  },
  // records
  {
    'jfsw63vl': {'ru': 'Записи', 'en': ''},
    'gnoanfnv': {'ru': 'Запросы', 'en': ''},
    'da9kktub': {'ru': 'Расписание', 'en': ''},
    'ugli50ot': {'ru': 'Ожидающие запросы', 'en': ''},
    '66z7kkwf': {'ru': 'Предстоящие посещения', 'en': ''},
  },
  // myServices
  {
    'w21i75dq': {'ru': 'Мои услуги', 'en': ''},
    'cj35joe3': {
      'ru': 'Вы можете добавить до 5 услуг в свой профиль. ',
      'en': '',
    },
    'ml7tjxuu': {'ru': 'Создать новую услугу', 'en': ''},
  },
  // chooseLocationCity
  {
    'c4xq9wb4': {'ru': 'Выберите свой город', 'en': ''},
    'ie17ultr': {'ru': 'Чтобы найти услуги и клиентов рядом с Вами', 'en': ''},
    'xamu0jwy': {'ru': 'Введите название', 'en': ''},
    'hfwzvn2l': {'ru': 'Подтвердить', 'en': ''},
  },
  // EditProfile
  {
    'pf0e32i2': {'ru': 'Редактировать', 'en': ''},
    '8dhm9ity': {'ru': 'Имя', 'en': ''},
    'hdt8ivaj': {'ru': 'О себе', 'en': ''},
    '5fm06avj': {'ru': 'Переключить тему', 'en': ''},
    '73ja9kd1': {
      'ru': 'Разрешить другим видеть вес ваших рекомендаций',
      'en': '',
    },
    'dhpmn30l': {'ru': 'Синхронизировать контакты', 'en': ''},
    'tyy0ss41': {
      'ru': 'Найдите друзей, чтобы видеть их рекомендации',
      'en': '',
    },
    '2xjjlkj0': {'ru': 'Управление аккаунтом', 'en': ''},
    'z5v9zc0a': {'ru': 'История посещений', 'en': ''},
    '1yguwjbh': {'ru': 'Выйти', 'en': ''},
    'z7rso59u': {'ru': 'Удалить аккаунт', 'en': ''},
    'hiy7hqd5': {'ru': 'Это действие нельзя отменить', 'en': ''},
  },
  // SearchResult
  {
    'gpfqo0lp': {'ru': 'Карта', 'en': ''},
    'nbdslzq7': {'ru': 'Список', 'en': ''},
  },
  // EditProfileMaster
  {
    '0xrybang': {'ru': 'Профиль мастера', 'en': ''},
    'usmerrp4': {'ru': 'Название', 'en': ''},
    'x6pqju0g': {'ru': 'Описание', 'en': ''},
    'jvo3hc0r': {
      'ru':
          'Выбранный адрес и категория будут предустановлены ко всем Вашим услугам. \nНо вы всегда можете их изменить при создании услуг',
      'en': '',
    },
    'v5prgqlh': {'ru': 'Изменить', 'en': ''},
    '4fyt8tg9': {'ru': 'Сохранить', 'en': ''},
  },
  // masterPage
  {
    '8lihgkbi': {'ru': 'Семён и ещё 2 контакта рекомендуют', 'en': ''},
    'iz458npx': {
      'ru': 'Высокий уровень доверия по оценкам вашего окружения',
      'en': '',
    },
    'nol6k5x3': {'ru': 'Услуги', 'en': ''},
    '5wo798cj': {'ru': 'Фильтр', 'en': ''},
    'r2v4ytku': {'ru': 'Время ответа', 'en': ''},
    'lawnsui4': {'ru': '~15 минут', 'en': ''},
    's7jmheux': {'ru': 'Связаться со специалистом', 'en': ''},
  },
  // recordPageMaster
  {
    'uzsowjzi': {'ru': 'Запись', 'en': ''},
    'tixrebhr': {'ru': 'Клиент', 'en': ''},
    'kc0n4r96': {'ru': 'Услуга', 'en': ''},
    'ui7n1sr3': {'ru': 'Клиент ждет подтверждения', 'en': ''},
    'bjgcuhqb': {
      'ru': 'Согласуйте с клиентом и выберите дату оказания услуги',
      'en': '',
    },
    '4tl4bbzl': {'ru': 'Выбранное время:', 'en': ''},
    'dv4879am': {'ru': 'Выбрать дату', 'en': ''},
    'wue3q6u6': {'ru': 'Контакты', 'en': ''},
    'p550d5wr': {'ru': 'Подтвердить запись', 'en': ''},
    'zxlm7xkx': {'ru': 'Отменить запись', 'en': ''},
    'j74og9am': {'ru': 'Подтвердите посещение', 'en': ''},
    'jlpnmsy5': {
      'ru':
          'Помогите вашим контактам найти проверенных специалистов, поделившись своим опытом.',
      'en': '',
    },
    '5yf4qywj': {'ru': 'Я был у этого специалиста', 'en': ''},
    '2xbicr2i': {'ru': 'Я рекомендую этого специалиста', 'en': ''},
    'nvdco5j7': {'ru': 'Расскажите подробнее', 'en': ''},
    '0190s11a': {
      'ru': 'Оставьте короткий комментарий (необязательно)',
      'en': '',
    },
    's2o31er2': {'ru': 'Вашу рекомендацию увидят ваши контакты.', 'en': ''},
    'sw919g47': {'ru': 'Отмена', 'en': ''},
  },
  // SearchInput
  {
    'wy7vqevc': {'ru': 'Поиск услуг...', 'en': ''},
  },
  // ServiceCardExtra
  {
    'vxmkzs8n': {'ru': '+ ещё 2 услуги', 'en': ''},
  },
  // ServiceCardClient
  {
    'yxlz56k4': {'ru': '•', 'en': ''},
    '1bo9kc55': {'ru': ' 98%', 'en': ''},
    '345ywele': {'ru': '13', 'en': ''},
  },
  // VisitItem
  {
    '7m1usi4s': {'ru': 'Завершено', 'en': ''},
  },
  // menu
  {
    '7auwom16': {'ru': 'Панель', 'en': ''},
    '1sts2fs0': {'ru': 'Мои услуги', 'en': ''},
    'w34zbn3q': {'ru': 'Записи', 'en': ''},
    'j9tiuuk9': {'ru': 'Профиль', 'en': ''},
    'zrgx6a00': {'ru': 'Главная', 'en': ''},
    'bxvure6x': {'ru': 'Чаты', 'en': ''},
    'ilmtj8go': {'ru': 'Кабинет', 'en': ''},
    'ihylkvry': {'ru': 'Профиль', 'en': ''},
  },
  // AppointmentCard
  {
    'y92l5fkh': {'ru': 'JD', 'en': ''},
  },
  // SpecialistServiceCard
  {
    '19y85y6g': {'ru': '•', 'en': ''},
    't6dd83p0': {'ru': '12 рекомендаций', 'en': ''},
    'oup3y74t': {'ru': '24 клиента', 'en': ''},
    '048gzdbj': {'ru': 'Удалить', 'en': ''},
    'h1eckqjc': {'ru': 'Редактировать', 'en': ''},
  },
  // currentLocation
  {
    'aauulvwl': {'ru': 'Местоположение', 'en': ''},
  },
  // uploadMedia
  {
    'wxllapno': {'ru': 'Камера', 'en': ''},
    'qujpa0e5': {'ru': 'Галерея', 'en': ''},
  },
  // noFavorite
  {
    'uc2ocjhr': {'ru': 'Здесь пока пусто =(', 'en': ''},
    '68s46vss': {'ru': 'Сохраните первую услугу себе в избранное', 'en': ''},
  },
  // saveServChange
  {
    'rxkx5udy': {'ru': 'Изменения сохранены', 'en': ''},
    'audoqkgm': {'ru': 'Услуга создана', 'en': ''},
    '7iln8vsd': {'ru': 'Хорошо', 'en': ''},
  },
  // createVocab
  {
    'e55rke39': {'ru': 'Создать список городов', 'en': ''},
  },
  // noService
  {
    '1gduukvi': {'ru': 'Здесь пока пусто =(', 'en': ''},
    'k9q5yztn': {'ru': 'Создайте свою первую услугу', 'en': ''},
  },
  // SpecialistServiceCardMap
  {
    'ckzmreej': {'ru': '•', 'en': ''},
    '7ghk9fw8': {'ru': '12 рекомендаций', 'en': ''},
    'hborns68': {'ru': '24 клиента', 'en': ''},
  },
  // noSetLoc
  {
    'ufp94dlt': {'ru': 'Не удается определить местоположение', 'en': ''},
    'kh9dczy5': {
      'ru':
          'Убедитесь что геолокация включена на устройстве, или попробуйте повторить позднее',
      'en': '',
    },
    '9oojginv': {'ru': 'Хорошо', 'en': ''},
  },
  // delServ
  {
    'r9urwors': {'ru': 'Уверены что хотите удалить услугу?', 'en': ''},
    '3e8ao5bu': {'ru': 'Это дейстие нельзя отменить', 'en': ''},
    '4gjsf3pk': {'ru': 'Отмена', 'en': ''},
    'j6t4dpxe': {'ru': 'Да, удалить', 'en': ''},
  },
  // noSetLocCopy
  {
    'dihgho8l': {'ru': 'Не удается определить местоположение', 'en': ''},
    '4aj6oubc': {
      'ru':
          'Убедитесь что геолокация включена на устройстве, или попробуйте повторить позднее',
      'en': '',
    },
    'prbq7l6i': {'ru': 'Хорошо', 'en': ''},
  },
  // noSetLocCopyCopy
  {
    'hypauy6c': {'ru': 'Не удается определить местоположение', 'en': ''},
    'tuxl5n7t': {
      'ru':
          'Убедитесь что геолокация включена на устройстве, или попробуйте повторить позднее',
      'en': '',
    },
    'xh00xsmo': {'ru': 'Хорошо', 'en': ''},
  },
  // contact_avatars
  {
    'z2ppj88b': {'ru': 'JD', 'en': ''},
    '6n40evke': {'ru': 'AS', 'en': ''},
    '6j66kmhj': {'ru': 'MK', 'en': ''},
  },
  // serviceCardBig
  {
    'egijd7bc': {'ru': 'Рекомендуют 48 человек', 'en': ''},
    '7cyqb1tx': {'ru': 'Записаться', 'en': ''},
  },
  // phoneCall
  {
    'kqzi00sa': {'ru': 'Позвонить', 'en': ''},
    't84giho8': {'ru': 'Скопировать', 'en': ''},
  },
  // Miscellaneous
  {
    'xu6gj5aj': {'ru': 'Текстовое поле', 'en': ''},
    'afgjavvu': {'ru': 'Мои услуги', 'en': ''},
    'ebtxirtj': {'ru': 'Сохранить и подтвердить', 'en': ''},
    'f822pv36': {'ru': '', 'en': ''},
    'i37q67wq': {'ru': '', 'en': ''},
    '4zwadiak': {'ru': '', 'en': ''},
    'v6s7y3jk': {'ru': '', 'en': ''},
    'rrh82y07': {'ru': '', 'en': ''},
    'mxef7836': {'ru': '', 'en': ''},
    'bt92jgbd': {'ru': '', 'en': ''},
    'fm4np5i6': {'ru': '', 'en': ''},
    'q2g9onuo': {'ru': '', 'en': ''},
    'vqd1ld64': {'ru': '', 'en': ''},
    'sduvtigo': {'ru': '', 'en': ''},
    '9qhhgani': {'ru': '', 'en': ''},
    'uqhej351': {'ru': '', 'en': ''},
    '7fidm1wk': {'ru': '', 'en': ''},
    's6w3803q': {'ru': '', 'en': ''},
    'ymitbhkw': {'ru': '', 'en': ''},
    'gzula4a7': {'ru': '', 'en': ''},
    'kpgc0e10': {'ru': '', 'en': ''},
    'c0ndrbrb': {'ru': '', 'en': ''},
    'lzux66j8': {'ru': '', 'en': ''},
    'h5qgdg5t': {'ru': '', 'en': ''},
    'astl1q7w': {'ru': '', 'en': ''},
    'cdj1l3ux': {'ru': '', 'en': ''},
    'xnnlj448': {'ru': '', 'en': ''},
    'mep203v8': {'ru': '', 'en': ''},
    '1xhmqm9g': {'ru': '', 'en': ''},
    'tftg1if5': {'ru': '', 'en': ''},
    'xdcwv6yo': {'ru': '', 'en': ''},
  },
].reduce((a, b) => a..addAll(b));
