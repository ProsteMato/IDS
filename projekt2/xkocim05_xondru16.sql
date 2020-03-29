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
DROP TABLE historia_subojov CASCADE CONSTRAINTS ;
DROP TABLE element CASCADE CONSTRAINTS ;
DROP TABLE miesto_magie CASCADE CONSTRAINTS ;
DROP TABLE predmet CASCADE CONSTRAINTS ;
DROP TABLE synergia_element CASCADE CONSTRAINTS ;
DROP TABLE historia_grimoar CASCADE CONSTRAINTS ;
DROP TABLE kuzla_v_grimoaroch CASCADE CONSTRAINTS ;
DROP TABLE kuzlo CASCADE CONSTRAINTS ;
DROP TABLE vedlajsie_elementy_v_kuzle CASCADE CONSTRAINTS ;
DROP TABLE aktivne_grimoare CASCADE CONSTRAINTS ;

----------- CREATE TABLES -----------

CREATE TABLE element
(
    id_element INT      GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    nazov       VARCHAR(255) NOT NULL UNIQUE,
    barva_magie VARCHAR(255) NOT NULL,
    specializace VARCHAR(255) NOT NULL
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

CREATE TABLE kuzelnik
(
    login       VARCHAR(255)  NOT NULL  PRIMARY KEY,
    heslo       VARCHAR(255)  NOT NULL CHECK(REGEXP_LIKE(heslo, '.*[A-Z]+.*[0-9]+.*')),
    meno        VARCHAR(255)  NOT NULL,
    mana        INT           NOT NULL CHECK ( mana >= 0 ),
    uroven      VARCHAR(255)  NOT NULL
);

CREATE TABLE predmet
(
    id_predmet INT      GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    id_kuzelnik VARCHAR(255) DEFAULT NULL,
    nazov       VARCHAR(255) NOT NULL,
    type        VARCHAR(255) NOT NULL CHECK ( type = 'grimoar' or type = 'zvitok' ),
    magia_grimoaru INT,
    id_grimoar_element INT,
    id_kuzlo_zvitku INT,

    CHECK (
        (type = 'grimoar' and magia_grimoaru >= 0 and id_grimoar_element is not NULL) or
        (type = 'zvitok' and id_kuzlo_zvitku is not NULL)
    ),

    CONSTRAINT id_kuzlo_FK_V_ZVITOK
        FOREIGN KEY (id_kuzlo_zvitku)
        REFERENCES kuzlo(id_kuzlo),
    CONSTRAINT id_kuzelnika_FK_P
        FOREIGN KEY(id_kuzelnik)
        REFERENCES kuzelnik(login),
    CONSTRAINT id_prim_element_FK_P
        FOREIGN KEY (id_grimoar_element)
        REFERENCES element(id_element)
);

CREATE TABLE aktivne_grimoare
(
    id_kuzelnik           VARCHAR(255) NOT NULL,
    aktivny_grimoar INT  DEFAULT NULL,
    CONSTRAINT id_aktivny_grimoar_FK
            FOREIGN KEY (aktivny_grimoar)
            REFERENCES predmet(id_predmet),
    CONSTRAINT id_kuzelnika_FK_AP
        FOREIGN KEY(id_kuzelnik)
        REFERENCES kuzelnik(login)
);

CREATE TABLE historia_subojov
(
    id_suboj    INT           GENERATED ALWAYS AS IDENTITY  NOT NULL PRIMARY KEY,
    nazov       VARCHAR(255)  NOT NULL,
    id_vyzyvatel VARCHAR(255) NOT NULL,
    id_super     VARCHAR(255) DEFAULT NULL,
    id_vitaz     VARCHAR(255) DEFAULT NULL,
    datum        DATE DEFAULT CURRENT_DATE,
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
    started_owning_date      DATE NOT NULL,
    stopped_owning_date      DATE DEFAULT NULL,
    CONSTRAINT id_majitel_FK_V_HG
            FOREIGN KEY (id_historia_kuzelnik)
            REFERENCES kuzelnik(login),
    CONSTRAINT id_grimoar_FK_V_HG
            FOREIGN KEY (id_historia_grimoar)
            REFERENCES predmet(id_predmet),
    UNIQUE (id_historia_kuzelnik, id_historia_grimoar)
);

CREATE TABLE kuzla_v_grimoaroch
(
    id INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    id_grimoar NOT NULL,
    id_kuzlo NOT NULL,
    CONSTRAINT id_grimoar_FK_V_KVG
            FOREIGN KEY (id_grimoar)
            REFERENCES predmet(id_predmet),
    CONSTRAINT id_kuzlo_FK_V_KVG
            FOREIGN KEY (id_kuzlo)
            REFERENCES kuzlo(id_kuzlo)
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
INSERT INTO kuzelnik(login, heslo, meno, mana, uroven)
VALUES ('Dumbo12','HateVoldemort23','Dumbledore',2001, 'S');

INSERT INTO kuzelnik(login, heslo, meno,mana,uroven)
VALUES ('Harry19', 'heSlo123','HarryPotter', 1560, 'A');

INSERT INTO kuzelnik(login, heslo, meno, mana, uroven)
VALUES ('Voldi14', 'morT1sDeA1h','Voldemort', 1580, 'SS');

INSERT INTO kuzelnik(login, heslo, meno, mana, uroven)
VALUES ('Hermiona99', 'lovesB00ks','Hermiona', 1600,  'D');

INSERT INTO kuzelnik(login, heslo, meno, mana, uroven)
VALUES ('GinyWeasley', 'tooManyBr0thers','Giny', 1021, 'B');

---------- DATA suboj -------
INSERT INTO historia_subojov(nazov, id_vyzyvatel, id_super, id_vitaz)
VALUES ('SUBOJ_01', 'Dumbo12', 'Harry19', 'Dumbo12');

INSERT INTO historia_subojov(nazov, id_vyzyvatel, id_super, id_vitaz)
VALUES ('SUBOJ_02', 'Harry19', 'Hermiona99', 'Hermiona99');

INSERT INTO historia_subojov(nazov, id_vyzyvatel, id_super, id_vitaz)
VALUES ('SUBOJ_03', 'Hermiona99', 'GinyWeasley', 'Hermiona99');

INSERT INTO historia_subojov(nazov, id_vyzyvatel, id_super, id_vitaz, datum)
VALUES ('SUBOJ_03', 'Hermiona99', 'GinyWeasley', 'Hermiona99', TO_DATE( '2020-03-01 15:15:00', 'YYYY-MM-DD HH24:MI:SS' ));

SELECT * FROM historia_subojov;

---------- DATA element -----
INSERT INTO element(nazov, barva_magie, specializace)
VALUES ('voda', 'modrá', 'podpora');

INSERT INTO element(nazov, barva_magie, specializace)
VALUES ('ohen', 'červená', 'útok');

INSERT INTO element(nazov, barva_magie, specializace)
VALUES ('vzduch', 'biela', 'obrana');

---------- DATA miesto magie -----
INSERT INTO miesto_magie( suradnica_x, suradnica_y, suradnica_z, velkost_presakovania, id_miesto_element)
VALUES (12, 189, -18, 10, 1);

INSERT INTO miesto_magie(suradnica_x, suradnica_y, suradnica_z, velkost_presakovania, id_miesto_element)
VALUES (1289, 42, 1987, 44, 2);

INSERT INTO miesto_magie(suradnica_x, suradnica_y, suradnica_z, velkost_presakovania, id_miesto_element)
VALUES (74982, 12785, -1745, 1, 1);

---------- DATA kuzlo -----
INSERT INTO kuzlo(nazov, obtiaznost_zoslania, typ, sila, id_prim_elementu)
VALUES ('Avadagedabra', 10, 'útočné', '5000', 2);

INSERT INTO kuzlo(nazov, obtiaznost_zoslania, typ, sila, id_prim_elementu)
VALUES ('Wingardium Leviosa ', 2, 'obranné', '500', 3);

INSERT INTO kuzlo(nazov, obtiaznost_zoslania, typ, sila, id_prim_elementu)
VALUES ('aqua ', 3, 'útočné', '1000', 1);

---------- DATA predmet -----
INSERT INTO predmet(nazov, type, magia_grimoaru, id_grimoar_element)
VALUES ('GRIM01', 'grimoar', 40, 1);

INSERT INTO predmet(nazov, type, magia_grimoaru, id_grimoar_element)
VALUES ('GRIM02', 'grimoar', 50, 2);

INSERT INTO predmet(nazov, id_kuzelnik, type, magia_grimoaru, id_grimoar_element)
VALUES ('GRIM03', 'Voldi14', 'grimoar', 100, 3);

INSERT INTO predmet(nazov, id_kuzelnik, type, id_kuzlo_zvitku)
VALUES ('Zvitok1', 'Hermiona99', 'zvitok', 1);

INSERT INTO predmet(nazov, id_kuzelnik, type, id_kuzlo_zvitku)
VALUES ('Zvitok2', 'GinyWeasley', 'zvitok', 2);

INSERT INTO predmet(nazov, id_kuzelnik, type, id_kuzlo_zvitku)
VALUES ('Smrť ťa čaká čoskoro', 'Voldi14', 'zvitok', 3);

---------- DATA aktivne grimoare -----

INSERT INTO aktivne_grimoare(id_kuzelnik)
VALUES ('Voldi14');

INSERT INTO aktivne_grimoare(id_kuzelnik)
VALUES ('Harry19');

INSERT INTO aktivne_grimoare(id_kuzelnik)
VALUES ('Dumbo12');

INSERT INTO aktivne_grimoare(id_kuzelnik)
VALUES ('GinyWeasley');

INSERT INTO aktivne_grimoare(id_kuzelnik, aktivny_grimoar)
VALUES ('Hermiona99', 2);

---------- DATA synergia element ----
INSERT INTO synergia_element(id_synergia_element, id_synergia_kuzelnik)
VALUES (1,'Hermiona99');

INSERT INTO synergia_element(id_synergia_element, id_synergia_kuzelnik)
VALUES (1,'Dumbo12');

INSERT INTO synergia_element(id_synergia_element, id_synergia_kuzelnik)
VALUES (2, 'Harry19');

----------- DATA historia grimoar ---
INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar,started_owning_date,stopped_owning_date)
VALUES ('Dumbo12',1, TO_DATE( '2020-03-01 15:15:00', 'YYYY-MM-DD HH24:MI:SS' ), TO_DATE( '2020-03-27 15:15:00', 'YYYY-MM-DD HH24:MI:SS' ));

INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar,started_owning_date,stopped_owning_date)
VALUES ('Harry19', 1, TO_DATE ('2020-03-27 18:10:26', 'YYYY-MM-DD HH24:MI:SS' ), TO_DATE ('2020-03-28 14:17:00', 'YYYY-MM-DD HH24:MI:SS' ));

INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar,started_owning_date,stopped_owning_date)
VALUES ('Harry19', 2, TO_DATE ('2020-02-10 17:59:25', 'YYYY-MM-DD HH24:MI:SS' ),TO_DATE ('2020-02-15 10:10:10', 'YYYY-MM-DD HH24:MI:SS' ));

INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar,started_owning_date,stopped_owning_date)
VALUES ('Harry19', 3, TO_DATE ('2020-02-01 02:06:08', 'YYYY-MM-DD HH24:MI:SS' ), TO_DATE ('2020-02-10 12:12:12', 'YYYY-MM-DD HH24:MI:SS' ));

INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar,started_owning_date)
VALUES ('Hermiona99', 2, TO_DATE ('2020-02-20 14:14:58', 'YYYY-MM-DD HH24:MI:SS' ));

INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar,started_owning_date)
VALUES ('Hermiona99', 1, TO_DATE ('2020-03-29 00:00:00' , 'YYYY-MM-DD HH24:MI:SS' ));

INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar,started_owning_date,stopped_owning_date)
VALUES ('Hermiona99', 3, TO_DATE ('2020-02-15 15:45:58', 'YYYY-MM-DD HH24:MI:SS' ), TO_DATE ('2020-02-23 18:25:48', 'YYYY-MM-DD HH24:MI:SS' ));

---------- DATA kuzla v grimoáry -----
INSERT INTO kuzla_v_grimoaroch(id_grimoar, id_kuzlo)
VALUES (1, 1);

INSERT INTO kuzla_v_grimoaroch(id_grimoar, id_kuzlo)
VALUES (1, 2);

INSERT INTO kuzla_v_grimoaroch(id_grimoar, id_kuzlo)
VALUES (3, 3);

INSERT INTO kuzla_v_grimoaroch(id_grimoar, id_kuzlo)
VALUES (2, 2);

INSERT INTO kuzla_v_grimoaroch(id_grimoar, id_kuzlo)
VALUES (2, 1);

---------- DATA vedlajsie elementy v kuzle -----
INSERT INTO vedlajsie_elementy_v_kuzle(id_element, id_kuzlo) VALUES (3, 1);

INSERT INTO vedlajsie_elementy_v_kuzle(id_element, id_kuzlo) VALUES (1, 3);

SELECT * from kuzelnik;
SELECT * from historia_grimoar;