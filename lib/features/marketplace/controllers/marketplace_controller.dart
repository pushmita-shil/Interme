import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../data/models/internship_model.dart';
import '../../../data/models/saved_internship_model.dart';
import '../../../data/models/user_model.dart';
import '../../../services/firebase/auth_service.dart';
import '../models/marketplace_filter_model.dart';
import '../services/marketplace_service.dart';

class MarketplaceController extends GetxController {
  final MarketplaceService _service = Get.find<MarketplaceService>();
  final AuthService _authService = Get.find<AuthService>();

  // Text search controller & reactive search stream
  final TextEditingController searchTextController = TextEditingController();
  final RxString searchQuery = ''.obs;

  // Categories list
  final List<String> categories = const [
    'All',
    'Software Development',
    'Data Science',
    'AI/ML',
    'UI/UX',
    'Cybersecurity',
    'Marketing',
    'Business Development',
  ];

  // Active filter state
  final Rx<MarketplaceFilterModel> filter = MarketplaceFilterModel().obs;

  // Internships lists for various sections
  final RxList<InternshipModel> featuredInternships = <InternshipModel>[].obs;
  final RxList<InternshipModel> recommendedInternships = <InternshipModel>[].obs;
  final RxList<InternshipModel> recentlyAddedInternships = <InternshipModel>[].obs;
  final RxList<InternshipModel> closingSoonInternships = <InternshipModel>[].obs;
  final RxList<InternshipModel> allInternships = <InternshipModel>[].obs;

  // Saved / Bookmarked internship IDs for instantaneous UI state
  final RxSet<String> savedInternshipIds = <String>{}.obs;
  StreamSubscription<List<SavedInternshipModel>>? _savedSub;

  // Loading & Pagination state
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  DocumentSnapshot? _lastDoc;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _setupDebounce();
    _setupSavedSubscription();
    loadAllSections();

    // Infinite scroll listener for All Internships
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore.value &&
          hasMore.value &&
          !isLoading.value) {
        loadMore();
      }
    });
  }

  void _setupDebounce() {
    // 350ms debounce on search input to prevent rapid Firestore queries
    debounce<String>(
      searchQuery,
      (query) {
        filter.update((val) {
          if (val != null) val.searchQuery = query;
        });
        refreshListings();
      },
      time: const Duration(milliseconds: 350),
    );
  }

  void _setupSavedSubscription() {
    final uid = _authService.currentUser?.id ?? '';
    if (uid.isNotEmpty) {
      _savedSub = _service.streamSavedInternships(uid).listen((savedList) {
        savedInternshipIds.assignAll(savedList.map((s) => s.internshipId));
      });
    }

    // If auth state changes, re-subscribe
    ever(_authService.rxCurrentUser, (UserModel? user) {
      _savedSub?.cancel();
      if (user != null && user.id.isNotEmpty) {
        _savedSub = _service.streamSavedInternships(user.id).listen((savedList) {
          savedInternshipIds.assignAll(savedList.map((s) => s.internshipId));
        });
      } else {
        savedInternshipIds.clear();
      }
    });
  }

  Future<void> loadAllSections() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Parallel fetch for speed
      final results = await Future.wait([
        _service.fetchFeaturedInternships(limit: 5),
        _service.fetchClosingSoonInternships(limit: 6),
        _service.fetchRecentlyAdded(limit: 6),
        _service.fetchInternships(pageSize: 10, filter: filter.value),
      ]);

      featuredInternships.assignAll(results[0] as List<InternshipModel>);
      closingSoonInternships.assignAll(results[1] as List<InternshipModel>);
      recentlyAddedInternships.assignAll(results[2] as List<InternshipModel>);

      final pagedResult = results[3] as PaginatedInternshipsResult;
      allInternships.assignAll(pagedResult.internships);
      _lastDoc = pagedResult.lastDocument;
      hasMore.value = pagedResult.hasMore;

      // Personalize recommendations based on current student profile
      _computeRecommendations();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load internship opportunities: $e';
      debugPrint('MarketplaceController loadAllSections error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refreshes the filtered 'All Internships' list
  Future<void> refreshListings() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      _lastDoc = null;

      final result = await _service.fetchInternships(
        pageSize: 10,
        startAfterDoc: null,
        filter: filter.value,
      );

      allInternships.assignAll(result.internships);
      _lastDoc = result.lastDocument;
      hasMore.value = result.hasMore;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to refresh opportunities: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads next page for infinite scroll
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;
      final result = await _service.fetchInternships(
        pageSize: 8,
        startAfterDoc: _lastDoc,
        filter: filter.value,
      );

      if (result.internships.isNotEmpty) {
        allInternships.addAll(result.internships);
        _lastDoc = result.lastDocument;
      }
      hasMore.value = result.hasMore;
    } catch (e) {
      debugPrint('MarketplaceController loadMore error: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Computes personalized recommendations matching student profile
  void _computeRecommendations() {
    final user = _authService.currentUser;
    final studentSkills = (user?.skills ?? []).map((s) => s.toLowerCase()).toSet();
    final preferredType = user?.preferredType?.toLowerCase() ?? '';
    final preferredLoc = user?.preferredLocation?.toLowerCase() ?? '';

    if (studentSkills.isEmpty && preferredType.isEmpty) {
      // Fallback: show featured & verified listings
      recommendedInternships.assignAll(
        allInternships.where((i) => i.isVerified).take(5).toList(),
      );
      return;
    }

    final scored = <MapEntry<InternshipModel, int>>[];

    for (final item in allInternships) {
      int score = 0;
      // Match skills
      for (final skill in item.skills) {
        if (studentSkills.contains(skill.toLowerCase())) {
          score += 3;
        }
      }
      // Match work mode preference
      if (preferredType.isNotEmpty &&
          item.workMode.toLowerCase().contains(preferredType)) {
        score += 2;
      }
      // Match location preference
      if (preferredLoc.isNotEmpty &&
          item.location.toLowerCase().contains(preferredLoc)) {
        score += 2;
      }
      if (item.isVerified) {
        score += 1;
      }
      if (score > 0) {
        scored.add(MapEntry(item, score));
      }
    }

    scored.sort((a, b) => b.value.compareTo(a.value));
    recommendedInternships.assignAll(
      scored.map((e) => e.key).take(6).toList(),
    );
  }

  void selectCategory(String category) {
    if (filter.value.selectedCategory == category) return;
    filter.update((val) {
      if (val != null) val.selectedCategory = category;
    });
    refreshListings();
  }

  void applyFilter(MarketplaceFilterModel newFilter) {
    filter.value = newFilter.clone();
    refreshListings();
  }

  void resetFilter() {
    filter.update((val) => val?.reset());
    searchTextController.clear();
    searchQuery.value = '';
    refreshListings();
  }

  /// Bookmarks or un-bookmarks an internship
  Future<void> toggleSave(InternshipModel internship) async {
    final uid = _authService.currentUser?.id ?? '';
    if (uid.isEmpty) {
      Get.snackbar(
        'Sign In Required',
        'Please sign in to bookmark opportunities.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final willBeSaved = !savedInternshipIds.contains(internship.id);

    // Optimistic UI update
    if (willBeSaved) {
      savedInternshipIds.add(internship.id);
    } else {
      savedInternshipIds.remove(internship.id);
    }

    try {
      final isSaved = await _service.toggleSaveInternship(
        studentId: uid,
        internship: internship,
      );
      Get.snackbar(
        isSaved ? 'Internship Saved' : 'Bookmark Removed',
        isSaved
            ? '${internship.title} added to your saved list.'
            : '${internship.title} removed from saved list.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      // Revert optimistic update on failure
      if (willBeSaved) {
        savedInternshipIds.remove(internship.id);
      } else {
        savedInternshipIds.add(internship.id);
      }
      Get.snackbar('Error', 'Failed to update bookmark: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  bool isInternshipSaved(String id) => savedInternshipIds.contains(id);

  @override
  void onClose() {
    searchTextController.dispose();
    scrollController.dispose();
    _savedSub?.cancel();
    super.onClose();
  }
}

