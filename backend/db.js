require("dotenv").config();

const sql = require("mssql");

const toBoolean = (value, fallback) => {
  if (value === undefined || value === "") {
    return fallback;
  }

  return ["1", "true", "yes"].includes(String(value).toLowerCase());
};

const config = {
  server: process.env.DB_SERVER || "localhost",
  database: process.env.DB_DATABASE || "restaurant_db",
  user: process.env.DB_USER || "sa",
  password: process.env.DB_PASSWORD || "",
  port: Number(process.env.DB_PORT || 1433),
  options: {
    encrypt: toBoolean(process.env.DB_ENCRYPT, false),
    trustServerCertificate: toBoolean(process.env.DB_TRUST_SERVER_CERTIFICATE, true)
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000
  }
};

let poolPromise;

function getPool() {
  if (!poolPromise) {
    poolPromise = sql.connect(config);
  }

  return poolPromise;
}

module.exports = {
  sql,
  getPool
};
