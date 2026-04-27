-- Sistemi i menaxhimit te restaurantit - SQL Server / SSMS
-- Ekzekutoje kete file ne SQL Server Management Studio.

IF DB_ID(N'restaurant_db') IS NOT NULL
BEGIN
  ALTER DATABASE restaurant_db SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE restaurant_db;
END;
GO

CREATE DATABASE restaurant_db;
GO

USE restaurant_db;
GO

CREATE TABLE dbo.klientet (
  klient_id INT IDENTITY(1,1) PRIMARY KEY,
  emri NVARCHAR(100) NOT NULL,
  email NVARCHAR(120) NOT NULL UNIQUE,
  telefoni NVARCHAR(30) NOT NULL,
  data_regjistrimit DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dbo.tavolinat (
  tavolina_id INT IDENTITY(1,1) PRIMARY KEY,
  numri_tavolines INT NOT NULL UNIQUE,
  kapaciteti INT NOT NULL,
  statusi NVARCHAR(30) NOT NULL DEFAULT N'E lire',
  CONSTRAINT chk_tavolinat_kapaciteti CHECK (kapaciteti > 0),
  CONSTRAINT chk_tavolinat_statusi CHECK (statusi IN (N'E lire', N'E rezervuar', N'E zene'))
);
GO

CREATE TABLE dbo.stafi (
  staf_id INT IDENTITY(1,1) PRIMARY KEY,
  emri NVARCHAR(100) NOT NULL,
  roli NVARCHAR(50) NOT NULL,
  telefoni NVARCHAR(30),
  email NVARCHAR(120) UNIQUE,
  aktiv BIT NOT NULL DEFAULT 1,
  CONSTRAINT chk_stafi_roli CHECK (roli IN (N'Menaxher', N'Kamarier', N'Kuzhinier', N'Arkatar'))
);
GO

CREATE TABLE dbo.kategorite (
  kategori_id INT IDENTITY(1,1) PRIMARY KEY,
  emri NVARCHAR(80) NOT NULL UNIQUE,
  pershkrimi NVARCHAR(MAX)
);
GO

CREATE TABLE dbo.menu_items (
  menu_item_id INT IDENTITY(1,1) PRIMARY KEY,
  kategori_id INT NOT NULL,
  emri NVARCHAR(100) NOT NULL,
  pershkrimi NVARCHAR(MAX),
  cmimi DECIMAL(8,2) NOT NULL,
  aktiv BIT NOT NULL DEFAULT 1,
  CONSTRAINT fk_menu_items_kategorite
    FOREIGN KEY (kategori_id) REFERENCES dbo.kategorite(kategori_id)
    ON UPDATE CASCADE
    ON DELETE NO ACTION,
  CONSTRAINT chk_menu_items_cmimi CHECK (cmimi >= 0)
);
GO

CREATE TABLE dbo.rezervimet (
  rezervim_id INT IDENTITY(1,1) PRIMARY KEY,
  klient_id INT NOT NULL,
  tavolina_id INT NULL,
  data_rezervimit DATE NOT NULL,
  ora_rezervimit TIME NOT NULL,
  numri_personave INT NOT NULL,
  statusi NVARCHAR(30) NOT NULL DEFAULT N'E re',
  mesazhi NVARCHAR(MAX),
  krijuar_me DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
  CONSTRAINT fk_rezervimet_klientet
    FOREIGN KEY (klient_id) REFERENCES dbo.klientet(klient_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_rezervimet_tavolinat
    FOREIGN KEY (tavolina_id) REFERENCES dbo.tavolinat(tavolina_id)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  CONSTRAINT chk_rezervimet_numri_personave CHECK (numri_personave > 0),
  CONSTRAINT chk_rezervimet_statusi CHECK (statusi IN (N'E re', N'Konfirmuar', N'Anuluar', N'Perfunduar'))
);
GO

CREATE TABLE dbo.porosite (
  porosi_id INT IDENTITY(1,1) PRIMARY KEY,
  klient_id INT NULL,
  staf_id INT NULL,
  tavolina_id INT NULL,
  data_porosise DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
  statusi NVARCHAR(30) NOT NULL DEFAULT N'E hapur',
  CONSTRAINT fk_porosite_klientet
    FOREIGN KEY (klient_id) REFERENCES dbo.klientet(klient_id)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  CONSTRAINT fk_porosite_stafi
    FOREIGN KEY (staf_id) REFERENCES dbo.stafi(staf_id)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  CONSTRAINT fk_porosite_tavolinat
    FOREIGN KEY (tavolina_id) REFERENCES dbo.tavolinat(tavolina_id)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  CONSTRAINT chk_porosite_statusi CHECK (statusi IN (N'E hapur', N'Ne pergatitje', N'E mbyllur', N'Anuluar'))
);
GO

CREATE TABLE dbo.porosia_detaj (
  detaj_id INT IDENTITY(1,1) PRIMARY KEY,
  porosi_id INT NOT NULL,
  menu_item_id INT NOT NULL,
  sasia INT NOT NULL,
  cmimi DECIMAL(8,2) NOT NULL,
  CONSTRAINT fk_porosia_detaj_porosite
    FOREIGN KEY (porosi_id) REFERENCES dbo.porosite(porosi_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_porosia_detaj_menu_items
    FOREIGN KEY (menu_item_id) REFERENCES dbo.menu_items(menu_item_id)
    ON UPDATE CASCADE
    ON DELETE NO ACTION,
  CONSTRAINT chk_porosia_detaj_sasia CHECK (sasia > 0),
  CONSTRAINT chk_porosia_detaj_cmimi CHECK (cmimi >= 0)
);
GO

CREATE TABLE dbo.pagesat (
  pagesa_id INT IDENTITY(1,1) PRIMARY KEY,
  porosi_id INT NOT NULL UNIQUE,
  shuma DECIMAL(10,2) NOT NULL,
  metoda NVARCHAR(30) NOT NULL,
  data_pageses DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
  statusi NVARCHAR(30) NOT NULL DEFAULT N'Paguar',
  CONSTRAINT fk_pagesat_porosite
    FOREIGN KEY (porosi_id) REFERENCES dbo.porosite(porosi_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT chk_pagesat_shuma CHECK (shuma >= 0),
  CONSTRAINT chk_pagesat_metoda CHECK (metoda IN (N'Cash', N'Kartel', N'Online')),
  CONSTRAINT chk_pagesat_statusi CHECK (statusi IN (N'Paguar', N'Ne pritje', N'Anuluar'))
);
GO

CREATE INDEX idx_rezervimet_data_ora ON dbo.rezervimet (data_rezervimit, ora_rezervimit);
CREATE INDEX idx_rezervimet_statusi ON dbo.rezervimet (statusi);
CREATE INDEX idx_porosite_statusi ON dbo.porosite (statusi);
GO

INSERT INTO dbo.klientet (emri, email, telefoni) VALUES
(N'Arben Krasniqi', N'arben@email.com', N'044111222'),
(N'Elira Berisha', N'elira@email.com', N'049333444'),
(N'Driton Gashi', N'driton@email.com', N'045555666'),
(N'Mira Hoti', N'mira@email.com', N'043777888');
GO

INSERT INTO dbo.tavolinat (numri_tavolines, kapaciteti, statusi) VALUES
(1, 2, N'E lire'),
(2, 4, N'E lire'),
(3, 6, N'E rezervuar'),
(4, 8, N'E lire'),
(5, 10, N'E lire');
GO

INSERT INTO dbo.stafi (emri, roli, telefoni, email) VALUES
(N'Sokol Kodra', N'Kuzhinier', N'044111112', N'sokol@restaurant.com'),
(N'Arta Basha', N'Menaxher', N'049111112', N'arta@restaurant.com'),
(N'Kujtim Demneri', N'Kamarier', N'045111112', N'kujtim@restaurant.com'),
(N'Blerina Shala', N'Arkatar', N'043111112', N'blerina@restaurant.com');
GO

INSERT INTO dbo.kategorite (emri, pershkrimi) VALUES
(N'Mengjesi', N'Ushqime per mengjes'),
(N'Mesdita', N'Pjata kryesore'),
(N'Pije', N'Pije te ftohta dhe te nxehta'),
(N'Oferta Javore', N'Oferta speciale te restaurantit');
GO

INSERT INTO dbo.menu_items (kategori_id, emri, pershkrimi, cmimi) VALUES
(1, N'Tost me avokado', N'Buke integrale, veze dhe avokado', 3.20),
(1, N'Muffin', N'Muffin me veze, djathe dhe spinaq', 2.80),
(2, N'Supe pule', N'Mish pule, patate dhe ereza', 5.50),
(2, N'Supe me perime', N'Brokoli, selino dhe ereza', 3.50),
(3, N'Kafe', N'Kafe espresso', 1.20),
(3, N'Leng portokalli', N'Leng i fresket portokalli', 2.00),
(4, N'Menu familjare', N'Oferta javore per familje', 18.00);
GO

INSERT INTO dbo.rezervimet (
  klient_id,
  tavolina_id,
  data_rezervimit,
  ora_rezervimit,
  numri_personave,
  statusi,
  mesazhi
) VALUES
(1, 2, '2026-04-28', '19:00:00', 4, N'Konfirmuar', N'Rezervim per darke'),
(2, 1, '2026-04-29', '10:00:00', 2, N'E re', N'Dritare nese ka mundesi'),
(3, 3, '2026-04-30', '20:00:00', 6, N'E re', N'Ditlindje familjare');
GO

INSERT INTO dbo.porosite (klient_id, staf_id, tavolina_id, statusi) VALUES
(1, 3, 2, N'E mbyllur'),
(2, 3, 1, N'E hapur');
GO

INSERT INTO dbo.porosia_detaj (porosi_id, menu_item_id, sasia, cmimi) VALUES
(1, 3, 2, 5.50),
(1, 5, 2, 1.20),
(2, 1, 1, 3.20),
(2, 6, 1, 2.00);
GO

INSERT INTO dbo.pagesat (porosi_id, shuma, metoda, statusi) VALUES
(1, 13.40, N'Cash', N'Paguar');
GO

CREATE VIEW dbo.v_rezervimet AS
SELECT
  r.rezervim_id,
  k.emri AS klienti,
  k.email,
  k.telefoni,
  t.numri_tavolines,
  r.data_rezervimit,
  r.ora_rezervimit,
  r.numri_personave,
  r.statusi,
  r.mesazhi
FROM dbo.rezervimet r
JOIN dbo.klientet k ON r.klient_id = k.klient_id
LEFT JOIN dbo.tavolinat t ON r.tavolina_id = t.tavolina_id;
GO

CREATE VIEW dbo.v_totali_porosive AS
SELECT
  p.porosi_id,
  k.emri AS klienti,
  p.statusi,
  COALESCE(SUM(pd.sasia * pd.cmimi), 0) AS totali
FROM dbo.porosite p
LEFT JOIN dbo.klientet k ON p.klient_id = k.klient_id
LEFT JOIN dbo.porosia_detaj pd ON p.porosi_id = pd.porosi_id
GROUP BY p.porosi_id, k.emri, p.statusi;
GO

CREATE VIEW dbo.v_te_ardhurat_ditore AS
SELECT
  CAST(data_pageses AS DATE) AS data_pageses,
  COUNT(*) AS numri_pagesave,
  SUM(shuma) AS totali_ditor
FROM dbo.pagesat
WHERE statusi = N'Paguar'
GROUP BY CAST(data_pageses AS DATE);
GO

-- Query testuese per ta pare qe databaza punon:
SELECT * FROM dbo.v_rezervimet ORDER BY data_rezervimit, ora_rezervimit;
SELECT * FROM dbo.v_totali_porosive ORDER BY porosi_id;
SELECT * FROM dbo.v_te_ardhurat_ditore ORDER BY data_pageses;
SELECT SUM(shuma) AS te_ardhurat_totale FROM dbo.pagesat WHERE statusi = N'Paguar';
GO
