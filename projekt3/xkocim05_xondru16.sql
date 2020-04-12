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
    id_active_grimoar INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
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
    id_synergy_element INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    id_synergy_element_FK    INT    NOT NULL,
    login_synergy_magician  VARCHAR(255)    NOT NULL,
    CONSTRAINT id_synergy_element_FK_SE
            FOREIGN KEY (id_synergy_element_FK)
            REFERENCES element(id_element),
    CONSTRAINT login_synergy_magician_FK_SE
            FOREIGN KEY (login_synergy_magician)
            REFERENCES magician(login)
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
    id_side_elements_spell INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    id_element INT NOT NULL,
    id_spell INT NOT NULL,
    CONSTRAINT id_element_FK_SES FOREIGN KEY (id_element) REFERENCES element(id_element),
    CONSTRAINT id_spell_FK_IN_SES FOREIGN KEY (id_spell) REFERENCES spell(id_spell)
);


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

INSERT INTO spell(name, hardness_of_casting, type, strength, id_prim_element)
VALUES ('aqua ', 3, 'attack', '100', 1);

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
VALUES ('Hermiona99', 1, TO_DATE ('2020-03-29 00:00:00' , 'YYYY-MM-DD HH24:MI:SS' ));

INSERT INTO history_grimoar(login_history_magician, id_history_grimoar_FK, started_owning_date, stopped_owning_date)
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


-------------------------------------------------
----------------- 3. PROJECT --------------------
-------------------------------------------------

------------------------------------------------
------ Search all battles in which magician ----
------      Hermiona was present       ---------
-------- SELECT with two tables ----------------
------------------------------------------------
SELECT
    k1.name AS magician_challenger,
    k2.name AS magician_opponent
FROM history_battles
INNER JOIN magician k1 ON login_challenger = k1.login
INNER JOIN magician k2 ON login_opponent = k2.login
WHERE k1.name = 'Hermiona' OR k2.name = 'Hermiona';

------------------------------------------------
------  Writes all coordinates of place  -------
------ leaking magic and writes element --------
------       that is leaking there      --------
----------   SELECT with two tables   ----------
------------------------------------------------
SELECT magical_place.coordinate_X as coordinate_x,
       magical_place.coordinate_Y as coordinate_y,
       magical_place.coordinate_Z as coordinate_z,
       element.name AS element
FROM magical_place
LEFT JOIN element ON (element.id_element = magical_place.id_place);

------------------------------------------------
------- Search all items of type grimoar -------
------  and write's the spells in it ad  -------
------   primary element of this spell   -------
------    SELECT with three tables    ----------
------------------------------------------------
SELECT item.name AS grimoar_name,
       spell.name AS spell_in_grimoar,
       element.name AS element_name
FROM item
INNER JOIN spells_grimoar ON (spells_grimoar.id_grimoar = item.id_item)
INNER JOIN spell ON (spell.id_spell = spells_grimoar.id_spell)
INNER JOIN element ON (element.id_element = spell.id_prim_element)
WHERE item.type = 'grimoar';

------------------------------------------------
--       Search all spells and counts its     --
--      average strength and writes only      --
--        the spells that have average        --
--         strength bigger than 200           --
--   GROUP BY with aggregation function AVG   --
----           sorted by largest            ----
------------------------------------------------
SELECT
    spell.name AS name_of_spell,
    AVG(spell.strength) AS average_strength
FROM spell
LEFT JOIN element ON spell.id_prim_element = element.id_element
GROUP BY spell.name
HAVING AVG(spell.strength) > 200
ORDER BY average_strength DESC ;

------------------------------------------------
----    Search all magicians and count how  ----
---       many of grimoars they owned       ----
-- GROUP BY  with aggregation function COUNT  --
----             sorted by largest          ----
------------------------------------------------
SELECT magician.name AS name_of_magician,
       COUNT(id_history_grimoar) AS number_of_grimoars
FROM history_grimoar
LEFT JOIN magician ON history_grimoar.login_history_magician = magician.login
GROUP BY magician.name
ORDER BY COUNT(login_history_magician) DESC;

------------------------------------------------
---- Search all elements that are a part of ----
------       side elements in spell       ------
---------  use of predicate EXISTS     ---------
------------------------------------------------
SELECT element.name AS name_of_element
FROM  element
WHERE
    EXISTS
    (
        SELECT side_elements_spell.id_element
        FROM side_elements_spell
        WHERE element.id_element=side_elements_spell.id_element
    );

------------------------------------------------
-----  Search all magicians that don't own  ----
-----                 any item              ----
---------      use of predicate  IN     --------
------------------------------------------------
SELECT * FROM magician
WHERE login NOT IN
      (SELECT item.login_magician
      FROM item
      WHERE item.login_magician IS NOT NULL);

