-- Étape 03 : les commandes

CREATE TABLE commande (
    id_commande   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date_commande DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE ligne_commande (
    id_commande INTEGER NOT NULL REFERENCES commande (id_commande),
    id_plat     INTEGER NOT NULL REFERENCES plat (id_plat),
    quantite    INTEGER NOT NULL CHECK (quantite > 0),
    PRIMARY KEY (id_commande, id_plat)
);

INSERT INTO commande (date_commande) VALUES
    ('2026-10-12'),
    ('2026-10-12'),
    ('2026-10-13'),
    ('2026-10-14'),
    ('2026-10-15'),
    ('2026-10-16');   -- commande 6 : vide, pour vérifier que le total vaut 0

INSERT INTO ligne_commande (id_commande, id_plat, quantite)
SELECT c.id_commande, p.id_plat, v.quantite
FROM (VALUES
        (1, 'Romazava',              2),
        (1, 'Ranon''ampango',        2),
        (2, 'Mi sao',                1),
        (2, 'Soupe chinoise',        1),
        (2, 'Mofo gasy (les 4)',     1),
        (3, 'Ravitoto sy henakisoa', 1),
        (3, 'Ranon''ampango',        1),
        (4, 'Akoho sy voanio',       3),
        (4, 'Ranon''ampango',        3),
        (4, 'Mofo gasy (les 4)',     2),
        (5, 'Romazava',              1),
        (5, 'Soupe chinoise',        1)
     ) AS v (num_commande, nom_plat, quantite)
JOIN plat p     ON p.nom = v.nom_plat
JOIN commande c ON c.id_commande = v.num_commande;
