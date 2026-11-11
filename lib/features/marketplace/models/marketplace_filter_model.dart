enum MarketplaceSortOption {
  mostRelevant,
  recentlyAdded,
  highestStipend,
  deadlineApproaching,
}

class MarketplaceFilterModel {
  String selectedCategory;
  String searchQuery;
  Set<String> selectedWorkModes; // 'Remote', 'Hybrid', 'Onsite'
  String stipendType; // 'All', 'Paid', 'Unpaid'
  double minStipend;
  double maxStipend;
  String durationOption; // 'All', '1-3 months', '3-6 months', '6+ months'
  String experienceLevel; // 'All', 'Beginner', 'Intermediate'
  bool verifiedOnly;
  String deadlineFilter; // 'All', 'Upcoming', 'Closing Soon'
  MarketplaceSortOption sortOption;

  MarketplaceFilterModel({
    this.selectedCategory = 'All',
    this.searchQuery = '',
    Set<String>? selectedWorkModes,
    this.stipendType = 'All',
    this.minStipend = 0.0,
    this.maxStipend = 100000.0,
    this.durationOption = 'All',
    this.experienceLevel = 'All',
    this.verifiedOnly = false,
    this.deadlineFilter = 'All',
    this.sortOption = MarketplaceSortOption.mostRelevant,
  }) : selectedWorkModes = selectedWorkModes ?? <String>{};

  int get activeFiltersCount {
    int count = 0;
    if (selectedCategory != 'All') count++;
    if (selectedWorkModes.isNotEmpty) count += selectedWorkModes.length;
    if (stipendType != 'All') count++;
    if (minStipend > 0 || maxStipend < 100000.0) count++;
    if (durationOption != 'All') count++;
    if (experienceLevel != 'All') count++;
    if (verifiedOnly) count++;
    if (deadlineFilter != 'All') count++;
    if (sortOption != MarketplaceSortOption.mostRelevant) count++;
    return count;
  }

  void reset() {
    selectedCategory = 'All';
    searchQuery = '';
    selectedWorkModes.clear();
    stipendType = 'All';
    minStipend = 0.0;
    maxStipend = 100000.0;
    durationOption = 'All';
    experienceLevel = 'All';
    verifiedOnly = false;
    deadlineFilter = 'All';
    sortOption = MarketplaceSortOption.mostRelevant;
  }

  MarketplaceFilterModel clone() {
    return MarketplaceFilterModel(
      selectedCategory: selectedCategory,
      searchQuery: searchQuery,
      selectedWorkModes: Set<String>.from(selectedWorkModes),
      stipendType: stipendType,
      minStipend: minStipend,
      maxStipend: maxStipend,
      durationOption: durationOption,
      experienceLevel: experienceLevel,
      verifiedOnly: verifiedOnly,
      deadlineFilter: deadlineFilter,
      sortOption: sortOption,
    );
  }
}

