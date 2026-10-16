-- Étape 08 : les ingrédients

CREATE TABLE ingredient (
    id_ingredient INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom           VARCHAR(100)  NOT NULL UNIQUE,
    unite         VARCHAR(10)   NOT NULL,                      -- g, ml, ...
    stock         NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (stock >= 0)
);

-- Quantité d'un ingrédient pour UNE portion d'un plat (dans l'unité de l'ingrédient)
CREATE TABLE recette (
    id_plat       INTEGER       NOT NULL REFERENCES plat (id_plat),
    id_ingredient INTEGER       NOT NULL REFERENCES ingredient (id_ingredient),
    quantite      NUMERIC(10,2) NOT NULL CHECK (quantite > 0),
    PRIMARY KEY (id_plat, id_ingredient)
);

INSERT INTO ingredient (nom, unite, stock) VALUES
    ('Riz',               'g',  50000),
    ('Viande de zébu',    'g',   8000),
    ('Brèdes mafana',     'g',   3000),
    ('Henakisoa',         'g',   5000),
    ('Ravitoto',          'g',   3000),
    ('Poulet',            'g',   6000),
    ('Lait de coco',      'ml',  2000),
    ('Nouilles',          'g',   4000),
    ('Légumes',           'g',   5000),
    ('Huile',             'ml',  3000),
    ('Bouillon',          'ml',  5000),
    ('Farine de riz',     'g',   4000),
    ('Sucre',             'g',   1500),
    ('Eau',               'ml', 20000);

-- Le romazava est donné par Rado ; les autres recettes sont des données de test
INSERT INTO recette (id_plat, id_ingredient, quantite)
SELECT p.id_plat, i.id_ingredient, v.quantite
FROM (VALUES
        ('Romazava',              'Riz',            250),
        ('Romazava',              'Viande de zébu', 150),
        ('Romazava',              'Brèdes mafana',  100),
        ('Ravitoto sy henakisoa', 'Riz',            250),
        ('Ravitoto sy henakisoa', 'Henakisoa',      150),
        ('Ravitoto sy henakisoa', 'Ravitoto',       100),
        ('Akoho sy voanio',       'Riz',            250),
        ('Akoho sy voanio',       'Poulet',         200),
        ('Akoho sy voanio',       'Lait de coco',   100),
        ('Mi sao',                'Nouilles',       200),
        ('Mi sao',                'Légumes',        100),
        ('Mi sao',                'Huile',           20),
        ('Soupe chinoise',        'Nouilles',       100),
        ('Soupe chinoise',        'Légumes',        100),
        ('Soupe chinoise',        'Bouillon',       300),
        ('Mofo gasy (les 4)',     'Farine de riz',  100),
        ('Mofo gasy (les 4)',     'Sucre',           20),
        ('Mofo gasy (les 4)',     'Huile',           30),
        ('Ranon''ampango',        'Riz',             30),
        ('Ranon''ampango',        'Eau',            250)
     ) AS v (nom_plat, nom_ingredient, quantite)
JOIN plat p       ON p.nom = v.nom_plat
JOIN ingredient i ON i.nom = v.nom_ingredient;
