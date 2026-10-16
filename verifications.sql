-- ===== Étape 01 : plats du plus cher au moins cher =====
SELECT nom, prix
FROM plat
ORDER BY prix DESC, nom;

