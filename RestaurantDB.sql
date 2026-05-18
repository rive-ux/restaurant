/*
================================================================================
  RestaurantDB — skema e databazës (SQL Server)
  Ekzekuto në SSMS: F5

  Përmbajtja:
    1. Krijimi i databazës
    2. Tabelat
    3. Të dhëna fillestare (shembull)

  Lidhjet:
    punonjesit ──┐
                 ├──► porosite ◄── klient
    menu         │
    rezervimet   └──  (formulari Rezervo — jo FK te klient)
================================================================================
*/

/* =============================================================================
   1. DATABAZA
   ============================================================================= */
IF DB_ID(N'RestaurantDB') IS NULL
    CREATE DATABASE RestaurantDB;
GO

USE RestaurantDB;
GO

/* =============================================================================
   2. TABELAT
   ============================================================================= */

IF OBJECT_ID(N'dbo.punonjesit', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.punonjesit (
        id              INT           NOT NULL PRIMARY KEY,
        emri            VARCHAR(50)   NOT NULL,
        roli            VARCHAR(15)   NOT NULL,
        numri           VARCHAR(15)   NULL,
        data_punesimit  DATE          NOT NULL,
        paga            INT           NOT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.klient', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.klient (
        id           INT           NOT NULL PRIMARY KEY,
        emri         VARCHAR(100)  NOT NULL,
        numri        VARCHAR(15)   NULL,
        email        VARCHAR(100)  NULL,
        regjistrimi  DATE          NOT NULL
    );
END
GO

IF OBJECT_ID(N'dbo.menu', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.menu (
        id                       INT            NOT NULL PRIMARY KEY,
        emri_i_artikullit        VARCHAR(100)   NOT NULL,
        pershkrimi_i_artikullit  VARCHAR(500)   NULL,
        cmimi                    DECIMAL(10, 2) NOT NULL,
        dispozicioni             BIT            NOT NULL,
        kategoria                VARCHAR(100)   NULL
    );
END
GO

IF OBJECT_ID(N'dbo.porosite', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.porosite (
        id                     INT            NOT NULL PRIMARY KEY,
        numri_i_tavolines      INT            NOT NULL,
        klient_id              INT            NOT NULL,
        punonjes_id            INT            NULL,
        data_dhe_ora_porosise  DATETIME2(0)   NOT NULL DEFAULT (GETDATE()),
        totali                 DECIMAL(10, 2) NOT NULL,
        CONSTRAINT FK_porosite_klient    FOREIGN KEY (klient_id)   REFERENCES dbo.klient (id),
        CONSTRAINT FK_porosite_punonjes FOREIGN KEY (punonjes_id) REFERENCES dbo.punonjesit (id)
    );
END
GO

IF OBJECT_ID(N'dbo.rezervimet', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.rezervimet (
        id                 INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
        emri               NVARCHAR(100)      NOT NULL,
        email              NVARCHAR(150)      NOT NULL,
        numri_telefonit    NVARCHAR(30)       NOT NULL,
        numri_musafirve    INT                NOT NULL,
        data_rezervimit    DATE               NOT NULL,
        koha               NVARCHAR(20)       NOT NULL,
        mesazhi            NVARCHAR(500)      NULL,
        CONSTRAINT CK_rezervimet_koha CHECK (koha IN (N'mengjes', N'drek', N'darke'))
    );
END
GO

/* =============================================================================
   3. TË DHËNA FILLESTARE (vetëm nëse tabela është bosh)
   ============================================================================= */

IF NOT EXISTS (SELECT 1 FROM dbo.punonjesit)
INSERT INTO dbo.punonjesit (id, emri, roli, numri, data_punesimit, paga)
VALUES
    (1, N'Arben',  N'kamarier',   N'044111111', '2024-01-15', 450),
    (2, N'Drita',  N'kuzhiniere', N'044333333', '2023-06-01', 520);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.klient)
INSERT INTO dbo.klient (id, emri, numri, email, regjistrimi)
VALUES
    (1, N'Blerim', N'044222222', N'blerim@gmail.com', '2026-05-10'),
    (2, N'Edona',  N'049555555', N'edona@gmail.com',  '2026-05-10'),
    (3, N'Fisnik', N'044777777', N'fisnik@gmail.com', '2026-05-10');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.menu)
INSERT INTO dbo.menu (id, emri_i_artikullit, pershkrimi_i_artikullit, cmimi, dispozicioni, kategoria)
VALUES
    (1, N'Pasta bolognese', N'Mish i grirë, salcë domatesh, spageta', 4.50, 1, N'Pasta'),
    (2, N'Pica proshute',   N'Proshutë, mozzarella, domate',         4.50, 1, N'Pizza'),
    (3, N'Supe me perime',  N'Perime të freskëta, erëza',            3.50, 1, N'Supë'),
    (4, N'Omlet',           N'Vezë, djathë, erëza',                  4.10, 1, N'Mëngjes');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.porosite)
INSERT INTO dbo.porosite (id, numri_i_tavolines, klient_id, punonjes_id, data_dhe_ora_porosise, totali)
VALUES
    (1, 3, 1, 1, '2026-05-10 12:30:00', 8.00),
    (2, 2, 2, 2, '2026-05-10 13:00:00', 4.50),
    (3, 1, 1, NULL, '2026-05-10 14:15:00', 4.10);
GO

IF COL_LENGTH('dbo.rezervimet', 'numri_musafirve') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.rezervimet WHERE email = N'blerim@gmail.com')
        INSERT INTO dbo.rezervimet (emri, email, numri_telefonit, numri_musafirve, data_rezervimit, koha, mesazhi)
        VALUES (N'Blerim', N'blerim@gmail.com', N'044222222', 4, '2026-05-11', N'darke', NULL);

    IF NOT EXISTS (SELECT 1 FROM dbo.rezervimet WHERE email = N'edona@gmail.com')
        INSERT INTO dbo.rezervimet (emri, email, numri_telefonit, numri_musafirve, data_rezervimit, koha, mesazhi)
        VALUES (N'Edona', N'edona@gmail.com', N'049555555', 2, '2026-05-12', N'mengjes', NULL);
END
GO

/*
  Skripte shtesë (api/):
    sql-reset-rezervimet-identitet.sql  — rikrijon vetëm rezervimet
    sql-radhit-rezervimet-shembull.sql  — id 1,2 shembull, pastaj nga Rezervo
    sql-create-restaurant-web-login.sql — login për api/.env
*/
