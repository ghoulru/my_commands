import 'package:objectbox/objectbox.dart';


/// Настройки
@Entity()
class Settings {
  @Id()
  int id = 0;

  @Unique()
  String name = '';

  String value = '';

  @override
  String toString() {
    return "$id / $name / $value";
  }
}