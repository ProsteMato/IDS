/**
* @file xkocim05_xondru16.sql
*
* @brief IDS project, part 2  - Svet mágie
*        SQL script for creating basic object of database's scheme
*
* @authors Martin Koči          <xkocim05@stud.fit.vutbr.cz>
*          Magdaléna Ondrušková <xondru16@stud.fit.vutbr.cz>
*
* @date  16/03/2020
*/

----------- DELETE existing TABLES ------
DROP TABLE kuzelnik CASCADE CONSTRAINTS ;
DROP TABLE suboj CASCADE CONSTRAINTS ;
DROP TABLE element CASCADE CONSTRAINTS ;
DROP TABLE miesto_magie CASCADE CONSTRAINTS ;
DROP TABLE predmet CASCADE CONSTRAINTS ;
DROP TABLE grimoar CASCADE CONSTRAINTS ;
DROP TABLE synergia_element CASCADE CONSTRAINTS ;
DROP TABLE historia_grimoar CASCADE CONSTRAINTS ;
DROP TABLE kuzla_v_grimoaroch CASCADE CONSTRAINTS ;
DROP TABLE kuzlo CASCADE CONSTRAINTS ;
DROP TABLE vedlajsie_elementy_v_kuzle CASCADE CONSTRAINTS ;
DROP TABLE zvitok CASCADE CONSTRAINTS ;

----------- CREATE TABLES -----------
CREATE TABLE kuzelnik
(
    id_kuzelnik INT           GENERATED ALWAYS AS IDENTITY NOT NULL  PRIMARY KEY,
    meno        VARCHAR(255)  NOT NULL,
    mana        INT           NOT NULL CHECK ( mana >= 0 ),
    uroven      VARCHAR(255)  NOT NULL
);

CREATE TABLE suboj
(
    id_suboj    INT           GENERATED ALWAYS AS IDENTITY  NOT NULL PRIMARY KEY,
    nazov       VARCHAR(255)  NOT NULL,
    id_vyzyvatel INT NOT NULL,
    id_super     INT NOT NULL,
    id_vitaz     INT NOT NULL,
    CONSTRAINT  id_vyzyvatel_FK
            FOREIGN KEY (id_vyzyvatel)
            REFERENCES kuzelnik(id_kuzelnik),
    CONSTRAINT  id_super_FK
            FOREIGN KEY (id_super)
            REFERENCES  kuzelnik(id_kuzelnik),
    CONSTRAINT  id_vitaz_FK
            FOREIGN KEY (id_vitaz)
            REFERENCES kuzelnik(id_kuzelnik)
);

CREATE TABLE element
(
    id_element INT      GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    nazov       VARCHAR(255) NOT NULL UNIQUE,
    barva_magie VARCHAR(255) NOT NULL,
    specializace VARCHAR(255) NOT NULL
);

CREATE TABLE miesto_magie
(
    id_miesto   INT           GENERATED ALWAYS AS IDENTITY NOT NULL  PRIMARY KEY,
    suradnica_X   INT NOT NULL CHECK ( suradnica_X>=0 ),
    suradnica_Y   INT NOT NULL CHECK (  suradnica_Y>=0 ),
    suradnica_Z   INT NOT NULL,
    velkost_presakovania INT  DEFAULT 1 CHECK (velkost_presakovania>0),
    id_miesto_element   INT NOT NULL,
    CONSTRAINT id_miesto_element_FK_MM
            FOREIGN KEY (id_miesto_element)
            REFERENCES element(id_element)
);

CREATE TABLE predmet
(
    id_predmet INT      GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    nazov       VARCHAR(255) NOT NULL,
    id_kuzelnik INT DEFAULT NULL,
    CONSTRAINT id_kuzelnika_FK_P
        FOREIGN KEY(id_kuzelnik)
        REFERENCES kuzelnik(id_kuzelnik)
);

CREATE TABLE grimoar
(
    id_grimoar  INT            GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    magia       VARCHAR(50)    NOT NULL,
    id_grimoar_predmet  INT            NOT NULL,
    id_grimoar_element  INT            NOT NULL,
    id_vlastni          INT,
    CONSTRAINT id_predmet_FK_G
            FOREIGN KEY (id_grimoar_predmet)
            REFERENCES predmet(id_predmet),
    CONSTRAINT id_prim_element_FK_G
            FOREIGN KEY (id_grimoar_element)
            REFERENCES element(id_element),
    CONSTRAINT id_vlastni_FK_G
        FOREIGN KEY (id_vlastni)
        REFERENCES kuzelnik(id_kuzelnik)
);

CREATE TABLE synergia_element
(
    id_synergia_element    INT    NOT NULL,
    id_synergia_kuzelnik   INT    NOT NULL,
    CONSTRAINT id_synergia_element_FK_V_SE
            FOREIGN KEY (id_synergia_element)
            REFERENCES element(id_element),
    CONSTRAINT id_synergia_kuzelnik_FK_V_SE
            FOREIGN KEY (id_synergia_kuzelnik)
            REFERENCES kuzelnik(id_kuzelnik)
);

CREATE TABLE historia_grimoar
(
    id_historia_kuzelnik     INT    NOT NULL,
    id_historia_grimoar      INT    NOT NULL,
    CONSTRAINT id_majitel_FK_V_HG
            FOREIGN KEY (id_historia_kuzelnik)
            REFERENCES kuzelnik(id_kuzelnik),
    CONSTRAINT id_grimoar_FK_V_HG
            FOREIGN KEY (id_historia_grimoar)
            REFERENCES grimoar(id_grimoar),
    UNIQUE (id_historia_kuzelnik, id_historia_grimoar)
);

CREATE TABLE kuzlo
(
    id_kuzlo INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    nazov VARCHAR(255) NOT NULL,
    obtiaznost_zoslania INT NOT NULL CHECK ( obtiaznost_zoslania >= 0 ),
    typ VARCHAR(255) NOT NULL,
    sila INT NOT NULL CHECK ( sila >= 0 ),
    id_prim_elementu INT NOT NULL,
    CONSTRAINT id_prime_element_FK_V_K
        FOREIGN KEY (id_prim_elementu)
        REFERENCES element(id_element)
);

CREATE TABLE kuzla_v_grimoaroch
(
    id INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    id_grimoar NOT NULL,
    id_kuzlo NOT NULL,
    CONSTRAINT id_grimoar_FK_V_KVG
            FOREIGN KEY (id_grimoar)
            REFERENCES grimoar(id_grimoar),
    CONSTRAINT id_kuzlo_FK_V_KVG
            FOREIGN KEY (id_kuzlo)
            REFERENCES kuzlo(id_kuzlo)
);

CREATE TABLE zvitok
(
    id_zvitok INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    pouzity INT CHECK ( pouzity = 0 OR  pouzity = 1),
    id_predmet INT NOT NULL,
    id_kuzlo INT NOT NULL,
    CONSTRAINT id_predmet_FK_V_ZVITOK FOREIGN KEY (id_predmet) REFERENCES predmet(id_predmet),
    CONSTRAINT id_kuzlo_FK_V_ZVITOK FOREIGN KEY (id_kuzlo) REFERENCES kuzlo(id_kuzlo)
);

CREATE TABLE vedlajsie_elementy_v_kuzle
(
    id_element INT NOT NULL,
    id_kuzlo INT NOT NULL,
    CONSTRAINT id_element_FK_V_VEK FOREIGN KEY (id_element) REFERENCES element(id_element),
    CONSTRAINT id_kuzlo_FK_V_VEK FOREIGN KEY (id_kuzlo) REFERENCES kuzlo(id_kuzlo)
);




---------------------------
----------- DATA ----------
---------------------------
--- SQL index from 1 ------

-------- DATA kuzelnik -------
INSERT INTO kuzelnik(meno,mana,uroven)
VALUES ('Dumbledore',2001, 'S');

INSERT INTO kuzelnik(meno,mana,uroven)
VALUES ('HarryPotter', 1560, 'A');

INSERT INTO kuzelnik(meno,mana,uroven)
VALUES ('Voldemort', 1580, 'SS');

INSERT INTO kuzelnik(meno, mana,uroven)
VALUES ('Hermiona', 1600,  'D');

INSERT INTO kuzelnik(meno, mana, uroven)
VALUES ('Giny', 1021, 'B');

---------- DATA suboj -------
INSERT INTO suboj(nazov, id_vyzyvatel, id_super, id_vitaz)
VALUES ('SUBOJ_01', 1,3,1);

INSERT INTO suboj(nazov, id_vyzyvatel, id_super, id_vitaz)
VALUES ('SUBOJ_02', 2,4,4);

INSERT INTO suboj(nazov, id_vyzyvatel, id_super, id_vitaz)
VALUES ('SUBOJ_03', 4,5,4);

---------- DATA element -----
INSERT INTO element(nazov, barva_magie, specializace)
VALUES ('voda', 'modrá', 'podpora');

INSERT INTO element(nazov, barva_magie, specializace)
VALUES ('ohen', 'červená', 'útok');

INSERT INTO element(nazov, barva_magie, specializace)
VALUES ('vzduch', 'biela', 'obrana');

---------- DATA miesto magie -----
INSERT INTO miesto_magie( suradnica_x, suradnica_y, suradnica_z, velkost_presakovania, id_miesto_element)
VALUES (12, 189,-18, 10, 1);

INSERT INTO miesto_magie(suradnica_x, suradnica_y, suradnica_z, velkost_presakovania, id_miesto_element)
VALUES (1289, 42, 1987, 44, 2);

INSERT INTO miesto_magie(suradnica_x, suradnica_y, suradnica_z, velkost_presakovania, id_miesto_element)
VALUES (74982,12785,-1745,1,1);

---------- DATA predmet -----
INSERT INTO predmet(nazov)
VALUES ('GRIM01');

INSERT INTO predmet(nazov)
VALUES ('GRIM02');

INSERT INTO predmet(nazov, id_kuzelnik)
VALUES ('GRIM03', 3);

INSERT INTO predmet(nazov, id_kuzelnik)
VALUES ('Zvitok1', 4);

INSERT INTO predmet(nazov, id_kuzelnik)
VALUES ('Zvitok2', 5);

INSERT INTO predmet(nazov, id_kuzelnik)
VALUES ('Smrť ťa čaká čoskoro', 3);

----------- DATA grimoar ------
INSERT INTO grimoar(magia, id_grimoar_predmet, id_grimoar_element)
VALUES ('voda', 1, 1);

INSERT INTO grimoar(magia, id_grimoar_predmet, id_grimoar_element)
VALUES ('vzduch', 2, 3);

INSERT INTO grimoar(magia, id_grimoar_predmet, id_grimoar_element)
VALUES ('oheň', 3, 2);

---------- DATA kuzlo -----
INSERT INTO kuzlo(nazov, obtiaznost_zoslania, typ, sila, id_prim_elementu)
VALUES ('Avadagedabra', 10, 'útočné', '5000', 2);

INSERT INTO kuzlo(nazov, obtiaznost_zoslania, typ, sila, id_prim_elementu)
VALUES ('Wingardium Leviosa ', 2, 'obranné', '500', 3);

INSERT INTO kuzlo(nazov, obtiaznost_zoslania, typ, sila, id_prim_elementu)
VALUES ('aqua ', 3, 'útočné', '1000', 1);

INSERT INTO kuzlo(nazov, obtiaznost_zoslania, typ, sila, id_prim_elementu)
VALUES ('Avadagedabra', 8, 'útočné', '2000', 2);

----------- DATA zvitok ------
INSERT INTO zvitok(pouzity, id_predmet, id_kuzlo)
VALUES (0, 4, 2);

INSERT INTO zvitok(pouzity, id_predmet, id_kuzlo)
VALUES (0, 6, 1);

INSERT INTO zvitok(pouzity, id_predmet, id_kuzlo)
VALUES (1, 5, 3);

---------- DATA synergia element ----
INSERT INTO synergia_element(id_synergia_element, id_synergia_kuzelnik)
VALUES (1,4);

INSERT INTO synergia_element(id_synergia_element, id_synergia_kuzelnik)
VALUES (1,1);

INSERT INTO synergia_element(id_synergia_element, id_synergia_kuzelnik)
VALUES (2, 2);

----------- DATA historia grimoar ---
INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar)
VALUES (1,1);

INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar)
VALUES (2, 1);

INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar)
VALUES (2, 2);

INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar)
VALUES (2, 3);

INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar)
VALUES (4, 2);

INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar)
VALUES (4, 1);

INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar)
VALUES (4, 3);

---------- DATA kuzla v grimoáry -----
INSERT INTO kuzla_v_grimoaroch(id_grimoar, id_kuzlo)
VALUES (1, 1);

INSERT INTO kuzla_v_grimoaroch(id_grimoar, id_kuzlo)
VALUES (1, 2);

INSERT INTO kuzla_v_grimoaroch(id_grimoar, id_kuzlo)
VALUES (1, 3);

INSERT INTO kuzla_v_grimoaroch(id_grimoar, id_kuzlo)
VALUES (1, 2);

INSERT INTO kuzla_v_grimoaroch(id_grimoar, id_kuzlo)
VALUES (2, 1);

---------- DATA vedlajsie elementy v kuzle -----
INSERT INTO vedlajsie_elementy_v_kuzle(id_element, id_kuzlo) VALUES (3, 1);

INSERT INTO vedlajsie_elementy_v_kuzle(id_element, id_kuzlo) VALUES (1, 3);


-------------------------------------------------
----------------- 3. PROJEKT --------------------
-------------------------------------------------

------------------------------------------------
-- Vyhľadá všetky súboje, v ktorých sa ---------
--      zúčastnil kúzelnik Hermiona    ---------
------ SELECT s dvoma tabuľkami ----------------
------------------------------------------------
SELECT
    k1.meno vyzivatel,
    k2.meno super
FROM suboj
INNER JOIN kuzelnik k1 ON id_vyzyvatel = k1.id_kuzelnik
INNER JOIN kuzelnik k2 ON id_super = k2.id_kuzelnik
WHERE k1.meno = 'Hermiona' OR k2.meno = 'Hermiona';

------------------------------------------------
----- Vyhľadá všetky kúzla a primárne ----------
-----    elementy ktoré obsahujú      ----------
---------- SELECT s dvoma tabuľkami ------------
------------------------------------------------
SELECT kuzlo.nazov AS nazov_kuzla,
       element.nazov AS nazov_elementu
FROM kuzlo
LEFT JOIN element ON kuzlo.id_prim_elementu = element.id_element;

------------------------------------------------
------- Vyhľadá všetky zvitky, ktoré -----------
----- obsahujú  kúzlo s elementom voda  --------
------    SELECT s tromi tabuľkami    ----------
------------------------------------------------
SELECT
    kuzlo.nazov AS nazov_kuzla,
    element.nazov AS nazov_elementu,
    predmet.nazov AS nazov_predmetu
FROM kuzlo
JOIN element ON (kuzlo.id_prim_elementu = element.id_element )
JOIN zvitok ON (kuzlo.id_kuzlo = zvitok.id_kuzlo)
JOIN predmet ON (predmet.id_predmet = zvitok.id_predmet)
WHERE element.nazov = 'voda';
------------------------------------------------
------   Vyhľadá kúzla a vypočíta jeho    ------
-- priemernú silu a vypíše jeho prim. element --
----   GROUP BY s agregačnou funkciou AVG    ---
----         zoradený od najväčšieho        ----
------------------------------------------------
SELECT
    kuzlo.nazov AS nazov_kuzla,
    AVG(sila) AS priemerna_sila
FROM kuzlo
JOIN element ON kuzlo.id_prim_elementu = element.id_element
GROUP BY kuzlo.nazov
HAVING AVG(sila) > 200
ORDER BY priemerna_sila DESC ;

------------------------------------------------
------   Vyhľadá kúzelníkov a spočíta     ------
------     koľko grimoárov vlastnili      ------
----   GROUP BY s agregačnou funkciou COUNT  ---
----         zoradený od najväčšieho        ----
------------------------------------------------
-- vyberie meno kuzelnika a count pre daného kuzelnika
SELECT kuzelnik.meno AS meno_kuzelnika,
       COUNT(id_historia_grimoar) AS pocet_grimoarov
FROM historia_grimoar
LEFT JOIN kuzelnik ON historia_grimoar.id_historia_kuzelnik = kuzelnik.id_kuzelnik
GROUP BY kuzelnik.meno
ORDER BY COUNT(id_historia_grimoar) DESC;

------------------------------------------------
------  Vyhľadá všetky elementy, ktoré sú ------
----  súčasťou vedľajších elementov v kúzle ----
---------  využitie predikátu EXISTS   ---------
------------------------------------------------
SELECT element.nazov AS nazov_elementu
FROM  element
WHERE
    EXISTS
    (
        SELECT vedlajsie_elementy_v_kuzle.id_element
        FROM vedlajsie_elementy_v_kuzle
        WHERE element.id_element=vedlajsie_elementy_v_kuzle.id_element
    );

------------------------------------------------
--------  Vyhľadá všetkých kúzelníkov ----------
--vypíše tých, ktorý nevlastnia žiadny predmet--
---------  využitie predikátu IN  ---------
------------------------------------------------
SELECT * FROM kuzelnik
WHERE id_kuzelnik NOT IN
      (SELECT predmet.id_kuzelnik
      FROM predmet
      WHERE predmet.id_kuzelnik IS NOT NULL);

