# Tatum Bank — Flutter Capstone Project

**All-in-One Banking, All for You.**

This is the capstone project for the **Techware Academy 6-Week Graduate
Trainee Programme (Mobile Development / Flutter track)** for Tatum Bank
graduate trainees. It implements the Tatum Bank Figma designs as a complete,
responsive Flutter application and demonstrates every major concept from the
syllabus: widgets and layouts, theming, navigation, forms and validation,
Provider state management, local storage, a REST API service layer, and an
authentication flow with protected screens.

## Screens implemented (from Figma)

| Flow | Screens |
|---|---|
| Onboarding | Splash (M01), Welcome (M02) |
| Auth | Create Account, Verify Your Identity (OTP), Welcome Back (Login), Forgot Password, Create New Password |
| Banking | Home Dashboard (V2), Account Information, Account Limits / KYC |
| States | Loading, empty, error, and not-found screens |

## Getting started

```bash
# 1. Generate the platform folders (android/, ios/, etc.)
flutter create .

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

> The app ships with `useMockApi = true` in `lib/app/constants.dart`, so it
> runs fully offline with demo data (Sarima Hassan's account). Log in with
> **any valid email/phone and any 8+ character password**. Any 6-digit OTP
> except `000000` verifies successfully. Flip `useMockApi` to `false` and set
> `apiBaseUrl` to connect a real backend — no screen code changes needed.

## Project structure (per the syllabus, Section 5)

```
lib/
├── main.dart                 # Entry point — MaterialApp + MultiProvider
├── app/
│   ├── routes.dart           # Named routes + route guard
│   ├── theme.dart            # Light & dark ThemeData, design tokens
│   └── constants.dart        # API base URL, storage keys, assets
├── models/                   # user, account, bank_transaction, account_limit
├── services/                 # api_service, auth_service, storage_service
├── providers/                # auth_provider, account_provider
├── screens/
│   ├── splash/  onboarding/  auth/  dashboard/  account/  common/
├── widgets/                  # custom_button, custom_input, otp_input,
│                             # info_banner, loading, empty_state, yellow_wave
└── utils/                    # validators, helpers
```

## Syllabus concepts → where to find them

| Week / Session | Concept | File(s) |
|---|---|---|
| W2 S4–6 | Widgets, layouts, themes, reusable components | `app/theme.dart`, `widgets/` |
| W3 S7 | Named routes, route arguments, not-found route | `app/routes.dart`, `screens/common/` |
| W3 S8 | Forms, validation, password visibility toggle | `utils/validators.dart`, `screens/auth/` |
| W3 S9 | Dialogs, bottom sheets, snackbars, app states | `screens/dashboard/home_screen.dart` |
| W4 S10–11 | Stateful widgets, Provider, ChangeNotifier | `providers/` |
| W4 S12 | SharedPreferences (token, user, theme) | `services/storage_service.dart` |
| W5 S13–14 | REST API, JSON models, service classes, errors | `services/api_service.dart`, `models/` |
| W5 S15 | Auth, tokens, protected screens, logout | `services/auth_service.dart`, route guard |
| W6 S17 | Testing | `test/widget_test.dart` |

## Building a release APK

```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

## Team workflow

- One feature branch per screen/flow (`feature/login`, `feature/dashboard`).
- Conventional commit messages (`feat:`, `fix:`, `docs:`).
- Pull requests reviewed by a teammate before merging into `main`.

---
*Techware Academy — Tatum Bank Graduate Trainee Tech Programme, 2026.*
