// routes/heartRateRoutes.js
const express = require("express");
const router = express.Router();
const heartRateController = require("../controllers/heartRateController");

// Rute GET untuk mengambil semua data detak jantung
router.get("/", heartRateController.getAllHeartRateData);

// Rute GET untuk mengambil rata-rata detak jantung
router.get("/average", heartRateController.getAverageHeartRate);

// Rute POST untuk menambahkan data detak jantung baru
router.post("/", heartRateController.addHeartRateData);

module.exports = router;
