# Schéma relationnel – la gargote de Rado

Notation : **clé primaire** en gras · `#` clé étrangère · `?` attribut facultatif.
SGBD : PostgreSQL (scripts exécutables dans l'ordre `migrations/etape_01.sql` → `etape_05.sql`).

---

## Étape 1 – La carte

PLAT(**id_plat**, nom, prix) (nouveau)

**Piège.** Le prix est un `INTEGER` (ariary sans centimes) : un type entier évite les erreurs d'arrondi des flottants. L'identifiant est une clé artificielle auto-générée (`id_plat`), car le nom d'un plat peut changer sans casser les références futures.

