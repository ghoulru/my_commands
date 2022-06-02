import 'package:objectbox/objectbox.dart';

const String appEncryptSecretKey = 'ioQT1GNjJXxOZuELU3HWr4LGSihQmfJy';
const int appEncryptSecretKeyIV = 16;
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