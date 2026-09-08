# رف التطبيقات — AppShelf (Flutter)

عميل موبايل عربي (RTL) لمتجر [AppShelf](../appshelf) بنفس الهوية البصرية الهادئة (slate / sage).

## المتطلبات

- Flutter 3.24+ (اختُبر على 3.24.3)
- خادم الويب Next.js يعمل محلياً على المنفذ `3000` (للوضع المتصل)

## التشغيل

```bash
cd appshelf_app
flutter pub get
flutter run
```

### عنوان الـ API

| البيئة | الافتراضي |
|--------|-----------|
| Android Emulator | `http://10.0.2.2:3000` |
| iOS Simulator / سطح المكتب | `http://localhost:3000` |

تخصيص:

```bash
flutter run --dart-define=APPSHELF_API_BASE=http://192.168.1.20:3000
```

شغّل الويب بحيث يقبل اتصالات الشبكة المحلية إن لزم:

```bash
cd ../appshelf
npm run dev -- -H 0.0.0.0 -p 3000
```

## حسابات تجريبية

| الدور | البريد | كلمة المرور |
|------|--------|-------------|
| مستخدم | `user@appshelf.app` | `user12345` |
| مطوّر | `dev@appshelf.app` | `developer123` |
| مدير | `admin@appshelf.app` | `admin12345` |

## الشاشات (MVP)

1. **المتجر** — مميّز، بحث، فئات، بطاقات تطبيقات  
2. **تفاصيل التطبيق** — أيقونة، لقطات، وصف، تثبيت/تحميل، مفضلة  
3. **دخول / تسجيل** — مستخدم أو مطوّر  
4. **مكتبتي** — مفضلة + مثبّتة  
5. **حسابي** — ملف شخصي + عنوان API  
6. **لوحة المطوّر** — حالة الحساب، قائمة تطبيقاتي، روابط للويب  

## المصادقة

- الويب يدعم الآن `Authorization: Bearer <token>` بجانب كوكي الجلسة.
- تسجيل الدخول/التسجيل يعيد `{ user, token }`؛ التطبيق يحفظ التوكن في `SharedPreferences`.

## وضع تجريبي (Mock)

إذا تعذّر الاتصال بالـ API، يظهر شارة **وضع تجريبي** ويُعرض كتالوج محلي (قسطي، نُظم، ميزان). المفضلة/الدخول تحتاج الـ API الحقيقي.

## هيكل المشروع

```
lib/
  config/api_config.dart
  theme/app_theme.dart
  models/ models.dart
  services/api_client.dart
  providers/
  screens/
  widgets/
```

## English

Arabic-first RTL Flutter client for AppShelf. Point `APPSHELF_API_BASE` at your Next.js server. Falls back to a local mock catalog when the API is unreachable. Auth uses Bearer tokens returned by `/api/auth/login` and `/api/auth/signup`.

## Run

```bash
flutter pub get
flutter run -d chrome   # or macos / android
```

API base defaults to emulator/host localhost:3000. Override in-app (Profile) or:

```bash
flutter run --dart-define=APPSHELF_API_BASE=https://appshelf-nine.vercel.app
```

## Auth

- Email demos: `user@appshelf.app` / `user12345`, `dev@appshelf.app` / `developer123`
- Google / Apple buttons call `/api/auth/oauth` (demo mode without client IDs)

## Release APK

```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```
