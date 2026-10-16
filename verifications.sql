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

