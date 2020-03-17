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
    nazov       VARCHAR(255) NOT NULL
);

CREATE TABLE miesto_magie
(
    id_miesto   INT           GENERATED ALWAYS AS IDENTITY NOT NULL  PRIMARY KEY,
    suradnica_X   INT NOT NULL CHECK ( suradnica_X>=0 ),
    suradnica_Y   INT NOT NULL CHECK (  suradnica_Y>=0 ),
    suradnica_Z   INT NOT NULL,
    velkost_presakovania INT  DEFAULT 1 CHECK (velkost_presakovania>0),
    id_miesto_element   INT NOT NULL,
    CONSTRAINT id_miesto_element_FK
            FOREIGN KEY (id_miesto_element)
            REFERENCES element(id_element)
);

CREATE TABLE predmet
(
    id_predmet INT      GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    nazov       VARCHAR(255) NOT NULL
);

CREATE TABLE grimoar
(
    id_grimoar  INT            GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    magia       VARCHAR(50)    NOT NULL,
    id_grimoar_predmet  INT            NOT NULL,
    id_grimoar_element  INT            NOT NULL,
    CONSTRAINT id_predmet_FK
            FOREIGN KEY (id_grimoar_predmet)
            REFERENCES predmet(id_predmet),
    CONSTRAINT id_prim_element_FK
            FOREIGN KEY (id_grimoar_element)
            REFERENCES element(id_element)
);

CREATE TABLE synergia_element
(
    id_synergia_element    INT    NOT NULL,
    id_synergia_kuzelnik   INT    NOT NULL,
    CONSTRAINT id_synergia_element_FK
            FOREIGN KEY (id_synergia_element)
            REFERENCES element(id_element),
    CONSTRAINT id_synergia_kuzelnik_FK
            FOREIGN KEY (id_synergia_kuzelnik)
            REFERENCES kuzelnik(id_kuzelnik)
);

CREATE TABLE historia_grimoar
(
    id_historia_kuzelnik     INT    NOT NULL,
    id_historia_grimoar      INT    NOT NULL,
    CONSTRAINT id_majitel_FK
            FOREIGN KEY (id_historia_kuzelnik)
            REFERENCES kuzelnik(id_kuzelnik),
    CONSTRAINT id_grimoar_FK
            FOREIGN KEY (id_historia_grimoar)
            REFERENCES grimoar(id_grimoar)
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

INSERT INTO element(nazov)
VALUES ('voda');

INSERT INTO element(nazov)
VALUES ('ohen');

---------- DATA miesto magie -----
INSERT INTO miesto_magie( suradnica_x, suradnica_y, suradnica_z, velkost_presakovania, id_miesto_element)
VALUES (12, 189,-18, 10, 1);

INSERT INTO miesto_magie(suradnica_x, suradnica_y, suradnica_z, velkost_presakovania, id_miesto_element)
VALUES (1289, 42, 1987, 44, 2);

INSERT INTO miesto_magie(suradnica_x, suradnica_y, suradnica_z, velkost_presakovania, id_miesto_element)
VALUES (74982,12785,-1745,1,1);

INSERT INTO predmet(nazov)
VALUES ('GRIM01');

INSERT INTO predmet(nazov)
VALUES ('GRIM02');
----------- DATA grimoar ------
INSERT INTO grimoar(magia, id_grimoar_predmet, id_grimoar_element)
VALUES ('voda', 1, 1);

INSERT INTO grimoar(magia, id_grimoar_predmet, id_grimoar_element)
VALUES ('vzduch', 2,1);

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
VALUES (4, 2);
