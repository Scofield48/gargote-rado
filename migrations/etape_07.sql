-- Étape 07 : les prix changent (le montant d'une commande ne doit plus jamais changer)
-- Principe : PRIX_PLAT conserve l'historique des prix ; LIGNE_COMMANDE fige le prix au moment de la vente.

-- 1) Historique des prix : prix de départ de chaque plat (début de la saisie : 1er octobre 2026)
CREATE TABLE prix_plat (
    id_plat    INTEGER NOT NULL REFERENCES plat (id_plat),
    date_debut DATE    NOT NULL,
    prix       INTEGER NOT NULL CHECK (prix > 0),
    PRIMARY KEY (id_plat, date_debut)
);

INSERT INTO prix_plat (id_plat, date_debut, prix)
SELECT id_plat, DATE '2026-10-01', prix FROM plat;

-- 2) L'augmentation du 15 octobre : romazava 7 000 -> 7 500 Ar
INSERT INTO prix_plat (id_plat, date_debut, prix)
SELECT id_plat, DATE '2026-10-15', 7500 FROM plat WHERE nom = 'Romazava';

UPDATE plat SET prix = 7500 WHERE nom = 'Romazava';   -- plat.prix = prix courant

-- 3) Prix figé dans chaque ligne de commande
ALTER TABLE ligne_commande ADD COLUMN prix_unitaire INTEGER;

-- reprise de l'existant : prix en vigueur à la date de la commande
UPDATE ligne_commande lc
   SET prix_unitaire = (
        SELECT pp.prix
        FROM prix_plat pp
        WHERE pp.id_plat = lc.id_plat
          AND pp.date_debut = (
                SELECT MAX(pp2.date_debut)
                FROM prix_plat pp2
                JOIN commande c ON c.id_commande = lc.id_commande
                WHERE pp2.id_plat = lc.id_plat
                  AND pp2.date_debut <= c.date_commande));

ALTER TABLE ligne_commande ALTER COLUMN prix_unitaire SET NOT NULL;
ALTER TABLE ligne_commande ADD CONSTRAINT ck_ligne_prix_unitaire CHECK (prix_unitaire > 0);

-- 4) Données de test : une commande passée après l'augmentation
INSERT INTO commande (date_commande, id_serveur, id_table_salle)
SELECT DATE '2026-10-16',
       (SELECT id_serveur FROM serveur WHERE nom = 'Njaka Rakoto'),
       (SELECT id_table_salle FROM table_salle WHERE numero = 2);

INSERT INTO ligne_commande (id_commande, id_plat, quantite, prix_unitaire)
SELECT c.id_commande, p.id_plat, v.quantite, p.prix
FROM (VALUES ('Romazava', 2), ('Ranon''ampango', 2)) AS v (nom_plat, quantite)
JOIN plat p ON p.nom = v.nom_plat
CROSS JOIN (SELECT MAX(id_commande) AS id_commande FROM commande) c;   -- la commande qui vient d'être créée
