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
    login       VARCHAR(255)  NOT NULL  PRIMARY KEY,
    heslo       VARCHAR(255)  NOT NULL CHECK(REGEXP_LIKE(heslo, '.*[A-Z]+.*[0-9]+.*')),
    meno        VARCHAR(255)  NOT NULL,
    mana        INT           NOT NULL CHECK ( mana >= 0 ),
    uroven      VARCHAR(255)  NOT NULL,
    aktivny_grimoar INT  DEFAULT null,
    CONSTRAINT id_aktivny_grimoar_FK
            FOREIGN KEY (aktivny_grimoar)
            REFERENCES predmet(id_predmet)
);

CREATE TABLE suboj
(
    id_suboj    INT           GENERATED ALWAYS AS IDENTITY  NOT NULL PRIMARY KEY,
    nazov       VARCHAR(255)  NOT NULL,
    id_vyzyvatel VARCHAR(255) NOT NULL,
    id_super     VARCHAR(255) DEFAULT NULL,
    id_vitaz     VARCHAR(255) DEFAULT NULL,
    CONSTRAINT  id_vyzyvatel_FK
            FOREIGN KEY (id_vyzyvatel)
            REFERENCES kuzelnik(login),
    CONSTRAINT  id_super_FK
            FOREIGN KEY (id_super)
            REFERENCES  kuzelnik(login),
    CONSTRAINT  id_vitaz_FK
            FOREIGN KEY (id_vitaz)
            REFERENCES kuzelnik(login)
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
    id_synergia_kuzelnik   VARCHAR(255)    NOT NULL,
    CONSTRAINT id_synergia_element_FK_V_SE
            FOREIGN KEY (id_synergia_element)
            REFERENCES element(id_element),
    CONSTRAINT id_synergia_kuzelnik_FK_V_SE
            FOREIGN KEY (id_synergia_kuzelnik)
            REFERENCES kuzelnik(login)
);

CREATE TABLE historia_grimoar
(
    id_historia_kuzelnik     VARCHAR(255)    NOT NULL,
    id_historia_grimoar      INT    NOT NULL,
    started_owning_date      VARCHAR(255) NOT NULL CHECK(REGEXP_LIKE(started_owning_date, '([0-2][0-9]|3[0-1])(.)(0[0-9]|1[0-2])(.)[0-9]{4}')),
    started_owning_time      VARCHAR(255) NOT NULL CHECK(REGEXP_LIKE(started_owning_time, '^(([0-1][0-9]|2[0-3])(:)([0-5][0-9])(:)[0-9]{2})$')),
    stopped_owning_date      VARCHAR(255) DEFAULT NULL CHECK(REGEXP_LIKE(stopped_owning_date, '([0-2][0-9]|3[0-1])(.)(0[0-9]|1[0-2])(.)[0-9]{4}')),
    stopped_owning_time      VARCHAR(255) DEFAULT NULL CHECK(REGEXP_LIKE(stopped_owning_time, '(([0-1][0-9]|2[0-3])(:)([0-5][0-9])(:)[0-9]{2})$')),
    CONSTRAINT id_majitel_FK_V_HG
            FOREIGN KEY (id_historia_kuzelnik)
            REFERENCES kuzelnik(login),
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
INSERT INTO kuzelnik(login,heslo,meno,mana,uroven,aktivny_grimoar)
VALUES ('Dumbo12','HateVoldemort23','Dumbledore',2001, 'S', 1);

INSERT INTO kuzelnik(login, heslo, meno,mana,uroven, aktivny_grimoar)
VALUES ('Harry19', 'heSlo123','HarryPotter', 1560, 'A',2);

INSERT INTO kuzelnik(login, heslo, meno,mana,uroven)
VALUES ('Voldi14', 'morT1sDeA1h','Voldemort', 1580, 'SS');

INSERT INTO kuzelnik(login, heslo,meno, mana,uroven, aktivny_grimoar)
VALUES ('Hermiona99', 'lovesB00ks','Hermiona', 1600,  'D', 2);

INSERT INTO kuzelnik(login, heslo, meno, mana, uroven)
VALUES ('GinyWeasley', 'tooManyBr0thers','Giny', 1021, 'B');

---------- DATA suboj -------
INSERT INTO suboj(nazov, id_vyzyvatel, id_super, id_vitaz)
VALUES ('SUBOJ_01', 'Dumbo12','Harry19','Dumbo12');

INSERT INTO suboj(nazov, id_vyzyvatel, id_super, id_vitaz)
VALUES ('SUBOJ_02', 'Harry19', 'Hermiona99', 'Hermiona99');

INSERT INTO suboj(nazov, id_vyzyvatel, id_super, id_vitaz)
VALUES ('SUBOJ_03', 'Hermiona99', 'GinyWeasley', 'Hermiona99');

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
VALUES ('GRIM03', 'Voldi14');

INSERT INTO predmet(nazov, id_kuzelnik)
VALUES ('Zvitok1', 'Hermiona99');

INSERT INTO predmet(nazov, id_kuzelnik)
VALUES ('Zvitok2', 'GinyWeasley');

INSERT INTO predmet(nazov, id_kuzelnik)
VALUES ('Smrť ťa čaká čoskoro', 'Voldi14');

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

----------- DATA zvitok ------
INSERT INTO zvitok(pouzity, id_predmet, id_kuzlo)
VALUES (0, 4, 2);

INSERT INTO zvitok(pouzity, id_predmet, id_kuzlo)
VALUES (0, 6, 1);

INSERT INTO zvitok(pouzity, id_predmet, id_kuzlo)
VALUES (1, 5, 3);

---------- DATA synergia element ----
INSERT INTO synergia_element(id_synergia_element, id_synergia_kuzelnik)
VALUES (1,'Hermiona99');

INSERT INTO synergia_element(id_synergia_element, id_synergia_kuzelnik)
VALUES (1,'Dumbo12');

INSERT INTO synergia_element(id_synergia_element, id_synergia_kuzelnik)
VALUES (2, 'Harry19');

----------- DATA historia grimoar ---
INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar,started_owning_date,started_owning_time,stopped_owning_date,stopped_owning_time)
VALUES ('Dumbo12',1, '25.03.2020', '15:15:00', '27.03.2020', '03:00:14');

INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar,started_owning_date,started_owning_time,stopped_owning_date,stopped_owning_time)
VALUES ('Harry19', 1, '27.03.2020', '18:10:26', '28.03.2020', '14:17:00');

INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar,started_owning_date,started_owning_time,stopped_owning_date,stopped_owning_time)
VALUES ('Harry19', 2, '10.02.2020', '17:59:25', '15.02.2020', '10:10:10');

INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar,started_owning_date,started_owning_time,stopped_owning_date,stopped_owning_time)
VALUES ('Harry19', 3, '01.02.2020', '02:06:08', '10.02.2020', '12:12:12');

INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar,started_owning_date,started_owning_time)
VALUES ('Hermiona99', 2, '20.02.2020','14:14:58');

INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar,started_owning_date,started_owning_time)
VALUES ('Hermiona99', 1, '29.03.2020', '00:00:00' );

INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar,started_owning_date,started_owning_time,stopped_owning_date,stopped_owning_time)
VALUES ('Hermiona99', 3, '15.02.2020', '15:45:58', '28.02.2020', '18:25:67');

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

SELECT * from kuzelnik;
SELECT * from suboj;
SELECT * from historia_grimoar;