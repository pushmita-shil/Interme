import 'dart:async';
import 'package:get/get.dart';
import '../../../data/models/application_model.dart';
import '../../../data/models/user_model.dart';
import '../../../services/firebase/auth_service.dart';
import '../services/marketplace_service.dart';

class ApplicationsController extends GetxController {
  final MarketplaceService _service = Get.find<MarketplaceService>();
  final AuthService _authService = Get.find<AuthService>();

  final RxList<ApplicationModel> allApplications = <ApplicationModel>[].obs;
  final RxString selectedStatusFilter = 'All'.obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<List<ApplicationModel>>? _sub;

  final List<String> statusFilters = const [
    'All',
    'Applied',
    'Under Review',
    'Interview',
    'Selected',
    'Rejected',
  ];

  @override
  void onInit() {
    super.onInit();
    _subscribeApplications();
  }

  void _subscribeApplications() {
    final uid = _authService.currentUser?.id ?? '';
    if (uid.isNotEmpty) {
      isLoading.value = true;
      _sub = _service.streamStudentApplications(uid).listen((apps) {
        allApplications.assignAll(apps);
        isLoading.value = false;
      }, onError: (e) {
        isLoading.value = false;
      });
    } else {
      isLoading.value = false;
    }

    ever(_authService.rxCurrentUser, (UserModel? user) {
      _sub?.cancel();
      if (user != null && user.id.isNotEmpty) {
        isLoading.value = true;
        _sub = _service.streamStudentApplications(user.id).listen((apps) {
          allApplications.assignAll(apps);
          isLoading.value = false;
        });
      } else {
        allApplications.clear();
        isLoading.value = false;
      }
    });
  }

  List<ApplicationModel> get filteredApplications {
    if (selectedStatusFilter.value == 'All') {
      return allApplications;
    }
    return allApplications
        .where((a) => a.status.toLowerCase() == selectedStatusFilter.value.toLowerCase())
        .toList();
  }

  void setFilter(String filter) {
    selectedStatusFilter.value = filter;
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}

