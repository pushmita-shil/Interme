import 'package:get/get.dart';
import '../controllers/marketplace_controller.dart';
import '../controllers/applications_controller.dart';
import '../services/marketplace_service.dart';

class MarketplaceBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MarketplaceService>()) {
      Get.put(MarketplaceService(), permanent: true);
    }
    Get.lazyPut<MarketplaceController>(() => MarketplaceController(), fenix: true);
    Get.lazyPut<ApplicationsController>(() => ApplicationsController(), fenix: true);
  }
}

