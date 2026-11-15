// SET 2 - BANK LOANS
// Collections: loans, customers, repayments
// loans: { _id, customerId, branchId, loanAmount, status }
// repayments: { _id, loanId, paymentDate, amount, status }

// Pipeline 1: loan documents with customer details
db.loans.aggregate([
  { $lookup: {
      from: "customers",
      localField: "customerId",
      foreignField: "_id",
      as: "customer"
  }},
  { $unwind: { path: "$customer", preserveNullAndEmptyArrays: true } },
  { $project: {
      loanId: "$_id", loanAmount: 1, status: 1,
      customerName: "$customer.customerName",
      customerId: "$customer._id"
  }}
]);

// Pipeline 2: loans with repayment collections
db.loans.aggregate([
  { $lookup: {
      from: "repayments",
      localField: "_id",
      foreignField: "loanId",
      as: "repayments"
  }},
  { $project: {
      loanAmount: 1, status: 1,
      repaymentCount: { $size: "$repayments" },
      repayments: 1
  }}
]);

// Pipeline 3: loans with latest repayment date (correlated pipeline lookup)
db.loans.aggregate([
  { $lookup: {
      from: "repayments",
      let: { currentLoanId: "$_id" },
      pipeline: [
        { $match: { $expr: { $eq: ["$loanId", "$$currentLoanId"] } } },
        { $sort: { paymentDate: -1 } },
        { $limit: 1 },
        { $project: { _id: 0, paymentDate: 1, amount: 1, status: 1 } }
      ],
      as: "latestRepayment"
  }},
  { $set: { latestRepayment: { $first: "$latestRepayment" } } },
  { $project: { loanAmount: 1, latestRepayment: 1 } }
]);

// ============================================================
