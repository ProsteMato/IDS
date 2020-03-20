/**
* @file xkocim05_xondru16.sql
*
* @brief IDS project, part 2  - Svet mágie
*        SQL script for creating basic object of database's scheme 
*
* @authors Martin Koči          <xkocim05@stud.fit.vutbr.cz> 
*          Magdaléna Ondrušková <xondru16@stud.fit.vutbr.cz>
*
* @date  19/03/2020
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
DROP SEQUENCE kuzelnik_sequence;

----------- CREATE TABLES -----------
CREATE TABLE kuzelnik
(
    id_kuzelnik INT           PRIMARY KEY, -- increasing using trigger
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
    id_vlastni          INT            DEFAULT NULL,
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
    UNIQUE (id_historia_grimoar, id_historia_kuzelnik)
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

------------------------------------------
--- Automatické generovanie hodnôt PK ----
---        pre tabuľku kuznik          ---
-----------   TRIGGER 1     --------------
------------------------------------------
CREATE SEQUENCE kuzelnik_sequence
    START WITH 1
    INCREMENT BY 1;
CREATE OR REPLACE TRIGGER kuzelnik_gen_id
    BEFORE INSERT ON kuzelnik
    FOR EACH ROW
    BEGIN
        :NEW.id_kuzelnik := kuzelnik_sequence.nextval;
    END;
/

------------------------------------------
----  Trigger na ukladanie histórie  -----
----           grimoárov             -----
-----------   TRIGGER 2     --------------
------------------------------------------
CREATE OR REPLACE TRIGGER grimoar_history
    AFTER INSERT OR UPDATE ON grimoar
    FOR EACH ROW
    BEGIN
        IF :NEW.id_vlastni IS NOT NULL
        THEN
            INSERT INTO historia_grimoar(id_historia_kuzelnik, id_historia_grimoar)
            VALUES (:NEW.id_vlastni, :NEW.id_grimoar);
        END IF;
    EXCEPTION
        WHEN others then
            dbms_output.put_line('Some error message you can build here or up above');
    END;
/
------------------------------------------------
------- Procedúra na vypočítanie win-rate ------
------- kúzelníka, spolu s ošetrením chýb ------
------------------------------------------------
CREATE OR REPLACE PROCEDURE win_rate (kuzelnik_meno IN VARCHAR ) AS
    CURSOR suboj_kuzelnik IS SELECT id_vyzyvatel,id_super,id_vitaz FROM suboj;
    pocet_subojov INT;
    pocet_vyhier INT;
    pocet_kuzelnikov INT;
    win_rate_kuzelnik NUMBER;
   -- TYPE kuzelnik_id_table IS TABLE OF kuzelnik.id_kuzelnik%TYPE ;
   -- kuzelnik_id kuzelnik_id_table;
    kuzelnik_id INT;
    vyzyvatel_id suboj.id_vyzyvatel%TYPE;
    super_id suboj.id_super%TYPE;
    suboj_vitaz suboj.id_vitaz%TYPE;
BEGIN
    pocet_subojov :=0;
    pocet_vyhier :=0;

    SELECT COUNT(id_kuzelnik) into pocet_kuzelnikov
    FROM kuzelnik
    WHERE kuzelnik_meno = meno;

    if pocet_kuzelnikov != 1 then
        DBMS_OUTPUT.PUT_LINE('Viac kúzelníkov s rovnakým menom!  ' || TO_CHAR(pocet_kuzelnikov));
    end if;


    -- ziskanie ID kúzelníka, ktorého win-rate rátame --
    SELECT id_kuzelnik into kuzelnik_id
    FROM kuzelnik
    WHERE kuzelnik_meno = meno;

    OPEN suboj_kuzelnik;
    LOOP
        FETCH suboj_kuzelnik INTO  vyzyvatel_id, super_id, suboj_vitaz;
        EXIT WHEN suboj_kuzelnik%NOTFOUND;  -- ukončujúca podmienka cyklu --

        -- spočíta počet súbojov v ktorých sa kúzelník zúčastnil --
        IF vyzyvatel_id = kuzelnik_id OR super_id = kuzelnik_id THEN
            pocet_subojov := pocet_subojov +1;
        END IF ;

        -- spočíta počet súbojov, ktoré kúzelník vyhral
        IF suboj_vitaz = kuzelnik_id THEN
            pocet_vyhier := pocet_vyhier +1;
        END IF;
    END LOOP;
    CLOSE suboj_kuzelnik;

    IF pocet_subojov = 0 then
        RAISE NO_DATA_FOUND;
    end if;

    if pocet_vyhier = 0 then
        win_rate_kuzelnik := 0;
         DBMS_OUTPUT.PUT_LINE('Kúzeník ' || kuzelnik_meno || ' má win-rate: ' || TO_CHAR(win_rate_kuzelnik) || '%.' );
    else
        win_rate_kuzelnik := pocet_vyhier / pocet_subojov * 100;
        DBMS_OUTPUT.PUT_LINE('Kúzeník ' || kuzelnik_meno || ' má win-rate: ' || TO_CHAR(win_rate_kuzelnik, '999.99') || '%.' );
    end if;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Žiadny súboj s daným kúzelníkom neexistuje.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Some other error.');
END;
/


------------------------------------------------------------------------
------- Procedúra na ziskanie počtu jednotlivch kúziel v grimoáry ------
-------            použitie kurzosu spolu s výnimkami             ------
------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE kuzla_v_grimoare (id_grimoaru IN INT) AS
    CURSOR kuzla_v_grim IS SELECT id_kuzlo from kuzla_v_grimoaroch where id_grimoar = id_grimoaru;
    TYPE count_kuzlo IS TABLE OF NUMBER INDEX BY VARCHAR2(255);
    kuzlo_id kuzla_v_grimoaroch.id_kuzlo%TYPE;
    count_kuziel count_kuzlo := count_kuzlo();
    grimoar_name VARCHAR2(255);
    nazov_kuzla VARCHAR2(255);
BEGIN
    SELECT predmet.nazov INTO grimoar_name FROM predmet
    JOIN grimoar ON grimoar.id_grimoar_predmet = predmet.id_predmet
    WHERE grimoar.id_grimoar = id_grimoaru;
    OPEN kuzla_v_grim;
    LOOP
        FETCH kuzla_v_grim into kuzlo_id;
        EXIT WHEN kuzla_v_grim%notfound;
        SELECT kuzlo.nazov into nazov_kuzla from kuzlo where id_kuzlo = kuzlo_id;
        if (count_kuziel.EXISTS (nazov_kuzla)) then
            count_kuziel(nazov_kuzla) := count_kuziel(nazov_kuzla) + 1;
        else
            count_kuziel(nazov_kuzla) := 1;
        end if;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Grimoár s id: ' || id_grimoaru || ' s nazvom: ' || grimoar_name || ' obsahuje kúzlá');
    nazov_kuzla := count_kuziel.FIRST;
    WHILE nazov_kuzla IS NOT NULL LOOP
        DBMS_OUTPUT.PUT_LINE(count_kuziel(nazov_kuzla) || 'x ' || nazov_kuzla);
        nazov_kuzla := count_kuziel.NEXT(nazov_kuzla);
    END LOOP;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Grimoár s id: ' || id_grimoaru || ' neexistuje!');
END;


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

INSERT INTO suboj(nazov, id_vyzyvatel, id_super, id_vitaz)
VALUES ('SUBOJ_04',2,4,2);

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
INSERT INTO grimoar(magia, id_grimoar_predmet, id_grimoar_element, id_vlastni)
VALUES ('voda', 1, 1, 1);

INSERT INTO grimoar(magia, id_grimoar_predmet, id_grimoar_element, id_vlastni)
VALUES ('vzduch', 2, 3, 5);

INSERT INTO grimoar(magia, id_grimoar_predmet, id_grimoar_element, id_vlastni)
VALUES ('oheň', 3, 2, 4);

INSERT INTO grimoar(magia, id_grimoar_predmet, id_grimoar_element)
VALUES ('oheň', 3, 2);

UPDATE grimoar
SET id_vlastni = 4
WHERE id_grimoar = 3;

UPDATE grimoar
SET id_vlastni = 4
WHERE id_grimoar = 1;

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
VALUES (1,4);

INSERT INTO synergia_element(id_synergia_element, id_synergia_kuzelnik)
VALUES (1,1);

INSERT INTO synergia_element(id_synergia_element, id_synergia_kuzelnik)
VALUES (2, 2);

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


-----------------------------------------------
------ Predvedenie funkcie triggerov ----------
-----------------------------------------------
SELECT * from kuzelnik;
INSERT INTO kuzelnik(meno, mana, uroven)
VALUES ('Ron Weasley', 158, 'S');
SELECT * from kuzelnik;

SELECT * from historia_grimoar;
SELECT * from suboj;
-------------------------------------------------
-----      Príklad zavolania procedúry     ------
-----   win-rate pre kúzelníka 'Hermiona'  ------
-------------------------------------------------
BEGIN
    win_rate('Hermiona');
END;


-----------------------------------------------------
-----      Príklad zavolania procedúry         ------
-----   kuzla_v_grimoare pre grimoar s id '1'  ------
-----------------------------------------------------
BEGIN
    kuzla_v_grimoare(1);
END;

------------------------------------------------
---  Definícia prístupových práv pre druhého ---
---          člena týmu: xkocim05            ---
------------------------------------------------
GRANT ALL ON kuzelnik to xkocim05;
GRANT ALL ON suboj to xkocim05;
GRANT ALL ON element to xkocim05;
GRANT ALL ON miesto_magie to xkocim05;
GRANT ALL ON predmet to xkocim05;
GRANT ALL ON grimoar to xkocim05;
GRANT ALL ON zvitok to xkocim05;
GRANT ALL ON historia_grimoar to xkocim05;
GRANT ALL ON synergia_element to xkocim05;
GRANT ALL ON kuzla_v_grimoaroch to xkocim05;
GRANT ALL ON vedlajsie_elementy_v_kuzle to xkocim05;
GRANT ALL ON kuzlo to xkocim05;

GRANT  EXECUTE ON win_rate to xkocim05;
