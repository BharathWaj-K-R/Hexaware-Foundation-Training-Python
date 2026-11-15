// SET 1 - LOGISTICS
// Collections: shipments, hubs, carriers, customers, deliveryEvents
// shipments: { _id, customerId, hubId, carrierId, delayDays, status }
// hubs: { _id, hubName }
// carriers: { _id, carrierName }
// deliveryEvents: { _id, shipmentId, eventType, eventDate, notes }

// Pipeline 1: shipments with delivery events (equivalent to joining shipments to events)
db.shipments.aggregate([
  { $lookup: {
      from: "deliveryEvents",
      localField: "_id",
      foreignField: "shipmentId",
      as: "deliveryEvents"
  }},
  { $unwind: { path: "$deliveryEvents", preserveNullAndEmptyArrays: true } },
  { $project: {
      shipmentId: "$_id", status: 1, delayDays: 1,
      eventType: "$deliveryEvents.eventType",
      eventDate: "$deliveryEvents.eventDate"
  }}
]);

// Pipeline 2: customers with their shipments
db.customers.aggregate([
  { $lookup: {
      from: "shipments",
      localField: "_id",
      foreignField: "customerId",
      as: "shipments"
  }},
  { $project: {
      customerName: 1,
      shipmentCount: { $size: "$shipments" },
      shipments: 1
  }}
]);

// Pipeline 3: carriers with average shipment delay, sorted highest first
db.carriers.aggregate([
  { $lookup: {
      from: "shipments",
      localField: "_id",
      foreignField: "carrierId",
      as: "shipments"
  }},
  { $set: {
      averageDelay: { $cond: [
        { $gt: [{ $size: "$shipments" }, 0] },
        { $avg: "$shipments.delayDays" },
        null
      ]}
  }},
  { $sort: { averageDelay: -1 } },
  { $project: { carrierName: 1, averageDelay: 1, shipmentCount: { $size: "$shipments" } } }
]);

// ============================================================
