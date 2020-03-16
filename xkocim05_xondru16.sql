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
DROP kuzelnik;
DROP suboj;
DROP miesto_magie;
DROP grimoar;
DROP synergia_element;
DROP historia_grimoar;


----------- CREATE TABLES -----------
-- TODO veľkosti dát v zátvorke
CREATE TABLE kuzelnik
(
    id_kuzelnik INT           NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    meno        VARCHAR(255)  NOT NULL,
    mana        INT           NOT NULL, -- TODO nezáporné
    uroven      INT(3)        NOT NULL
);

CREATE TABLE suboj
(
    id_suboj    INT           NOT NULL  GENERATED ALWAYS AS IDENTITY  PRIMARY KEY,
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

CREATE TABLE miesto_magie
(
    id_miesto   INT           NOT NULL GENERATED ALWAYS AS IDENTITY  PRIMARY KEY,
    suradnica_X   INT NOT NULL, -- TODO check kladné
    suradnica_Y   INT NOT NULL,  -- TODO check kladné
    suradnica_Z   INT NOT NULL,
    velkost_presakovania INT  NOT NULL, -- TODO check kladné default 1?
    id_element    INT NOT NULL,
    CONSTRAINT id_miesto_element_FK
            FOREIGN KEY (id_element)
            REFERENCES element(id_element)
);

CREATE TABLE grimoar
(
    id_grimoar  INT            NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    magia       VARCHAR(50)    NOT NULL,
    id_predmet  INT            NOT NULL,
    id_element  INT            NOT NULL,
    CONSTRAINT id_predmet_FK
            FOREIGN KEY (id_predmet)
            REFERENCES predmet(id_predmet),
    CONSTRAINT id_prim_element_FK
            FOREIGN KEY (id_element)
            REFERENCES element(id_elemnt)
);

CREATE TABLE synergia_element
(
    id_element    INT    NOT NULL,
    id_kuzelnik   INT    NOT NULL,
    CONSTRAINT id_synergia_element_FK
            FOREIGN KEY (id_element)
            REFERENCES element(id_elemnt),
    CONSTRAINT id_synergia_kuzelnik_FK
            FOREIGN KEY (id_kuzelnik)
            REFERENCES kuzelnik(id_kuzelnik)
);

CREATE TABLE historia_grimoar
(
    id_kuzelnik     INT    NOT NULL,
    id_grimoar      INT    NOT NULL,
    CONSTRAINT id_majitel_FK
            FOREIGN KEY (id_kuzelnik)
            REFERENCES kuzelnik(id_kuzelnik),
    CONSTRAINT id_grimoar_FK
            FOREIGN KEY (id_grimoar)
            REFERENCES grimoar(id_grimoar)
);


---------------------------
----------- DATA ----------
---------------------------
--- SQL index from 1 ------

-------- DATA kuzelnik -------
INSERT INTO kuzelnik(meno,mana,uroven)
VALUES ('Dumbledore',2001,99);

INSERT INTO kuzelnik(meno,mana,uroven)
VALUES ('Harry Potter', 1560, 42);

INSERT INTO kuzelnik(meno,mana,uroven)
VALUES ('Voldemort', 1580, 65);

INSERT INTO kuzelnik(meno, mana,uroven)
VALUES ('Hermiona', 1600, 50);

INSERT INTO kuzelnik(meno, mana, uroven)
VALUES ('Giny', 1021, 30);

---------- DATA suboj -------
INSERT INTO suboj(nazov, id_vyzyvatel, id_super, id_vitaz)
VALUES ('SUBOJ_01', 1,3,1);

INSERT INTO suboj(nazov, id_vyzyvatel, id_super, id_vitaz)
VALUES ('SUBOJ_02', 2,4,4);

INSERT INTO suboj(nazov, id_vyzyvatel, id_super, id_vitaz)
VALUES ('SUBOJ_03', 4,5,4);

---------- DATA miesto magie -----
INSERT INTO miesto_magie( suradnica_x, suradnica_y, suradnica_z, velkost_presakovania, id_element)
VALUES (12, 189,-18, 10, 1);

INSERT INTO miesto_magie(suradnica_x, suradnica_y, suradnica_z, velkost_presakovania, id_element)
VALUES (1289, 42, 1987, 47, 2);

INSERT INTO miesto_magie(suradnica_x, suradnica_y, suradnica_z, velkost_presakovania, id_element)
VALUES (74982,12785,-1745,1);

----------- DATA grimoar ------
INSERT INTO grimoar(magia, id_predmet, id_element)
VALUES ('voda', 1, 1);

INSERT INTO grimoar(magia, id_predmet, id_element)
VALUES ('vzduch', 2,1);

---------- DATA synergia element ----
INSERT INTO synergia_element(id_element, id_kuzelnik)
VALUES (1,4);

INSERT INTO synergia_element(id_element, id_kuzelnik)
VALUES (1,1);

INSERT INTO synergia_element(id_element, id_kuzelnik)
VALUES (2, 2);

----------- DATA historia grimoar ---
INSERT INTO historia_grimoar(id_kuzelnik, id_grimoar)
VALUES (1,1);

INSERT INTO historia_grimoar(id_kuzelnik, id_grimoar)
VALUES (2, 1);

INSERT INTO historia_grimoar(id_kuzelnik, id_grimoar)
VALUES (4, 2);