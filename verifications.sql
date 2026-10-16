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

