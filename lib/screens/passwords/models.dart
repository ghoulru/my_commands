import 'package:objectbox/objectbox.dart';

/// Категория
@Entity()
class CategoryTabModel {
  @Id()
  int id = 0;
  String name = '';
  int sort = 0;

  @Backlink()
  final items = ToMany<PasswordsItem>();
}
/// Элемент, запись
@Entity()
class PasswordsItem {
  @Id()
  int id = 0;
  String name = '';

  final category = ToOne<CategoryTabModel>();

  @Backlink()
  final entities = ToMany<PasswordsItemEntity>();
}

/// запись внутри PasswordsItem, ФТП, БД и прочее
@Entity()
class PasswordsItemEntity {
  @Id()
  int id = 0;
  String name = '';
  int sort = 0;

  final parent = ToOne<PasswordsItem>();
}