-- Sistemi i menaxhimit te restaurantit - MySQL database
-- Importoje kete file ne MySQL ose phpMyAdmin.

DROP DATABASE IF EXISTS restaurant_db;
CREATE DATABASE restaurant_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE restaurant_db;

CREATE TABLE klientet (
  klient_id INT AUTO_INCREMENT PRIMARY KEY,
  emri VARCHAR(100) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  telefoni VARCHAR(30) NOT NULL,
  data_regjistrimit TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE tavolinat (
  tavolina_id INT AUTO_INCREMENT PRIMARY KEY,
  numri_tavolines INT NOT NULL UNIQUE,
  kapaciteti INT NOT NULL,
  statusi ENUM('E lire', 'E rezervuar', 'E zene') NOT NULL DEFAULT 'E lire',
  CONSTRAINT chk_tavolinat_kapaciteti CHECK (kapaciteti > 0)
) ENGINE=InnoDB;

CREATE TABLE stafi (
  staf_id INT AUTO_INCREMENT PRIMARY KEY,
  emri VARCHAR(100) NOT NULL,
  roli ENUM('Menaxher', 'Kamarier', 'Kuzhinier', 'Arkatar') NOT NULL,
  telefoni VARCHAR(30),
  email VARCHAR(120) UNIQUE,
  aktiv BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE kategorite (
  kategori_id INT AUTO_INCREMENT PRIMARY KEY,
  emri VARCHAR(80) NOT NULL UNIQUE,
  pershkrimi TEXT
) ENGINE=InnoDB;

CREATE TABLE menu_items (
  menu_item_id INT AUTO_INCREMENT PRIMARY KEY,
  kategori_id INT NOT NULL,
  emri VARCHAR(100) NOT NULL,
  pershkrimi TEXT,
  cmimi DECIMAL(8,2) NOT NULL,
  aktiv BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_menu_items_kategorite
    FOREIGN KEY (kategori_id) REFERENCES kategorite(kategori_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT chk_menu_items_cmimi CHECK (cmimi >= 0)
) ENGINE=InnoDB;

CREATE TABLE rezervimet (
  rezervim_id INT AUTO_INCREMENT PRIMARY KEY,
  klient_id INT NOT NULL,
  tavolina_id INT,
  data_rezervimit DATE NOT NULL,
  ora_rezervimit TIME NOT NULL,
  numri_personave INT NOT NULL,
  statusi ENUM('E re', 'Konfirmuar', 'Anuluar', 'Perfunduar') NOT NULL DEFAULT 'E re',
  mesazhi TEXT,
  krijuar_me TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_rezervimet_klientet
    FOREIGN KEY (klient_id) REFERENCES klientet(klient_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_rezervimet_tavolinat
    FOREIGN KEY (tavolina_id) REFERENCES tavolinat(tavolina_id)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  CONSTRAINT chk_rezervimet_numri_personave CHECK (numri_personave > 0)
) ENGINE=InnoDB;

CREATE TABLE porosite (
  porosi_id INT AUTO_INCREMENT PRIMARY KEY,
  klient_id INT,
  staf_id INT,
  tavolina_id INT,
  data_porosise TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  statusi ENUM('E hapur', 'Ne pergatitje', 'E mbyllur', 'Anuluar') NOT NULL DEFAULT 'E hapur',
  CONSTRAINT fk_porosite_klientet
    FOREIGN KEY (klient_id) REFERENCES klientet(klient_id)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  CONSTRAINT fk_porosite_stafi
    FOREIGN KEY (staf_id) REFERENCES stafi(staf_id)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  CONSTRAINT fk_porosite_tavolinat
    FOREIGN KEY (tavolina_id) REFERENCES tavolinat(tavolina_id)
    ON UPDATE CASCADE
    ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE porosia_detaj (
  detaj_id INT AUTO_INCREMENT PRIMARY KEY,
  porosi_id INT NOT NULL,
  menu_item_id INT NOT NULL,
  sasia INT NOT NULL,
  cmimi DECIMAL(8,2) NOT NULL,
  CONSTRAINT fk_porosia_detaj_porosite
    FOREIGN KEY (porosi_id) REFERENCES porosite(porosi_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_porosia_detaj_menu_items
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(menu_item_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT chk_porosia_detaj_sasia CHECK (sasia > 0),
  CONSTRAINT chk_porosia_detaj_cmimi CHECK (cmimi >= 0)
) ENGINE=InnoDB;

CREATE TABLE pagesat (
  pagesa_id INT AUTO_INCREMENT PRIMARY KEY,
  porosi_id INT NOT NULL UNIQUE,
  shuma DECIMAL(10,2) NOT NULL,
  metoda ENUM('Cash', 'Kartel', 'Online') NOT NULL,
  data_pageses TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  statusi ENUM('Paguar', 'Ne pritje', 'Anuluar') NOT NULL DEFAULT 'Paguar',
  CONSTRAINT fk_pagesat_porosite
    FOREIGN KEY (porosi_id) REFERENCES porosite(porosi_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT chk_pagesat_shuma CHECK (shuma >= 0)
) ENGINE=InnoDB;

CREATE INDEX idx_rezervimet_data_ora ON rezervimet (data_rezervimit, ora_rezervimit);
CREATE INDEX idx_rezervimet_statusi ON rezervimet (statusi);
CREATE INDEX idx_porosite_statusi ON porosite (statusi);

INSERT INTO klientet (emri, email, telefoni) VALUES
('Arben Krasniqi', 'arben@email.com', '044111222'),
('Elira Berisha', 'elira@email.com', '049333444'),
('Driton Gashi', 'driton@email.com', '045555666'),
('Mira Hoti', 'mira@email.com', '043777888');

INSERT INTO tavolinat (numri_tavolines, kapaciteti, statusi) VALUES
(1, 2, 'E lire'),
(2, 4, 'E lire'),
(3, 6, 'E rezervuar'),
(4, 8, 'E lire'),
(5, 10, 'E lire');

INSERT INTO stafi (emri, roli, telefoni, email) VALUES
('Sokol Kodra', 'Kuzhinier', '044111112', 'sokol@restaurant.com'),
('Arta Basha', 'Menaxher', '049111112', 'arta@restaurant.com'),
('Kujtim Demneri', 'Kamarier', '045111112', 'kujtim@restaurant.com'),
('Blerina Shala', 'Arkatar', '043111112', 'blerina@restaurant.com');

INSERT INTO kategorite (emri, pershkrimi) VALUES
('Mengjesi', 'Ushqime per mengjes'),
('Mesdita', 'Pjata kryesore'),
('Pije', 'Pije te ftohta dhe te nxehta'),
('Oferta Javore', 'Oferta speciale te restaurantit');

INSERT INTO menu_items (kategori_id, emri, pershkrimi, cmimi) VALUES
(1, 'Tost me avokado', 'Buke integrale, veze dhe avokado', 3.20),
(1, 'Muffin', 'Muffin me veze, djathe dhe spinaq', 2.80),
(2, 'Supe pule', 'Mish pule, patate dhe ereza', 5.50),
(2, 'Supe me perime', 'Brokoli, selino dhe ereza', 3.50),
(3, 'Kafe', 'Kafe espresso', 1.20),
(3, 'Leng portokalli', 'Leng i fresket portokalli', 2.00),
(4, 'Menu familjare', 'Oferta javore per familje', 18.00);

INSERT INTO rezervimet (
  klient_id,
  tavolina_id,
  data_rezervimit,
  ora_rezervimit,
  numri_personave,
  statusi,
  mesazhi
) VALUES
(1, 2, '2026-04-28', '19:00:00', 4, 'Konfirmuar', 'Rezervim per darke'),
(2, 1, '2026-04-29', '10:00:00', 2, 'E re', 'Dritare nese ka mundesi'),
(3, 3, '2026-04-30', '20:00:00', 6, 'E re', 'Ditlindje familjare');

INSERT INTO porosite (klient_id, staf_id, tavolina_id, statusi) VALUES
(1, 3, 2, 'E mbyllur'),
(2, 3, 1, 'E hapur');

INSERT INTO porosia_detaj (porosi_id, menu_item_id, sasia, cmimi) VALUES
(1, 3, 2, 5.50),
(1, 5, 2, 1.20),
(2, 1, 1, 3.20),
(2, 6, 1, 2.00);

INSERT INTO pagesat (porosi_id, shuma, metoda, statusi) VALUES
(1, 13.40, 'Cash', 'Paguar');

CREATE VIEW v_rezervimet AS
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
FROM rezervimet r
JOIN klientet k ON r.klient_id = k.klient_id
LEFT JOIN tavolinat t ON r.tavolina_id = t.tavolina_id;

CREATE VIEW v_totali_porosive AS
SELECT
  p.porosi_id,
  k.emri AS klienti,
  p.statusi,
  COALESCE(SUM(pd.sasia * pd.cmimi), 0) AS totali
FROM porosite p
LEFT JOIN klientet k ON p.klient_id = k.klient_id
LEFT JOIN porosia_detaj pd ON p.porosi_id = pd.porosi_id
GROUP BY p.porosi_id, k.emri, p.statusi;

CREATE VIEW v_te_ardhurat_ditore AS
SELECT
  DATE(data_pageses) AS data_pageses,
  COUNT(*) AS numri_pagesave,
  SUM(shuma) AS totali_ditor
FROM pagesat
WHERE statusi = 'Paguar'
GROUP BY DATE(data_pageses);

-- Query testuese per ta pare qe databaza punon:
SELECT * FROM v_rezervimet ORDER BY data_rezervimit, ora_rezervimit;
SELECT * FROM v_totali_porosive ORDER BY porosi_id;
SELECT * FROM v_te_ardhurat_ditore ORDER BY data_pageses;
SELECT SUM(shuma) AS te_ardhurat_totale FROM pagesat WHERE statusi = 'Paguar';
