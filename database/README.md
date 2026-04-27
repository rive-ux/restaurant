# Databaza e restaurantit

Ky folder permban databazen funksionale MySQL per projektin "Sistemi i menaxhimit te restaurantit".

## File kryesor

```text
restaurant_db.sql
```

Ky script krijon:

- databazen `restaurant_db`
- tabelat per klientet, tavolinat, rezervimet, stafin, kategorite, menune, porosite, detajet e porosive dhe pagesat
- lidhjet me `FOREIGN KEY`
- te dhena testuese
- disa view/query praktike per raporte

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
