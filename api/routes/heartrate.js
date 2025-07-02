// routes/heartRateRoutes.js
const express = require("express");
const router = express.Router();
const heartRateController = require("../controllers/heartRateController");

// Default: semua data 1 jam terakhir
router.get("/", heartRateController.getAllHeartRateData);

// Post data dari IoT
router.post("/", heartRateController.addHeartRateData);

// New: tren per 15 menit dari 1 jam terakhir
router.get("/trend/hourly", heartRateController.getHourlyTrend);

// New: tren harian (7 hari terakhir)
router.get("/trend/daily", heartRateController.getDailyTrend);

module.exports = router;
