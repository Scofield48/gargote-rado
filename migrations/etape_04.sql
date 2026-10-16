-- Étape 04 : les habitués

CREATE TABLE client (
    id_client INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom       VARCHAR(100) NOT NULL,
    telephone VARCHAR(20)  UNIQUE          -- facultatif
);

-- clé étrangère facultative : NULL = client de passage
ALTER TABLE commande ADD COLUMN id_client INTEGER;
ALTER TABLE commande ADD CONSTRAINT fk_commande_client
    FOREIGN KEY (id_client) REFERENCES client (id_client);

INSERT INTO client (nom, telephone) VALUES
    ('Hery Andrianina',   '034 00 111 22'),
    ('Voahangy Ravelona', '032 00 333 44'),
    ('Tojo Rakotomalala', NULL);

UPDATE commande SET id_client = (SELECT id_client FROM client WHERE nom = 'Hery Andrianina')
 WHERE id_commande IN (1, 4);
UPDATE commande SET id_client = (SELECT id_client FROM client WHERE nom = 'Voahangy Ravelona')
 WHERE id_commande = 3;
-- commandes 2, 5 et 6 : clients de passage (id_client reste NULL)
