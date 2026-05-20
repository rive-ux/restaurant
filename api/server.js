'use strict';

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const sql = require('mssql');

const app = express();
app.use(cors({ origin: true }));

const port = process.env.PORT || 3000;

/** Konfigurim për SQL Server Authentication (më i përshtatshëm për Node.js). */
const sqlConfig = {
  user: process.env.SQL_USER,
  password: process.env.SQL_PASSWORD,
  server: process.env.SQL_SERVER || 'localhost',
  database: process.env.SQL_DATABASE || 'RestaurantDB',
  options: {
    encrypt: true,
    trustServerCertificate: true,
  },
};

app.get('/api/db-status', async (req, res) => {
  if (!sqlConfig.user || !sqlConfig.password) {
    return res.json({
      ok: false,
      message:
        'Mungon SQL_USER ose SQL_PASSWORD. Kopjo api/env.example si api/.env dhe plotëso.',
    });
  }

  try {
    await sql.connect(sqlConfig);
    const result = await sql.query`SELECT COUNT(*) AS cnt FROM dbo.klient`;
    const cnt = result.recordset[0].cnt;
    return res.json({
      ok: true,
      message: `Lidhja me RestaurantDB OK. Klientë në tabelë: ${cnt}.`,
    });
  } catch (err) {
    return res.json({ ok: false, message: err.message });
  } finally {
    try {
      await sql.close();
    } catch (_) {
      /* ignore */
    }
  }
});

app.listen(port, () => {
  console.log(`Restaurant API: http://localhost:${port}  (GET /api/db-status)`);
});
