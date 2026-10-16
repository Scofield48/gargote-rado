-- Étape 05 : serveurs et tables de la salle
-- (« table » est un mot réservé SQL : la table de la salle s'appelle table_salle)

CREATE TABLE serveur (
    id_serveur INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom        VARCHAR(100) NOT NULL
);

CREATE TABLE table_salle (
    id_table_salle INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero         INTEGER NOT NULL UNIQUE CHECK (numero > 0)
);

INSERT INTO serveur (nom) VALUES ('Njaka Rakoto'), ('Lalao Rasoa');
INSERT INTO table_salle (numero) VALUES (1), (2), (3), (4), (5), (6), (7), (8);

-- serveur : obligatoire à terme, mais des commandes existent déjà
ALTER TABLE commande ADD COLUMN id_serveur INTEGER;
ALTER TABLE commande ADD CONSTRAINT fk_commande_serveur
    FOREIGN KEY (id_serveur) REFERENCES serveur (id_serveur);

-- table : facultative (NULL = plat à emporter)
ALTER TABLE commande ADD COLUMN id_table_salle INTEGER;
ALTER TABLE commande ADD CONSTRAINT fk_commande_table_salle
    FOREIGN KEY (id_table_salle) REFERENCES table_salle (id_table_salle);

-- reprise des commandes existantes
UPDATE commande SET id_serveur = (SELECT id_serveur FROM serveur WHERE nom = 'Njaka Rakoto')
 WHERE id_commande IN (1, 2, 4);
UPDATE commande SET id_serveur = (SELECT id_serveur FROM serveur WHERE nom = 'Lalao Rasoa')
 WHERE id_commande IN (3, 5, 6);

UPDATE commande SET id_table_salle = (SELECT id_table_salle FROM table_salle WHERE numero = 3) WHERE id_commande = 1;
UPDATE commande SET id_table_salle = (SELECT id_table_salle FROM table_salle WHERE numero = 5) WHERE id_commande = 2;
UPDATE commande SET id_table_salle = (SELECT id_table_salle FROM table_salle WHERE numero = 3) WHERE id_commande = 4;
UPDATE commande SET id_table_salle = (SELECT id_table_salle FROM table_salle WHERE numero = 1) WHERE id_commande = 6;
-- commandes 3 et 5 : à emporter (id_table_salle reste NULL)

ALTER TABLE commande ALTER COLUMN id_serveur SET NOT NULL;
