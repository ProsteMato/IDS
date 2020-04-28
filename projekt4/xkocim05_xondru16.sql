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

DROP SEQUENCE element_sequence ;
DROP MATERIALIZED VIEW spells_with_primary_element_air ;
DROP INDEX magician_ind;
DROP INDEX history_grim_ind;

----------- CREATE TABLES -----------

CREATE TABLE element
(
    id_element INT      PRIMARY KEY,
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
    level_magic      VARCHAR(255)  NOT NULL CHECK (REGEXP_LIKE(level_magic, 'E|D|C|B|A|S|SS'))
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
    login_magician           VARCHAR(255) NOT NULL PRIMARY KEY ,
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
    id_synergy_element INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    id_synergy_element_FK    INT    NOT NULL,
    login_synergy_magician  VARCHAR(255)    NOT NULL,
    CONSTRAINT id_synergy_element_FK_SE
            FOREIGN KEY (id_synergy_element_FK)
            REFERENCES element(id_element),
    CONSTRAINT login_synergy_magician_FK_SE
            FOREIGN KEY (login_synergy_magician)
            REFERENCES magician(login),
    UNIQUE (id_synergy_element_FK, login_synergy_magician)
);

CREATE TABLE history_grimoar
(
    id_history_grimoar INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    login_history_magician     VARCHAR(255)    NOT NULL,
    id_history_grimoar_FK      INT    NOT NULL,
    started_owning_date      DATE NOT NULL,
    stopped_owning_date      DATE DEFAULT NULL,
    CONSTRAINT login_owner_FK_HG
            FOREIGN KEY (login_history_magician)
            REFERENCES magician(login),
    CONSTRAINT id_grimoar_FK_HG
            FOREIGN KEY (id_history_grimoar_FK)
            REFERENCES item(id_item)
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
    CONSTRAINT id_spell_FK_IN_SES FOREIGN KEY (id_spell) REFERENCES spell(id_spell),
    PRIMARY KEY (id_spell, id_element)
);


------------------------------------------
--- Automatic generation of PK's values --
---        for table element           ---
-----------     TRIGGER 1     ------------
------------------------------------------
CREATE SEQUENCE element_sequence
    START WITH 1
    INCREMENT BY 1;
CREATE OR REPLACE TRIGGER element_gen_id
    BEFORE INSERT ON element
    FOR EACH ROW
    BEGIN
        :NEW.id_element := element_sequence.nextval;
    END;
/

------------------------------------------
----  Trigger for saving history of  -----
----           grimoars              -----
-----------   TRIGGER 2     --------------
------------------------------------------
CREATE OR REPLACE TRIGGER grimoar_history
    AFTER INSERT OR UPDATE ON item
    FOR EACH ROW
    BEGIN
        IF INSERTING THEN
            IF :NEW.login_magician IS NOT NULL AND :NEW.type = 'grimoar'
            THEN
                INSERT INTO history_grimoar(login_history_magician, id_history_grimoar_FK, started_owning_date)
                VALUES (:NEW.login_magician, :NEW.id_item, CURRENT_DATE);
            END IF;
        END IF;

        IF UPDATING THEN
            IF :NEW.login_magician IS NOT NULL AND :NEW.login_magician != :OLD.login_magician
            THEN
                UPDATE history_grimoar
                SET stopped_owning_date = CURRENT_DATE
                WHERE login_history_magician = :OLD.login_magician AND :OLD.id_item = id_history_grimoar;
                INSERT INTO history_grimoar(login_history_magician, id_history_grimoar_FK, started_owning_date)
                VALUES (:NEW.login_magician, :NEW.id_item, CURRENT_DATE);

            ELSIF :NEW.login_magician IS NULL AND :OLD.login_magician IS NOT NULL
            THEN
                UPDATE history_grimoar
                SET stopped_owning_date = CURRENT_DATE
                WHERE login_history_magician = :OLD.login_magician AND :OLD.id_item = id_history_grimoar;
            END IF;
        END IF;
    EXCEPTION
        WHEN others then
            dbms_output.put_line('Some error happened!');
    END;
/

--------------------------------------------------
--   Procedure that counts win rate of magician --
--------------------------------------------------
CREATE OR REPLACE PROCEDURE win_rate (name_of_magician IN VARCHAR ) IS
    CURSOR battle_magician IS SELECT * FROM history_battles;
    CURSOR magicians IS SELECT magician.login FROM magician WHERE name_of_magician = magician.name;
    TYPE number_of_battles IS TABLE OF NUMBER INDEX BY VARCHAR2(255);
    number_of_battles_magician number_of_battles := number_of_battles();
    number_of_wins number_of_battles := number_of_battles();
    win_rate_magician NUMBER;
    battle_row history_battles%rowtype;
BEGIN
    FOR magician in magicians LOOP
        number_of_battles_magician(magician.login) := 0;
        number_of_wins(magician.login) := 0;
    end loop;

    OPEN battle_magician;
    LOOP
        FETCH battle_magician INTO battle_row;
        EXIT WHEN battle_magician%NOTFOUND;
        FOR magician in magicians LOOP
        --counts number of battles that magician was a part of  --
        IF battle_row.login_challenger = magician.login OR battle_row.login_opponent = magician.login THEN
           number_of_battles_magician(magician.login) := number_of_battles_magician(magician.login) + 1;
        END IF;

        --counts number of battles that magician won
        IF battle_row.login_winner = magician.login THEN
           number_of_wins(magician.login) := number_of_wins(magician.login) + 1;
        END If;
        end loop;
    END LOOP;
    CLOSE battle_magician;

    for magician in magicians LOOP
        IF number_of_battles_magician(magician.login) = 0 then
            DBMS_OUTPUT.PUT_LINE('Magician with login ' || magician.login || ' and with name ' || name_of_magician
                                     || ' wasnt a part of any battle!');
            CONTINUE;
        end if;

        if number_of_wins(magician.login) = 0 then
            win_rate_magician := 0;
            DBMS_OUTPUT.PUT_LINE('Magician ' || name_of_magician || ' has win-rate: ' || TO_CHAR(win_rate_magician) || '%.' );
        else
            win_rate_magician := number_of_wins(magician.login) / number_of_battles_magician(magician.login) * 100;
            DBMS_OUTPUT.PUT_LINE('Magician with login ' || magician.login || ' and with name ' || name_of_magician
                                     || ' has win-rate: ' || TO_CHAR(win_rate_magician, '999.99') || '%.' );
        end if;
    end loop;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No data with given magician found.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Some other error.');
END;
/


------------------------------------------------------------------------
------- Procedure for displaying number of spells in grimoar      ------
------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE spells_in_grimoar (id_grimoaru IN INT) AS
    CURSOR kuzla_v_grim IS SELECT id_spell from spells_grimoar where id_grimoar = id_grimoaru;
    TYPE count_kuzlo IS TABLE OF NUMBER INDEX BY VARCHAR2(255);
    kuzlo_id spells_grimoar.id_spell%TYPE;
    count_kuziel count_kuzlo := count_kuzlo();
    grimoar_name VARCHAR2(255);
    nazov_kuzla VARCHAR2(255);
BEGIN
    SELECT item.name INTO grimoar_name FROM item
    WHERE item.id_item = id_grimoaru;
    OPEN kuzla_v_grim;
    LOOP
        FETCH kuzla_v_grim into kuzlo_id;
        EXIT WHEN kuzla_v_grim%notfound;
        SELECT spell.name into nazov_kuzla from spell where id_spell = kuzlo_id;
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
    CLOSE kuzla_v_grim;

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
VALUES ('Hermiona98', 'sdfsf99','Hermiona', 2000,  'E');

INSERT INTO magician(login, password, name, mana, level_magic)
VALUES ('Hermiona97', 'lovesBasda00ks','Hermiona', 2500,  'SS');

INSERT INTO magician(login, password, name, mana, level_magic)
VALUES ('Hermiona96', 'lovesssB00ks','Hermiona', 2400,  'S');

INSERT INTO magician(login, password, name, mana, level_magic)
VALUES ('Hermiona95', 'lovesaaaB00ks','Hermiona', 0800,  'A');

INSERT INTO magician(login, password, name, mana, level_magic)
VALUES ('GinyWeasley', 'tooManyBr0thers','Giny', 1021, 'B');

---------- DATA history of battles -------
INSERT INTO history_battles(login_challenger, login_opponent, login_winner)
VALUES ('Dumbo12', 'Harry19', 'Dumbo12');

INSERT INTO history_battles(login_challenger, login_opponent, login_winner)
VALUES ('Harry19', 'Hermiona99', 'Harry19');

INSERT INTO history_battles(login_challenger, login_opponent, login_winner)
VALUES ('Hermiona99', 'GinyWeasley', 'Hermiona99');

INSERT INTO history_battles(login_challenger, login_opponent, login_winner)
VALUES ('Hermiona99', 'GinyWeasley', 'GinyWeasley');

INSERT INTO history_battles(login_challenger, login_opponent, login_winner)
VALUES ('Dumbo12', 'Voldi14', 'Dumbo12');

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
VALUES ('Avadagedabra', 10, 'attack', 5000, 2);

INSERT INTO spell(name, hardness_of_casting, type, strength, id_prim_element)
VALUES ('Wingardium Leviosa ', 2, 'defence', 500, 3);

INSERT INTO spell(name, hardness_of_casting, type, strength, id_prim_element)
VALUES ('aqua ', 3, 'attack', 1000, 1);

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
INSERT INTO synergy_element(id_synergy_element_FK, login_synergy_magician)
VALUES (1,'Hermiona99');

INSERT INTO synergy_element(id_synergy_element_FK, login_synergy_magician)
VALUES (1,'Dumbo12');

INSERT INTO synergy_element(id_synergy_element_FK, login_synergy_magician)
VALUES (2, 'Harry19');

----------- DATA history grimoar ---
INSERT INTO history_grimoar(login_history_magician, id_history_grimoar_FK, started_owning_date, stopped_owning_date)
VALUES ('Dumbo12',1, TO_DATE( '2020-03-01 15:15:00', 'YYYY-MM-DD HH24:MI:SS' ), TO_DATE( '2020-03-27 15:15:00', 'YYYY-MM-DD HH24:MI:SS' ));

INSERT INTO history_grimoar(login_history_magician, id_history_grimoar_FK, started_owning_date, stopped_owning_date)
VALUES ('Harry19', 1, TO_DATE ('2020-03-27 18:10:26', 'YYYY-MM-DD HH24:MI:SS' ), TO_DATE ('2020-03-28 14:17:00', 'YYYY-MM-DD HH24:MI:SS' ));

INSERT INTO history_grimoar(login_history_magician, id_history_grimoar_FK, started_owning_date, stopped_owning_date)
VALUES ('Harry19', 2, TO_DATE ('2020-02-10 17:59:25', 'YYYY-MM-DD HH24:MI:SS' ),TO_DATE ('2020-02-15 10:10:10', 'YYYY-MM-DD HH24:MI:SS' ));

INSERT INTO history_grimoar(login_history_magician, id_history_grimoar_FK, started_owning_date, stopped_owning_date)
VALUES ('Harry19', 3, TO_DATE ('2020-02-01 02:06:08', 'YYYY-MM-DD HH24:MI:SS' ), TO_DATE ('2020-02-10 12:12:12', 'YYYY-MM-DD HH24:MI:SS' ));

INSERT INTO history_grimoar(login_history_magician, id_history_grimoar_FK, started_owning_date)
VALUES ('Hermiona99', 2, TO_DATE ('2020-02-20 14:14:58', 'YYYY-MM-DD HH24:MI:SS' ));

INSERT INTO history_grimoar(login_history_magician, id_history_grimoar_FK, started_owning_date)
VALUES ('Hermiona98', 1, TO_DATE ('2020-03-29 00:00:00' , 'YYYY-MM-DD HH24:MI:SS' ));

INSERT INTO history_grimoar(login_history_magician, id_history_grimoar_FK, started_owning_date)
VALUES ('Hermiona97', 3, TO_DATE ('2020-03-29 00:00:00' , 'YYYY-MM-DD HH24:MI:SS' ));

INSERT INTO history_grimoar(login_history_magician, id_history_grimoar_FK, started_owning_date, stopped_owning_date)
VALUES ('Hermiona99', 3, TO_DATE ('2020-02-15 15:45:58', 'YYYY-MM-DD HH24:MI:SS' ), TO_DATE ('2020-02-23 18:25:48', 'YYYY-MM-DD HH24:MI:SS' ));

UPDATE item
SET login_magician = 'Harry19'
WHERE id_item = 2;

SELECT * from history_grimoar;

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
------   Demonstration of triggers   ----------
-----------------------------------------------
SELECT * from element;
INSERT INTO element(name, color_of_magic, specialization)
VALUES ('earth', 'brown', 'attack');
SELECT * from element;

SELECT * from history_grimoar;
SELECT * from history_battles;
-------------------------------------------------
---   Example of calling procedure win-rate   ---
---           for magician Hermiona           ---
-------------------------------------------------
BEGIN
    win_rate('Hermiona');
END;


-----------------------------------------------------
--  Example of calling procedure spells_in_grimoar --
--              with id_grimoar = 1                --
-----------------------------------------------------
BEGIN
    spells_in_grimoar(1);
END;

------------------------------------------------
---  Definition of authorization for second  ---
---          member of team: xondru16        ---
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


-------------------------------------------------
-----           Materialized view             ---
---- shows spells with primary element air  ---
-------------------------------------------------
CREATE MATERIALIZED VIEW spells_with_primary_element_air AS
    SELECT name
    FROM xkocim05.spell
    WHERE id_prim_element = 3;

--- Displays materialized view
SELECT * FROM spells_with_primary_element_air;

--- Add new item into table
INSERT INTO spell(name, hardness_of_casting, type, strength, id_prim_element)
VALUES ('Accio', 15, 'charm', 400, 3);

--- Materialized view didn't change
SELECT * FROM spells_with_primary_element_air;

------------------------------------------------
----    Search all magicians and count how  ----
---       many of grimoars they owned       ----
-- GROUP BY  with aggregation function COUNT  --
----             sorted by largest          ----
------------------------------------------------
EXPLAIN PLAN FOR
SELECT magician.name AS name_of_magician,
       COUNT(id_history_grimoar) AS number_of_grimoars
FROM history_grimoar
LEFT JOIN magician ON history_grimoar.login_history_magician = magician.login
GROUP BY magician.name
ORDER BY COUNT(login_history_magician) DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

CREATE INDEX magician_ind ON magician(name, login);
CREATE INDEX history_grim_ind ON history_grimoar(login_history_magician);

EXPLAIN PLAN  FOR
SELECT magician.name AS name_of_magician,
    COUNT(id_history_grimoar) AS number_of_grimoars
FROM history_grimoar
LEFT JOIN magician ON history_grimoar.login_history_magician = magician.login
GROUP BY magician.name
ORDER BY COUNT(login_history_magician) DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);