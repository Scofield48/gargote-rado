# Schéma relationnel – la gargote de Rado

Notation : **clé primaire** en gras · `#` clé étrangère · `?` attribut facultatif.
SGBD : PostgreSQL (scripts exécutables dans l'ordre `migrations/etape_01.sql` → `etape_05.sql`).

---

## Étape 1 – La carte

PLAT(**id_plat**, nom, prix) (nouveau)

**Piège.** Le prix est un `INTEGER` (ariary sans centimes) : un type entier évite les erreurs d'arrondi des flottants. L'identifiant est une clé artificielle auto-générée (`id_plat`), car le nom d'un plat peut changer sans casser les références futures.

---

## Étape 2 – Les catégories

CATEGORIE(**id_categorie**, libelle) (nouveau)
PLAT(**id_plat**, nom, prix, #id_categorie) (modifié)

**Piège.** Avec une colonne `categorie VARCHAR(50)`, la même catégorie est ressaisie à chaque plat : une faute de frappe (« Soupe » / « Soupes » / « soupe ») crée de fausses catégories, renommer une catégorie oblige à modifier toutes les lignes, et une catégorie sans plat ne peut pas exister (impossible de la compter à 0).

---

## Étape 3 – Les commandes

CATEGORIE(**id_categorie**, libelle)
PLAT(**id_plat**, nom, prix, #id_categorie)
COMMANDE(**id_commande**, date_commande) (nouveau)
LIGNE_COMMANDE(**#id_commande**, **#id_plat**, quantite) (nouveau)

**Piège.** La quantité se place dans la table d'association `LIGNE_COMMANDE`, car elle dépend du couple (commande, plat) : elle n'appartient ni à `COMMANDE` (plusieurs plats) ni à `PLAT` (plusieurs commandes).

