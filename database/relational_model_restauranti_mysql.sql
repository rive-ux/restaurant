-- =============================================================================
-- Model relacionor: "restauranti"
-- Bazuar në tabelat: klient, punonjesit, menu, porosite, rezervimet
-- Motor: MySQL / MariaDB (int, ENUM, TIMESTAMP, DECIMAL)
-- =============================================================================
-- Marrëdhëniet kryesore:
--   klient 1 ──< N porosite
--   klient 1 ──< N rezervimet
--   punonjesit 1 ──< N porosite (opsionale, NULL nëse nuk caktohet)
--   punonjesit 1 ──< N rezervimet (opsionale)
--   menu: katalog i pavarur; lidhja me porosi bëhet përmes artikujt_e_porosise
-- Shënim: Në disa diagrama shfaqet linjë menu–klient; në modelin normalizuar
--         menu nuk referon klient; porositë lidhen me klient dhe me rreshta menu.
-- =============================================================================

CREATE DATABASE IF NOT EXISTS restauranti
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE restauranti;

-- ----------------------------------------------------------------------------- klient
CREATE TABLE klient (
    id            INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    emri          VARCHAR(100)     NOT NULL,
    numri         VARCHAR(15)      NULL,
    email         VARCHAR(100)     NULL,
    regjistrimi   TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------- punonjesit
CREATE TABLE punonjesit (
    id              INT UNSIGNED   NOT NULL AUTO_INCREMENT,
    emri            VARCHAR(50)    NOT NULL,
    roli            VARCHAR(15)    NOT NULL,
    numri           VARCHAR(15)    NULL,
    data_punesimit  TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    paga            INT            NOT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------- menu (katalog)
CREATE TABLE menu (
    id                       INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    emri_i_artikullit        VARCHAR(100)     NOT NULL,
    pershkrimi_i_artikullit  VARCHAR(500)     NULL,
    cmimi                    DECIMAL(10, 2)   NOT NULL,
    dispozicioni             TINYINT(1)       NOT NULL DEFAULT 1 COMMENT '1 = në dispozicion',
    kategoria                VARCHAR(100)     NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------- porosite
CREATE TABLE porosite (
    id                      INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    numri_i_tavolines       INT              NOT NULL,
    klient_id               INT UNSIGNED     NOT NULL,
    punonjes_id             INT UNSIGNED     NULL,
    data_dhe_ora_porosise   TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    totali                  DECIMAL(10, 2)   NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_porosite_klient
        FOREIGN KEY (klient_id) REFERENCES klient (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_porosite_punonjes
        FOREIGN KEY (punonjes_id) REFERENCES punonjesit (id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------- rezervimet
CREATE TABLE rezervimet (
    id               INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    klient_id        INT UNSIGNED     NOT NULL,
    punonjes_id      INT UNSIGNED     NULL,
    data_rezervimit  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tavolina         INT              NOT NULL,
    nr_personave     INT              NOT NULL,
    statusi          ENUM('pranuar', 'ne procesim', 'anuluar') NOT NULL DEFAULT 'ne procesim',
    mesazh           VARCHAR(500)     NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_rezervimet_klient
        FOREIGN KEY (klient_id) REFERENCES klient (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_rezervimet_punonjes
        FOREIGN KEY (punonjes_id) REFERENCES punonjesit (id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------- artikujt_e_porosise (normalizim: shumë artikuj për një porosi)
-- Përdoret kur një porosi përmban disa rreshta nga menu.
CREATE TABLE artikujt_e_porosise (
    id              INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    porosi_id       INT UNSIGNED     NOT NULL,
    menu_id         INT UNSIGNED     NOT NULL,
    sasia           SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    cmimi_njehsi   DECIMAL(10, 2)   NOT NULL COMMENT 'Çmimi në momentin e porosisë',
    PRIMARY KEY (id),
    CONSTRAINT fk_artikuj_porosi
        FOREIGN KEY (porosi_id) REFERENCES porosite (id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_artikuj_menu
        FOREIGN KEY (menu_id) REFERENCES menu (id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;
