// controllers/heartRateController.js
const db = require("../config/db.js");

// Mengambil semua data detak jantung
exports.getAllHeartRateData = async (req, res) => {
  try {
    const result = await db.query(
      "SELECT * FROM heart_rate_data ORDER BY timestamp DESC"
    );
    res.status(200).json(result.rows);
  } catch (err) {
    console.error("Error fetching heart rate data:", err);
    res.status(500).send("Internal Server Error");
  }
};

// Mengambil rata-rata detak jantung
exports.getAverageHeartRate = async (req, res) => {
  try {
    const result = await db.query(
      "SELECT AVG(bpm) AS avg_bpm FROM heart_rate_data"
    );
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error("Error fetching average heart rate:", err);
    res.status(500).send("Internal Server Error");
  }
}

// Menambahkan data detak jantung baru
exports.addHeartRateData = async (req, res) => {
  const { bpm, avg_bpm, spo2 } = req.body;

  // Validasi input
  if (
    typeof bpm === "undefined" ||
    typeof avg_bpm === "undefined" ||
    typeof spo2 === "undefined"
  ) {
    return res
      .status(400)
      .send("Missing required fields: bpm, avg_bpm, or spo2");
  }

  try {
    const query = `
            INSERT INTO heart_rate_data (bpm, avg_bpm, spo2)
            VALUES ($1, $2, $3)
            RETURNING *;
        `;
    const values = [bpm, avg_bpm, spo2];
    const result = await db.query(query, values);
    res.status(201).json(result.rows[0]); // Mengembalikan data yang baru saja dimasukkan
  } catch (err) {
    console.error("Error inserting heart rate data:", err);
    res.status(500).send("Internal Server Error");
  }
};
