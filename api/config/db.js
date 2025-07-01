require("dotenv").config(); // <-- Tambahkan baris ini di paling atas

const { Pool } = require("pg");

const pool = new Pool({
  user: process.env.DB_USER, // Menggunakan variabel lingkungan
  host: process.env.DB_HOST,
  database: process.env.DB_DATABASE,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

pool.on("error", (err) => {
  console.error("Unexpected error on idle client", err);
  process.exit(-1);
});

module.exports = {
  query: (text, params, callback) => {
    console.log("EXECUTING QUERY:", text, params || "");
    return pool.query(text, params, callback);
  },
};
