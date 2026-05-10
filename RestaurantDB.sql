/* RestaurantDB — SSMS, F5 */

-- 1) Databaza (nëse ekziston, e anashkalon krijimin)
IF DB_ID(N'RestaurantDB') IS NULL
    CREATE DATABASE RestaurantDB;
GO

USE RestaurantDB;
GO

-- 2) Tabelat
CREATE TABLE punonjesit (
    id              INT            PRIMARY KEY NOT NULL,
    emri            VARCHAR(50)    NOT NULL,
    roli            VARCHAR(15)    NOT NULL,
    numri           VARCHAR(15)    NULL,
    data_punesimit  DATE           NOT NULL,
    paga            INT            NOT NULL
);
GO

CREATE TABLE klient (
    id           INT            PRIMARY KEY NOT NULL,
    emri         VARCHAR(100)   NOT NULL,
    numri        VARCHAR(15)    NULL,
    email        VARCHAR(100)   NULL,
    regjistrimi  DATE           NOT NULL
);
GO

CREATE TABLE menu (
    id                       INT             PRIMARY KEY NOT NULL,
    emri_i_artikullit        VARCHAR(100)    NOT NULL,
    pershkrimi_i_artikullit  VARCHAR(500)    NULL,
    cmimi                    DECIMAL(10, 2)  NOT NULL,
    dispozicioni             BIT             NOT NULL,
    kategoria                VARCHAR(100)    NULL
);
GO

CREATE TABLE porosite (
    id                     INT             PRIMARY KEY NOT NULL,
    numri_i_tavolines      INT             NOT NULL,
    klient_id              INT             NOT NULL,
    punonjes_id            INT             NULL,
    data_dhe_ora_porosise  DATETIME2(0)    NOT NULL DEFAULT (GETDATE()),
    totali                 DECIMAL(10, 2)  NOT NULL,
    FOREIGN KEY (klient_id) REFERENCES klient (id),
    FOREIGN KEY (punonjes_id) REFERENCES punonjesit (id)
);
GO

CREATE TABLE rezervimet (
    id               INT            PRIMARY KEY NOT NULL,
    klient_id        INT            NOT NULL,
    punonjes_id      INT            NULL,
    data_rezervimit  DATETIME2(0)   NOT NULL DEFAULT (GETDATE()),
    tavolina         INT            NOT NULL,
    nr_personave     INT            NOT NULL,
    statusi          VARCHAR(30)    NOT NULL DEFAULT ('ne procesim'),
    mesazh           VARCHAR(500)   NULL,
    CHECK (statusi IN ('pranuar', 'ne procesim', 'anuluar')),
    FOREIGN KEY (klient_id) REFERENCES klient (id),
    FOREIGN KEY (punonjes_id) REFERENCES punonjesit (id)
);
GO

-- Nëse e ke krijuar tabelën më parë pa mesazh, ekzekuto:
-- USE RestaurantDB; ALTER TABLE rezervimet ADD mesazh VARCHAR(500) NULL;

-- 3) Insert
INSERT INTO punonjesit (id, emri, roli, numri, data_punesimit, paga)
VALUES
    (1, 'Arben',  'kamarier',  '044111111', '2024-01-15', 450),
    (2, 'Drita',  'kuzhiniere', '044333333', '2023-06-01', 520);

INSERT INTO klient (id, emri, numri, email, regjistrimi)
VALUES
    (1, 'Blerim', '044222222', 'blerim@gmail.com',  '2026-05-10'),
    (2, 'Edona',  '049555555', 'edona@gmail.com',   '2026-05-10'),
    (3, 'Fisnik', '044777777', 'fisnik@gmail.com',  '2026-05-10');

INSERT INTO menu (id, emri_i_artikullit, pershkrimi_i_artikullit, cmimi, dispozicioni, kategoria)
VALUES
    (1, 'Pasta bolognese',  'Mish i grirë, salcë domatesh, spageta',  4.50, 1, 'Pasta'),
    (2, 'Pica proshute',    'Proshutë, mozzarella, domate',          4.50, 1, 'Pizza'),
    (3, 'Supe me perime',   'Perime të freskëta, erëza',             3.50, 1, 'Supë'),
    (4, 'Omlet',            'Vezë, djathë, erëza',                   4.10, 1, 'Mëngjes');

INSERT INTO porosite (id, numri_i_tavolines, klient_id, punonjes_id, data_dhe_ora_porosise, totali)
VALUES
    (1, 3, 1, 1, '2026-05-10 12:30:00', 8.00),
    (2, 2, 2, 2, '2026-05-10 13:00:00', 4.50),
    (3, 1, 1, NULL, '2026-05-10 14:15:00', 4.10);

INSERT INTO rezervimet (id, klient_id, punonjes_id, data_rezervimit, tavolina, nr_personave, statusi, mesazh)
VALUES
    (1, 1, 1, '2026-05-11 19:00:00', 5, 4, 'pranuar', NULL),
    (2, 2, 2, '2026-05-12 19:30:00', 2, 2, 'ne procesim', NULL),
    (3, 3, NULL, '2026-05-13 20:00:00', 8, 6, 'anuluar', NULL);
GO
