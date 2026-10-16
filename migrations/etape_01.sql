-- Étape 01 : la carte
-- SGBD : PostgreSQL (identité : GENERATED ALWAYS AS IDENTITY, aussi valable sous Oracle 12c+)

CREATE TABLE plat (
    id_plat INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom     VARCHAR(100) NOT NULL,
    prix    INTEGER      NOT NULL CHECK (prix > 0)   -- en ariary, sans centimes
);

INSERT INTO plat (nom, prix) VALUES
    ('Romazava',              7000),
    ('Ravitoto sy henakisoa', 8000),
    ('Akoho sy voanio',       8500),
    ('Mi sao',                6000),
    ('Soupe chinoise',        5000),
    ('Mofo gasy (les 4)',     1000),
    ('Ranon''ampango',         500);
