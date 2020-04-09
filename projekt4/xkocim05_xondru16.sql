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
----------- DELETE existing TABLES ------
DROP TABLE magician CASCADE CONSTRAINTS ;
DROP TABLE history_battles CASCADE CONSTRAINTS ;
DROP TABLE element CASCADE CONSTRAINTS ;
DROP TABLE magical_place CASCADE CONSTRAINTS ;
DROP TABLE item CASCADE CONSTRAINTS ;
DROP TABLE synergy_element CASCADE CONSTRAINTS ;
DROP TABLE history_grimoar CASCADE CONSTRAINTS ;
DROP TABLE spells_grimoar CASCADE CONSTRAINTS ;
DROP TABLE spell CASCADE CONSTRAINTS ;
DROP TABLE side_elements_spell CASCADE CONSTRAINTS ;
DROP TABLE active_grimoar CASCADE CONSTRAINTS ;

----------- CREATE TABLES -----------

CREATE TABLE element
(
    id_element INT      GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    name       VARCHAR(255) NOT NULL UNIQUE,
    color_of_magic VARCHAR(255) NOT NULL,
    specialization VARCHAR(255) NOT NULL
);

CREATE TABLE spell
(
    id_spell INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    hardness_of_casting INT NOT NULL CHECK ( hardness_of_casting >= 0 ),
    type VARCHAR(255) NOT NULL,
    strength INT NOT NULL CHECK ( strength >= 0 ),
    id_prim_element INT NOT NULL,
    CONSTRAINT id_prime_element_FK_S
        FOREIGN KEY (id_prim_element)
        REFERENCES element(id_element)
);

CREATE TABLE magician
(
    login       VARCHAR(255)  NOT NULL  PRIMARY KEY,
    password       VARCHAR(255)  NOT NULL CHECK(REGEXP_LIKE(password, '.*[A-Z]+.*[0-9]+.*')),
    name        VARCHAR(255)  NOT NULL,
    mana        INT           NOT NULL CHECK ( mana >= 0 ),
    level_magic      VARCHAR(255)  NOT NULL
);

CREATE TABLE item
(
    id_item INT      GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    login_magician VARCHAR(255) DEFAULT NULL,
    name       VARCHAR(255) NOT NULL,
    type        VARCHAR(255) NOT NULL CHECK ( type = 'grimoar' or type = 'scroll' ),
    magic_grimoar INT,
    id_grimoar_element INT,
    id_spell_scroll INT,

    CHECK (
        (type = 'grimoar' and magic_grimoar >= 0 and id_grimoar_element is not NULL) or
        (type = 'scroll' and id_spell_scroll is not NULL)
    ),

    CONSTRAINT id_spell_FK_SCROLL
        FOREIGN KEY (id_spell_scroll)
        REFERENCES spell(id_spell),
    CONSTRAINT login_magician_FK_I
        FOREIGN KEY(login_magician)
        REFERENCES magician(login),
    CONSTRAINT id_prim_element_FK_I
        FOREIGN KEY (id_grimoar_element)
        REFERENCES element(id_element)
);

CREATE TABLE active_grimoar
(
    login_magician           VARCHAR(255) NOT NULL,
    active_grimoar INT  DEFAULT NULL,
    CONSTRAINT id_active_grimoar_FK
            FOREIGN KEY (active_grimoar)
            REFERENCES item(id_item),
    CONSTRAINT login_magician_FK_AG
        FOREIGN KEY(login_magician)
        REFERENCES magician(login)
);

CREATE TABLE history_battles
(
    id_battle    INT           GENERATED ALWAYS AS IDENTITY  NOT NULL PRIMARY KEY,
    login_challenger VARCHAR(255) NOT NULL,
    login_opponent     VARCHAR(255) DEFAULT NULL,
    login_winner     VARCHAR(255) DEFAULT NULL,
    date_battle        DATE DEFAULT CURRENT_DATE,
    CONSTRAINT  login_challenger_FK
            FOREIGN KEY (login_challenger)
            REFERENCES magician(login),
    CONSTRAINT  login_opponent_FK
            FOREIGN KEY (login_opponent)
            REFERENCES  magician(login),
    CONSTRAINT  login_winner_FK
            FOREIGN KEY (login_winner)
            REFERENCES magician(login)
);

CREATE TABLE magical_place
(
    id_place   INT           GENERATED ALWAYS AS IDENTITY NOT NULL  PRIMARY KEY,
    coordinate_X   INT NOT NULL CHECK ( coordinate_X>=0 ),
    coordinate_Y   INT NOT NULL CHECK (  coordinate_Y>=0 ),
    coordinate_Z   INT NOT NULL,
    size_leaking INT  DEFAULT 1 CHECK (size_leaking>0),
    id_place_element   INT NOT NULL,
    CONSTRAINT id_place_element_FK_MP
            FOREIGN KEY (id_place_element)
            REFERENCES element(id_element)
);

CREATE TABLE synergy_element
(
    id_synergy_element    INT    NOT NULL,
    login_synergy_magician  VARCHAR(255)    NOT NULL,
    CONSTRAINT id_synergy_element_FK_SE
            FOREIGN KEY (id_synergy_element)
            REFERENCES element(id_element),
    CONSTRAINT login_synergy_magician_FK_SE
            FOREIGN KEY (login_synergy_magician)
            REFERENCES magician(login)
);

CREATE TABLE history_grimoar
(
    login_history_magician     VARCHAR(255)    NOT NULL,
    id_history_grimoar      INT    NOT NULL,
    started_owning_date      DATE NOT NULL,
    stopped_owning_date      DATE DEFAULT NULL,
    CONSTRAINT login_owner_FK_HG
            FOREIGN KEY (login_history_magician)
            REFERENCES magician(login),
    CONSTRAINT id_grimoar_FK_HG
            FOREIGN KEY (id_history_grimoar)
            REFERENCES item(id_item),
    UNIQUE (login_history_magician, id_history_grimoar)
);

CREATE TABLE spells_grimoar
(
    id INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    id_grimoar NOT NULL,
    id_spell NOT NULL,
    CONSTRAINT id_grimoar_FK_SG
            FOREIGN KEY (id_grimoar)
            REFERENCES item(id_item),
    CONSTRAINT id_spell_FK_SG
            FOREIGN KEY (id_spell)
            REFERENCES spell(id_spell)
);

CREATE TABLE side_elements_spell
(
    id_element INT NOT NULL,
    id_spell INT NOT NULL,
    CONSTRAINT id_element_FK_SES FOREIGN KEY (id_element) REFERENCES element(id_element),
    CONSTRAINT id_spell_FK_IN_SES FOREIGN KEY (id_spell) REFERENCES spell(id_spell)
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
CREATE OR REPLACE PROCEDURE win_rate (kuzelnik_meno IN VARCHAR ) IS
    CURSOR suboj_kuzelnik IS SELECT * FROM suboj;
    CURSOR kuzelnici IS SELECT id_kuzelnik FROM kuzelnik WHERE kuzelnik_meno = meno;
    TYPE suboj_pocet IS TABLE OF NUMBER INDEX BY VARCHAR2(255);
    pocet_subojov suboj_pocet := suboj_pocet();
    pocet_vyhier suboj_pocet := suboj_pocet();
    win_rate_kuzelnik NUMBER;
    suboj_row suboj%rowtype;
BEGIN
    FOR kuzelnik in kuzelnici LOOP
        pocet_subojov(kuzelnik.id_kuzelnik) := 0;
        pocet_vyhier(kuzelnik.id_kuzelnik) := 0;
    end loop;

    OPEN suboj_kuzelnik;
    LOOP
        FETCH suboj_kuzelnik INTO suboj_row;
        EXIT WHEN suboj_kuzelnik%NOTFOUND;
        FOR kuzelnik in kuzelnici LOOP
        --spočíta počet súbojov v ktorých sa kúzelník zúčastnil --
        IF suboj_row.id_vyzyvatel = kuzelnik.id_kuzelnik OR suboj_row.id_super = kuzelnik.id_kuzelnik THEN
           pocet_subojov(kuzelnik.id_kuzelnik) := pocet_subojov(kuzelnik.id_kuzelnik) + 1;
        END IF;

        --spočíta počet súbojov, ktoré kúzelník vyhral
        IF suboj_row.id_vitaz = kuzelnik.id_kuzelnik THEN
           pocet_vyhier(kuzelnik.id_kuzelnik) := pocet_vyhier(kuzelnik.id_kuzelnik) + 1;
        END If;
        end loop;
    END LOOP;
    CLOSE suboj_kuzelnik;

    for kuzelnik in kuzelnici LOOP
        IF pocet_subojov(kuzelnik.id_kuzelnik) = 0 then
            DBMS_OUTPUT.PUT_LINE('Kuzelnik s id ' || kuzelnik.id_kuzelnik || ' a s menom ' || kuzelnik_meno || ' nehrál žiadny súboj!');
            CONTINUE;
        end if;

        if pocet_vyhier(kuzelnik.id_kuzelnik) = 0 then
            win_rate_kuzelnik := 0;
            DBMS_OUTPUT.PUT_LINE('Kúzelník ' || kuzelnik_meno || ' má win-rate: ' || TO_CHAR(win_rate_kuzelnik) || '%.' );
        else
            win_rate_kuzelnik := pocet_vyhier(kuzelnik.id_kuzelnik) / pocet_subojov(kuzelnik.id_kuzelnik) * 100;
            DBMS_OUTPUT.PUT_LINE('Kúzelník s id '|| kuzelnik.id_kuzelnik || ' a s menom ' || kuzelnik_meno || ' má win-rate: ' || TO_CHAR(win_rate_kuzelnik, '999.99') || '%.' );
        end if;
    end loop;

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

-------- DATA magician -------
INSERT INTO magician(login, password, name, mana, level_magic)
VALUES ('Dumbo12','HateVoldemort23','Dumbledore',2001, 'S');

INSERT INTO magician(login, password, name, mana, level_magic)
VALUES ('Harry19', 'heSlo123','HarryPotter', 1560, 'A');

INSERT INTO magician(login, password, name, mana, level_magic)
VALUES ('Voldi14', 'morT1sDeA1h','Voldemort', 1580, 'SS');

INSERT INTO magician(login, password, name, mana, level_magic)
VALUES ('Hermiona99', 'lovesB00ks','Hermiona', 1600,  'D');

INSERT INTO magician(login, password, name, mana, level_magic)
VALUES ('GinyWeasley', 'tooManyBr0thers','Giny', 1021, 'B');

---------- DATA history of battles -------
INSERT INTO history_battles(login_challenger, login_opponent, login_winner)
VALUES ('Dumbo12', 'Harry19', 'Dumbo12');

INSERT INTO history_battles(login_challenger, login_opponent, login_winner)
VALUES ('Harry19', 'Hermiona99', 'Hermiona99');

INSERT INTO history_battles(login_challenger, login_opponent, login_winner)
VALUES ('Hermiona99', 'GinyWeasley', 'Hermiona99');

---------- DATA element -----
INSERT INTO element(name, color_of_magic, specialization)
VALUES ('water', 'blue', 'support');

INSERT INTO element(name, color_of_magic, specialization)
VALUES ('fire', 'red', 'attack');

INSERT INTO element(name, color_of_magic, specialization)
VALUES ('air', 'white', 'defence');

---------- DATA place of magic -----
INSERT INTO magical_place(coordinate_X, coordinate_Y, coordinate_Z, size_leaking, id_place_element)
VALUES (12, 189, -18, 10, 1);

INSERT INTO magical_place(coordinate_X, coordinate_Y, coordinate_Z, size_leaking, id_place_element)
VALUES (1289, 42, 1987, 44, 2);

INSERT INTO magical_place(coordinate_X, coordinate_Y, coordinate_Z, size_leaking, id_place_element)
VALUES (74982, 12785, -1745, 1, 1);

---------- DATA spell -----
INSERT INTO spell(name, hardness_of_casting, type, strength, id_prim_element)
VALUES ('Avadagedabra', 10, 'attack', '5000', 2);

INSERT INTO spell(name, hardness_of_casting, type, strength, id_prim_element)
VALUES ('Wingardium Leviosa ', 2, 'defence', '500', 3);

INSERT INTO spell(name, hardness_of_casting, type, strength, id_prim_element)
VALUES ('aqua ', 3, 'attack', '1000', 1);

---------- DATA item -----
INSERT INTO item(name, type, magic_grimoar, id_grimoar_element)
VALUES ('GRIM01', 'grimoar', 40, 1);

INSERT INTO item(name, type, magic_grimoar, id_grimoar_element)
VALUES ('GRIM02', 'grimoar', 50, 2);

INSERT INTO item(name, login_magician,type, magic_grimoar, id_grimoar_element)
VALUES ('GRIM03', 'Voldi14', 'grimoar', 100, 3);

INSERT INTO item(name, login_magician, type, id_spell_scroll)
VALUES ('Scroll1', 'Hermiona99', 'scroll', 1);

INSERT INTO item(name, login_magician, type, id_spell_scroll)
VALUES ('Scroll2', 'GinyWeasley', 'scroll', 2);

INSERT INTO item(name, login_magician, type, id_spell_scroll)
VALUES ('Death waits for you', 'Voldi14', 'scroll', 3);

---------- DATA active grimoars -----

INSERT INTO active_grimoar(login_magician)
VALUES ('Voldi14');

INSERT INTO active_grimoar(login_magician)
VALUES ('Harry19');

INSERT INTO active_grimoar(login_magician)
VALUES ('Dumbo12');

INSERT INTO active_grimoar(login_magician)
VALUES ('GinyWeasley');

INSERT INTO active_grimoar(login_magician, active_grimoar)
VALUES ('Hermiona99', 2);

---------- DATA synergy element ----
INSERT INTO synergy_element(id_synergy_element, login_synergy_magician)
VALUES (1,'Hermiona99');

INSERT INTO synergy_element(id_synergy_element, login_synergy_magician)
VALUES (1,'Dumbo12');

INSERT INTO synergy_element(id_synergy_element, login_synergy_magician)
VALUES (2, 'Harry19');

----------- DATA history grimoar ---
INSERT INTO history_grimoar(login_history_magician, id_history_grimoar, started_owning_date, stopped_owning_date)
VALUES ('Dumbo12',1, TO_DATE( '2020-03-01 15:15:00', 'YYYY-MM-DD HH24:MI:SS' ), TO_DATE( '2020-03-27 15:15:00', 'YYYY-MM-DD HH24:MI:SS' ));

INSERT INTO history_grimoar(login_history_magician, id_history_grimoar, started_owning_date, stopped_owning_date)
VALUES ('Harry19', 1, TO_DATE ('2020-03-27 18:10:26', 'YYYY-MM-DD HH24:MI:SS' ), TO_DATE ('2020-03-28 14:17:00', 'YYYY-MM-DD HH24:MI:SS' ));

INSERT INTO history_grimoar(login_history_magician, id_history_grimoar, started_owning_date, stopped_owning_date)
VALUES ('Harry19', 2, TO_DATE ('2020-02-10 17:59:25', 'YYYY-MM-DD HH24:MI:SS' ),TO_DATE ('2020-02-15 10:10:10', 'YYYY-MM-DD HH24:MI:SS' ));

INSERT INTO history_grimoar(login_history_magician, id_history_grimoar, started_owning_date, stopped_owning_date)
VALUES ('Harry19', 3, TO_DATE ('2020-02-01 02:06:08', 'YYYY-MM-DD HH24:MI:SS' ), TO_DATE ('2020-02-10 12:12:12', 'YYYY-MM-DD HH24:MI:SS' ));

INSERT INTO history_grimoar(login_history_magician, id_history_grimoar, started_owning_date)
VALUES ('Hermiona99', 2, TO_DATE ('2020-02-20 14:14:58', 'YYYY-MM-DD HH24:MI:SS' ));

INSERT INTO history_grimoar(login_history_magician, id_history_grimoar, started_owning_date)
VALUES ('Hermiona99', 1, TO_DATE ('2020-03-29 00:00:00' , 'YYYY-MM-DD HH24:MI:SS' ));

INSERT INTO history_grimoar(login_history_magician, id_history_grimoar, started_owning_date, stopped_owning_date)
VALUES ('Hermiona99', 3, TO_DATE ('2020-02-15 15:45:58', 'YYYY-MM-DD HH24:MI:SS' ), TO_DATE ('2020-02-23 18:25:48', 'YYYY-MM-DD HH24:MI:SS' ));

---------- DATA spells in grimoar -----
INSERT INTO spells_grimoar(id_grimoar, id_spell)
VALUES (1, 1);

INSERT INTO spells_grimoar(id_grimoar, id_spell)
VALUES (1, 2);

INSERT INTO spells_grimoar(id_grimoar, id_spell)
VALUES (3, 3);

INSERT INTO spells_grimoar(id_grimoar, id_spell)
VALUES (2, 2);

INSERT INTO spells_grimoar(id_grimoar, id_spell)
VALUES (2, 1);

---------- DATA side elements in spell -----
INSERT INTO side_elements_spell(id_element, id_spell) VALUES (3, 1);

INSERT INTO side_elements_spell(id_element, id_spell) VALUES (1, 3);


-----------------------------------------------
------ Predvedenie funkcie triggerov ----------
-----------------------------------------------
SELECT * from magician;
INSERT INTO magician(meno, mana, uroven)
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
    spells_in_grimoar(1);
END;

------------------------------------------------
---  Definícia prístupových práv pre druhého ---
---          člena týmu: xkocim05            ---
------------------------------------------------
GRANT ALL ON magician to xondru16;
GRANT ALL ON history_battles to xondru16;
GRANT ALL ON element to xondru16;
GRANT ALL ON magical_place to xondru16;
GRANT ALL ON item to xondru16;
GRANT ALL ON history_grimoar to xondru16;
GRANT ALL ON synergy_element to xondru16;
GRANT ALL ON spells_grimoar to xondru16;
GRANT ALL ON side_elements_spell to xondru16;
GRANT ALL ON spell to xondru16;

GRANT EXECUTE ON win_rate to xondru16;
GRANT EXECUTE ON spells_in_grimoar to xondru16;
