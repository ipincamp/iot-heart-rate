require("dotenv").config(); // <-- Tambahkan baris ini di paling atas

const express = require("express");
const bodyParser = require("body-parser");
const heartRateRoutes = require("./routes/heartrate");

const app = express();
const port = process.env.API_PORT || 3000; // Menggunakan variabel lingkungan, atau default ke 3000

// Middleware untuk mem-parsing body JSON
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Menggunakan rute heart rate untuk endpoint /heartrate
app.use("/api/heartrate", heartRateRoutes);


// Menjalankan server
app.listen(port, () => {
  console.log(`IoT API listening at http://localhost:${port}`);
});
