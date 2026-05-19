import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';

class DummyDataHelper {
  static List<ServiceRecord> getDummyServices() {
    return [
      ServiceRecord.getDocumentFromData({
        'title': 'Мужская стрижка и оформление бороды',
        'description': 'Классическая мужская стрижка любой сложности, мытье головы и профессиональное оформление бороды опасной бритвой.',
        'price': 1500,
        'time': 60,
        'categoryKey': 'hair',
        'owner': UserRecord.collection.doc('dummy_master_1'),
        'image': ['https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=500'],
      }, ServiceRecord.collection.doc('dummy_srv_1')),
      ServiceRecord.getDocumentFromData({
        'title': 'Маникюр с покрытием гель-лаком',
        'description': 'Аппаратный или комбинированный маникюр, выравнивание ногтевой пластины и покрытие премиальным гель-лаком под кутикулу.',
        'price': 2000,
        'time': 120,
        'categoryKey': 'nails',
        'owner': UserRecord.collection.doc('dummy_master_1'),
        'image': ['https://images.unsplash.com/photo-1604654894610-df63bc536371?w=500'],
      }, ServiceRecord.collection.doc('dummy_srv_2')),
      ServiceRecord.getDocumentFromData({
        'title': 'Расслабляющий массаж всего тела',
        'description': 'Глубокий релакс-массаж с использованием ароматических масел. Помогает снять стресс, усталость и мышечное напряжение.',
        'price': 3500,
        'time': 90,
        'categoryKey': 'massage',
        'owner': UserRecord.collection.doc('dummy_master_1'),
        'image': ['https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=500'],
      }, ServiceRecord.collection.doc('dummy_srv_3')),
      ServiceRecord.getDocumentFromData({
        'title': 'Сложное окрашивание волос',
        'description': 'Современные техники окрашивания: шатуш, балаяж, аиртач. Индивидуальный подбор оттенка и щадящее осветление.',
        'price': 8000,
        'time': 240,
        'categoryKey': 'hair',
        'owner': UserRecord.collection.doc('dummy_master_1'),
        'image': ['https://images.unsplash.com/photo-1560066984-138dadb4c035?w=500'],
      }, ServiceRecord.collection.doc('dummy_srv_4')),
      ServiceRecord.getDocumentFromData({
        'title': 'Вечерний макияж',
        'description': 'Стойкий и выразительный макияж для особых случаев. Используется профессиональная косметика премиум-класса.',
        'price': 3000,
        'time': 90,
        'categoryKey': 'makeup',
        'owner': UserRecord.collection.doc('dummy_master_1'),
        'image': ['https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=500'],
      }, ServiceRecord.collection.doc('dummy_srv_5')),
      ServiceRecord.getDocumentFromData({
        'title': 'Ламинирование и ботокс ресниц',
        'description': 'Красивый изгиб, насыщенный цвет и глубокое питание ресниц. Эффект держится до 1,5 месяцев.',
        'price': 1800,
        'time': 60,
        'categoryKey': 'brows',
        'image': ['https://images.unsplash.com/photo-1512496015851-a1dc8a477858?w=500'],
      }, ServiceRecord.collection.doc('dummy_srv_6')),
      ServiceRecord.getDocumentFromData({
        'title': 'SPA-программа "Перезагрузка"',
        'description': 'Комплексный уход: распаривание, скрабирование тела, обертывание и расслабляющий массаж.',
        'price': 5500,
        'time': 150,
        'categoryKey': 'spa',
        'image': ['https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=500'],
      }, ServiceRecord.collection.doc('dummy_srv_7')),
      ServiceRecord.getDocumentFromData({
        'title': 'Художественная татуировка',
        'description': 'Разработка индивидуального эскиза и нанесение татуировки. Стоимость указана за один сеанс.',
        'price': 10000,
        'time': 180,
        'categoryKey': 'tattoo',
        'image': ['https://images.unsplash.com/photo-1598371839696-5c5bb00bdc28?w=500'],
      }, ServiceRecord.collection.doc('dummy_srv_8')),
    ];
  }
}
