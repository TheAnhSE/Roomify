/**
 * UPDATE HOTELS WITH COORDINATES
 * ===============================
 * Script to add latitude and longitude to all hotels in Firestore
 *
 * HOW TO RUN:
 *   1. npm install firebase-admin (if not already installed)
 *   2. Place serviceAccountKey.json in the same folder
 *   3. node update_hotels_coords.js
 */

const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// Coordinates for each hotel
// Format: hotelId -> { latitude, longitude }
const hotelCoordinates = {
  // ── ĐÀ NẴNG ───────────────────────────────────────────
  hotel_dn_1: { latitude: 16.0544, longitude: 108.2022 }, // Danang Marriott Resort & Spa
  hotel_dn_2: { latitude: 16.0566, longitude: 108.2006 }, // Hyatt Regency Danang Resort
  hotel_dn_3: { latitude: 16.0471, longitude: 108.2193 }, // Novotel Danang Premier Han River

  // ── HỘI AN ────────────────────────────────────────────
  hotel_ha_1: { latitude: 15.8845, longitude: 108.3382 }, // Four Seasons Resort The Nam Hai
  hotel_ha_2: { latitude: 15.8794, longitude: 108.3294 }, // Anantara Hoi An Resort
  hotel_ha_3: { latitude: 15.8758, longitude: 108.3323 }, // Vinh Hung Heritage Hotel

  // ── PHÚ QUỐC ──────────────────────────────────────────
  hotel_pq_1: { latitude: 10.3017, longitude: 103.9833 }, // JW Marriott Phu Quoc Emerald Bay
  hotel_pq_2: { latitude: 10.2875, longitude: 103.9878 }, // Fusion Resort Phu Quoc
  hotel_pq_3: { latitude: 10.1969, longitude: 103.8828 }, // Vinpearl Resort & Spa Phu Quoc

  // ── HÀ NỘI ────────────────────────────────────────────
  hotel_hn_1: { latitude: 21.0285, longitude: 105.8554 }, // Sofitel Legend Metropole Hanoi
  hotel_hn_2: { latitude: 21.0881, longitude: 105.7849 }, // InterContinental Hanoi Westlake
  hotel_hn_3: { latitude: 21.0258, longitude: 105.8378 }, // La Siesta Classic Ma May

  // ── TP. HỒ CHÍ MINH ───────────────────────────────────
  hotel_hcm_1: { latitude: 10.7938, longitude: 106.7273 }, // Park Hyatt Saigon
  hotel_hcm_2: { latitude: 10.7754, longitude: 106.7016 }, // The Reverie Saigon
  hotel_hcm_3: { latitude: 10.7713, longitude: 106.7034 }, // Liberty Central Saigon Citypoint

  // ── SAPA ──────────────────────────────────────────────
  hotel_sp_1: { latitude: 22.3402, longitude: 103.8439 }, // Hotel de la Coupole - MGallery
  hotel_sp_2: { latitude: 22.3419, longitude: 103.8426 }, // Topas Ecolodge
  hotel_sp_3: { latitude: 22.3365, longitude: 103.8478 }, // Pao's Sapa Leisure Hotel

  // ── HẠ LONG ───────────────────────────────────────────
  hotel_hl_1: { latitude: 20.8549, longitude: 107.1803 }, // Vinpearl Resort & Spa Hạ Long
  hotel_hl_2: { latitude: 20.8547, longitude: 107.1756 }, // Wyndham Legend Halong
  hotel_hl_3: { latitude: 20.8535, longitude: 107.1678 }, // Mường Thanh Luxury Hạ Long Centre

  // ── HẢI PHÒNG ─────────────────────────────────────────
  hotel_hp_1: { latitude: 20.8645, longitude: 106.6837 }, // Sheraton Hai Phong
  hotel_hp_2: { latitude: 20.8525, longitude: 106.6751 }, // Meliá Vinpearl Hai Phong Rivera
  hotel_hp_3: { latitude: 20.8559, longitude: 106.6844 }, // Mercure Hai Phong
};

async function updateHotelsWithCoordinates() {
  console.log("🗺️  Starting to update hotels with coordinates...\n");

  let successCount = 0;
  let errorCount = 0;

  for (const [hotelId, coordinates] of Object.entries(hotelCoordinates)) {
    try {
      const hotelRef = db.collection("hotels").doc(hotelId);

      // Update hotel with latitude and longitude
      await hotelRef.update({
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
      });

      console.log(`✅ Updated ${hotelId}: lat=${coordinates.latitude}, lng=${coordinates.longitude}`);
      successCount++;
    } catch (error) {
      console.error(`❌ Error updating ${hotelId}:`, error.message);
      errorCount++;
    }
  }

  console.log(`\n📊 Summary:`);
  console.log(`   ✅ Success: ${successCount}`);
  console.log(`   ❌ Errors:  ${errorCount}`);
  console.log(`   📍 Total:   ${Object.keys(hotelCoordinates).length}`);

  process.exit(0);
}

updateHotelsWithCoordinates().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
