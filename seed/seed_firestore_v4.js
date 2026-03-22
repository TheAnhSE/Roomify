/**
 * FIREBASE FIRESTORE SEED SCRIPT — v2
 * =====================================
 * Hotel Booking App — Vietnamese Destinations, English Content
 *
 * HOW TO RUN:
 *   1. npm install firebase-admin
 *   2. Place serviceAccountKey.json in the same folder
 *   3. node seed_firestore.js
 *
 * DATA GENERATED:
 *   - 5  destinations
 *   - 15 hotels        (3 per destination)
 *   - 120 rooms        (8 per hotel: 3 Standard + 3 Deluxe + 2 Suite)
 *
 * CRITICAL: hotel.city must EXACTLY match destination.name (byte-for-byte).
 * The SearchScreen uses a strict equality filter: .where('city', isEqualTo: city)
 */

const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// ─────────────────────────────────────────────────────────────
// HELPER — batch writer that auto-flushes at 490 ops
// Firestore hard limit: 500 writes per batch
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
      console.log(`  ✓ Committed ${this.count} writes (cumulative: ${this.total})`);
      this.batch = this.db.batch();
      this.count = 0;
    }
  }

  async autoFlush() {
    if (this.count >= 490) await this.flush();
  }
}

// ─────────────────────────────────────────────────────────────
// DESTINATIONS
// ─────────────────────────────────────────────────────────────
const destinations = [
  {
    id: "dest_danang",
    name: "Đà Nẵng",
    imageUrl: "https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=800&q=80",
    description:
      "A vibrant coastal city on central Vietnam's coastline, famous for My Khe Beach, the iconic Dragon Bridge, and the misty peaks of Ba Na Hills. One of Southeast Asia's fastest-growing travel destinations.",
    hotelCount: 3,
  },
  {
    id: "dest_hoian",
    name: "Hội An",
    imageUrl: "https://images.unsplash.com/photo-1528127269322-539801943592?w=800&q=80",
    description:
      "A UNESCO World Heritage town renowned for its well-preserved Ancient Quarter, colourful lantern-lit streets, and the tranquil Thu Bon River. Widely regarded as the most atmospheric town in Vietnam.",
    hotelCount: 3,
  },
  {
    id: "dest_phuquoc",
    name: "Phú Quốc",
    imageUrl: "https://images.unsplash.com/photo-1573843981267-be1999ff37cd?w=800&q=80",
    description:
      "Vietnam's largest island, offering pristine white-sand beaches, crystal-clear waters, and breathtaking sunsets along its western coast. Often dubbed 'The Pearl Island' and Vietnam's answer to the Maldives.",
    hotelCount: 3,
  },
  {
    id: "dest_hanoi",
    name: "Hà Nội",
    imageUrl: "https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800&q=80",
    description:
      "Vietnam's millennium-old capital city blending French colonial grandeur with ancient Vietnamese heritage. Home to Hoan Kiem Lake, the Old Quarter's 36 guild streets, and a legendary street-food culture.",
    hotelCount: 3,
  },
  {
    id: "dest_hcm",
    name: "TP. Hồ Chí Minh",
    imageUrl: "https://images.unsplash.com/photo-1583417319070-4a69db38a483?w=800&q=80",
    description:
      "Vietnam's economic powerhouse and most dynamic metropolis, where French colonial landmarks meet gleaming skyscrapers. Renowned for its electric street-food scene, rooftop bars, and round-the-clock energy.",
    hotelCount: 3,
  },
  {
    id: "dest_sapa",
    name: "Sapa",
    imageUrl: "https://images.unsplash.com/photo-1590400589139-3832c3f1de92?w=800&q=80",
    description:
      "A misty mountain town in northwest Vietnam known for its terraced rice fields, vibrant hill-tribe culture, and the peak of Fansipan. Famous for dramatic landscapes and cool climate year-round.",
    hotelCount: 3,
  },
  {
    id: "dest_halong",
    name: "Hạ Long",
    imageUrl: "https://images.unsplash.com/photo-1528127269322-539801943592?w=800&q=80",
    description:
      "A UNESCO World Heritage site renowned for its emerald waters and thousands of towering limestone islands topped with rainforests. One of the most spectacular natural wonders of the world.",
    hotelCount: 3,
  },
  {
    id: "dest_haiphong",
    name: "Hải Phòng",
    imageUrl: "https://images.unsplash.com/photo-1596701062351-8c2c14d1fdd0?w=800&q=80",
    description:
      "Vietnam's third-largest city and the premier port in northern Vietnam. Often called the 'City of Flamboyant Flowers', it serves as a major hub for tourism to Cat Ba Island and Lan Ha Bay.",
    hotelCount: 3,
  },
];

// ─────────────────────────────────────────────────────────────
// HOTELS
// city MUST match destination.name exactly — do NOT abbreviate
// ─────────────────────────────────────────────────────────────
const hotels = [

  // ── ĐÀ NẴNG ──────────────────────────────────────────────
  {
    id: "hotel_dn_1",
    name: "Danang Marriott Resort & Spa",
    city: "Đà Nẵng",
    country: "Vietnam",
    address: "7 Vo Nguyen Giap, My An, Ngu Hanh Son, Da Nang",
    imageUrls: [
      "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80",
      "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80",
      "https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80",
      "https://images.unsplash.com/photo-1540541338287-41700207dee6?w=800&q=80",
    ],
    rating: 4.8,
    priceFrom: 2500000,
    description:
      "A five-star beachfront resort sitting directly on My Khe Beach — consistently ranked among Asia's top ten beaches. Features two infinity pools, a world-class spa, and three restaurants serving Vietnamese and international cuisine with uninterrupted East Sea views.",
    amenities: [
      "Free WiFi", "Infinity Pool", "Spa & Wellness", "Restaurant",
      "Beach Bar", "Fitness Center", "Airport Shuttle", "Parking", "Shopping Center",
    ],
    stars: 5,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_dn_2",
    name: "Hyatt Regency Danang Resort",
    city: "Đà Nẵng",
    country: "Vietnam",
    address: "5 Truong Sa, Hoa Hai, Ngu Hanh Son, Da Nang",
    imageUrls: [
      "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&q=80",
      "https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=800&q=80",
      "https://images.unsplash.com/photo-1551882547-ff40c63fe2a4?w=800&q=80",
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80",
    ],
    rating: 4.7,
    priceFrom: 1800000,
    description:
      "An expansive five-star resort with private villas, three outdoor pools, and a dedicated 100-metre private beach. The architecture draws inspiration from the ancient Cham civilisation, creating a distinctive cultural ambiance rarely found in modern luxury resorts.",
    amenities: [
      "Free WiFi", "Private Beach", "3 Swimming Pools", "Spa",
      "5 Restaurants", "Fitness Center", "Water Sports", "Kids Club",
    ],
    stars: 5,
    checkInTime: "15:00",
    checkOutTime: "11:00",
  },
  {
    id: "hotel_dn_3",
    name: "Novotel Danang Premier Han River",
    city: "Đà Nẵng",
    country: "Vietnam",
    address: "36 Bach Dang, Thach Thang, Hai Chau, Da Nang",
    imageUrls: [
      "https://images.unsplash.com/photo-1576354302919-96748cb8299e?w=800&q=80",
      "https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80",
      "https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800&q=80",
      "https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80",
    ],
    rating: 4.5,
    priceFrom: 1200000,
    description:
      "A sleek city-centre hotel commanding stunning views of the Han River and Dragon Bridge from most rooms. Situated just 200 metres from Dragon Bridge and within walking distance of major attractions, it offers the ideal base for urban exploration.",
    amenities: [
      "Free WiFi", "Rooftop Pool", "Restaurant", "Sky Bar",
      "Fitness Center", "Laundry Service", "Airport Shuttle",
    ],
    stars: 4,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },

  // ── HỘI AN ────────────────────────────────────────────────
  {
    id: "hotel_ha_1",
    name: "Four Seasons Resort The Nam Hai",
    city: "Hội An",
    country: "Vietnam",
    address: "Block Ha My, Dien Duong, Dien Ban, Quang Nam",
    imageUrls: [
      "https://images.unsplash.com/photo-1439130490301-25e322d88054?w=800&q=80",
      "https://images.unsplash.com/photo-1444201983204-c43cbd584d93?w=800&q=80",
      "https://images.unsplash.com/photo-1602002418816-5c0aeef426aa?w=800&q=80",
      "https://images.unsplash.com/photo-1561501900-3701fa6a0864?w=800&q=80",
    ],
    rating: 4.9,
    priceFrom: 5000000,
    description:
      "An award-winning resort consistently ranked among Asia's finest, set amid lush gardens on Ha My Beach. All 100 villas feature private pools and butler service. The spa draws on ancient Vietnamese healing traditions, while the culinary programme celebrates the extraordinary food culture of Hoi An.",
    amenities: [
      "Free WiFi", "Pool Villa", "Private Beach", "Traditional Spa",
      "3 Swimming Pools", "Fine Dining Restaurant", "Cooking Class", "Old Town Tour", "Butler Service",
    ],
    stars: 5,
    checkInTime: "15:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_ha_2",
    name: "Anantara Hoi An Resort",
    city: "Hội An",
    country: "Vietnam",
    address: "1 Pham Hong Thai, Cam Pho, Hoi An, Quang Nam",
    imageUrls: [
      "https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800&q=80",
      "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=80",
      "https://images.unsplash.com/photo-1499856374078-b0696a03ef8e?w=800&q=80",
      "https://images.unsplash.com/photo-1496417263034-38ec4f0b665a?w=800&q=80",
    ],
    rating: 4.6,
    priceFrom: 2800000,
    description:
      "A riverside five-star resort ideally positioned in the heart of the Ancient Town, overlooking the Thu Bon River. Vietnamese traditional architecture blends seamlessly with contemporary comforts, and the Ancient Town is just a five-minute stroll away.",
    amenities: [
      "Free WiFi", "River View Pool", "Spa", "Restaurant",
      "Free Bicycles", "Cooking Class", "Fitness Center", "River View",
    ],
    stars: 5,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_ha_3",
    name: "Vinh Hung Heritage Hotel",
    city: "Hội An",
    country: "Vietnam",
    address: "143 Tran Phu, Minh An, Hoi An, Quang Nam",
    imageUrls: [
      "https://images.unsplash.com/photo-1574691250077-03a929faece5?w=800&q=80",
      "https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80",
      "https://images.unsplash.com/photo-1586375300773-8384e3e4916f?w=800&q=80",
      "https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800&q=80",
    ],
    rating: 4.3,
    priceFrom: 800000,
    description:
      "A 200-year-old merchant house on Tran Phu Street — the most celebrated heritage street in Hoi An. Fully restored to its original form with modern amenities thoughtfully integrated. Staying here means sleeping inside a living museum steps from the Ancient Town's famous lantern-lit alleys.",
    amenities: [
      "Free WiFi", "200-Year-Old Heritage House", "Ancient Town Centre",
      "Complimentary Breakfast", "Lantern Festival Tour", "Free Bicycles",
    ],
    stars: 3,
    checkInTime: "13:00",
    checkOutTime: "11:00",
  },

  // ── PHÚ QUỐC ──────────────────────────────────────────────
  {
    id: "hotel_pq_1",
    name: "JW Marriott Phu Quoc Emerald Bay",
    city: "Phú Quốc",
    country: "Vietnam",
    address: "Khu Bai Khem, An Thoi, Phu Quoc, Kien Giang",
    imageUrls: [
      "https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800&q=80",
      "https://images.unsplash.com/photo-1614267157481-ca2b81ac6fcc?w=800&q=80",
      "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=80",
      "https://images.unsplash.com/photo-1563911302283-d2bc129e7570?w=800&q=80",
    ],
    rating: 4.9,
    priceFrom: 6000000,
    description:
      "Phu Quoc's most opulent resort, inspired by a 19th-century European university campus and set on the pristine shores of Khem Beach. The property features a water park, a casino, and six signature restaurants, making it a self-contained world of extraordinary luxury.",
    amenities: [
      "Free WiFi", "Private Khem Beach", "Water Park", "Casino",
      "6 Restaurants", "Spa & Salon", "Fitness Center", "Butler Service", "Seaplane Transfer",
    ],
    stars: 5,
    checkInTime: "15:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_pq_2",
    name: "Fusion Resort Phu Quoc",
    city: "Phú Quốc",
    country: "Vietnam",
    address: "Ong Lang Beach, Cua Duong, Phu Quoc, Kien Giang",
    imageUrls: [
      "https://images.unsplash.com/photo-1540202404-a2f29637228f?w=800&q=80",
      "https://images.unsplash.com/photo-1584132915807-fd1f5fbc078f?w=800&q=80",
      "https://images.unsplash.com/photo-1578645510447-e20b4311e3ce?w=800&q=80",
      "https://images.unsplash.com/photo-1566737236500-c8ac43014a67?w=800&q=80",
    ],
    rating: 4.7,
    priceFrom: 3500000,
    description:
      "An all-inclusive hideaway of pool villas perfectly positioned on Phu Quoc's western coast to capture legendary sunsets. Unlimited spa treatments are included every day, along with all meals, beverages, and non-motorised water sports — the definition of effortless indulgence.",
    amenities: [
      "All-Inclusive", "Free WiFi", "Pool Villa", "Unlimited Spa",
      "Private Beach", "Kayak & Snorkelling", "Morning Yoga", "24/7 Bar",
    ],
    stars: 5,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_pq_3",
    name: "Vinpearl Resort & Spa Phu Quoc",
    city: "Phú Quốc",
    country: "Vietnam",
    address: "Bai Dai, Ganh Dau, Phu Quoc, Kien Giang",
    imageUrls: [
      "https://images.unsplash.com/photo-1543968996-ee822b8176ba?w=800&q=80",
      "https://images.unsplash.com/photo-1519449374306-4e2c2e8e47e7?w=800&q=80",
      "https://images.unsplash.com/photo-1580041279827-9a6e2dc48a58?w=800&q=80",
      "https://images.unsplash.com/photo-1568084680786-a84f91d1153c?w=800&q=80",
    ],
    rating: 4.4,
    priceFrom: 1500000,
    description:
      "A sprawling five-star complex fronting the 8-kilometre Bai Dai Beach, consistently rated Vietnam's most beautiful stretch of sand. VinWonders theme park and the Vinpearl Safari — home to over 3,000 animals — are located within the resort grounds, perfect for families.",
    amenities: [
      "Free WiFi", "Bai Dai Beach Access", "VinWonders Theme Park",
      "Wildlife Safari", "2 Swimming Pools", "Spa", "Kids Club", "Buffet Restaurant",
    ],
    stars: 5,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },

  // ── HÀ NỘI ────────────────────────────────────────────────
  {
    id: "hotel_hn_1",
    name: "Sofitel Legend Metropole Hanoi",
    city: "Hà Nội",
    country: "Vietnam",
    address: "15 Ngo Quyen, Hoan Kiem, Hanoi",
    imageUrls: [
      "https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800&q=80",
      "https://images.unsplash.com/photo-1562778612-e1e0cda9915c?w=800&q=80",
      "https://images.unsplash.com/photo-1560347876-aeef00ee58a1?w=800&q=80",
      "https://images.unsplash.com/photo-1522798514-97ceb8c4f1c8?w=800&q=80",
    ],
    rating: 4.9,
    priceFrom: 4500000,
    description:
      "Hanoi's most storied luxury hotel, operating since 1901 and a National Historic Monument. Graham Greene wrote parts of The Quiet American here, and Charlie Chaplin honeymooned in its legendary suites. Set a five-minute walk from Hoan Kiem Lake, it remains the gold standard of Hanoi hospitality.",
    amenities: [
      "Free WiFi", "Outdoor Pool", "Spa", "3 Restaurants",
      "Champagne Bar", "Fitness Center", "24/7 Concierge", "Wine Cellar", "Hanoi Heritage Tour",
    ],
    stars: 5,
    checkInTime: "15:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_hn_2",
    name: "InterContinental Hanoi Westlake",
    city: "Hà Nội",
    country: "Vietnam",
    address: "1A Nghi Tam, Tay Ho, Hanoi",
    imageUrls: [
      "https://images.unsplash.com/photo-1587490499596-b3f5b06c2a5e?w=800&q=80",
      "https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80",
      "https://images.unsplash.com/photo-1629140727571-9b5c6f6267b4?w=800&q=80",
      "https://images.unsplash.com/photo-1593085512500-5d55148d6f0d?w=800&q=80",
    ],
    rating: 4.7,
    priceFrom: 2200000,
    description:
      "A five-star hotel uniquely built over West Lake, Hanoi's largest lake, offering 360-degree water panoramas from its over-water villas. The setting is extraordinary — absolute tranquillity just minutes from the city's Old Quarter, with sunset views that are among the finest in Indochina.",
    amenities: [
      "Free WiFi", "Over-Water Villas", "Lake View Pool", "Spa",
      "West Lake View Restaurant", "Bar", "Fitness Center", "Private Boat Service",
    ],
    stars: 5,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_hn_3",
    name: "La Siesta Classic Ma May",
    city: "Hà Nội",
    country: "Vietnam",
    address: "94 Ma May, Hoan Kiem, Hanoi",
    imageUrls: [
      "https://images.unsplash.com/photo-1566409579-560691bcea48?w=800&q=80",
      "https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=800&q=80",
      "https://images.unsplash.com/photo-1612537935159-e1ed7be30f33?w=800&q=80",
      "https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=800&q=80",
    ],
    rating: 4.4,
    priceFrom: 900000,
    description:
      "A charming boutique hotel nestled in the heart of Hanoi's 36-Street Old Quarter. A two-minute walk from Hoan Kiem Lake and one minute from the famous night market. The Indochine-inspired décor creates a warm, intimate atmosphere that large hotels simply cannot replicate.",
    amenities: [
      "Free WiFi", "Old Quarter Centre", "Complimentary Breakfast",
      "Rooftop Restaurant", "Bar", "Concierge Service", "Motorbike Rental",
    ],
    stars: 4,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },

  // ── TP. HỒ CHÍ MINH ───────────────────────────────────────
  {
    id: "hotel_hcm_1",
    name: "Park Hyatt Saigon",
    city: "TP. Hồ Chí Minh",
    country: "Vietnam",
    address: "2 Lam Son Square, Ben Nghe, District 1, Ho Chi Minh City",
    imageUrls: [
      "https://images.unsplash.com/photo-1549294413-26f195200c16?w=800&q=80",
      "https://images.unsplash.com/photo-1593053272405-3ea2af91c491?w=800&q=80",
      "https://images.unsplash.com/photo-1615460549969-36fa19521a4f?w=800&q=80",
      "https://images.unsplash.com/photo-1600011689032-8b628b8a8747?w=800&q=80",
    ],
    rating: 4.8,
    priceFrom: 3800000,
    description:
      "Saigon's most celebrated five-star address, opposite the iconic Opera House in the heart of District 1. The architecture marries French colonial elegance with contemporary design, while Square One restaurant has earned its reputation as the finest dining room in the city.",
    amenities: [
      "Free WiFi", "Pool", "Spa", "2 Restaurants",
      "Bar", "Fitness Center", "Concierge", "Business Centre", "Airport Transfer",
    ],
    stars: 5,
    checkInTime: "15:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_hcm_2",
    name: "The Reverie Saigon",
    city: "TP. Hồ Chí Minh",
    country: "Vietnam",
    address: "22-36 Nguyen Hue, Ben Nghe, District 1, Ho Chi Minh City",
    imageUrls: [
      "https://images.unsplash.com/photo-1606402179428-a57976d71fa4?w=800&q=80",
      "https://images.unsplash.com/photo-1587213811864-c89ada7774e3?w=800&q=80",
      "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=80",
      "https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=800&q=80",
    ],
    rating: 4.8,
    priceFrom: 5500000,
    description:
      "Vietnam's most extravagant hotel, adorned with Italian Renaissance interiors of breathtaking opulence. Located on the Nguyen Hue pedestrian boulevard with Saigon River views from its sky bar. Rolls-Royce airport transfers and a level of personalised service rarely encountered in Southeast Asia.",
    amenities: [
      "Free WiFi", "Rooftop Pool", "Luxury Spa", "4 Restaurants",
      "Sky Bar", "Fitness Center", "Butler Service", "Rolls-Royce Transfer",
    ],
    stars: 5,
    checkInTime: "15:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_hcm_3",
    name: "Liberty Central Saigon Citypoint",
    city: "TP. Hồ Chí Minh",
    country: "Vietnam",
    address: "59 Pasteur, Nguyen Thai Binh, District 1, Ho Chi Minh City",
    imageUrls: [
      "https://images.unsplash.com/photo-1601701119533-fde05b8a19ed?w=800&q=80",
      "https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?w=800&q=80",
      "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800&q=80",
      "https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?w=800&q=80",
    ],
    rating: 4.3,
    priceFrom: 900000,
    description:
      "A contemporary four-star hotel in the core of District 1, featuring a rooftop infinity pool and bar with panoramic city views. A five-minute walk from the Nguyen Hue Walking Street and Ben Thanh Market, offering unbeatable value in prime Saigon.",
    amenities: [
      "Free WiFi", "Rooftop Infinity Pool", "Restaurant",
      "Rooftop Bar", "Fitness Center", "Business Centre", "Airport Transfer",
    ],
    stars: 4,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },

  // ── SAPA ──────────────────────────────────────────────
  {
    id: "hotel_sp_1",
    name: "Hotel de la Coupole - MGallery",
    city: "Sapa",
    country: "Vietnam",
    address: "1 Hoang Lien Street, Sapa, Lao Cai",
    imageUrls: [
      "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80",
      "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80",
      "https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80",
      "https://images.unsplash.com/photo-1540541338287-41700207dee6?w=800&q=80",
    ],
    rating: 4.9,
    priceFrom: 3500000,
    description:
      "A masterpiece of design by Bill Bensley, blending French haute couture with Sapa hill tribe style. Featuring an indoor heated pool, a luxurious spa, and direct access to the Fansipan cable car station.",
    amenities: [
      "Free WiFi", "Indoor Heated Pool", "Luxury Spa", "French Restaurant",
      "Rooftop Bar", "Fitness Center", "Mountain Views", "Cable Car Access",
    ],
    stars: 5,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_sp_2",
    name: "Topas Ecolodge",
    city: "Sapa",
    country: "Vietnam",
    address: "Thanh Kim, Sapa, Lao Cai",
    imageUrls: [
      "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&q=80",
      "https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=800&q=80",
      "https://images.unsplash.com/photo-1551882547-ff40c63fe2a4?w=800&q=80",
      "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80",
    ],
    rating: 4.8,
    priceFrom: 4500000,
    description:
      "A boutique eco-lodge positioned on a majestic hilltop deep in the mountains of Hoang Lien National Park. Famous for its breathtaking infinity pool overlooking terraced valleys.",
    amenities: [
      "Free WiFi", "Infinity Pool", "Eco-Friendly", "Organic Restaurant",
      "Mountain Retreat", "Spa", "Trekking Tours", "Free Shuttle",
    ],
    stars: 5,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_sp_3",
    name: "Pao's Sapa Leisure Hotel",
    city: "Sapa",
    country: "Vietnam",
    address: "Muong Hoa Street, Sapa, Lao Cai",
    imageUrls: [
      "https://images.unsplash.com/photo-1576354302919-96748cb8299e?w=800&q=80",
      "https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80",
      "https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800&q=80",
      "https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80",
    ],
    rating: 4.6,
    priceFrom: 1800000,
    description:
      "Offering the best views of the iconic Muong Hoa Valley. The hotel curves seamlessly along the hillside, providing modern luxury with panoramic vistas from all its rooms.",
    amenities: [
      "Free WiFi", "Indoor Pool", "Valley View", "Restaurant",
      "Rooftop Bar", "Fitness Center", "Spa & Massage",
    ],
    stars: 5,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },

  // ── HẠ LONG ──────────────────────────────────────────────
  {
    id: "hotel_hl_1",
    name: "Vinpearl Resort & Spa Hạ Long",
    city: "Hạ Long",
    country: "Vietnam",
    address: "Reu Island, Bai Chay, Ha Long, Quang Ninh",
    imageUrls: [
      "https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800&q=80",
      "https://images.unsplash.com/photo-1614267157481-ca2b81ac6fcc?w=800&q=80",
      "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=80",
      "https://images.unsplash.com/photo-1563911302283-d2bc129e7570?w=800&q=80",
    ],
    rating: 4.7,
    priceFrom: 2800000,
    description:
      "A spectacular resort located entirely on its own private island (Reu Island), offering 360-degree views of Ha Long Bay. Accessible by a quick speedboat transfer, it is a perfect sanctuary of relaxation.",
    amenities: [
      "Free WiFi", "Private Island", "3 Beaches", "Large Outdoor Pool",
      "Spa", "Fitness Center", "Multiple Restaurants", "Speedboat Transfer",
    ],
    stars: 5,
    checkInTime: "15:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_hl_2",
    name: "Wyndham Legend Halong",
    city: "Hạ Long",
    country: "Vietnam",
    address: "12 Ha Long Road, Bai Chay, Ha Long, Quang Ninh",
    imageUrls: [
      "https://images.unsplash.com/photo-1540202404-a2f29637228f?w=800&q=80",
      "https://images.unsplash.com/photo-1584132915807-fd1f5fbc078f?w=800&q=80",
      "https://images.unsplash.com/photo-1578645510447-e20b4311e3ce?w=800&q=80",
      "https://images.unsplash.com/photo-1566737236500-c8ac43014a67?w=800&q=80",
    ],
    rating: 4.5,
    priceFrom: 1600000,
    description:
      "A premier five-star hotel situated on the coastline of Bai Chay, boasting breathtaking views of the ocean and the Bai Chay Bridge. Offers an outdoor pool and world-class dining.",
    amenities: [
      "Free WiFi", "Ocean View", "Outdoor Pool", "Fitness Center",
      "Japanese/Chinese Restaurant", "Kids Club", "Business Centre",
    ],
    stars: 5,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_hl_3",
    name: "Mường Thanh Luxury Hạ Long Centre",
    city: "Hạ Long",
    country: "Vietnam",
    address: "Zone 2, Ha Long street, Bai Chay, Ha Long, Quang Ninh",
    imageUrls: [
      "https://images.unsplash.com/photo-1543968996-ee822b8176ba?w=800&q=80",
      "https://images.unsplash.com/photo-1519449374306-4e2c2e8e47e7?w=800&q=80",
      "https://images.unsplash.com/photo-1580041279827-9a6e2dc48a58?w=800&q=80",
      "https://images.unsplash.com/photo-1568084680786-a84f91d1153c?w=800&q=80",
    ],
    rating: 4.3,
    priceFrom: 1200000,
    description:
      "Located right in the heart of the Bai Chay tourist area alongside Ha Long Bay. This modern hotel offers luxury accommodations with excellent facilities for both leisure and business travelers.",
    amenities: [
      "Free WiFi", "Swimming Pool", "Spa & Wellness", "Fitness Center",
      "Karaoke", "Bar/Lounge", "Conference Rooms",
    ],
    stars: 5,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },

  // ── HẢI PHÒNG ─────────────────────────────────────────────
  {
    id: "hotel_hp_1",
    name: "Sheraton Hai Phong",
    city: "Hải Phòng",
    country: "Vietnam",
    address: "Vinhomes Imperia, Hanoi Road, Thuong Ly, Hong Bang, Hai Phong",
    imageUrls: [
      "https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800&q=80",
      "https://images.unsplash.com/photo-1562778612-e1e0cda9915c?w=800&q=80",
      "https://images.unsplash.com/photo-1560347876-aeef00ee58a1?w=800&q=80",
      "https://images.unsplash.com/photo-1522798514-97ceb8c4f1c8?w=800&q=80",
    ],
    rating: 4.8,
    priceFrom: 2200000,
    description:
      "Hải Phòng's tallest and most luxurious tower, offering panoramic views of the entire city. It combines elegant European design with exceptional modern amenities.",
    amenities: [
      "Free WiFi", "Indoor Pool", "Sheraton Spa", "Dining Restaurants",
      "Sky Bar", "Fitness Center", "Executive Lounge", "City Panoramas",
    ],
    stars: 5,
    checkInTime: "15:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_hp_2",
    name: "Meliá Vinpearl Hai Phong Rivera",
    city: "Hải Phòng",
    country: "Vietnam",
    address: "Manhattan 9, Vinhomes Imperia, Hong Bang, Hai Phong",
    imageUrls: [
      "https://images.unsplash.com/photo-1587490499596-b3f5b06c2a5e?w=800&q=80",
      "https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&q=80",
      "https://images.unsplash.com/photo-1629140727571-9b5c6f6267b4?w=800&q=80",
      "https://images.unsplash.com/photo-1593085512500-5d55148d6f0d?w=800&q=80",
    ],
    rating: 4.6,
    priceFrom: 1800000,
    description:
      "An elegant oasis in the bustling city, featuring classic French architecture with beautiful lake views within the Vinhomes Imperia complex.",
    amenities: [
      "Free WiFi", "Outdoor Pool", "YHI Spa", "Lake View",
      "Fitness Center", "Gourmet Dining", "Tennis Court",
    ],
    stars: 5,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },
  {
    id: "hotel_hp_3",
    name: "Mercure Hai Phong",
    city: "Hải Phòng",
    country: "Vietnam",
    address: "12 Lach Tray Street, Ngo Quyen, Hai Phong",
    imageUrls: [
      "https://images.unsplash.com/photo-1566409579-560691bcea48?w=800&q=80",
      "https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=800&q=80",
      "https://images.unsplash.com/photo-1612537935159-e1ed7be30f33?w=800&q=80",
      "https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=800&q=80",
    ],
    rating: 4.4,
    priceFrom: 1100000,
    description:
      "A trendy 5-star hotel centrally located near the Opera House and Lach Tray stadium, offering modern French flair combined with local Vietnamese hospitality.",
    amenities: [
      "Free WiFi", "Rooftop Pool", "Bloom Spa", "Flame Grill Restaurant",
      "Cloud9 Bar", "Fitness Center", "Business Centre",
    ],
    stars: 5,
    checkInTime: "14:00",
    checkOutTime: "12:00",
  },
];

// ─────────────────────────────────────────────────────────────
// ROOM IMAGES — shared across hotels by room type
// Using distinct Unsplash photo IDs per type for visual variety
// ─────────────────────────────────────────────────────────────
// ROOM_IMAGES — completely separate from hotel gallery photos.
// All 9 IDs verified unique against every hotel imageUrl in this file.
const ROOM_IMAGES = {
  // Standard: clean, bright bedroom interiors
  standard: [
    "https://images.unsplash.com/photo-1540518614846-7eded433c457?w=800&q=80",
    "https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800&q=80",
    "https://images.unsplash.com/photo-1595515106969-1ce99aad1e04?w=800&q=80",
  ],
  // Deluxe: spacious rooms with balcony or bathtub feature
  deluxe: [
    "https://images.unsplash.com/photo-1616486029423-aaa4789e8c9a?w=800&q=80",
    "https://images.unsplash.com/photo-1617104678098-de229db43db7?w=800&q=80",
    "https://images.unsplash.com/photo-1631049421450-348ccd7f8949?w=800&q=80",
  ],
  // Suite: large living area, premium furnishing
  suite: [
    "https://images.unsplash.com/photo-1590490359153-cf32a22b58bc?w=800&q=80",
    "https://images.unsplash.com/photo-1574082595-4c7c31ae0f67?w=800&q=80",
    "https://images.unsplash.com/photo-1561105378-de50ee1c1a04?w=800&q=80",
  ],
};

// ─────────────────────────────────────────────────────────────
// ROOM FACTORY
// 12 rooms per hotel:  4 Standard + 4 Deluxe + 4 Suite
//
// Price multipliers (cheapest Standard === hotel.priceFrom):
//
//   Standard  101  ×1.00   2 guests   base room
//             102  ×1.08   2 guests   city view
//             103  ×1.15   2 guests   pool view
//             104  ×1.22   3 guests   extra bed
//
//   Deluxe    201  ×1.60   2 guests   balcony
//             202  ×1.70   2 guests   ocean view balcony
//             203  ×1.80   2 guests   corner room panorama
//             204  ×1.90   3 guests   extra bed + balcony
//
//   Suite     301  ×2.80   2 guests   Junior Suite
//             302  ×3.00   2 guests   Junior Suite ocean view
//             303  ×3.40   4 guests   Suite with dining area
//             304  ×4.00   4 guests   Presidential Suite
//
// Total: 12 × 15 hotels = 180 rooms
// ─────────────────────────────────────────────────────────────
function createRoomsForHotel(hotelId, priceFrom) {
  const r = Math.round;

  return [
    // ── Standard (4 rooms) ────────────────────────────────
    {
      id: `${hotelId}_r101`,
      hotelId,
      roomNumber: "101",
      roomType: "Standard",
      pricePerNight: priceFrom,
      capacity: 2,
      imageUrls: ROOM_IMAGES.standard,
      isAvailable: true,
      amenities: [
        "Free WiFi", "Flat-screen TV", "Air Conditioning",
        "Mini Bar", "In-room Safe", "Shower",
      ],
    },
    {
      id: `${hotelId}_r102`,
      hotelId,
      roomNumber: "102",
      roomType: "Standard",
      pricePerNight: r(priceFrom * 1.08),
      capacity: 2,
      imageUrls: ROOM_IMAGES.standard,
      isAvailable: true,
      amenities: [
        "Free WiFi", "Flat-screen TV", "Air Conditioning",
        "Mini Bar", "In-room Safe", "Shower", "City View",
      ],
    },
    {
      id: `${hotelId}_r103`,
      hotelId,
      roomNumber: "103",
      roomType: "Standard",
      pricePerNight: r(priceFrom * 1.15),
      capacity: 2,
      imageUrls: ROOM_IMAGES.standard,
      isAvailable: true,
      amenities: [
        "Free WiFi", "Flat-screen TV", "Air Conditioning",
        "Mini Bar", "In-room Safe", "Shower", "Pool View",
      ],
    },
    {
      id: `${hotelId}_r104`,
      hotelId,
      roomNumber: "104",
      roomType: "Standard",
      pricePerNight: r(priceFrom * 1.22),
      capacity: 3,
      imageUrls: ROOM_IMAGES.standard,
      isAvailable: true,
      amenities: [
        "Free WiFi", "Flat-screen TV", "Air Conditioning",
        "Mini Bar", "In-room Safe", "Shower", "Extra Bed",
      ],
    },

    // ── Deluxe (4 rooms) ──────────────────────────────────
    {
      id: `${hotelId}_r201`,
      hotelId,
      roomNumber: "201",
      roomType: "Deluxe",
      pricePerNight: r(priceFrom * 1.6),
      capacity: 2,
      imageUrls: ROOM_IMAGES.deluxe,
      isAvailable: true,
      amenities: [
        "Free WiFi", "Flat-screen TV", "Air Conditioning",
        "Mini Bar", "In-room Safe", "Bathtub", "Balcony", "Welcome Drinks",
      ],
    },
    {
      id: `${hotelId}_r202`,
      hotelId,
      roomNumber: "202",
      roomType: "Deluxe",
      pricePerNight: r(priceFrom * 1.7),
      capacity: 2,
      imageUrls: ROOM_IMAGES.deluxe,
      isAvailable: true,
      amenities: [
        "Free WiFi", "Flat-screen TV", "Air Conditioning",
        "Mini Bar", "In-room Safe", "Bathtub", "Ocean View Balcony", "Welcome Drinks",
      ],
    },
    {
      id: `${hotelId}_r203`,
      hotelId,
      roomNumber: "203",
      roomType: "Deluxe",
      pricePerNight: r(priceFrom * 1.8),
      capacity: 2,
      imageUrls: ROOM_IMAGES.deluxe,
      isAvailable: true,
      amenities: [
        "Free WiFi", "Flat-screen TV", "Air Conditioning",
        "Mini Bar", "In-room Safe", "Bathtub", "Corner Room Panorama", "Welcome Drinks",
      ],
    },
    {
      id: `${hotelId}_r204`,
      hotelId,
      roomNumber: "204",
      roomType: "Deluxe",
      pricePerNight: r(priceFrom * 1.9),
      capacity: 3,
      imageUrls: ROOM_IMAGES.deluxe,
      isAvailable: true,
      amenities: [
        "Free WiFi", "Flat-screen TV", "Air Conditioning",
        "Mini Bar", "In-room Safe", "Bathtub", "Balcony", "Welcome Drinks", "Extra Bed",
      ],
    },

    // ── Suite (4 rooms) ───────────────────────────────────
    {
      id: `${hotelId}_r301`,
      hotelId,
      roomNumber: "301",
      roomType: "Suite",
      pricePerNight: r(priceFrom * 2.8),
      capacity: 2,
      imageUrls: ROOM_IMAGES.suite,
      isAvailable: true,
      amenities: [
        "Free WiFi", "65-inch Smart TV", "Air Conditioning",
        "Premium Mini Bar", "In-room Safe", "Jacuzzi Bathtub",
        "Separate Living Room", "Butler Service", "Welcome Fruits & Drinks", "Late Checkout",
      ],
    },
    {
      id: `${hotelId}_r302`,
      hotelId,
      roomNumber: "302",
      roomType: "Suite",
      pricePerNight: r(priceFrom * 3.0),
      capacity: 2,
      imageUrls: ROOM_IMAGES.suite,
      isAvailable: true,
      amenities: [
        "Free WiFi", "65-inch Smart TV", "Air Conditioning",
        "Premium Mini Bar", "In-room Safe", "Jacuzzi Bathtub",
        "Separate Living Room", "Ocean View", "Butler Service",
        "Welcome Fruits & Drinks", "Late Checkout",
      ],
    },
    {
      id: `${hotelId}_r303`,
      hotelId,
      roomNumber: "303",
      roomType: "Suite",
      pricePerNight: r(priceFrom * 3.4),
      capacity: 4,
      imageUrls: ROOM_IMAGES.suite,
      isAvailable: true,
      amenities: [
        "Free WiFi", "65-inch Smart TV", "Air Conditioning",
        "Premium Mini Bar", "In-room Safe", "Jacuzzi Bathtub",
        "Separate Living Room", "Private Dining Area", "Butler Service",
        "Welcome Fruits & Drinks", "Late Checkout", "Airport Transfer",
      ],
    },
    {
      id: `${hotelId}_r304`,
      hotelId,
      roomNumber: "304",
      roomType: "Suite",
      pricePerNight: r(priceFrom * 4.0),
      capacity: 4,
      imageUrls: ROOM_IMAGES.suite,
      isAvailable: true,
      amenities: [
        "Free WiFi", "65-inch Smart TV", "Air Conditioning",
        "Premium Mini Bar", "In-room Safe", "Jacuzzi Bathtub",
        "Separate Living Room", "Private Dining Room", "Private Terrace",
        "Butler Service", "Welcome Fruits & Drinks",
        "Late Checkout", "Airport Transfer", "Complimentary Laundry",
      ],
    },
  ];
}

// ─────────────────────────────────────────────────────────────
// SEED
// ─────────────────────────────────────────────────────────────
async function seed() {
  console.log("🚀 Starting Firestore seed...\n");
  const writer = new BatchWriter(db);

  // 1. Destinations
  console.log("📍 Seeding destinations...");
  for (const dest of destinations) {
    const { id, ...data } = dest;
    writer.set(db.collection("destinations").doc(id), data);
    await writer.autoFlush();
  }
  await writer.flush();
  console.log(`   → ${destinations.length} destinations written\n`);

  // 2. Hotels
  console.log("🏨 Seeding hotels...");
  for (const hotel of hotels) {
    const { id, ...data } = hotel;
    writer.set(db.collection("hotels").doc(id), data);
    await writer.autoFlush();
  }
  await writer.flush();
  console.log(`   → ${hotels.length} hotels written\n`);

  // 3. Rooms (8 per hotel)
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
  console.log(`   → ${roomCount} rooms written\n`);

  // Summary
  console.log("✅ Seed complete!");
  console.log("─".repeat(38));
  console.log(`  Destinations : ${destinations.length}`);
  console.log(`  Hotels       : ${hotels.length}`);
  console.log(`  Rooms        : ${roomCount}`);
  console.log(`  Total writes : ${writer.total}`);
  console.log("─".repeat(38));
  console.log("\nVerify at https://console.firebase.google.com\n");
}

// ─────────────────────────────────────────────────────────────
// OPTIONAL CLEAR — uncomment clearCollections() call below
// to wipe destinations / hotels / rooms before re-seeding.
// bookings and users are intentionally preserved.
// ─────────────────────────────────────────────────────────────
async function clearCollection(name) {
  const snap = await db.collection(name).get();
  if (snap.empty) return;
  const w = new BatchWriter(db);
  for (const doc of snap.docs) {
    w.batch.delete(doc.ref);
    w.count++;
    w.total++;
    await w.autoFlush();
  }
  await w.flush();
  console.log(`  🗑  Cleared ${snap.size} docs from '${name}'`);
}

async function clearCollections() {
  console.log("🗑  Clearing existing data...");
  await clearCollection("destinations");
  await clearCollection("hotels");
  await clearCollection("rooms");
  console.log("   Done\n");
}

// ─────────────────────────────────────────────────────────────
// ENTRY
// ─────────────────────────────────────────────────────────────
(async () => {
  try {
    await clearCollections(); // remove old data first
    await seed();
    process.exit(0);
  } catch (err) {
    console.error("❌ Seed failed:", err);
    process.exit(1);
  }
})();
