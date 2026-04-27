# Databaza e restaurantit

Ky folder permban databazen funksionale per projektin "Sistemi i menaxhimit te restaurantit".

## File kryesor

```text
restaurant_db.sql
```

Ky script eshte per MySQL/phpMyAdmin. Per SQL Server Management Studio perdor:

```text
restaurant_db_sql_server.sql
```

Script-et krijojne:

- databazen `restaurant_db`
- tabelat per klientet, tavolinat, rezervimet, stafin, kategorite, menune, porosite, detajet e porosive dhe pagesat
- lidhjet me `FOREIGN KEY`
- te dhena testuese
- disa view/query praktike per raporte

## Si importohet ne SQL Server Management Studio

1. Hape `SQL Server Management Studio`.
2. Lidhu me serverin tend lokal.
3. Kliko `File` -> `Open` -> `File...`.
4. Zgjedhe file-in:

   ```text
   database/restaurant_db_sql_server.sql
   ```

5. Kliko `Execute` ose shtyp `F5`.

Pas ekzekutimit, databaza `restaurant_db` shfaqet te `Databases`.

Query testuese per SQL Server:

```sql
USE restaurant_db;
GO

SELECT * FROM v_rezervimet;
SELECT * FROM v_totali_porosive;
SELECT * FROM v_te_ardhurat_ditore;
```

## Si lidhet website-i me SQL Server

Website-i nuk lidhet direkt me SQL Server. Lidhja behet permes backend-it Node.js qe gjendet ne folderin `backend/`.

1. Sigurohu qe databaza `restaurant_db` eshte krijuar ne SSMS.
2. Krijo nje file `.env` ne folderin kryesor te projektit, duke kopjuar `.env.example`.
3. Ploteso te dhenat e SQL Server-it:

   ```text
   DB_SERVER=localhost
   DB_PORT=1433
   DB_DATABASE=restaurant_db
   DB_USER=sa
   DB_PASSWORD=passwordi_yt
   ```

4. Instalo paketat:

   ```bash
   npm install
   ```

5. Starto backend-in:

   ```bash
   npm start
   ```

6. Hape website-in me Live Server ose nga backend-i:

   ```text
   http://localhost:3000
   ```

7. Testo lidhjen:

   ```text
   http://localhost:3000/api/health
   ```

   Nese lidhja eshte ne rregull, kthen:

   ```json
   { "ok": true, "database": "connected" }
   ```

## Si importohet ne phpMyAdmin

1. Hape XAMPP.
2. Starto `Apache` dhe `MySQL`.
3. Hape browser-in:

   ```text
   http://localhost/phpmyadmin
   ```

4. Kliko `Import`.
5. Zgjedhe file-in:

   ```text
   database/restaurant_db.sql
   ```

6. Kliko `Go`.

Pas importimit, databaza `restaurant_db` shfaqet ne listen e databazave.

## Si importohet me terminal

```bash
mysql -u root -p < database/restaurant_db.sql
```

Nese root nuk ka password ne XAMPP:

```bash
mysql -u root < database/restaurant_db.sql
```

## Query testuese

Pas importimit mund te provosh:

```sql
USE restaurant_db;

SELECT * FROM v_rezervimet;
SELECT * FROM v_totali_porosive;
SELECT * FROM v_te_ardhurat_ditore;
```

## Shenim

Website-i aktual eshte statik dhe dashboard-i ruan rezervimet ne browser me `localStorage`.
Ky script SQL eshte databaza reale qe mund te lidhet me website-in nese me vone shtohet backend me PHP, Node.js ose ndonje teknologji tjeter.
