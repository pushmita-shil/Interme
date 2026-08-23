import 'package:get/get.dart';
import '../../services/firebase/firestore_service.dart';
import '../../services/firebase/auth_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FirestoreService(), permanent: true);
    Get.put(AuthService(), permanent: true);
  }
}
