# Flutter Hotel Booking — Project Setup & Team Task Division

## 🎯 Context
Nhóm 5 người, mới học Flutter 3 tháng, deadline 1-2 tuần.
App đặt phòng khách sạn tại Việt Nam, Android, Firebase backend.
Toàn bộ spec kỹ thuật nằm trong **flutter_hotel_booking_prompt_v4.md** — đọc file đó trước khi làm bất cứ điều gì.

---

## PHẦN 1 — SETUP DỰ ÁN (Người Lead làm, ~2 tiếng)

### Bước 1: Tạo Flutter project
```bash
flutter create hotel_booking_app
cd hotel_booking_app
```

### Bước 2: Tạo cấu trúc thư mục
Tạo đầy đủ các thư mục sau (tạo file `.gitkeep` trong mỗi thư mục rỗng):
```
lib/
├── core/constants/
├── core/utils/
├── data/models/
├── data/repositories/
└── screens/auth/
    screens/home/
    screens/search/
    screens/hotel/
    screens/booking/
    screens/profile/
```

Chạy lệnh này để tạo nhanh:
```bash
mkdir -p lib/core/constants lib/core/utils \
         lib/data/models lib/data/repositories \
         lib/screens/auth lib/screens/home lib/screens/search \
         lib/screens/hotel lib/screens/booking lib/screens/profile
```

### Bước 3: Cập nhật pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.0
  cloud_firestore: ^5.4.0
  cached_network_image: ^3.3.0
```
Chạy: `flutter pub get`

### Bước 4: Kết nối Firebase
```bash
# Cài Firebase CLI (cần Node.js)
npm install -g firebase-tools
firebase login

# Cài FlutterFire CLI
dart pub global activate flutterfire_cli

# Kết nối project (chạy trong thư mục hotel_booking_app)
flutterfire configure
# → Chọn project Firebase đã tạo
# → Chọn platform: android
# → File firebase_options.dart sẽ tự sinh ra
```

### Bước 5: Setup Git repo
```bash
git init
git add .
git commit -m "init: project setup + firebase config"

# Tạo repo trên GitHub rồi push lên
git remote add origin <github-url>
git push -u origin main
```

### Bước 6: Tạo các branch cho từng người
```bash
git checkout -b feature/data-layer       # Người 1
git checkout -b feature/auth-screens     # Người 2
git checkout -b feature/home-search      # Người 3
git checkout -b feature/hotel-booking    # Người 4
git checkout -b feature/profile          # Người 5
```

### Bước 7: Tạo file shared dùng chung — làm TRƯỚC khi cả nhóm bắt đầu

**`lib/core/utils/date_formatter.dart`**
```dart
class DateFormatter {
  static String format(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }
}
```

**`lib/core/utils/currency_formatter.dart`**
```dart
class CurrencyFormatter {
  static String format(double amount) {
    final formatted = amount.toInt().toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.');
    return '$formatted ₫';
  }
}
```

**`lib/core/constants/app_colors.dart`**
```dart
import 'package:flutter/material.dart';

// Màu sắc theo Figma design — "blue-Sky" #0FA3E2
class AppColors {
  // Màu chủ đạo — chính xác từ Figma color spec
  static const primary = Color(0xFF0FA3E2);      // blue-Sky từ Figma
  static const primaryDark = Color(0xFF0888C0);  // pressed / hover state

  // Backgrounds
  static const background = Color(0xFFFFFFFF);   // trắng — màu nền chính
  static const surface = Color(0xFFF5F5F5);      // nền card, input field
  static const surfaceDark = Color(0xFFEEEEEE);  // divider, border nhẹ

  // Text
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF757575);
  static const textHint = Color(0xFFBDBDBD);

  // Semantic
  static const error = Color(0xFFE53935);
  static const star = Color(0xFFFFC107);          // màu sao rating

  // Success screen (Register success, Booking success)
  // Dùng primary thay vì xanh lá — đúng với Figma (màn xanh dương)
  static const successBackground = primary;
  static const successText = Color(0xFFFFFFFF);

  // Status badge trong booking history
  static const statusConfirmed = Color(0xFF29B6F6);  // xanh dương = confirmed
  static const statusCancelled = Color(0xFFE53935);  // đỏ = cancelled
  static const statusCompleted = Color(0xFF9E9E9E);  // xám = completed
}
```

**`lib/core/constants/app_strings.dart`**
```dart
class AppStrings {
  static const appName = 'Hotel Booking Vietnam';
  static const loading = 'Đang tải...';
  static const errorGeneric = 'Đã xảy ra lỗi. Vui lòng thử lại.';
  static const errorNetwork = 'Không thể kết nối. Kiểm tra internet.';
  static const emptyHotels = 'Không tìm thấy khách sạn';
  static const emptyBookings = 'Chưa có lịch sử đặt phòng';
}
```

**`lib/main.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'core/constants/app_colors.dart';
import 'screens/auth/login_screen.dart';
// import sau khi làm xong:
// import 'screens/home/home_screen.dart';
// import 'screens/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Booking Vietnam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        // Input field style toàn app — khớp Figma (bo tròn, nền xám nhạt)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        // Button style toàn app — bo tròn mạnh như Figma
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// Splash screen — logo giữa màn trắng (ảnh 1 trong Figma)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Icon(Icons.hotel, size: 80, color: AppColors.primary),
      ),
    );
  }
}

// Kiểm tra trạng thái đăng nhập
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const MainScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

// Bottom navigation — 2 tab: Home + Profile (theo Figma)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Uncomment sau khi Người 3 và Người 5 implement xong
    // final screens = [HomeScreen(), ProfileScreen()];
    return Scaffold(
      body: _currentIndex == 0
          ? const Center(child: Text('HomeScreen — chờ Người 3'))
          : const Center(child: Text('ProfileScreen — chờ Người 5')),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}
```

Commit tất cả lên main:
```bash
git add .
git commit -m "setup: shared utils, constants, main.dart"
git push
```

---

## PHẦN 2 — CHIA VIỆC CHO 5 NGƯỜI

> Mỗi người làm trên branch riêng của mình.
> Pull từ main trước khi bắt đầu: `git pull origin main`

---

### 👤 NGƯỜI 1 — Data Layer
**Branch:** `feature/data-layer`
**Thời gian:** 2-3 ngày (làm trước, cả nhóm cần file này)
**Ưu tiên: PHẢI XONG TRƯỚC KHI 4 NGƯỜI CÒN LẠI BẮT ĐẦU**

Implement đầy đủ 6 files theo spec trong `flutter_hotel_booking_prompt_v4.md`:

```
lib/data/models/
├── user_model.dart         ← copy từ spec, không sáng tạo thêm
├── destination_model.dart
├── hotel_model.dart
├── room_model.dart
├── guest_model.dart
└── booking_model.dart      ← chú ý null-check Timestamp (đã có trong spec)

lib/data/repositories/
├── auth_repository.dart
├── destination_repository.dart
├── hotel_repository.dart
├── room_repository.dart
└── booking_repository.dart ← chú ý dùng Transaction (đã có trong spec)
```

Sau khi xong: `flutter analyze` — fix hết lỗi — push lên rồi báo cả nhóm.
Cả nhóm merge branch này về main ngay: `git merge feature/data-layer`

---

### 👤 NGƯỜI 2 — Auth Screens + Onboarding
**Branch:** `feature/auth-screens`
**Thời gian:** 1-2 ngày
**Chờ Người 1 merge xong mới bắt đầu**

```
lib/screens/
├── onboarding/
│   └── onboarding_screen.dart   ← 3 slides đơn giản, làm ~2 tiếng
└── auth/
    ├── login_screen.dart
    └── register_screen.dart
```

**`onboarding_screen.dart`** — 3 slides, layout đơn giản
```dart
// Cấu trúc: Stack(ảnh nền + DraggableScrollableSheet chứa content)
// 3 slides: PageView, dots indicator bên dưới
// Slide cuối: nút đổi thành "Get Started" → LoginScreen
// Chỉ hiện 1 lần — dùng bool đơn giản hoặc luôn hiện cũng được

final slides = [
  OnboardingSlide(
    title: 'Khám phá điểm đến',
    description: 'Tìm hàng nghìn điểm du lịch tuyệt vời tại Việt Nam',
    imageUrl: 'https://images.unsplash.com/photo-1528127269322-539801943592?w=800',
  ),
  OnboardingSlide(
    title: 'Đặt phòng dễ dàng',
    description: 'Chọn phòng yêu thích và xác nhận chỉ trong vài giây',
    imageUrl: 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=800',
  ),
  OnboardingSlide(
    title: 'Trải nghiệm tuyệt vời',
    description: 'Hàng trăm khách sạn chất lượng đang chờ bạn',
    imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
  ),
];
```

Cập nhật `SplashScreen` trong `main.dart` để sau splash → `OnboardingScreen` thay vì `AuthWrapper`.
`OnboardingScreen` slide cuối → `AuthWrapper`.

Yêu cầu chi tiết:

**`login_screen.dart`**
- Email + password TextFormField với validator
- Nút "Đăng nhập" với CircularProgressIndicator khi loading
- Error message Text widget hiện bên dưới nút
- TextButton "Quên mật khẩu?" → gọi `AuthRepository.resetPassword`
- TextButton "Đăng ký" → Navigator.push sang RegisterScreen

**`register_screen.dart`**
- 5 fields: fullName, phone, email, password, confirmPassword
- Validate: email format, password ≥ 6 ký tự, 2 password phải khớp
- Nút "Đăng ký" với loading state
- Error message Text widget
- TextButton "Đã có tài khoản? Đăng nhập" → Navigator.pop

Shared widget dùng ở mọi màn hình:
```
lib/widgets/
└── avatar_widget.dart      ← buildAvatar() function từ spec
```

---

### 👤 NGƯỜI 3 — Home & Search
**Branch:** `feature/home-search`
**Thời gian:** 2-3 ngày
**Chờ Người 1 merge xong mới bắt đầu**

```
lib/screens/home/
└── home_screen.dart

lib/screens/search/
└── search_screen.dart
```

**`home_screen.dart`**
- AppBar: Text("Hotel Booking") + buildAvatar(user) ở bên phải
- Search TextField: onSubmitted → Navigator.push SearchScreen(query: text)
- Section "Địa danh nổi tiếng":
  - SizedBox height 200 + horizontal ListView
  - Mỗi DestinationCard: Stack(ảnh + gradient + tên + số khách sạn)
  - Tap → Navigator.push SearchScreen(city: destination.name)
- Section "Khách sạn nổi bật":
  - Vertical ListView.builder shrinkWrap
  - Mỗi HotelCard: Row(ảnh trái + info phải + rating + giá)
  - Tap → Navigator.push HotelDetailScreen(hotel: hotel)

**`search_screen.dart`**
- Nhận optional params: `String? city`, `String? query`
- TextField có IconButton clear (×) khi có text
- DropdownButton filter thành phố: "Tất cả" + list từ DestinationRepository
- Kết quả: ListView HotelCard
- Empty state: Center(child: Column(icon + text "Không tìm thấy kết quả"))

---

### 👤 NGƯỜI 4 — Hotel Detail & Booking Flow
**Branch:** `feature/hotel-booking`
**Thời gian:** 3-4 ngày (nhiều nhất)
**Chờ Người 1 merge xong mới bắt đầu**

```
lib/screens/hotel/
└── hotel_detail_screen.dart

lib/screens/booking/
├── booking_form_screen.dart
└── booking_confirmation_screen.dart
```

**`hotel_detail_screen.dart`**
- Nhận: `HotelModel hotel`
- Stack: PageView ảnh (swipe) + dots indicator bên dưới
- SliverAppBar hoặc CustomScrollView để ảnh scroll cùng content
- Info section: tên, Row stars Icons, rating, địa chỉ, checkIn/Out
- Amenities: Wrap(spacing: 8, children: amenities.map → Chip)
- Room section: ListView rooms từ RoomRepository
- Mỗi RoomCard: Card(Row(ảnh + Column(tên, giá, capacity, nút "Đặt ngay")))

**`booking_form_screen.dart`**
- Nhận: `HotelModel hotel`, `RoomModel room`
- Date picker: ElevatedButton mở showDateRangePicker
  - firstDate: DateTime.now() — KHÔNG cho chọn ngày quá khứ
  - Validate: checkOut > checkIn, tối đa 30 đêm
- Form 4 fields: firstName, lastName, phone, email
- Summary Card: tên phòng + số đêm + tổng tiền
- Nút "Xác nhận đặt phòng":
  - Guard: `if (_isLoading) return;`
  - Disable khi đang loading
  - On success: Navigator.pushReplacement BookingConfirmationScreen

**`booking_confirmation_screen.dart`**
- Nhận: `BookingModel booking`
- Center column: Icon check_circle (green, size 80) + confirmationCode bold + summary
- ElevatedButton "Về trang chủ" → Navigator.pushAndRemoveUntil HomeScreen

---

### 👤 NGƯỜI 5 — Profile & My Bookings
**Branch:** `feature/profile`
**Thời gian:** 1-2 ngày
**Chờ Người 1 merge xong mới bắt đầu**

```
lib/screens/profile/
└── profile_screen.dart
```

**`profile_screen.dart`**
- Header: Column(buildAvatar(radius: 40) + fullName bold + email)
- ListTile "Đăng xuất" với icon → AuthRepository.logout → Navigator.pushAndRemoveUntil LoginScreen
- Divider
- Text "Lịch sử đặt phòng" bold
- FutureBuilder lấy bookings từ BookingRepository.getBookingsByUser
- Mỗi BookingHistoryCard:
  ```
  Card
  ├── Row: hotelName (bold) + status badge (Chip màu)
  ├── Text: confirmationCode
  ├── Row: checkIn → checkOut (dùng DateFormatter)
  ├── Text: totalPrice (dùng CurrencyFormatter)
  └── [nếu status == "confirmed"] TextButton "Huỷ đặt phòng"
        → showDialog xác nhận → cancelBooking → setState reload
  ```
- Status badge colors:
  - "confirmed" → Colors.green
  - "cancelled" → Colors.red
  - "completed" → Colors.grey

---

## PHẦN 3 — QUY TẮC CHUNG CHO CẢ NHÓM

### Git workflow
```bash
# Mỗi ngày bắt đầu làm:
git pull origin main          # lấy code mới nhất

# Khi xong 1 tính năng nhỏ:
git add .
git commit -m "feat: mô tả ngắn"
git push origin <tên-branch-của-mình>

# Khi muốn merge vào main (báo cả nhóm trước):
git checkout main
git merge <tên-branch>
git push origin main
```

### Quy tắc đặt tên commit
```
feat: thêm tính năng mới         → feat: implement login screen
fix: sửa bug                     → fix: null check timestamp
style: chỉnh UI                  → style: update hotel card layout
```

### Khi bị lỗi — làm theo thứ tự này
```
1. Đọc kỹ error message
2. Chạy: flutter analyze
3. Hỏi AI với đầy đủ: error message + đoạn code liên quan
4. Hỏi teammate
```

### Checklist trước khi merge vào main
```
□ flutter analyze → 0 errors
□ Chạy app trên emulator không crash
□ Màn hình hiển thị đúng data từ Firestore
□ Loading state hiện đúng lúc
□ Error case hiện SnackBar tiếng Việt
```

---

## PHẦN 4 — TIMELINE

```
Ngày 1    Người 1 setup project + bắt đầu data layer
           Cả nhóm: clone repo, đọc spec v4

Ngày 2-3  Người 1: hoàn thành data layer + merge main
           Người 2, 3, 4, 5: pull main + bắt đầu làm song song

Ngày 4-5  Người 2: Auth screens xong
           Người 3: Home + Search xong
           Người 4: Hotel detail xong (booking flow sang ngày 5-6)
           Người 5: Profile xong

Ngày 6-7  Người 4: Booking flow + confirmation xong
           Cả nhóm: merge vào main, test integration

Ngày 8-9  Fix bug tích hợp, test luồng hoàn chỉnh end-to-end
           UI polish: padding, màu sắc, font

Ngày 10+  Buffer, chuẩn bị demo, fix critical bugs
```

---

## LƯU Ý QUAN TRỌNG

> Người 1 là người quan trọng nhất — nếu data layer sai, cả nhóm bị block.
> Người 1 nên là người giỏi nhất trong nhóm hoặc được hỗ trợ nhiều nhất.

> Mỗi người đọc toàn bộ `flutter_hotel_booking_prompt_v4.md` trước khi code —
> đặc biệt phần Rules và Implementation Order.

> Khi có conflict khi merge: báo cả nhóm, giải quyết cùng nhau, không tự ý overwrite code người khác.

---

## PHẦN 5 — UI GUIDELINES THEO FIGMA

Toàn bộ nhóm áp dụng thống nhất các quy tắc UI sau để app trông đồng nhất.

### Màu sắc
```
Primary (nút, icon active, highlight): #29B6F6
Nền màn hình:                          #FFFFFF
Nền card / input:                      #F5F5F5
Text chính:                            #1A1A1A
Text phụ:                              #757575
Sao rating:                            #FFC107
Lỗi / Huỷ:                            #E53935
Success screen background:             #29B6F6  ← xanh dương (không phải xanh lá)
```

### Border radius — bo tròn mạnh theo Figma
```
Nút bấm lớn (Login, Register...):  BorderRadius.circular(16)
Card khách sạn, phòng:              BorderRadius.circular(12)
Input field:                        BorderRadius.circular(12)
Chip amenities:                     BorderRadius.circular(8)
Avatar:                             CircleAvatar (tròn hoàn toàn)
```

### Màn hình thành công — Register success & Booking success
```dart
// Cả 2 màn hình dùng cùng 1 pattern (ảnh 7 và 15 trong Figma)
Scaffold(
  backgroundColor: AppColors.primary,  // nền xanh dương
  body: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo hoặc icon trắng
        Icon(Icons.check_circle_outline, size: 80, color: Colors.white),
        SizedBox(height: 24),
        Text('Tiêu đề', style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        )),
        Text('Mô tả phụ', style: TextStyle(color: Colors.white70)),
      ],
    ),
  ),
  bottomNavigationBar: Padding(
    padding: EdgeInsets.all(24),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,  // chữ xanh trên nền trắng
      ),
      onPressed: () { /* navigate */ },
      child: Text('Back to home'),
    ),
  ),
)
```

### Home screen hero section
```dart
// Header có ảnh nền + gradient overlay + search bar (ảnh 10 Figma)
Stack(
  children: [
    // Ảnh nền
    CachedNetworkImage(height: 220, fit: BoxFit.cover, ...),
    // Gradient tối dần từ dưới
    Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black54],
        ),
      ),
    ),
    // Text + search bar
    Positioned(bottom: 16, left: 16, right: 16,
      child: Column(children: [
        Text('Khám phá Việt Nam', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        SearchBar(...),
      ]),
    ),
  ],
)
```

### HotelCard layout
```dart
// Layout nằm ngang: ảnh trái + info phải (ảnh 11 Figma)
Card(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: Row(
    children: [
      // Ảnh vuông bên trái
      ClipRRect(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
        child: CachedNetworkImage(width: 100, height: 100, fit: BoxFit.cover),
      ),
      // Info bên phải
      Expanded(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(hotel.name, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(hotel.city, style: TextStyle(color: AppColors.textSecondary)),
              Row(children: [
                Icon(Icons.star, color: AppColors.star, size: 14),
                Text('${hotel.rating}'),
              ]),
              Text(CurrencyFormatter.format(hotel.priceFrom),
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    ],
  ),
)
```

### Những thứ BỎ so với Figma gốc
```
✅ Onboarding slides (ảnh 2,3,4)   → GIỮ LẠI — đơn giản, ấn tượng khi demo
❌ Social login Facebook/Apple      → chỉ giữ Email/Password
❌ Map trong hotel detail           → bỏ
❌ Reviews section                  → bỏ
❌ FAQ / People frequently ask      → bỏ
❌ Wishlist tab + tính năng         → bỏ
❌ Notification tab                 → bỏ
❌ Dark mode / Change language      → bỏ
❌ Terms & Privacy legal            → bỏ
❌ Age field trong Register         → bỏ (không có trong UserModel)
❌ ID Number trong booking form     → bỏ (không có trong GuestModel)
```
