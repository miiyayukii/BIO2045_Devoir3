# Dépôt modèle pour le cours BIO 2045
# Devoir 3 - Dynamique épidémique et campagne de vaccination 
## Organisation du projet

### I. Introduction
### II. Présentation du modèle 
### III. Implémentation 
#### Code pour la simulation
- Les packages necessaires
- Les fonctions utilisés
- La simulations 
### IV. Principeaux résultats 
### V. Discussion
### VI. Conclusion 

## Contexte

Une épidémie s'est propagée dans une population de 3750 agents naïfs. La maladie est asymptomatique et très virulante, causant la mort de l'individus infecté au bout de 21 jours. La contagiant se fait par contact et a 40% de chance d'être transmise à un individus sain. 

## But du programme 

Trouver une stratégie éfficace pour stopper la propagation de cette infection léthale et sauver le plus grand nombre d'agents à la fin de la simulation.

## matériels

On dispose de:
+ Budget initial de 21 000$
+ Tests RAT : permettant la detection des agents malades. Et ayant un cout d'utilisation de 4$
+ Vaccins : qui une fois actifs, guérissent l'agent et le protège de tout possible infection futur jusqu'à la fin de la simulation. Une dose coutant 17$


## Plus de détails

La stratégie consiste à trouver un bon compromis entre faire des tests pour déceler les porteurs et vacciner la population pour la protéger et stopper l'épidémie.
Pour que la stratégie soit efficace, elle doit permettre la survie du plus grand nombre d'agent à la fin de la simulation.

## Contraintes inclusent dans le modèle 

Afin d'être le plus réaliste possible plusieurs contraintes ont étaient ajouté au modèle :
- Les agents se déplace alétoirement sur une lattice (le paysage) ayant 2 dimensions bien défini et non changeable. 
- le taux d'infection est de 40% possible par contact entre agents (lorsqu'ils sont dans la même cellule). Cette règle permet de définir le taux de transmission de la maladie. Plus on augmente ce taux plus la maladie se propagera vite, et à un plus grand nombre d'individus.
- L'infection est toujours léthale sans traitement. Après 21 jours (génération) de l'infection l'agent meurt.
- La maladie est asymptomatique. Donc on ne peut savoir qu'elle existe qu'après le premier mort. Cette règle est importante dans la mesure où plusieurs maladies sont non detectable sans test.
- Le test RAT qui permet la detection de la maladie, a 5% de chance de produire un faux négatif. Dans la réalité les tests ne sont jamais fiable à 100%, il ont toujours un pourcentage d'erreur, produisant des faux négatif ou des faux positif. Dans cette simulation, les faux positif ne sont pris en compte pour simplifier le code.
- Un budget initial de 21000$ est fixé limitant les interventions possibles. fair un test coute 4$ et un vaccin 17$. Une fois le buget fini, aucune autre intervention n'est possible. Cette contrainte est très importante vu que la stratégie la plus efficace doit aussi être réaliste financièrement pour l'appliquer. Le volet économique étant souvant un frein important dans la mise en place d'intervention de grande envergure. 



