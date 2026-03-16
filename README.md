# Roomify — Ứng dụng đặt phòng khách sạn Việt Nam

Flutter + Firebase | Android only | PRM393 — Nhóm 5 người

---

## Yêu cầu môi trường

| Công cụ | Phiên bản |
|---------|-----------|
| Flutter | >= 3.10.4 |
| Dart | >= 3.0 |
| Android SDK | API 21+ |
| Firebase CLI | >= 13.x |
| FlutterFire CLI | >= 1.x |

---

## Setup lần đầu (mỗi thành viên làm 1 lần)

### 1. Clone repo

```bash
git clone <repo-url>
cd roomify
```

### 2. Cài dependencies

```bash
flutter pub get
```

### 3. Firebase — QUAN TRỌNG

File `google-services.json` và `firebase_options.dart` đã có sẵn trong repo (repo private).  
**Không cần chạy lại `flutterfire configure`.**  
Nếu vì lý do nào đó 2 file trên bị mất, liên hệ nhóm trưởng để lấy lại.

### 4. Chạy app

```bash
flutter run
```

---

## Cấu trúc thư mục

```
lib/
├── main.dart                          # SplashScreen + AuthWrapper + MainScreen
├── firebase_options.dart              # Firebase config (auto-generated)
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Màu sắc toàn app (#29B6F6)
│   │   └── app_strings.dart           # String constants
│   └── utils/
│       ├── date_formatter.dart        # DateTime → "dd/MM/yyyy"
│       └── currency_formatter.dart    # double → "1.200.000 ₫"
├── data/
│   ├── models/                        # 6 models — DONE
│   │   ├── user_model.dart
│   │   ├── destination_model.dart
│   │   ├── hotel_model.dart
│   │   ├── room_model.dart
│   │   ├── guest_model.dart
│   │   └── booking_model.dart
│   └── repositories/                  # 5 repositories — DONE
│       ├── auth_repository.dart
│       ├── destination_repository.dart
│       ├── hotel_repository.dart
│       ├── room_repository.dart
│       └── booking_repository.dart
├── screens/
│   ├── auth/                          # Người 2
│   ├── onboarding/                    # Người 2
│   ├── home/                          # Người 3
│   ├── search/                        # Người 3
│   ├── hotel/                         # Người 4
│   ├── booking/                       # Người 4
│   └── profile/                       # Người 5
└── widgets/
    └── avatar_widget.dart             # buildAvatar(user, {radius}) — DONE
```

---

## Phân công nhóm

| Người | Nhiệm vụ | Trạng thái |
|-------|----------|-----------|
| Người 1 | Data Layer (models + repositories) | DONE |
| Người 2 | `onboarding/`, `auth/login_screen.dart`, `auth/register_screen.dart` | Chưa làm |
| Người 3 | `home/home_screen.dart`, `search/search_screen.dart` | Chưa làm |
| Người 4 | `hotel/hotel_detail_screen.dart`, `booking/booking_form_screen.dart`, `booking/booking_confirmation_screen.dart` | Chưa làm |
| Người 5 | `profile/profile_screen.dart` | Chưa làm |

---

## Quy tắc bắt buộc (KHÔNG được vi phạm)

1. **State management: `setState` ONLY** — BLoC và Provider bị cấm
2. **Navigation: `Navigator.push` / `Navigator.pushReplacement` ONLY** — named routes bị cấm
3. **Mọi Firestore call MUST có `try/catch`** — error message bằng tiếng Việt
4. **Mọi async screen MUST có `CircularProgressIndicator`** khi loading
5. **Không dùng `.first` trực tiếp trên list** — dùng getter `thumbnailUrl`
6. **Tất cả giá tiền dùng `CurrencyFormatter`**, tất cả ngày dùng `DateFormatter`
7. **Không cast Timestamp trực tiếp** — luôn null-check trước

---

## Firestore Collections

```
users/{uid}           → email, fullName, phone
destinations/{id}     → name, imageUrl, description, hotelCount
hotels/{id}           → name, city, address, imageUrls, rating, priceFrom, ...
rooms/{id}            → hotelId, roomNumber, roomType, pricePerNight, isAvailable, ...
bookings/{id}         → userId, hotelId, roomId, checkIn, checkOut, status, guest{...}
```

---

## Sau khi implement xong 1 screen

Chạy lệnh này trước khi commit:

```bash
flutter analyze
```

Phải đạt **0 issues** mới được commit.
