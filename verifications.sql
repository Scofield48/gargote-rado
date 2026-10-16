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
SELECT c.id_commande, c.date_commande,
       COALESCE(SUM(lc.quantite * p.prix), 0) AS montant_total
FROM commande c
LEFT JOIN ligne_commande lc ON lc.id_commande = c.id_commande
LEFT JOIN plat p            ON p.id_plat = lc.id_plat
GROUP BY c.id_commande, c.date_commande
ORDER BY c.id_commande;

-- ===== Étape 04 : commandes avec le nom du client (« client de passage » si aucun) =====
SELECT c.id_commande, c.date_commande,
       COALESCE(cl.nom, 'client de passage') AS client
FROM commande c
LEFT JOIN client cl ON cl.id_client = c.id_client
ORDER BY c.id_commande;

-- ===== Étape 05 : nombre de commandes et chiffre d'affaires par serveur =====
SELECT s.nom AS serveur,
       COUNT(DISTINCT c.id_commande)            AS nb_commandes,
       COALESCE(SUM(lc.quantite * p.prix), 0)   AS chiffre_affaires
FROM serveur s
LEFT JOIN commande c        ON c.id_serveur = s.id_serveur
LEFT JOIN ligne_commande lc ON lc.id_commande = c.id_commande
LEFT JOIN plat p            ON p.id_plat = lc.id_plat
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
SELECT c.id_commande,
       d.montant_du,
       COALESCE(p.montant_paye, 0)                  AS montant_paye,
       d.montant_du - COALESCE(p.montant_paye, 0)   AS reste_a_payer
FROM commande c
JOIN (SELECT lc.id_commande, SUM(lc.quantite * pl.prix) AS montant_du
      FROM ligne_commande lc
      JOIN plat pl ON pl.id_plat = lc.id_plat
      GROUP BY lc.id_commande) d ON d.id_commande = c.id_commande
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

