import 'objectbox.g.dart';

//https://docs.objectbox.io/getting-started
class ObjectBox {
  late final Store store;

  ObjectBox._create(this.store) {
    //
  }

  static Future<ObjectBox> create() async {
    final store = await openStore();

    return ObjectBox._create(store);
  }
}