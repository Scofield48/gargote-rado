-- ===== Étape 01 : plats du plus cher au moins cher =====
SELECT nom, prix
FROM plat
ORDER BY prix DESC, nom;

-- ===== Étape 02 : nombre de plats par catégorie (y compris sans plat) =====
SELECT c.libelle AS categorie, COUNT(p.id_plat) AS nb_plats
FROM categorie c
LEFT JOIN plat p ON p.id_categorie = c.id_categorie
GROUP BY c.id_categorie, c.libelle
ORDER BY c.id_categorie;

-- ===== Étape 03 : montant total de chaque commande =====
-- (mis à jour à l'étape 7 : utilise le prix figé prix_unitaire de chaque ligne)
SELECT c.id_commande, c.date_commande,
       COALESCE(SUM(lc.quantite * lc.prix_unitaire), 0) AS montant_total
FROM commande c
LEFT JOIN ligne_commande lc ON lc.id_commande = c.id_commande
GROUP BY c.id_commande, c.date_commande
ORDER BY c.id_commande;

-- ===== Étape 04 : commandes avec le nom du client (« client de passage » si aucun) =====
SELECT c.id_commande, c.date_commande,
       COALESCE(cl.nom, 'client de passage') AS client
FROM commande c
LEFT JOIN client cl ON cl.id_client = c.id_client
ORDER BY c.id_commande;

-- ===== Étape 05 : nombre de commandes et chiffre d'affaires par serveur =====
-- (mis à jour à l'étape 7 : utilise le prix figé prix_unitaire)
SELECT s.nom AS serveur,
       COUNT(DISTINCT c.id_commande)                       AS nb_commandes,
       COALESCE(SUM(lc.quantite * lc.prix_unitaire), 0)    AS chiffre_affaires
FROM serveur s
LEFT JOIN commande c        ON c.id_serveur = s.id_serveur
LEFT JOIN ligne_commande lc ON lc.id_commande = c.id_commande
GROUP BY s.id_serveur, s.nom
ORDER BY s.id_serveur;

-- Contrôle complémentaire : commandes sur place / à emporter
SELECT c.id_commande,
       COALESCE(CAST(t.numero AS VARCHAR), 'à emporter') AS table_salle,
       s.nom AS serveur
FROM commande c
JOIN serveur s            ON s.id_serveur = c.id_serveur
LEFT JOIN table_salle t   ON t.id_table_salle = c.id_table_salle
ORDER BY c.id_commande;

-- ===== Étape 06 : commandes non soldées (dû, payé, reste à payer) =====
-- (mis à jour à l'étape 7 : le montant dû utilise le prix figé prix_unitaire)
SELECT c.id_commande,
       d.montant_du,
       COALESCE(p.montant_paye, 0)                  AS montant_paye,
       d.montant_du - COALESCE(p.montant_paye, 0)   AS reste_a_payer
FROM commande c
JOIN (SELECT id_commande, SUM(quantite * prix_unitaire) AS montant_du
      FROM ligne_commande
      GROUP BY id_commande) d ON d.id_commande = c.id_commande
LEFT JOIN (SELECT id_commande, SUM(montant) AS montant_paye
           FROM paiement
           GROUP BY id_commande) p ON p.id_commande = c.id_commande
WHERE d.montant_du > COALESCE(p.montant_paye, 0)
ORDER BY c.id_commande;

-- Détail des paiements
SELECT pa.id_commande, m.libelle AS mode_paiement, pa.montant, pa.reference_transaction
FROM paiement pa
JOIN mode_paiement m ON m.id_mode_paiement = pa.id_mode_paiement
ORDER BY pa.id_paiement;

-- ===== Étape 07 : le constat et la correction =====
-- Montant des commandes avec le prix COURANT du plat (ancienne méthode, fausse)
-- comparé au prix FIGÉ dans la ligne de commande (bonne méthode).
-- Commande 1 : 16 000 (faux, le romazava a augmenté) contre 15 000 (correct).
SELECT c.id_commande, c.date_commande,
       SUM(lc.quantite * p.prix)          AS montant_prix_courant,
       SUM(lc.quantite * lc.prix_unitaire) AS montant_prix_fige
FROM commande c
JOIN ligne_commande lc ON lc.id_commande = c.id_commande
JOIN plat p            ON p.id_plat = lc.id_plat
GROUP BY c.id_commande, c.date_commande
ORDER BY c.id_commande;

-- Bonus : historique des prix de chaque plat dont le prix a changé
SELECT p.nom, pp.date_debut, pp.prix
FROM prix_plat pp
JOIN plat p ON p.id_plat = pp.id_plat
WHERE p.id_plat IN (SELECT id_plat FROM prix_plat GROUP BY id_plat HAVING COUNT(*) > 1)
ORDER BY p.nom, pp.date_debut;

-- ===== Étape 08 : consommation théorique d'ingrédients le 12 octobre 2026 =====
SELECT i.nom AS ingredient, i.unite,
       SUM(lc.quantite * r.quantite) AS consommation_theorique
FROM commande c
JOIN ligne_commande lc ON lc.id_commande = c.id_commande
JOIN recette r         ON r.id_plat = lc.id_plat
JOIN ingredient i      ON i.id_ingredient = r.id_ingredient
WHERE c.date_commande = DATE '2026-10-12'
GROUP BY i.id_ingredient, i.nom, i.unite
ORDER BY i.nom;

