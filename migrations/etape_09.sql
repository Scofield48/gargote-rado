-- Étape 09 : les menus du jour
-- Un menu est un plat (même table PLAT, donc commandable via LIGNE_COMMANDE)
-- composé d'autres plats (association réflexive COMPOSITION_MENU).

INSERT INTO categorie (libelle) VALUES ('Menu');

INSERT INTO plat (nom, prix, id_categorie)
SELECT 'Menu Romazava', 8000, id_categorie FROM categorie WHERE libelle = 'Menu';

INSERT INTO prix_plat (id_plat, date_debut, prix)
SELECT id_plat, DATE '2026-10-16', prix FROM plat WHERE nom = 'Menu Romazava';

CREATE TABLE composition_menu (
    id_menu  INTEGER NOT NULL REFERENCES plat (id_plat),
    id_plat  INTEGER NOT NULL REFERENCES plat (id_plat),
    quantite INTEGER NOT NULL DEFAULT 1 CHECK (quantite > 0),
    PRIMARY KEY (id_menu, id_plat),
    CONSTRAINT ck_menu_pas_lui_meme CHECK (id_menu <> id_plat)
);

-- Menu Romazava = 1 romazava + 1 ranon'ampango + 1 mofo gasy
INSERT INTO composition_menu (id_menu, id_plat, quantite)
SELECT m.id_plat, p.id_plat, 1
FROM plat m
JOIN plat p ON p.nom IN ('Romazava', 'Ranon''ampango', 'Mofo gasy (les 4)')
WHERE m.nom = 'Menu Romazava';

-- Le menu se commande comme un plat : une commande à emporter avec un Menu Romazava
INSERT INTO commande (date_commande, id_serveur)
SELECT DATE '2026-10-16', (SELECT id_serveur FROM serveur WHERE nom = 'Lalao Rasoa');

INSERT INTO ligne_commande (id_commande, id_plat, quantite, prix_unitaire)
SELECT c.id_commande, p.id_plat, 1, p.prix
FROM (SELECT MAX(id_commande) AS id_commande FROM commande) c, plat p   -- c = la commande qui vient d'être créée
WHERE p.nom = 'Menu Romazava';
