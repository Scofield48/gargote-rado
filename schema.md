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
