// routes/heartRateRoutes.js
const express = require("express");
const router = express.Router();
const heartRateController = require("../controllers/heartRateController");

// Rute GET untuk mengambil semua data detak jantung
router.get("/", heartRateController.getAllHeartRateData);

// Rute POST untuk menambahkan data detak jantung baru
router.post("/", heartRateController.addHeartRateData);

module.exports = router;
