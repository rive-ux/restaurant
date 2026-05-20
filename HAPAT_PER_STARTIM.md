# Hapat per ta lidhur website-in me SQL Server

Ky udhezues eshte per Windows + SQL Server Management Studio (SSMS).

## 1. Krijo databazen ne SSMS

1. Hape `SQL Server Management Studio`.
2. Lidhu me SQL Server-in tend lokal.
3. Kliko `New Query`.
4. Hape file-in:

   ```text
   database/restaurant_db_sql_server.sql
   ```

5. Kopjo krejt permbajtjen ne `New Query`.
6. Kliko `Execute` ose shtyp `F5`.
7. Te `Databases`, beje `Refresh`.
8. Duhet te shfaqet databaza:

   ```text
   restaurant_db
   ```

## 2. Krijo konfigurimin .env

Ne folderin kryesor te projektit, ekzekuto:

```text
setup-windows.bat
```

Ky script krijon file-in `.env` nga `.env.example`.

Pastaj hape `.env` dhe ndrysho keto vlera sipas SQL Server-it tend:

```env
DB_SERVER=localhost
DB_PORT=1433
DB_DATABASE=restaurant_db
DB_USER=sa
DB_PASSWORD=PASSWORDI_YT
```

Nese perdor `SQL Server Authentication`, zakonisht:

```env
DB_USER=sa
DB_PASSWORD=passwordi_i_sa
```

Nese ne SSMS lidheshe me nje server tjeter, vendose emrin e sakte te serverit te `DB_SERVER`.

Shembuj:

```env
DB_SERVER=localhost
DB_SERVER=.\SQLEXPRESS
DB_SERVER=DESKTOP-12345\SQLEXPRESS
```

## 3. Instalo paketat e Node.js

`setup-windows.bat` e ben kete automatikisht me:

```text
npm install
```

Nese komanda `npm` nuk njihet, instalo Node.js LTS nga:

```text
https://nodejs.org
```

Pastaj mbylle dhe hape prape terminalin.

## 4. Starto website-in dhe backend-in

Ekzekuto:

```text
start-restaurant.bat
```

Ose ne terminal:

```powershell
npm start
```

Nese gjithcka eshte ne rregull, shfaqet:

```text
Restaurant API running at http://localhost:3000
```

Mos e mbyll terminalin.

## 5. Testo lidhjen me databaze

Hape browser-in:

```text
http://localhost:3000/api/health
```

Duhet te shfaqet:

```json
{
  "ok": true,
  "database": "connected"
}
```

## 6. Hape website-in

Website:

```text
http://localhost:3000
```

Dashboard:

```text
http://localhost:3000/dashboard/
```

## 7. Provo rezervimin

1. Hape `http://localhost:3000`.
2. Shko te forma `Rezervo`.
3. Ploteso formen.
4. Kliko `Rezervo`.
5. Hape `http://localhost:3000/dashboard/`.
6. Rezervimi duhet te shfaqet ne dashboard dhe te ruhet ne SQL Server.

## Probleme te shpeshta

### `Failed to connect to localhost:1433`

Kontrollo:

- SQL Server eshte startuar.
- `DB_SERVER` eshte i sakte.
- `DB_PORT=1433` eshte i hapur.
- SQL Server lejon TCP/IP connections.

### `Login failed for user 'sa'`

Kontrollo:

- Password-i ne `.env` eshte i sakte.
- SQL Server Authentication eshte aktiv.
- User-i `sa` nuk eshte disabled.

### `npm is not recognized`

Instalo Node.js LTS:

```text
https://nodejs.org
```

Pastaj hape terminalin prape.
