const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
require("dotenv").config();

const app = express();
const port = process.env.PORT || 3306;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Routes
const heartrateRoutes = require("./routes/heartrate");
app.use("/api", heartrateRoutes);

// Run server
app.listen(port, () => {
  console.log(`✅ Server running at http://localhost:${port}`);
});
