const express = require("express");
const cors = require("cors");
const { getPool, sql } = require("./db");

const app = express();
const port = Number(process.env.PORT || 3000);

app.use(cors({ origin: process.env.CORS_ORIGIN || "*" }));
app.use(express.json());
app.use(express.static("."));

function normalizeReservation(row) {
  return {
    id: String(row.rezervim_id),
    name: row.klienti || "",
    email: row.email || "",
    phone: row.telefoni || "",
    guests: String(row.numri_personave || ""),
    date: row.data_rezervimit ? row.data_rezervimit.toISOString().slice(0, 10) : "",
    time: row.ora_rezervimit ? String(row.ora_rezervimit).slice(0, 5) : "",
    message: row.mesazhi || "",
    status: row.statusi || "E re",
    tableNumber: row.numri_tavolines || null
  };
}

function validateReservation(body) {
  const errors = [];

  if (!body.name) errors.push("Emri eshte i detyrueshem.");
  if (!body.email) errors.push("Email eshte i detyrueshem.");
  if (!body.phone) errors.push("Telefoni eshte i detyrueshem.");
  if (!body.date) errors.push("Data eshte e detyrueshme.");
  if (!body.time) errors.push("Koha eshte e detyrueshme.");
  if (!body.guests || Number(body.guests) < 1) errors.push("Numri i mysafireve duhet te jete me i madh se 0.");

  return errors;
}

function parseSqlDate(value) {
  if (!value) return null;

  if (/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return value;
  }

  const dotMatch = value.match(/^(\d{1,2})\.(\d{1,2})\.(\d{4})$/);
  if (dotMatch) {
    return `${dotMatch[3]}-${dotMatch[2].padStart(2, "0")}-${dotMatch[1].padStart(2, "0")}`;
  }

  const slashMatch = value.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/);
  if (slashMatch) {
    return `${slashMatch[3]}-${slashMatch[2].padStart(2, "0")}-${slashMatch[1].padStart(2, "0")}`;
  }

  return value;
}

function parseSqlTime(value) {
  if (!value) return null;

  const lower = String(value).toLowerCase();
  if (lower === "mengjes") return "10:00";
  if (lower === "mesdite") return "13:00";
  if (lower === "evente") return "19:00";

  return value;
}

app.get("/api/health", async (req, res) => {
  try {
    const pool = await getPool();
    await pool.request().query("SELECT 1 AS ok");
    res.json({ ok: true, database: "connected" });
  } catch (error) {
    res.status(500).json({ ok: false, error: error.message });
  }
});

app.get("/api/rezervime", async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT *
      FROM dbo.v_rezervimet
      ORDER BY data_rezervimit, ora_rezervimit
    `);

    res.json(result.recordset.map(normalizeReservation));
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post("/api/rezervime", async (req, res) => {
  const errors = validateReservation(req.body);
  if (errors.length) {
    return res.status(400).json({ errors });
  }

  const date = parseSqlDate(req.body.date);
  const time = parseSqlTime(req.body.time);
  const guests = Number.parseInt(String(req.body.guests).replace(/\D/g, ""), 10);

  try {
    const pool = await getPool();
    const transaction = new sql.Transaction(pool);

    await transaction.begin();

    try {
      const existingClient = await new sql.Request(transaction)
        .input("email", sql.NVarChar(120), req.body.email)
        .query("SELECT klient_id FROM dbo.klientet WHERE email = @email");

      let clientId = existingClient.recordset[0] && existingClient.recordset[0].klient_id;

      if (!clientId) {
        const insertedClient = await new sql.Request(transaction)
          .input("emri", sql.NVarChar(100), req.body.name)
          .input("email", sql.NVarChar(120), req.body.email)
          .input("telefoni", sql.NVarChar(30), req.body.phone)
          .query(`
            INSERT INTO dbo.klientet (emri, email, telefoni)
            OUTPUT INSERTED.klient_id
            VALUES (@emri, @email, @telefoni)
          `);
        clientId = insertedClient.recordset[0].klient_id;
      }

      const insertedReservation = await new sql.Request(transaction)
        .input("klient_id", sql.Int, clientId)
        .input("data_rezervimit", sql.Date, date)
        .input("ora_rezervimit", sql.Time, time)
        .input("numri_personave", sql.Int, guests)
        .input("mesazhi", sql.NVarChar(sql.MAX), req.body.message || "")
        .query(`
          INSERT INTO dbo.rezervimet (
            klient_id,
            data_rezervimit,
            ora_rezervimit,
            numri_personave,
            mesazhi
          )
          OUTPUT INSERTED.rezervim_id
          VALUES (
            @klient_id,
            @data_rezervimit,
            @ora_rezervimit,
            @numri_personave,
            @mesazhi
          )
        `);

      await transaction.commit();

      res.status(201).json({
        id: String(insertedReservation.recordset[0].rezervim_id),
        name: req.body.name,
        email: req.body.email,
        phone: req.body.phone,
        guests: String(guests),
        date,
        time,
        message: req.body.message || "",
        status: "E re"
      });
    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.patch("/api/rezervime/:id/status", async (req, res) => {
  const allowedStatuses = ["E re", "Konfirmuar", "Anuluar", "Perfunduar"];
  if (!allowedStatuses.includes(req.body.status)) {
    return res.status(400).json({ error: "Status i pavlefshem." });
  }

  try {
    const pool = await getPool();
    await pool.request()
      .input("id", sql.Int, req.params.id)
      .input("status", sql.NVarChar(30), req.body.status)
      .query("UPDATE dbo.rezervimet SET statusi = @status WHERE rezervim_id = @id");

    res.json({ id: req.params.id, status: req.body.status });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete("/api/rezervime/:id", async (req, res) => {
  try {
    const pool = await getPool();
    await pool.request()
      .input("id", sql.Int, req.params.id)
      .query("DELETE FROM dbo.rezervimet WHERE rezervim_id = @id");

    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete("/api/rezervime", async (req, res) => {
  try {
    const pool = await getPool();
    await pool.request().query("DELETE FROM dbo.rezervimet");
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(port, () => {
  console.log(`Restaurant API running at http://localhost:${port}`);
});
