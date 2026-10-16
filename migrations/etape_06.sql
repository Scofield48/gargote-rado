-- Étape 06 : les paiements

-- Table de référence des modes de paiement (ajouter un mode = un INSERT)
CREATE TABLE mode_paiement (
    id_mode_paiement INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    libelle          VARCHAR(30) NOT NULL UNIQUE
);

INSERT INTO mode_paiement (libelle) VALUES
    ('Espèces'), ('MVola'), ('Orange Money'), ('Airtel Money');

-- Une commande peut avoir plusieurs paiements (paiement partiel, mode mixte)
CREATE TABLE paiement (
    id_paiement           INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_commande           INTEGER     NOT NULL REFERENCES commande (id_commande),
    id_mode_paiement      INTEGER     NOT NULL REFERENCES mode_paiement (id_mode_paiement),
    montant               INTEGER     NOT NULL CHECK (montant > 0),
    date_paiement         DATE        NOT NULL DEFAULT CURRENT_DATE,
    reference_transaction VARCHAR(50),                 -- renseignée pour le mobile money
    UNIQUE (id_mode_paiement, reference_transaction)   -- une référence ne sert qu'une fois
);

-- Commande 1 : 10 000 Ar en espèces + 5 000 Ar par MVola ; commande 2 : 6 000 Ar par Orange Money
INSERT INTO paiement (id_commande, id_mode_paiement, montant, date_paiement, reference_transaction)
SELECT v.id_commande, m.id_mode_paiement, v.montant, DATE '2026-10-12', v.reference
FROM (VALUES
        (1, 'Espèces',      10000, CAST(NULL AS VARCHAR)),
        (1, 'MVola',         5000, 'MV261012A001'),
        (2, 'Orange Money',  6000, 'OM261012B002')
     ) AS v (id_commande, mode, montant, reference)
JOIN mode_paiement m ON m.libelle = v.mode;
