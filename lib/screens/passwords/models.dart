import 'package:objectbox/objectbox.dart';

/// Категория
@Entity()
class CategoryTabModel {
  @Id()
  int id = 0;

  @Unique()
  String name = '';
  int sort = 0;

  @Backlink()
  final items = ToMany<PasswordsItem>();

  @override
  String toString() {
    return "$id / $name / sort=$sort / itemsLength=" + items.length.toString();
  }
}
/// Элемент, запись
@Entity()
class PasswordsItem {
  @Id()
  int id = 0;
  String name = '';

  String logoURL = '';

  final category = ToOne<CategoryTabModel>();

  @Backlink()
  final entities = ToMany<PasswordsItemEntity>();

  @override
  String toString() {
    return "$id / name=$name / logo=$logoURL / entitiesLength = "+ entities.length.toString();
  }
}

/// запись внутри PasswordsItem, ФТП, БД и прочее
enum PasswordsItemEntitySubtype {
  string,
  url,
}

@Entity()
class PasswordsItemEntity {
  @Id()
  int id = 0;
  int sort = 0;
  String type = 'entry';
  PasswordsItemEntitySubtype subtype = PasswordsItemEntitySubtype.string;//подтип, для правильного вывода, напр. ссылка будет кликабельная
  String name = '';
  String value = '';

  final parent = ToOne<PasswordsItem>();

  int get dbSubtype {
    _ensureStableEnumValues();
    return subtype.index;
  }
  set dbSubtype(int value) {
    _ensureStableEnumValues();
    subtype =  PasswordsItemEntitySubtype.values[value];
  }

  void _ensureStableEnumValues() {
    assert(PasswordsItemEntitySubtype.string.index == 0);
    assert(PasswordsItemEntitySubtype.url.index == 1);
  }

  @override
  String toString() {
    return "$id / type=$type / subtype=$subtype / name=$name / value=$value / sort=$sort";
  }
  //TODO историю установок значений, дата-значение, но не факт что понадобится
}
