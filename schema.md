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

---

## Étape 4 – Les habitués

CATEGORIE(**id_categorie**, libelle)
PLAT(**id_plat**, nom, prix, #id_categorie)
CLIENT(**id_client**, nom, telephone?) (nouveau)
COMMANDE(**id_commande**, date_commande, #id_client?) (modifié)
LIGNE_COMMANDE(**#id_commande**, **#id_plat**, quantite)

**Piège.** Non : la clé étrangère `id_client` est facultative (NULL = client de passage). Il faut une `LEFT JOIN` de `COMMANDE` vers `CLIENT` ; une `JOIN` simple éliminerait toutes les commandes de clients de passage.

---

## Étape 5 – Serveurs et tables

CATEGORIE(**id_categorie**, libelle)
PLAT(**id_plat**, nom, prix, #id_categorie)
CLIENT(**id_client**, nom, telephone?)
SERVEUR(**id_serveur**, nom) (nouveau)
TABLE_SALLE(**id_table_salle**, numero) (nouveau)
COMMANDE(**id_commande**, date_commande, #id_client?, #id_serveur, #id_table_salle?) (modifié)
LIGNE_COMMANDE(**#id_commande**, **#id_plat**, quantite)

**Piège.** Une table de la salle est un objet physique permanent, alors qu'une commande est un événement daté : une même table accueille de nombreuses commandes au fil du temps, d'où une clé étrangère de `COMMANDE` vers `TABLE_SALLE` (facultative : NULL = à emporter). `TABLE` est un mot réservé du SQL (`CREATE TABLE`, `ALTER TABLE`), donc inutilisable comme nom de table sans guillemets : on utilise `table_salle`.

---

## Étape 6 – Les paiements

CATEGORIE(**id_categorie**, libelle)
PLAT(**id_plat**, nom, prix, #id_categorie)
CLIENT(**id_client**, nom, telephone?)
SERVEUR(**id_serveur**, nom)
TABLE_SALLE(**id_table_salle**, numero)
MODE_PAIEMENT(**id_mode_paiement**, libelle) (nouveau)
COMMANDE(**id_commande**, date_commande, #id_client?, #id_serveur, #id_table_salle?)
LIGNE_COMMANDE(**#id_commande**, **#id_plat**, quantite)
PAIEMENT(**id_paiement**, #id_commande, #id_mode_paiement, montant, date_paiement, reference_transaction?) (nouveau)

**Piège.** Une colonne `montant_paye` dans `COMMANDE` ne garde qu'un total : elle ne dit pas qui a payé quoi, par quel mode, quand, avec quelle référence, et ne permet pas de paiement en plusieurs fois ni en mode mixte ; de plus, c'est une donnée calculable (redondante) qui peut devenir fausse. Pour le mode de paiement, un `CHECK (mode IN (...))` est simple et évite une jointure, mais ajouter ou renommer un mode oblige à modifier la structure et le libellé est répété à chaque ligne ; une table de référence permet d'ajouter un mode par un simple `INSERT`, garantit l'intégrité par clé étrangère et peut porter d'autres informations, au prix d'une jointure en plus : c'est le choix retenu.

---

## Étape 7 – Les prix changent

CATEGORIE(**id_categorie**, libelle)
PLAT(**id_plat**, nom, prix, #id_categorie) — `prix` = prix courant
PRIX_PLAT(**#id_plat**, **date_debut**, prix) (nouveau)
CLIENT(**id_client**, nom, telephone?)
SERVEUR(**id_serveur**, nom)
TABLE_SALLE(**id_table_salle**, numero)
MODE_PAIEMENT(**id_mode_paiement**, libelle)
COMMANDE(**id_commande**, date_commande, #id_client?, #id_serveur, #id_table_salle?)
LIGNE_COMMANDE(**#id_commande**, **#id_plat**, quantite, prix_unitaire) (modifié)
PAIEMENT(**id_paiement**, #id_commande, #id_mode_paiement, montant, date_paiement, reference_transaction?)

**Constat.** Après le passage du romazava à 7 500 Ar, la requête de l'étape 3 (qui lit `plat.prix`) donne 16 000 Ar pour la commande 1 au lieu de 15 000 : le montant d'une ancienne facture a changé, car le prix n'est pas conservé dans la commande.

**Correction.** Le prix de vente est figé dans `LIGNE_COMMANDE.prix_unitaire` au moment de la commande : le montant d'une commande ne dépend plus de `PLAT.prix`. Bonus : `PRIX_PLAT` garde l'historique de tous les prix (un prix est valable de `date_debut` jusqu'au début du prix suivant) ; `PLAT.prix` reste le prix courant, mis à jour en même temps qu'une nouvelle ligne de `PRIX_PLAT`. Les requêtes des étapes 3, 5 et 6 de `verifications.sql` utilisent désormais `prix_unitaire`.

---

## Étape 8 – Les ingrédients

CATEGORIE(**id_categorie**, libelle)
PLAT(**id_plat**, nom, prix, #id_categorie)
PRIX_PLAT(**#id_plat**, **date_debut**, prix)
INGREDIENT(**id_ingredient**, nom, unite, stock) (nouveau)
RECETTE(**#id_plat**, **#id_ingredient**, quantite) (nouveau)
CLIENT(**id_client**, nom, telephone?)
SERVEUR(**id_serveur**, nom)
TABLE_SALLE(**id_table_salle**, numero)
MODE_PAIEMENT(**id_mode_paiement**, libelle)
COMMANDE(**id_commande**, date_commande, #id_client?, #id_serveur, #id_table_salle?)
LIGNE_COMMANDE(**#id_commande**, **#id_plat**, quantite, prix_unitaire)
PAIEMENT(**id_paiement**, #id_commande, #id_mode_paiement, montant, date_paiement, reference_transaction?)

**Piège.** Une colonne `ingredients VARCHAR(500)` (« riz, zébu, brèdes ») n'est pas une donnée exploitable : on ne peut pas y mettre les quantités ni les unités, ni calculer la consommation, ni lier l'ingrédient à son stock, et les fautes de frappe ou les variantes d'écriture rendent les recherches fausses. La relation plat–ingrédient est une association n–n qui porte une quantité, d'où la table `RECETTE`.

---

## Étape 9 – Les menus du jour

CATEGORIE(**id_categorie**, libelle)
PLAT(**id_plat**, nom, prix, #id_categorie)
COMPOSITION_MENU(**#id_menu**, **#id_plat**, quantite) (nouveau)
PRIX_PLAT(**#id_plat**, **date_debut**, prix)
INGREDIENT(**id_ingredient**, nom, unite, stock)
RECETTE(**#id_plat**, **#id_ingredient**, quantite)
CLIENT(**id_client**, nom, telephone?)
SERVEUR(**id_serveur**, nom)
TABLE_SALLE(**id_table_salle**, numero)
MODE_PAIEMENT(**id_mode_paiement**, libelle)
COMMANDE(**id_commande**, date_commande, #id_client?, #id_serveur, #id_table_salle?)
LIGNE_COMMANDE(**#id_commande**, **#id_plat**, quantite, prix_unitaire)
PAIEMENT(**id_paiement**, #id_commande, #id_mode_paiement, montant, date_paiement, reference_transaction?)

Dans `COMPOSITION_MENU`, `id_menu` et `id_plat` référencent tous deux `PLAT` (association réflexive). Le menu a sa propre catégorie « Menu ».

**Piège.** Une table `menu` séparée obligerait `LIGNE_COMMANDE` à référencer deux tables (plat ou menu), alors que le menu se commande comme un plat : en faire un plat garde une seule clé étrangère. La contrainte `CHECK (id_menu <> id_plat)` empêche un menu de se contenir lui-même ; elle ne détecte pas un cycle indirect (A contient B qui contient A), qui demanderait un contrôle applicatif ou un déclencheur.
