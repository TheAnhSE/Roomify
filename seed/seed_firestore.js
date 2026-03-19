/**
 * FIREBASE FIRESTORE SEED SCRIPT
 * ================================
 * Dữ liệu mẫu cho Flutter Hotel Booking App
 *
 * CÁCH CHẠY:
 *   1. npm install firebase-admin
 *   2. Tải serviceAccountKey.json từ Firebase Console:
 *      Project Settings → Service Accounts → Generate new private key
 *   3. Đặt file serviceAccountKey.json cùng thư mục với script này
 *   4. node seed_firestore.js
 *
 * DỮ LIỆU TẠO RA:
 *   - 5 destinations (Đà Nẵng, Hội An, Phú Quốc, Hà Nội, TP.HCM)
 *   - 15 hotels    (3 hotel / destination)
 *   - 45 rooms     (3 room / hotel: Standard, Deluxe, Suite)
 *
 * QUAN TRỌNG: hotel.city phải khớp CHÍNH XÁC destination.name
 * vì SearchScreen filter theo city == destination.name
 */

const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// ─────────────────────────────────────────────────────────────
// HELPER — tạo batch write, tự flush khi đủ 500 ops
// Firestore giới hạn 500 writes/batch
// ─────────────────────────────────────────────────────────────
class BatchWriter {
  constructor(db) {
    this.db = db;
    this.batch = db.batch();
    this.count = 0;
    this.total = 0;
  }

  set(ref, data) {
    this.batch.set(ref, data);
    this.count++;
    this.total++;
  }

  async flush() {
    if (this.count > 0) {
      await this.batch.commit();
      console.log(`  ✓ Committed ${this.count} writes (total: ${this.total})`);
      this.batch = this.db.batch();
      this.count = 0;
    }
  }

  async autoFlush() {
    if (this.count >= 490) await this.flush(); // safety margin
  }
}

// ─────────────────────────────────────────────────────────────
// DATA DEFINITIONS
// ─────────────────────────────────────────────────────────────

/**
 * 5 Destinations — ảnh từ Unsplash (free, no key required)
 * hotelCount = 3 vì mỗi destination có 3 hotel bên dưới
 */
const destinations = [
  {
    id: "dest_danang",
    name: "Đà Nẵng",
    imageUrl:
      "https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=800&q=80",
    description:
      "Thành phố biển năng động với bãi biển Mỹ Khê trải dài, cầu Rồng biểu tượng và núi Bà Nà Hills huyền ảo. Điểm du lịch hàng đầu miền Trung Việt Nam.",
    hotelCount: 3,
  },
  {
    id: "dest_hoian",
    name: "Hội An",
    imageUrl:
      "https://images.unsplash.com/photo-1528127269322-539801943592?w=800&q=80",
    description:
      "Phố cổ di sản UNESCO với những ngôi nhà cổ đèn lồng rực rỡ, sông Hoài thơ mộng và ẩm thực đặc sắc. Viên ngọc của du lịch miền Trung.",
    hotelCount: 3,
  },
  {
    id: "dest_phuquoc",
    name: "Phú Quốc",
    imageUrl:
      "https://images.unsplash.com/photo-1573843981267-be1999ff37cd?w=800&q=80",
    description:
      "Đảo ngọc thiên đường với bãi biển trong xanh, hoàng hôn huyền ảo và hải sản tươi ngon. Maldives của Việt Nam.",
    hotelCount: 3,
  },
  {
    id: "dest_hanoi",
    name: "Hà Nội",
    imageUrl:
      "https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800&q=80",
    description:
      "Thủ đô nghìn năm văn hiến với Hồ Hoàn Kiếm, phố cổ 36 phố phường và ẩm thực đường phố đặc sắc. Trái tim của văn hóa Việt.",
    hotelCount: 3,
  },
  {
    id: "dest_hcm",
    name: "TP. Hồ Chí Minh",
    imageUrl:
      "https://images.unsplash.com/photo-1583417319070-4a69db38a483?w=800&q=80",
    description:
      "Thành phố năng động nhất Việt Nam với nhịp sống sôi động, ẩm thực đa dạng và kiến trúc độc đáo pha trộn Đông-Tây.",
    hotelCount: 3,
  },
];

/**
 * 15 Hotels — 3 per destination
 * city PHẢI KHỚP CHÍNH XÁC với destination.name
 * priceFrom = giá thấp nhất của các room thuộc hotel đó (Standard room)
 */
const hotels = [
  // ═══════════════════════════════════════
  // ĐÀ NẴNG — 3 hotels
  // ═══════════════════════════════════════
  {
    id: "hotel_dn_1",
    name: "Danang Marriott Resort & Spa",
    city: "Đà Nẵng", // ← phải khớp destination.name
    country: "Việt Nam",
    address: "7 Võ Nguyên Giáp, Mỹ An, Ngũ Hành Sơn, Đà Nẵng",
    imageUrls: [
      "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80",
      "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80",
      "https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80",
      "https://images.unsplash.com/photo-1540541338287-41700207dee6?w=800&q=80",
    ],
    rating: 4.8,
    priceFrom: 2500000,
    description:
      "Resort 5 sao sang trọng nằm ngay bãi biển Mỹ Khê. Sở hữu 2 bể bơi vô cực, spa đẳng cấp thế giới và nhà hàng phục vụ ẩm thực Việt Nam và quốc tế. Tầm nhìn trực tiếp ra biển Đông.",
    amenities: [
      "Wifi miễn phí",
      "Hồ bơi vô cực",
      "Spa & Wellness",
      "Nhà hàng",
      "Bar",
      "Phòng gym",
      "Đưa đón sân bay",
      "Bãi đỗ xe",
      "Trung tâm thương mại",
    ],
    stars: 5,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_dn_2",
    name: "Hyatt Regency Danang Resort",
    city: "Đà Nẵng",
    country: "Việt Nam",
    address: "5 Trường Sa, Hoà Hải, Ngũ Hành Sơn, Đà Nẵng",
    imageUrls: [
      "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&q=80",
      "https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=800&q=80",
      "https://images.unsplash.com/photo-1551882547-ff40c63fe2a4?w=800&q=80",
      "https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800&q=80",
    ],
    rating: 4.7,
    priceFrom: 1800000,
    description:
      "Resort nghỉ dưỡng đẳng cấp 5 sao với hệ thống villa riêng biệt, 3 bể bơi ngoài trời và bãi biển tư riêng 100m. Kiến trúc mang cảm hứng Chăm Pa cổ điển.",
    amenities: [
      "Wifi miễn phí",
      "Bãi biển riêng",
      "3 Hồ bơi",
      "Spa",
      "5 Nhà hàng",
      "Phòng gym",
      "Hoạt động thể thao biển",
      "Kids Club",
    ],
    stars: 5,
    checkInTime: "15:00",
    checkOutTime: "11:00",
  },
  {
    id: "hotel_dn_3",
    name: "Novotel Danang Premier Han River",
    city: "Đà Nẵng",
    country: "Việt Nam",
    address: "36 Bạch Đằng, Thạch Thang, Hải Châu, Đà Nẵng",
    imageUrls: [
      "https://images.unsplash.com/photo-1576354302919-96748cb8299e?w=800&q=80",
      "https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80",
      "https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800&q=80",
      "https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80",
    ],
    rating: 4.5,
    priceFrom: 1200000,
    description:
      "Khách sạn trung tâm thành phố với tầm nhìn tuyệt đẹp ra sông Hàn và cầu Rồng. Vị trí đắc địa, cách Cầu Rồng 200m, di chuyển thuận tiện đến mọi điểm du lịch.",
    amenities: [
      "Wifi miễn phí",
      "Hồ bơi",
      "Nhà hàng",
      "Bar trên mái",
      "Phòng gym",
      "Dịch vụ giặt ủi",
      "Đưa đón sân bay",
    ],
    stars: 4,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },

  // ═══════════════════════════════════════
  // HỘI AN — 3 hotels
  // ═══════════════════════════════════════
  {
    id: "hotel_ha_1",
    name: "Four Seasons Resort The Nam Hai",
    city: "Hội An",
    country: "Việt Nam",
    address: "Block Ha My, Điện Dương, Điện Bàn, Quảng Nam",
    imageUrls: [
      "https://images.unsplash.com/photo-1439130490301-25e322d88054?w=800&q=80",
      "https://images.unsplash.com/photo-1444201983204-c43cbd584d93?w=800&q=80",
      "https://images.unsplash.com/photo-1602002418816-5c0aeef426aa?w=800&q=80",
      "https://images.unsplash.com/photo-1561501900-3701fa6a0864?w=800&q=80",
    ],
    rating: 4.9,
    priceFrom: 5000000,
    description:
      "Resort 5 sao biểu tượng của Hội An với 100 villa và pool villa nằm giữa thiên nhiên xanh mát. Đoạt giải best resort châu Á nhiều năm liền. Trải nghiệm spa Việt Nam độc đáo.",
    amenities: [
      "Wifi miễn phí",
      "Pool Villa",
      "Bãi biển riêng",
      "Spa truyền thống",
      "3 Hồ bơi",
      "Nhà hàng fine dining",
      "Cooking class",
      "Tour phố cổ",
      "Butler service",
    ],
    stars: 5,
    checkInTime: "15:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_ha_2",
    name: "Anantara Hoi An Resort",
    city: "Hội An",
    country: "Việt Nam",
    address: "1 Phạm Hồng Thái, Cẩm Phô, Hội An, Quảng Nam",
    imageUrls: [
      "https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80",
      "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=80",
      "https://images.unsplash.com/photo-1499856374078-b0696a03ef8e?w=800&q=80",
      "https://images.unsplash.com/photo-1496417263034-38ec4f0b665a?w=800&q=80",
    ],
    rating: 4.6,
    priceFrom: 2800000,
    description:
      "Resort nằm ngay trung tâm phố cổ Hội An bên bờ sông Thu Bồn. Kiến trúc kết hợp truyền thống Việt Nam với tiện nghi hiện đại. Đi bộ 5 phút đến phố cổ.",
    amenities: [
      "Wifi miễn phí",
      "Hồ bơi",
      "Sông view",
      "Spa",
      "Nhà hàng",
      "Xe đạp miễn phí",
      "Cooking class",
      "Phòng gym",
    ],
    stars: 5,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_ha_3",
    name: "Vinh Hung Heritage Hotel",
    city: "Hội An",
    country: "Việt Nam",
    address: "143 Trần Phú, Minh An, Hội An, Quảng Nam",
    imageUrls: [
      "https://images.unsplash.com/photo-1574691250077-03a929faece5?w=800&q=80",
      "https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80",
      "https://images.unsplash.com/photo-1586375300773-8384e3e4916f?w=800&q=80",
      "https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80",
    ],
    rating: 4.3,
    priceFrom: 800000,
    description:
      "Nhà cổ 200 năm tuổi nằm ngay trên phố Trần Phú — con phố di sản đẹp nhất Hội An. Trải nghiệm sống trong không gian cổ kính, được trùng tu nguyên bản với đầy đủ tiện nghi hiện đại.",
    amenities: [
      "Wifi miễn phí",
      "Nhà cổ 200 năm",
      "Trung tâm phố cổ",
      "Bữa sáng miễn phí",
      "Tour đèn lồng",
      "Xe đạp miễn phí",
    ],
    stars: 3,
    checkInTime: "13:00",
    checkOutTime: "11:00",
  },

  // ═══════════════════════════════════════
  // PHÚ QUỐC — 3 hotels
  // ═══════════════════════════════════════
  {
    id: "hotel_pq_1",
    name: "JW Marriott Phu Quoc Emerald Bay",
    city: "Phú Quốc",
    country: "Việt Nam",
    address: "Khu Bãi Khem, An Thới, Phú Quốc, Kiên Giang",
    imageUrls: [
      "https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800&q=80",
      "https://images.unsplash.com/photo-1614267157481-ca2b81ac6fcc?w=800&q=80",
      "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=80",
      "https://images.unsplash.com/photo-1563911302283-d2bc129e7570?w=800&q=80",
    ],
    rating: 4.9,
    priceFrom: 6000000,
    description:
      "Resort xa xỉ nhất Phú Quốc lấy cảm hứng từ trường đại học cổ điển châu Âu thế kỷ 19. Nằm trên bãi biển Khem hoang sơ, sở hữu water park, casino và 6 nhà hàng đẳng cấp.",
    amenities: [
      "Wifi miễn phí",
      "Bãi biển Khem riêng",
      "Water Park",
      "Casino",
      "6 Nhà hàng",
      "Spa & Salon",
      "Phòng gym",
      "Butler service",
      "Đưa đón thuỷ phi cơ",
    ],
    stars: 5,
    checkInTime: "15:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_pq_2",
    name: "Fusion Resort Phu Quoc",
    city: "Phú Quốc",
    country: "Việt Nam",
    address: "Bãi Ông Lang, Cửa Dương, Phú Quốc, Kiên Giang",
    imageUrls: [
      "https://images.unsplash.com/photo-1540202404-a2f29637228f?w=800&q=80",
      "https://images.unsplash.com/photo-1584132915807-fd1f5fbc078f?w=800&q=80",
      "https://images.unsplash.com/photo-1578645510447-e20b4311e3ce?w=800&q=80",
      "https://images.unsplash.com/photo-1566737236500-c8ac43014a67?w=800&q=80",
    ],
    rating: 4.7,
    priceFrom: 3500000,
    description:
      "All-inclusive resort với villa và pool villa nhìn ra hoàng hôn tuyệt đẹp bờ tây Phú Quốc. Spa vô hạn mỗi ngày, ăn uống thoải mái và không khí nghỉ dưỡng hoàn toàn riêng tư.",
    amenities: [
      "All-inclusive",
      "Wifi miễn phí",
      "Pool Villa",
      "Spa vô hạn",
      "Bãi biển riêng",
      "Kayak & Snorkeling",
      "Yoga buổi sáng",
      "Bar 24/7",
    ],
    stars: 5,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_pq_3",
    name: "Vinpearl Resort & Spa Phu Quoc",
    city: "Phú Quốc",
    country: "Việt Nam",
    address: "Bãi Dài, Gành Dầu, Phú Quốc, Kiên Giang",
    imageUrls: [
      "https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=800&q=80",
      "https://images.unsplash.com/photo-1543968996-ee822b8176ba?w=800&q=80",
      "https://images.unsplash.com/photo-1601701119533-fde05b8a19ed?w=800&q=80",
      "https://images.unsplash.com/photo-1568084680786-a84f91d1153c?w=800&q=80",
    ],
    rating: 4.4,
    priceFrom: 1500000,
    description:
      "Khu nghỉ dưỡng 5 sao với bãi tắm Bãi Dài trong xanh dài 8km. VinWonders Phú Quốc và Safari ngay trong khuôn viên. Phù hợp cho gia đình và cặp đôi.",
    amenities: [
      "Wifi miễn phí",
      "Bãi biển Bãi Dài",
      "VinWonders gần kề",
      "Safari",
      "2 Hồ bơi",
      "Spa",
      "Kids Club",
      "Nhà hàng buffet",
    ],
    stars: 5,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },

  // ═══════════════════════════════════════
  // HÀ NỘI — 3 hotels
  // ═══════════════════════════════════════
  {
    id: "hotel_hn_1",
    name: "Sofitel Legend Metropole Hanoi",
    city: "Hà Nội",
    country: "Việt Nam",
    address: "15 Ngô Quyền, Hoàn Kiếm, Hà Nội",
    imageUrls: [
      "https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800&q=80",
      "https://images.unsplash.com/photo-1562778612-e1e0cda9915c?w=800&q=80",
      "https://images.unsplash.com/photo-1560347876-aeef00ee58a1?w=800&q=80",
      "https://images.unsplash.com/photo-1522798514-97ceb8c4f1c8?w=800&q=80",
    ],
    rating: 4.9,
    priceFrom: 4500000,
    description:
      "Khách sạn lịch sử sang trọng nhất Hà Nội từ năm 1901. Di sản văn hoá nơi Charlie Chaplin, Graham Greene đã từng lưu trú. Vị trí trung tâm, cách Hồ Hoàn Kiếm 5 phút đi bộ.",
    amenities: [
      "Wifi miễn phí",
      "Hồ bơi ngoài trời",
      "Spa",
      "3 Nhà hàng",
      "Bar",
      "Phòng gym",
      "Dịch vụ concierge 24/7",
      "Hầm rượu",
      "Tour Hà Nội cổ",
    ],
    stars: 5,
    checkInTime: "15:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_hn_2",
    name: "InterContinental Hanoi Westlake",
    city: "Hà Nội",
    country: "Việt Nam",
    address: "1A Nghi Tàm, Tây Hồ, Hà Nội",
    imageUrls: [
      "https://images.unsplash.com/photo-1563911302283-d2bc129e7570?w=800&q=80",
      "https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80",
      "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&q=80",
      "https://images.unsplash.com/photo-1593085512500-5d55148d6f0d?w=800&q=80",
    ],
    rating: 4.7,
    priceFrom: 2200000,
    description:
      "Khách sạn 5 sao nằm trên mặt hồ Tây với tầm nhìn 360 độ ra hồ lớn nhất Hà Nội. Thiết kế độc đáo với các villa nổi trên mặt nước, không gian yên bình giữa lòng thủ đô.",
    amenities: [
      "Wifi miễn phí",
      "Villa trên hồ",
      "Hồ bơi",
      "Spa",
      "Nhà hàng hồ Tây view",
      "Bar",
      "Phòng gym",
      "Dịch vụ thuyền",
    ],
    stars: 5,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_hn_3",
    name: "La Siesta Classic Ma May",
    city: "Hà Nội",
    country: "Việt Nam",
    address: "94 Mã Mây, Hoàn Kiếm, Hà Nội",
    imageUrls: [
      "https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800&q=80",
      "https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=800&q=80",
      "https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800&q=80",
      "https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=800&q=80",
    ],
    rating: 4.4,
    priceFrom: 900000,
    description:
      "Boutique hotel nằm ngay trung tâm 36 phố phường Hà Nội cổ. Đi bộ 2 phút đến Hồ Hoàn Kiếm, 1 phút đến chợ đêm. Thiết kế Indochine tinh tế, dịch vụ ấm cúng.",
    amenities: [
      "Wifi miễn phí",
      "Trung tâm phố cổ",
      "Bữa sáng miễn phí",
      "Nhà hàng mái",
      "Bar",
      "Dịch vụ concierge",
      "Thuê xe máy",
    ],
    stars: 4,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },

  // ═══════════════════════════════════════
  // TP. HỒ CHÍ MINH — 3 hotels
  // ═══════════════════════════════════════
  {
    id: "hotel_hcm_1",
    name: "Park Hyatt Saigon",
    city: "TP. Hồ Chí Minh",
    country: "Việt Nam",
    address: "2 Công Trường Lam Sơn, Bến Nghé, Quận 1, TP.HCM",
    imageUrls: [
      "https://images.unsplash.com/photo-1549294413-26f195200c16?w=800&q=80",
      "https://images.unsplash.com/photo-1593053272405-3ea2af91c491?w=800&q=80",
      "https://images.unsplash.com/photo-1615460549969-36fa19521a4f?w=800&q=80",
      "https://images.unsplash.com/photo-1600011689032-8b628b8a8747?w=800&q=80",
    ],
    rating: 4.8,
    priceFrom: 3800000,
    description:
      "Khách sạn 5 sao biểu tượng tại trung tâm Quận 1, đối diện Nhà hát Thành phố. Kết hợp kiến trúc thuộc địa Pháp với thiết kế hiện đại. Nhà hàng Square One nổi tiếng nhất Sài Gòn.",
    amenities: [
      "Wifi miễn phí",
      "Hồ bơi",
      "Spa",
      "2 Nhà hàng",
      "Bar",
      "Phòng gym",
      "Dịch vụ concierge",
      "Trung tâm thương vụ",
      "Đưa đón sân bay",
    ],
    stars: 5,
    checkInTime: "15:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_hcm_2",
    name: "The Reverie Saigon",
    city: "TP. Hồ Chí Minh",
    country: "Việt Nam",
    address: "22-36 Nguyễn Huệ, Bến Nghé, Quận 1, TP.HCM",
    imageUrls: [
      "https://images.unsplash.com/photo-1606402179428-a57976d71fa4?w=800&q=80",
      "https://images.unsplash.com/photo-1587213811864-c89ada7774e3?w=800&q=80",
      "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=80",
      "https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=800&q=80",
    ],
    rating: 4.8,
    priceFrom: 5500000,
    description:
      "Một trong những khách sạn xa xỉ nhất Sài Gòn với thiết kế Italian Renaissance cực kỳ ấn tượng. Nằm trên phố đi bộ Nguyễn Huệ, bar trên tầng cao với view sông Sài Gòn tuyệt đẹp.",
    amenities: [
      "Wifi miễn phí",
      "Hồ bơi rooftop",
      "Spa đẳng cấp",
      "4 Nhà hàng",
      "Sky bar",
      "Phòng gym",
      "Butler service",
      "Rolls-Royce đưa đón",
    ],
    stars: 5,
    checkInTime: "15:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_hcm_3",
    name: "Liberty Central Saigon Citypoint",
    city: "TP. Hồ Chí Minh",
    country: "Việt Nam",
    address: "59 Pasteur, Nguyễn Thái Bình, Quận 1, TP.HCM",
    imageUrls: [
      "https://images.unsplash.com/photo-1496417263034-38ec4f0b665a?w=800&q=80",
      "https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?w=800&q=80",
      "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80",
      "https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?w=800&q=80",
    ],
    rating: 4.3,
    priceFrom: 900000,
    description:
      "Khách sạn 4 sao hiện đại ngay trung tâm Quận 1 với rooftop pool và bar nhìn ra toàn cảnh thành phố. Đi bộ 5 phút đến phố đi bộ Nguyễn Huệ và Chợ Bến Thành.",
    amenities: [
      "Wifi miễn phí",
      "Rooftop pool",
      "Nhà hàng",
      "Rooftop bar",
      "Phòng gym",
      "Trung tâm thương vụ",
      "Đưa đón sân bay",
    ],
    stars: 4,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },
];

/**
 * Room templates — mỗi hotel có 3 phòng: Standard, Deluxe, Suite
 * pricePerNight của Deluxe và Suite tính tự động từ Standard
 *
 * Ảnh phòng — dùng chung theo loại phòng để đảm bảo realistic
 */
const ROOM_IMAGES = {
  standard: [
    "https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80",
    "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&q=80",
    "https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800&q=80",
  ],
  deluxe: [
    "https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800&q=80",
    "https://images.unsplash.com/photo-1560347876-aeef00ee58a1?w=800&q=80",
    "https://images.unsplash.com/photo-1560185008-a33f5c7b1844?w=800&q=80",
  ],
  suite: [
    "https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80",
    "https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80",
    "https://images.unsplash.com/photo-1601918774516-f25a2d545ba7?w=800&q=80",
  ],
};

/**
 * Tạo 3 rooms cho mỗi hotel
 * @param {string} hotelId
 * @param {number} priceFrom - giá Standard = priceFrom của hotel
 */
function createRoomsForHotel(hotelId, priceFrom) {
  return [
    {
      id: `${hotelId}_room_101`,
      hotelId: hotelId,
      roomNumber: "101",
      roomType: "Standard",
      pricePerNight: priceFrom, // bằng priceFrom → consistent với HotelCard hiển thị
      capacity: 2,
      imageUrls: ROOM_IMAGES.standard,
      isAvailable: true,
      amenities: [
        "Wifi miễn phí",
        "TV màn hình phẳng",
        "Điều hoà",
        "Mini bar",
        "Két an toàn",
        "Vòi tắm",
      ],
    },
    {
      id: `${hotelId}_room_201`,
      hotelId: hotelId,
      roomNumber: "201",
      roomType: "Deluxe",
      pricePerNight: Math.round(priceFrom * 1.6), // Deluxe = 1.6x Standard
      capacity: 2,
      imageUrls: ROOM_IMAGES.deluxe,
      isAvailable: true,
      amenities: [
        "Wifi miễn phí",
        "TV màn hình phẳng",
        "Điều hoà",
        "Mini bar",
        "Két an toàn",
        "Bồn tắm",
        "Ban công view đẹp",
        "Đồ uống chào đón",
      ],
    },
    {
      id: `${hotelId}_room_301`,
      hotelId: hotelId,
      roomNumber: "301",
      roomType: "Suite",
      pricePerNight: Math.round(priceFrom * 2.8), // Suite = 2.8x Standard
      capacity: 4,
      imageUrls: ROOM_IMAGES.suite,
      isAvailable: true,
      amenities: [
        "Wifi miễn phí",
        "Smart TV 65 inch",
        "Điều hoà",
        "Mini bar cao cấp",
        "Két an toàn",
        "Bồn tắm Jacuzzi",
        "Phòng khách riêng",
        "Butler service",
        "Đồ uống & trái cây chào đón",
        "Late checkout",
      ],
    },
  ];
}

// ─────────────────────────────────────────────────────────────
// MAIN SEED FUNCTION
// ─────────────────────────────────────────────────────────────
async function seed() {
  console.log("🚀 Bắt đầu seed Firestore...\n");
  const writer = new BatchWriter(db);

  // ── 1. DESTINATIONS ───────────────────────────────────────
  console.log("📍 Seeding destinations...");
  for (const dest of destinations) {
    const { id, ...data } = dest;
    writer.set(db.collection("destinations").doc(id), data);
    await writer.autoFlush();
  }
  await writer.flush();
  console.log(`  → ${destinations.length} destinations\n`);

  // ── 2. HOTELS ─────────────────────────────────────────────
  console.log("🏨 Seeding hotels...");
  for (const hotel of hotels) {
    const { id, ...data } = hotel;
    writer.set(db.collection("hotels").doc(id), data);
    await writer.autoFlush();
  }
  await writer.flush();
  console.log(`  → ${hotels.length} hotels\n`);

  // ── 3. ROOMS ──────────────────────────────────────────────
  console.log("🛏️  Seeding rooms...");
  let roomCount = 0;

  for (const hotel of hotels) {
    const rooms = createRoomsForHotel(hotel.id, hotel.priceFrom);
    for (const room of rooms) {
      const { id, ...data } = room;
      writer.set(db.collection("rooms").doc(id), data);
      roomCount++;
      await writer.autoFlush();
    }
  }
  await writer.flush();
  console.log(`  → ${roomCount} rooms\n`);

  // ── 4. SUMMARY ────────────────────────────────────────────
  console.log("✅ Seed hoàn thành!");
  console.log("─".repeat(40));
  console.log(`  Destinations : ${destinations.length}`);
  console.log(`  Hotels       : ${hotels.length}`);
  console.log(`  Rooms        : ${roomCount}`);
  console.log(`  Tổng writes  : ${writer.total}`);
  console.log("─".repeat(40));
  console.log("\nKiểm tra Firebase Console:");
  console.log("  https://console.firebase.google.com\n");
}

// ─────────────────────────────────────────────────────────────
// OPTIONAL: XOÁ DỮ LIỆU CŨ TRƯỚC KHI SEED LẠI
// Bỏ comment hàm clearCollections và gọi trước seed() nếu cần
// ─────────────────────────────────────────────────────────────
async function clearCollection(collectionName) {
  const snapshot = await db.collection(collectionName).get();
  if (snapshot.empty) return;

  const writer = new BatchWriter(db);
  for (const doc of snapshot.docs) {
    writer.batch.delete(doc.ref);
    writer.count++;
    writer.total++;
    await writer.autoFlush();
  }
  await writer.flush();
  console.log(`  🗑️  Cleared ${snapshot.size} docs from '${collectionName}'`);
}

async function clearCollections() {
  console.log("🗑️  Xoá dữ liệu cũ...");
  await clearCollection("destinations");
  await clearCollection("hotels");
  await clearCollection("rooms");
  // Không xoá 'bookings' và 'users' để bảo toàn dữ liệu user thật
  console.log("  ✓ Xong\n");
}

// ─────────────────────────────────────────────────────────────
// ENTRY POINT
// ─────────────────────────────────────────────────────────────
(async () => {
  try {
    // Bỏ comment dòng dưới nếu muốn xoá dữ liệu cũ trước:
    // await clearCollections();

    await seed();
    process.exit(0);
  } catch (err) {
    console.error("❌ Lỗi khi seed:", err);
    process.exit(1);
  }
})();
