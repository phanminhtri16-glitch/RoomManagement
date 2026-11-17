import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

/**
 * Tác vụ định kỳ (Cron Job): Chạy vào 00:00 ngày đầu tiên của mỗi tháng
 * Tự động tạo bản nháp hóa đơn (Draft Invoices) cho các phòng/ki-ốt đang thuê.
 */
export const generateMonthlyInvoices = functions.pubsub
  .schedule("0 0 1 * *")
  .timeZone("Asia/Ho_Chi_Minh")
  .onRun(async (context) => {
    const now = new Date();
    const currentMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}`;

    console.log(`Bắt đầu tạo hóa đơn nháp cho tháng: ${currentMonth}`);

    const roomsSnapshot = await db
      .collection("rooms")
      .where("status", "==", "OCCUPIED")
      .get();

    const batch = db.batch();

    roomsSnapshot.forEach((doc) => {
      const room = doc.data();
      const invoiceRef = db.collection("invoices").doc();

      batch.set(invoiceRef, {
        ownerId: room.ownerId,
        propertyId: room.propertyId,
        roomId: doc.id,
        roomName: room.name,
        tenantId: room.currentTenantId || null,
        billingMonth: currentMonth,
        status: "DRAFT", // DRAFT -> PENDING -> PAID
        roomRentPrice: room.baseRentPrice || 0,
        electricOldNumber: room.lastElectricNumber || 0,
        electricNewNumber: 0,
        waterOldNumber: room.lastWaterNumber || 0,
        waterNewNumber: 0,
        totalAmount: room.baseRentPrice || 0,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    await batch.commit();
    console.log(`Đã tạo xong ${roomsSnapshot.size} hóa đơn nháp.`);
    return null;
  });
