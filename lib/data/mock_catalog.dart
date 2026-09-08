import '../models/models.dart';

/// Offline / API-unavailable catalog mirroring web seed apps.
class MockCatalog {
  static List<StoreApp> apps() {
    return const [
      StoreApp(
        id: 'seed-app-appshelf',
        slug: 'appshelf',
        developerId: 'seed-dev-appshelf',
        name: 'AppShelf',
        nameAr: 'رف التطبيقات',
        shortDescription:
            'Official mobile client for the AppShelf indie store.',
        shortDescriptionAr:
            'العميل الرسمي لمتجر رف التطبيقات — تصفّح وثبّت وأضف للمفضلة.',
        description:
            'Browse independent Arabic-friendly apps and install APKs from AppShelf.',
        descriptionAr:
            'تصفّح تطبيقات مستقلة مناسبة للعربية وثبّتها من متجر رف التطبيقات.',
        whatsNew: 'v1.0.0 — first public mobile client.',
        whatsNewAr: 'الإصدار 1.0.0 — أول عميل موبايل علني.',
        iconUrl: '/apps/appshelf-icon.svg',
        screenshots: [
          '/apps/appshelf/shot-1.svg',
          '/apps/appshelf/shot-2.svg',
          '/apps/appshelf/shot-3.svg',
        ],
        packageId: 'app.appshelf.appshelf_app',
        version: '1.0.0',
        sizeLabel: '~18 MB',
        downloadUrl: '/downloads/appshelf.apk',
        websiteUrl: 'https://appshelf.app',
        category: 'tools',
        platform: 'android',
        status: 'published',
        featured: true,
        downloadsPlaceholder: 1,
      ),
      StoreApp(
        id: 'seed-app-qisti',
        slug: 'qisti',
        developerId: 'seed-dev-appshelf',
        name: 'Qisti',
        nameAr: 'قسطي',
        shortDescription:
            'Track installments, checks, and debts with calm local reminders.',
        shortDescriptionAr:
            'تابع الأقساط والشيكات والديون مع تذكيرات محلية هادئة.',
        description:
            'Qisti is a calm Arabic app for tracking installments, checks, and debts.',
        descriptionAr:
            'قسطي تطبيق عربي هادئ لمتابعة الأقساط والشيكات والديون، مع تذكيرات محلية قبل الموعد. بياناتك على جهازك.',
        whatsNew: 'v1.0.7 — polished reminders and release APK.',
        whatsNewAr: 'الإصدار 1.0.7 — تحسين التذكيرات ونشر APK.',
        iconUrl: '/apps/qisti-icon.png',
        screenshots: [
          '/apps/qisti/shot-1.svg',
          '/apps/qisti/shot-2.svg',
          '/apps/qisti/shot-3.svg',
        ],
        packageId: 'com.qisti.qisti',
        version: '1.0.7',
        sizeLabel: '~25 MB',
        downloadUrl:
            'https://github.com/m7moud2/qisti/releases/download/v1.0.7/qisti.apk',
        websiteUrl: 'https://m7moud2.github.io/qisti/',
        category: 'finance',
        platform: 'android',
        status: 'published',
        featured: true,
        downloadsPlaceholder: 12,
      ),
      StoreApp(
        id: 'seed-app-nudhum',
        slug: 'nudhum',
        developerId: 'seed-dev-appshelf',
        name: 'Nudhum',
        nameAr: 'نُظم',
        shortDescription:
            'A quiet personal organizer for notes and weekly focus.',
        shortDescriptionAr:
            'منظّم شخصي هادئ للملاحظات والقوائم وتركيز الأسبوع.',
        description: 'Nudhum helps indie users keep light plans.',
        descriptionAr:
            'نُظم يساعد على حفظ خطط خفيفة بدون لوحات صاخبة — ملاحظات وقوائم ونظرة أسبوعية هادئة.',
        whatsNew: 'v0.9 — first public demo listing.',
        whatsNewAr: 'الإصدار 0.9 — أول إدراج تجريبي علني.',
        iconUrl: '/apps/nudhum-icon.svg',
        screenshots: ['/apps/nudhum/shot-1.svg'],
        packageId: 'app.appshelf.nudhum',
        version: '0.9.0',
        sizeLabel: '~8 MB',
        downloadUrl: 'https://appshelf.app',
        websiteUrl: 'https://appshelf.app',
        category: 'productivity',
        platform: 'android',
        status: 'published',
        featured: false,
        downloadsPlaceholder: 4,
      ),
      StoreApp(
        id: 'seed-app-mizan',
        slug: 'mizan',
        developerId: 'seed-dev-appshelf',
        name: 'Mizan',
        nameAr: 'ميزان',
        shortDescription:
            'Simple expense awareness — calm weekly totals.',
        shortDescriptionAr:
            'وعي بسيط بالمصاريف — سجّل الإنفاق وشاهد مجاميع أسبوعية هادئة.',
        description: 'Mizan is a lightweight finance companion.',
        descriptionAr:
            'ميزان رفيق مالي خفيف لتتبع مصاريف اليوم مع ملخصات أسبوعية لطيفة.',
        whatsNew: 'v0.8 — demo APK placeholder.',
        whatsNewAr: 'الإصدار 0.8 — إدراج تجريبي برابط نائب.',
        iconUrl: '/apps/mizan-icon.svg',
        screenshots: ['/apps/mizan/shot-1.svg'],
        packageId: 'app.appshelf.mizan',
        version: '0.8.0',
        sizeLabel: '~6 MB',
        downloadUrl: 'https://appshelf.app',
        category: 'finance',
        platform: 'android',
        status: 'published',
        featured: false,
        downloadsPlaceholder: 7,
      ),
    ];
  }
}

const categoryLabelsAr = <String, String>{
  'all': 'الكل',
  'finance': 'مالية',
  'tools': 'أدوات',
  'productivity': 'إنتاجية',
  'lifestyle': 'نمط حياة',
  'education': 'تعليم',
  'games': 'ألعاب',
  'other': 'أخرى',
};

String categoryLabel(String key) => categoryLabelsAr[key] ?? key;

const developerStatusLabels = <String, String>{
  'incomplete': 'أكمل ملف الناشر',
  'awaiting_payment': 'بانتظار الدفع',
  'pending_review': 'قيد المراجعة',
  'approved': 'معتمد للنشر',
  'rejected': 'مرفوض',
};
