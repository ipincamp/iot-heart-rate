// controllers/heartRateController.js
const db = require("../config/db.js");
const moment = require("moment-timezone");

// Mengambil semua data detak jantung
exports.getAllHeartRateData = async (req, res) => {
  try {
    const result = await db.query(
      "SELECT * FROM heart_rate_data ORDER BY timestamp DESC"
    );
    const adjusted = result.rows.map((row) => {
      return {
        ...row,
        timestamp: moment(row.timestamp)
          .tz("Asia/Jakarta")
          .format("YYYY-MM-DD HH:mm:ss"),
      };
    });
    res.status(200).json(adjusted);
  } catch (err) {
    console.error("Error fetching heart rate data:", err);
    res.status(500).send("Internal Server Error");
  }
};

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

// 🕒 Endpoint tren 1 jam terakhir (kelompok 15 menit)
exports.getHourlyTrend = async (req, res) => {
  try {
    const result = await db.query(`
    SELECT 
    EXTRACT(HOUR FROM timestamp) AS hour,
    COUNT(*) as total,
    AVG(bpm) AS avg_bpm
    FROM heart_rate_data
    WHERE timestamp >= NOW() - INTERVAL '1 hour'
    GROUP BY EXTRACT(HOUR FROM timestamp)
    ORDER BY hour;

    `);

    const response = result.rows.map((row) => ({
      group: Number(row.hour),
      avg_bpm: Number(row.avg_bpm),
    }));

    res.status(200).json(response);
  } catch (err) {
    console.error("Error fetching hourly trend:", err);
    res.status(500).send("Internal Server Error");
  }
};

// 📅 Endpoint tren harian (rata-rata BPM per hari)
exports.getDailyTrend = async (req, res) => {
  try {
    const result = await db.query(`
  SELECT 
    TO_CHAR(DATE(timestamp AT TIME ZONE 'Asia/Jakarta'), 'YYYY-MM-DD') AS date,
    ROUND(AVG(bpm)::numeric, 2) AS avg_bpm
  FROM heart_rate_data
  WHERE timestamp >= NOW() - INTERVAL '7 days'
  GROUP BY date
  ORDER BY date ASC
`);

    const response = result.rows.map((row) => ({
      date: moment(row.date).format("YYYY-MM-DD"),
      avg_bpm: Number(row.avg_bpm),
    }));

    res.status(200).json(response);
  } catch (err) {
    console.error("Error fetching daily trend:", err);
    res.status(500).send("Internal Server Error");
  }
};
