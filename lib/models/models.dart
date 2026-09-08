class StoreApp {
  const StoreApp({
    required this.id,
    required this.slug,
    required this.developerId,
    required this.name,
    required this.nameAr,
    required this.shortDescription,
    required this.shortDescriptionAr,
    required this.description,
    required this.descriptionAr,
    required this.whatsNew,
    required this.whatsNewAr,
    required this.iconUrl,
    required this.screenshots,
    required this.packageId,
    required this.version,
    required this.sizeLabel,
    required this.downloadUrl,
    this.websiteUrl,
    required this.category,
    required this.platform,
    required this.status,
    this.featured = false,
    this.downloadsPlaceholder = 0,
  });

  final String id;
  final String slug;
  final String developerId;
  final String name;
  final String nameAr;
  final String shortDescription;
  final String shortDescriptionAr;
  final String description;
  final String descriptionAr;
  final String whatsNew;
  final String whatsNewAr;
  final String iconUrl;
  final List<String> screenshots;
  final String packageId;
  final String version;
  final String sizeLabel;
  final String downloadUrl;
  final String? websiteUrl;
  final String category;
  final String platform;
  final String status;
  final bool featured;
  final int downloadsPlaceholder;

  String get displayName => nameAr.isNotEmpty ? nameAr : name;
  String get displayShort =>
      shortDescriptionAr.isNotEmpty ? shortDescriptionAr : shortDescription;
  String get displayDescription =>
      descriptionAr.isNotEmpty ? descriptionAr : description;
  String get displayWhatsNew =>
      whatsNewAr.isNotEmpty ? whatsNewAr : whatsNew;

  factory StoreApp.fromJson(Map<String, dynamic> json) {
    return StoreApp(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      developerId: json['developerId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameAr: json['nameAr']?.toString() ?? '',
      shortDescription: json['shortDescription']?.toString() ?? '',
      shortDescriptionAr: json['shortDescriptionAr']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      descriptionAr: json['descriptionAr']?.toString() ?? '',
      whatsNew: json['whatsNew']?.toString() ?? '',
      whatsNewAr: json['whatsNewAr']?.toString() ?? '',
      iconUrl: json['iconUrl']?.toString() ?? '',
      screenshots: (json['screenshots'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      packageId: json['packageId']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      sizeLabel: json['sizeLabel']?.toString() ?? '',
      downloadUrl: json['downloadUrl']?.toString() ?? '',
      websiteUrl: json['websiteUrl']?.toString(),
      category: json['category']?.toString() ?? 'other',
      platform: json['platform']?.toString() ?? 'android',
      status: json['status']?.toString() ?? 'published',
      featured: json['featured'] == true,
      downloadsPlaceholder:
          int.tryParse('${json['downloadsPlaceholder'] ?? 0}') ?? 0,
    );
  }
}

class PublisherInfo {
  const PublisherInfo({
    required this.name,
    required this.verified,
    this.website,
    this.slug,
  });

  final String name;
  final bool verified;
  final String? website;
  final String? slug;

  factory PublisherInfo.fromJson(Map<String, dynamic> json) {
    return PublisherInfo(
      name: json['name']?.toString() ?? 'مطوّر',
      verified: json['verified'] == true,
      website: json['website']?.toString(),
      slug: json['slug']?.toString(),
    );
  }
}

class LibraryFlags {
  const LibraryFlags({this.favorited = false, this.installed = false});

  final bool favorited;
  final bool installed;

  factory LibraryFlags.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LibraryFlags();
    return LibraryFlags(
      favorited: json['favorited'] == true,
      installed: json['installed'] == true,
    );
  }
}

class AppDetailBundle {
  const AppDetailBundle({
    required this.app,
    required this.library,
    required this.publisher,
  });

  final StoreApp app;
  final LibraryFlags library;
  final PublisherInfo publisher;
}

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.subscriptionActive = false,
    this.subscriptionPlan,
    this.developerStatus,
  });

  final String id;
  final String email;
  final String name;
  final String role;
  final bool subscriptionActive;
  final String? subscriptionPlan;
  final String? developerStatus;

  bool get isDeveloper => role == 'developer' || role == 'admin';

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      subscriptionActive: json['subscriptionActive'] == true,
      subscriptionPlan: json['subscriptionPlan']?.toString() ??
          json['plan']?.toString(),
      developerStatus: json['developerStatus']?.toString(),
    );
  }
}

class DeveloperProfile {
  const DeveloperProfile({
    required this.slug,
    required this.name,
    required this.bio,
    required this.verified,
    required this.apps,
    this.country,
    this.website,
  });

  final String slug;
  final String name;
  final String bio;
  final bool verified;
  final String? country;
  final String? website;
  final List<StoreApp> apps;

  factory DeveloperProfile.fromJson(Map<String, dynamic> json) {
    return DeveloperProfile(
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? 'مطوّر',
      bio: json['bio']?.toString() ?? '',
      verified: json['verified'] == true,
      country: json['country']?.toString(),
      website: json['website']?.toString(),
      apps: (json['apps'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) => StoreApp.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
