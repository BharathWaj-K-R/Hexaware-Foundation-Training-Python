// SET 3 - RETAIL RETURNS
// Collections: returns, orderItems, orders, products, customers, stores
// returns: { _id, orderItemId, refundAmount, status, returnDate }
// orderItems: { _id, orderId, productId, quantity, unitPrice }
// orders: { _id, customerId, storeId, orderDate }
// products: { _id, productName, category }
// customers: { _id, customerName }
// stores: { _id, storeName, region }

// Pipeline 1: returns with order-item and product information
db.returns.aggregate([
  { $lookup: {
      from: "orderItems",
      localField: "orderItemId",
      foreignField: "_id",
      as: "orderItem"
  }},
  { $unwind: "$orderItem" },
  { $lookup: {
      from: "products",
      localField: "orderItem.productId",
      foreignField: "_id",
      as: "product"
  }},
  { $unwind: { path: "$product", preserveNullAndEmptyArrays: true } },
  { $project: {
      returnId: "$_id", refundAmount: 1, status: 1,
      productName: "$product.productName",
      quantity: "$orderItem.quantity"
  }}
]);

// Pipeline 2: customers with their return history
db.customers.aggregate([
  { $lookup: {
      from: "orders",
      localField: "_id",
      foreignField: "customerId",
      as: "orders"
  }},
  { $lookup: {
      from: "returns",
      let: { customerOrderIds: "$orders._id" },
      pipeline: [
        { $lookup: {
            from: "orderItems",
            localField: "orderItemId",
            foreignField: "_id",
            as: "item"
        }},
        { $unwind: "$item" },
        { $match: { $expr: { $in: ["$item.orderId", "$$customerOrderIds"] } } }
      ],
      as: "returns"
  }},
  { $project: {
      customerName: 1,
      orderCount: { $size: "$orders" },
      returnCount: { $size: "$returns" },
      returns: 1
  }}
]);

// Pipeline 3: stores with refund totals, highest first
db.stores.aggregate([
  { $lookup: {
      from: "orders",
      localField: "_id",
      foreignField: "storeId",
      as: "orders"
  }},
  { $unwind: { path: "$orders", preserveNullAndEmptyArrays: true } },
  { $lookup: {
      from: "orderItems",
      localField: "orders._id",
      foreignField: "orderId",
      as: "items"
  }},
  { $unwind: { path: "$items", preserveNullAndEmptyArrays: true } },
  { $lookup: {
      from: "returns",
      localField: "items._id",
      foreignField: "orderItemId",
      as: "returns"
  }},
  { $set: {
      orderRefund: { $sum: "$returns.refundAmount" }
  }},
  { $group: {
      _id: "$_id",
      storeName: { $first: "$storeName" },
      region: { $first: "$region" },
      totalRefund: { $sum: "$orderRefund" }
  }},
  { $sort: { totalRefund: -1 } }
]);
