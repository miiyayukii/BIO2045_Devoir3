# ---
# title: Dynamique épidémique et campagne de vaccination 
# repository: tpoisot/BIO245-modele
# auteurs:
#    - nom: Ben Brahim
#      prenom: Dorra
#      matricule: 20302117
#      github: premierAuteur
#    - nom: Nadler
#      prenom: Christina
#      matricule: 20313890
#      github: ChristinaN31
#    - nom: Auteur
#      prenom: troiseme
#      matricule: XXXXXXXX
#      github: TroisiAut
# ---

# # Introduction

# La propagation rapide des maladies infectieuses représente un défi majeur en
# santé publique, en raison de la complexité des interactions entre individus et
# des dynamiques de transmission.  La compréhension de ces dynamiques est
# essentielle afin de mettre en place des stratégies efficaces pour limiter la
# propagation d’un agent pathogène. La modélisation constitue un outil important
# en épidémiologie, permettant de simplifier ces systèmes afin d'évaluer l’impact
# de différents paramètres sur l’évolution d’une épidémie @keeling2008modeling.

# Le modèle dans ce travail simule la propagation d’une maladie infectieuse au
# sein d’une population d’individus mobiles, qui entrent en contact les uns avec
# les autres. La transmission survient lors de ces interactions, selon une
# probabilité fixe, ce qui permet de représenter les mécanismes fondamentaux de
# contagion tout en conservant un modèle simple. Dans ce cas, la maladie est 
# supposée être toujours fatale après une durée déterminée, pour permettre de 
# simplifier la dynamique du modèle et de se concentrer sur l'évolution de
# l’infection dans la population.

# Plusieurs contraintes ont été intégrées au modèle afin de représenter
# des conditions proches de la réalité. Premièrement, les individus infectés
# sont asymptomatiques, ce qui signifie qu’ils peuvent être détectés seulement à
# l’aide de tests diagnostiques. En effet, une proportion importante des
# infections peut se produire sans symptômes, rendant leur identification
# difficile sans dépistage @oran2020prevalence. De plus, les tests utilisés ne
# sont pas parfaitement fiables et peuvent produire des faux négatifs, ce qui
# introduit une incertitude supplémentaire dans la prise de décision.
# Ensuite, la vaccination constitue le principal moyen d’intervention dans
# le modèle. Une fois active, elle empêche les individus de contracter la maladie
# et de contribuer à sa propagation. Toutefois, un délai est nécessaire avant
# que la vaccination ne devienne active, ce qui correspond au temps requis pour
# que le système immunitaire développe une réponse protectrice @nikoloudis2025delayed.
# Cette contrainte est essentielle parce qu’elle influence
# directement l’efficacité des stratégies mises en place. Enfin, un budget
# limité est imposé pour la réalisation des tests et l’administration des
# vaccins. Cette contrainte reflète les réalités des systèmes de santé, où selon
# l’Organisation mondiale de la santé, les ressources sont restreintes et
# doivent être utilisées de manière optimale. Ainsi, les décisions de dépistage
# et de vaccination doivent être prises de façon stratégique afin de maximiser
# la réduction de la propagation de la maladie. 

# Dans ce contexe, nous adoptons une stratégie ciblée inspirée du traçage des
# contacts et de la vaccination en anneau. À partir du premier décès, les interventions
# sont concentrées dans les cellules spatiales contenant des individus infectés, 
# considérées comme des zones à risque de transmission. Les individus présents dans
# ces cellules sont directement vaccinés par prévention et cure pour ne pas gaspiller
# l'argent dans de nouveaux tests. Des études ont en fait montré que le traçage des 
# contacts permet de contrôler efficacement la propagation des épidémies en identifiant
# rapidement les chaînes de transmissions @hellewell2020feasibility. De plus, la 
# vaccination en anneau permet de limiter la propagation en ciblant les individus
# à haut risque autour des cas détectés @henao2015efficacy.

# Alors, la problématique de ce travail est la determination de comment optimiser
# l'utilisation de ressources limitées pour réduire la propagation d'une maladie
# infectieuse, dans un contexte où les individus infectés sont difficilement
# détectables et où les interventions sont coûteuses.

# L’objectif de ce travail est donc d'évaluer l'impact d'une stratégie de 
# dépistage et de vaccination sur la propagation d'une maladie infectieuse, en
# tenant compte de contraintes biologiques et économiques réalistes. Cette approche
# permet de mieux comprendre comment différents décisions d'intervention influencent
# l’évolution d’une épidémie.

# L'hypothèse est qu'une stratégie ciblée de
# dépistage et de vaccination, concentrée sur les zones à risques définies par
# la présence d'individus infectés, permettra de réduire plus efficacement la
# mortalité qu'une stratégie aléatoire @henao2015efficacy.

# Le résultat attendu est une diminution significative du nombre d'individus
# infectés au cours du temps, ainsi qu'une réduction de la dispersion spatiale
# des événements d'infection, suggérant une limitation de la propagation de
# la maladie. Et donc une stratégie efficace. 


# # Présentation du modèle

# Le modèle utilisé est un modèle épidémique. Le code simule la propagation d'une infection dans une 
# population de 3750 agents non immunisés. Ces agents se déplacent de façon aléatoire sur une lattice 
# carrée à 2 dimensions, de 100 x 100 cellules. 
# Au début de la simulation un seul agent, choisi aléatoirement, est rendu malade. Cet agent infecté
# a 40% de chance de contaminer chaque individu sain présent dans la même cellule de la lattice.
# Le temps dans la simulation est détérminé par les déplacements des agents, tandis qu'yne génération
# est égale à un mouvement pour tous les agents.
# Lorsqu'un agent a été infecté depuis 21 générations, il est retiré de la population et donc de la lattice.
# Il est alors considéré comme mort des suites de l'infection. 

# Après la mort du premier agent, donc à la diminution de la taille de la population, des tests RAT sont réalisés
# sur un nombre d'agents pris aléatoirement dans la population. Un test RAT détecte l'état de l'agent, soit 
# infectieux ou non. Si l'agent est malade, le test RAT le déclare positif dans 95% des cas, 
# et fait un faux négatif dans 5% des cas. Sans tests, il n'est pas possible de savoir qui est infecté.
# Si le RAT est positif, l'agent malade est vacciné. La vaccination change l'état 'vacciné' de l'agent de faux
# à vrai, et inscrit le jour de l'injection de la dose. Après 2 jours du vaccin, l'agent est guéri
# (s'il est toujours vivant) et ne peut plus être contaminés même en présence d'autres agents malades.

# Un budget_initiale est fixé, et chacun des vaccins et des tests a un coût qui est déduit de ce budget 
# à chaque utilisation. Si une intervention est demandée et que le budget n'est pas suffisant,
# un message est affiché pour indiquer quel traitement doit être exécuter. Ce message permet
# l'ajuster le code afin qu'une intervention soit réalisée uniquement si les fonds disponibles sont suffisants.

# Les variations de la taille de la population, le budget restant ainsi que les évenèments de contaminations,
# de mortalité et de protection sont présentés à la fin de la simulation à l'aide de schémas et de courbes,
# afin d'analyser l'évolution du système au cours de la simulation. 

# # Implémentation

# Le modèle est implémenté dans Julia à partir du code fourni pour simuler
# la propagation d'une épidémie.

# Dans cette étude, l'implémentation du modèle repose sur une 
# simulation basée sur des agents, où chaque individu de la 
# population est représenté explicitement et évolue dans le temps
# selon un ensemble de règles biologiques et probabilistes. 

# L'objectif est de traduire les mécanismes de propagation d'une maladie
# infectieuse ainsi que la stratégie d'intervention (dépistage et vaccination)
# en un système de règles simples appliquées à chaque pas de temps.
# Cette approche permet de reproduire la dynamique de l'épidémie tout en intégrant des contraintes réalistes,
# telles qu'un budget limité et l'absence d'information sur l'état infectieux des individus. 

# La simulation repose sur les règles suivantes, appliquées à chaque pas de temps:

# 1. Une population d'individus est distribuée dans l'espace, avec un seul agent,
# choisi aléatoirement, initialement infectés.

# 2. À chaque répétition, les individus se déplacent dans l'espace, ce qui permet les interactions entre eux. 

# 3. Lorsqu'un individu infectieux entre en contact avec un individu sain,
# la transmission peut se produire avec une probabilité de 0,4, simulant une maladie relativement contagieuse.

# 4. Les individus infectés restent contagieux pendant une durée de 21 itérations,
# après quoi ils meurent et sont retirés de la population, mettant fin à leur capacité de transmission.

# 5. À chaque pas de temps, un sous-ensemble d'individus est sélectionné aléatoirement afin d'être testé.
# Le nombre d'individus testés est initalement fixé à 900,
# puis diminue progressivement au cours de la simulation afin de respecter les contraintes de budget.

# 6. Les tests permettent de détecter les individus infectés avec une sensibilité de 95%,
# ce qui implique la présence de faux négatifs et introduit une incertitude dans le processus de détection.

# 7. Lorsqu'un individu est détecté positif, une intervention est déclenchée, incluant la vaccination de cet
# individu ainsi que les individus situés dans la même cellule spatiale, correspondant à une zone à risque.

# 8. Les individus vaccinés deviennent protégés après un délai de 2 itérations, durant lequel ils peuvent
# encore être infectés (s'ils sont sains) ou transmettre la maladie (s'ils sont infectés). 

# 9. Le nombre de tests et de vaccinations est limité par un budget fixe de $21000. Chaque test et
# chaque vaccin ont un coût de $4 et $17 respectivement, ce qui impose un compromis entre dépistage et
# vaccination, influençant directement l'efficacité de la stratégie.

# Ces règles traduisent donc les mécanismes biologiques de propagation et les contraintes d'intervention
# en un cadre simulé permettant l'évaluation de l'efficacité de la stratégie mise en place.  

# ## Packages nécessaires

import Random
using CairoMakie
CairoMakie.activate!(px_per_unit=6.0)
using StatsBase
import UUIDs

# ### Initiation du point de départ

Random.seed!(123456)

# ## Variables

budget_initiale = 21000
cout_vaccin = 17
cout_test = 4
sum_vacc_prix = 0
sum_rat_prix = 0

# Puisque nous allons identifier des agents, nous utiliserons des UUIDs pour
# leur donner un indentifiant unique: UUIDs.uuid4()

# ## Création des types

# Le premier type que nous avons besoin de créer est un agent. Les agents se
# déplacent sur une lattice, et on doit donc suivre leur position. On doit
# savoir si ils sont infectieux, et dans ce cas, combien de jours il leur reste,
# on note aussi s'il sont vacciné, la date du vaccin (s'ils le sont) et si le
# vaccin est actif ou pas :

Base.@kwdef mutable struct Agent
    x::Int64 = 0
    y::Int64 = 0
    clock::Int64 = 21 
    infectious::Bool = false
    id::UUIDs.UUID = UUIDs.uuid4() 
    vaccine::Bool = false
    date_vaccin::Int64 = 0
    vaccin_actif::Bool = false
end

# La deuxième structure dont nous aurons besoin est un paysage, qui est défini
# par les coordonnées min/max sur les axes x et y:

Base.@kwdef mutable struct Landscape
    xmin::Int64 = -25
    xmax::Int64 = 25
    ymin::Int64 = -25
    ymax::Int64 = 25
end

# Nous allons maintenant créer un paysage de départ:

L = Landscape(xmin=-50, xmax=50, ymin=-50, ymax=50)

# ## Création de nouvelles fonctions

# On va commencer par générer une fonction pour créer des agents au hasard. Il
# existe une fonction pour faire ceci dans _Julia_: `rand`. Pour que notre code
# soit facile a comprendre, nous allons donc ajouter deux méthodes à cette
# fonction:

Random.rand(::Type{Agent}, L::Landscape) = Agent(x=rand(L.xmin:L.xmax), y=rand(L.ymin:L.ymax))
Random.rand(::Type{Agent}, L::Landscape, n::Int64) = [rand(Agent, L) for _ in 1:n]

# On peut maintenant exprimer l'opération de déplacer un agent dans le paysage.
# Puisque la position de l'agent va changer, notre fonction se termine par `!`:

"""
    move!(A::Agent, L::Landscape; torus=true)
Cette fonction fait bouger les agents au fils en mettant à jour leurs positions
dans l'environnement à chaque pas de temps.
'A' doit être de type Agent. 'L' doit être de type Landscape. 'torus' est de
type bool et est true par défaut.
"""
function move!(A::Agent, L::Landscape; torus=true)
    
    ## On fait bouger l'agent A de façon aléatoire dans la lattice 

    A.x += rand(-1:1)
    A.y += rand(-1:1)

    ## Quand l'agent atteint le bord, on défini comment si se 
    ## déplacera selon le type de d'environnement dans lequel il évolue 
    ## (si torus l'agent se téleporte à l'autre bout 
    ## et si non torus il rebondi et reste à sa place)

    if torus
        A.y = A.y < L.ymin ? L.ymax : A.y 
        A.x = A.x < L.xmin ? L.xmax : A.x
        A.y = A.y > L.ymax ? L.ymin : A.y
        A.x = A.x > L.xmax ? L.xmin : A.x
    else
        A.y = A.y < L.ymin ? L.ymin : A.y
        A.x = A.x < L.xmin ? L.xmin : A.x
        A.y = A.y > L.ymax ? L.ymax : A.y
        A.x = A.x > L.xmax ? L.xmax : A.x
    end
    return A
end

# Nous pouvons maintenant définir des fonctions qui vont nous permettre de nous
# simplifier la rédaction du code. 

# D'abord, on a besoin de suivre les dépenses pour ne pas dépasser le budget
# initialement fixé 

"""
    finance!(vacc)
Cette fonction deduis le prix du test RAT ou du vaccin du budget quand on les
utilises.
'vacc' est de type bool. vacc=true si on utilise un vaccin et vacc=false si
c'est un test RAT.
"""
function finance!(vacc)
    global budget_initiale, cout_test, cout_vaccin, sum_rat_prix, sum_vacc_prix

    ## On verifie qu'on a assez d'argent et quel traitement, vaccin ou test,
    ## on fait, puis on enlève le cout du traitement du budget

    if (budget_initiale >= cout_vaccin) & vacc
        budget_initiale -= cout_vaccin

        ## on enregistre dans quel produit les dépenses sont faites

        sum_vacc_prix += cout_vaccin

        ## Pour être sur de pas vacciner si le budget ne le permet pas 
        ## un message apparaît pour nous signaler que le code doit être révisé 
        ## pour vérifier les fond avant d'initier la vaccination

        if budget_initiale < 17
            println("pas assez de fond pour vaccin")
        end

    end
    if (budget_initiale >= cout_test) & vacc == false
        budget_initiale -= cout_test

        ## on enregistre dans quel produit les dépenses sont faites
        
        sum_rat_prix += cout_test

        ## Pour être sur de pas faire de test RAT si le budget ne le permet pas 
        ## un message apparaît pour nous signaler que le code doit être révisé 
        ## pour vérifier les fonds avant d'initier un test 

        if budget_initiale < 4
            println("pas assez de fond pour test")
        end

    end
    return nothing
end

# On vérifie plusieurs information à propos de l'état de l'agent :
# s'il est infecté

"""
    isinfectious(agent::Agent)
Cette fonction permet de vérifier l'état infectieux de l'agent, et elle renvoie
'true' si l'agent est infecté.
    
'agent' doit être de type Agent.
"""
isinfectious(agent::Agent) = agent.infectious

# Ou sain:

"""
    ishealthy(agent::Agent)
Cette fonction permet de vérifier l'état de santé de l'agent, et elle renvoie
'true' si l'agent est sain.
'agent' doit être de type Agent.
"""
ishealthy(agent::Agent) = !isinfectious(agent)

# On vérifie également si un agent est vacciné

"""
    vaccineee(agent::Agent)
Cette fonction vérifie la fiche vaccination de l'agent. Elle renvoie 'true' si
l'agent est déjà vacciné.
'agent' doit être de type Agent.
"""
vaccineee(agent::Agent) = agent.vaccine

# Ou alors s'il est non vacciné

"""
    nonvaccinee(agent::Agent)
Cette fonction vérifie la fiche vaccination de l'agent. Et elle renvoie 'true'
si l'agent est non vacciné.
'agent' doit être de type Agent.
"""
nonvaccinee(agent::Agent) = !vaccineee(agent)

# Enfin, si l'agent est vacciné on vérifie si le vaccin est actif 

"""
    vac_actif(agent::Agent)
Cette fonction vérifie la fiche vaccination de l'agent. Et elle renvoie 'true'
si l'agent a un vaccin actif (donc vacciné depuis au moins deux jours). 'agent'
doit être de type Agent.
"""
vac_actif(agent::Agent) = agent.vaccin_actif

# Ou non actif

"""
    not_actif(agent::Agent)
Cette fonction vérifie la fiche vaccination de l'agent. Et elle renvoie 'true'
si l'agent a un vaccin non actif (donc quand l'agent est vacciné depuis moins 
de 2jours ou quand il n'est pas vacciné).
'agent' doit être de type Agent.
"""
not_actif(agent::Agent) = !vac_actif(agent)

# On peut maintenant définir une fonction pour prendre, dans une population,
# uniquement les agents qui répondent à une condition qu'on défini. Pour que ce
# soit clair, nous allons créer un _alias_, `Population`, qui voudra dire
# `Vector{Agent}`:

const Population = Vector{Agent}

# Population d'agents infectieux :

"""
    infectious(pop::Population)
Cette fonction permet de filtrer les agents selon leurs états de santé. Elle
selectionne tous les individus infecté de la population 'pop', créant un vecteur
d'agent infecté.
'pop' doit être de type Population.
"""
infectious(pop::Population) = filter(isinfectious, pop)

# Population d'agents sains :

"""
    healthy(pop::Population)
Cette fonction permet de filtrer les agents selon leurs états de santé. Elle
selectionne tous les individus sain de la population 'pop', créant un vecteur
d'agent non malade.
'pop' doit être de type Population.
"""
healthy(pop::Population) = filter(ishealthy, pop)


# Population d'agents ayant un vaccin actif 
# donc protégé des infections / mort par la maldie 

"""
    protected(pop::Population)
Cette fonction permet de créer un vecteur contenant les individus ayant un
vaccin actif, donc les individus protégé de tous dangers. 'pop' doit être de
type Population.
"""
protected(pop::Population) = filter(vac_actif, pop)

# Population avec les agents vaccinés

"""
    vaccinated(pop::Population)
Cette fonction permet de créer un vecteur contenant les individus vaccinés.
'pop' doit être de type Population.
"""
vaccinated(pop::Population) = filter(vaccineee, pop)

# Population avec les agents non vacciné

"""
    notVaccinated(pop::Population)
Cette fonction permet de créer un vecteur contenant les individus non vaccinés.
'pop' doit être de type Population.
"""
notVaccinated(pop::Population) = filter(nonvaccinee, pop)

# Et enfin, population avec les agents n'ayant pas un vaccin actif

"""
    NotProtected(pop::Population)
Cette fonction permet de créer un vecteur contenant les agents n'ayant pas un vaccin actif.
Donc les individus pouvant encore contracter la maladie s'ils sont exposés à des contaminés.
'pop' doit être de type Population.
"""
NotProtected(pop::Population) = filter(not_actif, pop)

# La maladie étant asymptomatique on a besoin de test pour détecter les malades.
# Les tests n'étant pas fiable dans 100% des cas, ils ont une probabilité de 5 %
# de donner un faux négatif, rendant la detection des porteurs plus compliqué
# Les tests ont un cout de 4 dollar qui est déduis du budget quand le test est
# fait.

"""
    RAT!(agent::Agent)
Cette fonction simule un test de dépistage de la maladie. Si l'agent est
infecté, le test a 95% de chance de renvoyer true et 5% de chance de faire un
faux négatif. Si l'agent est sain le test est toujours fiable (renvoie false).
'agent' doit être de type Agent. 'moment' doit etre de type Int.
"""
function RAT!(agent::Agent, moment)

    ## frais du test

    finance!(false)
    push!(agent_teste, TestEvent(moment, agent.id, agent.x, agent.y))

    if isinfectious(agent)

        ## probabilité de faux négatif

        if rand() <= 0.05
            test = false
        else
            test = true
        end
    else
        test = false
    end
    return test
end

# Nous allons ajouter une fonction permettant d'administrer un vaccin aux
# individus. Le vaccin n'est pas immédiatement efficace, un délai de 2
# générations est nécessaire avant qu'il confère une immunité complète. Cela
# reflète le temps requis pour que la réponse immunitaire se développe.

"""
    vaccinate!(agent::Agent, jour_vacc)
Cette fonction enlève les frais du vaccin du budget total. Mais aussi, elle
inscrit dans la fiche de l'agent la date du vaccin et change son statue à
vacciné.
'agent' doit être de type Agent. 'jour_vacc' doit être de type Int64.
"""
function vaccinate!(agent::Agent, jour_vacc)

    ## frais du vaccin déduis du budget

    finance!(true)

    ## modification du statue de vaccination
    ## stockage de la date de vaccination

    agent.vaccine = true
    agent.date_vaccin = jour_vacc

    return nothing
end

# Fonction qui simule l'activation du vaccin en changeant les valeurs dans la
# fiche de l'agent vacciné

"""
    activ_vaccin!(agent::Agent)
Cette fonction change l'état de santé de l'agent, de malade à guéri. Et informe
que le vaccin est maintenant actif.
'agent' doit être de type Agent.
"""
function activ_vaccin!(agent::Agent)

    ## activation du vaccin
    ## rétablissement de l'agent

    agent.vaccin_actif = true
    agent.infectious = false

    return nothing
end

# Nous allons enfin écrire une fonction pour trouver l'ensemble des agents d'une
# population qui sont dans la même cellule qu'un agent:

"""
   incell(target::Agent, pop::Population)
 
Cette fonction permet de  trouver l'ensemble des agents d'une population qui
sont dans la même cellule qu'un agent donné.
'target' doit être de type Agent. 'pop' doit être de type Population.
"""
incell(target::Agent, pop::Population) = filter(ag -> (ag.x, ag.y) == (target.x, target.y), pop)

# La contagiant n'étant pas systématique, cette fonction permet d'ajouter un peu d'aléatoir
# dans quel agent contractera la maladie après exposition à un malade

"""
    contagiant!(pop::Population, time)
Cette fonction simule la propagation de la maladie d'un agent infécté à un autre sain après 
que les deux aient été en contact (présent dans la même cellule).
La contagiant n'est pas systématique, il y a une probabilité de 40% que la personne saine attrape
la maladie après son contact avec l'agent malade.
'pop' doit être de type Population. 'time' doit être de type Int (c'est la date de la contagiant).
"""
function contagiant!(pop::Population, time)
    for agent in Random.shuffle(infectious(pop))
        neighbors = NotProtected(incell(agent, pop))
        for neighbor in neighbors

            ## Probabilité de contagiant lors de l'exposition à un malade, contagiant non possible si l'agent est vacciné

            if rand() <= 0.4
                neighbor.infectious = true

                ## Ajout de l'évènement d'infection à la fiche des évènements

                push!(events, InfectionEvent(time, agent.id, neighbor.id, agent.x, agent.y))
            end
        end
    end
end

# ## Paramètres initiaux

# Notez qu'on peut réutiliser notre _alias_ pour écrire une fonction beaucoup plus
# expressive pour générer une population:

"""
    Population(L::Landscape, n::Integer)
Cette fonction permet de générer aléatoirement n agents différents dans l'espace
L.
'L' doit être de type Landscape. 'n' doit être de type Integer.
"""
function Population(L::Landscape, n::Integer)
    return rand(Agent, L, n)
end

# On en profite pour simplifier l'affichage de cette population:

Base.show(io::IO, ::MIME"text/plain", p::Population) = print(io, "Une population avec $(length(p)) agents")

# Et on génère notre population initiale:

population = Population(L, 3750)

# Pour commencer la simulation, il faut identifier un cas index, que nous allons
# choisir au hasard dans la population un agent qui devient malade :

rand(population).infectious = true

# Nous initialisons la simulation au temps 0, et nous allons la laisser se
# dérouler au plus 2000 pas de temps:

tick = 0
maxlength = 2000

# Pour étudier les résultats de la simulation, nous allons stocker la taille de
# populations à chaque pas de temps,
# 'S' pour les individus pas encore infecté,
# 'I' pour les agents malade, 'mort' pour les agents infectieux depuis plus de 21
# jours, 'retabli' pour les agent ayant recu un vaccin qui s'est activé après 2
# générations, et 'test_positif' pour les agents testé avec le RAT et qui ont été
# declarés malade : 

S = zeros(Int64, maxlength);
I = zeros(Int64, maxlength);
mort = zeros(Int64, maxlength);
retabli = zeros(Int64, maxlength);
test_positif = zeros(Int64, maxlength);

# Mais nous allons aussi stocker tous les évènements importants pendant la
# simulation, dans des types immutables :

# Évenements d'infection

struct InfectionEvent
    time::Int64
    from::UUIDs.UUID
    to::UUIDs.UUID
    x::Int64
    y::Int64
end

events = InfectionEvent[]

# Évènement de mort

struct MortEvent
    time::Int64
    who::UUIDs.UUID
    x::Int64
    y::Int64
end

qui_meurt = MortEvent[]

# Évenements d'activation de vaccin

struct ProtectionEvent
    time::Int64
    who::UUIDs.UUID
    x::Int64
    y::Int64
end

protegee = ProtectionEvent[]

# Évenements de test RAT

struct TestEvent
    time::Int64
    who::UUIDs.UUID
    x::Int64
    y::Int64
end

agent_teste = TestEvent[]

# Évenements de test positif

struct TestPositif
    time::Int64
    who::UUIDs.UUID
    x::Int64
    y::Int64
end

positif_test = TestPositif[]

# On defini le nombre de personne qui seront testés : 'nb_tirage'.

# Pour limiter la propagation de la maladie, 
# on veut tester le plus de personnes possible pour avoir une idée de
# la prévalence de la maladie, tout en ne dépassant pas
# un budget fixé (environ la moitié du budget initiale) pour laisser assez
# d'argent aux vaccins.

nb_tirage = 900

# ## Simulation

# La simulation continue de tourner simulant le temps qui passe (un pas de temps
# = une generation) La simulation s'arrête si on atteint le nombre max de
# génération, ou si le nombre d'infecté devient nul, signifier la fin de
# l'épidémie. (possible par la mort des agents avant une nouvelle contagiant ou
# l'éradication de la maladie grâce au vaccin)

while (length(infectious(population)) != 0) & (tick < maxlength) ## TP: ce serait peut-être une bonne idée de faire des fonctions pour simplifier ce code (plus tard)

    ## On spécifie que nous utilisons les variables définies plus haut

    global tick, population, test_positif, nb_tirage

    tick += 1

    ## Movement

    for agent in population
        move!(agent, L; torus=false)
    end

    ## Infection

    contagiant!(population, tick)

    ## Change in survival

    for agent in infectious(population)
        agent.clock -= 1

        ## Suivi des évènements de mort 

        if agent.clock == 0
            push!(qui_meurt, MortEvent(tick, agent.id, agent.x, agent.y))
        end
    end

    ## Enregistrement du nombre de mort 

    deadagent = filter(x -> x.clock == 0, population)
    mort[tick] = length(deadagent)

    ## Remove agents that died

    population = filter(x -> x.clock > 0, population)

    ## début compagne test et vaccination après le premier mort qui indique 
    ## la présence de cette maladie asymptomatiques   

    if length(population) < 3750

        ## Stratégie utilisé : 
        ## On tire alétoirement un nombre d'agent qu'on va tester      

        populationAtester = StatsBase.sample(population, nb_tirage, replace=false)
        for personne in populationAtester

            ## On cére un vecteur avec les individus testés positifs après
            ## vérification qu'on a le font nécessaire et on veut que le vecteur 
            ## soit present en dehors de la boucle pour extraire les donnée qu'il contient

            if budget_initiale >= (cout_test * length(populationAtester))

                global test_positif

                agent_test_positif = filter(x -> RAT!(personne, tick), populationAtester)
                test_positif[tick] = length(agent_test_positif)

                for infecte in agent_test_positif

                    push!(positif_test, TestPositif(tick, infecte.id, infecte.x, infecte.y))

                    ## on vaccine les personnes testés positif si elles ne
                    ## sont pas déja vaccinées seulement si on a l'argent
                    ## pour le vaccin

                    if (nonvaccinee(infecte)) & (budget_initiale >= cout_vaccin)
                        vaccinate!(infecte, tick)
                    end

                    ## puis on trouve les personnes dans la même cellule spatiale
                    ## que les individus positif (zone à risque)

                    personnes = incell(infecte, population)
                    for p in personnes

                        ## Si l'individu n'est pas encore vacciné,
                        ## on le vaccine s'il y a assez d'argent dans le budget

                        if (nonvaccinee(p)) & (budget_initiale >= cout_vaccin)
                            vaccinate!(p, tick)
                        end

                    end
                end
            end
        end

        ##  Baisse du nombre de personne échantilloné aléatoirement pour le RAT,
        ## tout en gardant un nombre entier (Int) grâce a l'arrondissement vers la valeur la plus proche:

        nb_tirage = round(Int, nb_tirage * 0.2)

        ## activation du vaccin apres delais de 2 generation

        for personne in vaccinated(population)
            if tick == (personne.date_vaccin + 2)
                activ_vaccin!(personne)

                ## on peut enregistrer l'activation du vaccin

                push!(protegee, ProtectionEvent(tick, personne.id, personne.x, personne.y))
                println("activVac")
            end
        end
    end

    ## stockage du nombre de personnes guérie après vaccination 
    ## (donc le nombre de persone qui ont survécu assez longtemps pour l'activation du vaccin)

    retabli[tick] = length(protected(population))

    ## Store population size

    S[tick] = length(healthy(population))
    I[tick] = length(infectious(population))

end

# ### Série temporelle
# Avant toute chose, nous allons couper les séries temporelles au moment de la
# dernière génération:

S = S[1:tick];
I = I[1:tick];
mort = mort[1:tick];
retabli = retabli[1:tick];
test_positif = test_positif[1:tick];

# ### Nombre de cas par individu infectieux
# Nous allons ensuite observer la distribution du nombre de cas créés par chaque
# individus. Pour ceci, nous devons prendre le contenu de `events`, et vérifier
# combien de fois chaque individu est représenté dans le champ `from`: parcourt
# tous les event dans le vecteur events et extrait .from de chaque élément,
# formant un nouveau vecteur des valeurs event.from 
# + countmap() prend ce vecteur et renvoie un dictionnaire Dict qui compte
#   combien de fois chaque valeur apparaît

infxn_by_uuid = countmap([event.from for event in events]);

# La commande `countmap` renvoie un dictionnaire, qui associe chaque UUID au
# nombre de fois ou il apparaît:
# Notez que ceci nous indique combien d'individus ont été infectieux au total:

length(infxn_by_uuid)

# On compte également combien de personne meurt, est protégé par le vaccin 
# et combien de test sont fait à chaque generation

dico_mort = countmap([corp.time for corp in qui_meurt]);
dico_protegee = countmap([gueri.time for gueri in protegee]);
dico_test = countmap([rat.time for rat in agent_teste]);

# À combien de génération il y a eu une intervention pour tester les agents 
# Et combien de personne ont pu être sauvé grâce au vaccin :

length(dico_test)
length(dico_protegee)

# Pour savoir combien de fois chaque nombre d'infections apparaît, il faut
# utiliser `countmap` une deuxième fois:

nb_inxfn = countmap(values(infxn_by_uuid))

# # Présentation des résultats

# Au début de la simulaton la population est composé de **3750 agents**.

# ## _Avant l'intervention pour controler la maladie_ :
#
# 1730 évènements d'infection se sont produit, 2894 agents meurt 
# et la population finale contient seulement 856 agents encore
# vivant.

# ## _Après l'intervention_ :
#
# Affichage des informations pertinante :
# Ce qui reste du budget initial, dans quoi l'argent 
# a été investi et le nombre restant d'agents dans la population

println("Le nombre d'agent encore vivant est ", length(population))
println( "Ce qui reste du budget de 21 000 est : ", budget_initiale )
println( "L'argent total dépensé dans des tests est:", sum_rat_prix )
println( "L'argent total dépensé dans des vaccins est:", sum_vacc_prix )


#-Courbe de suivis du nombre d'individus dans la population 

f = Figure()
ax = Axis(f[1, 1]; xlabel="Génération", ylabel="Population")
stairs!(ax, 1:tick, S, label="Susceptibles", color=:orange)
stairs!(ax, 1:tick, I, label="Infectieux", color=:red)
stairs!(ax, 1:tick, test_positif, label="Malade détecté", color=:yellow)
stairs!(ax, 1:tick, mort, label="mort", color=:black)
stairs!(ax, 1:tick, retabli, label="rétabli", color=:green)
axislegend(ax)
current_figure()

# **Figure 1:** Courbes de suivi de la taille des populations des agents sains mais 
# encore à risque, des infectés, des morts, des agents malade detecté et des agents 
# guéri par le vaccin. 

f = Figure()
ax = Axis(f[1, 1]; xlabel="Génération", ylabel="taille population")
lines!(ax, 1:tick, S, label="mort", color=:black)
axislegend(ax)
current_figure()

# **Figure 2:** Courbe de l'évolution de la taille de la population au fils 
# des génération.


f = Figure()
ax = Axis(f[1, 1]; xlabel="Génération", ylabel="Population")
lines!(ax, 1:tick, test_positif, label="Malade détecté", color=:blue)
lines!(ax, 1:tick, retabli, label="rétabli", color=:green)
axislegend(ax)
current_figure()

# **Figure 3:** Courbes du nombre d'agents malades détéctés 
# et du nombre d'agent avec un vaccin actif au fil des générations.

f = Figure()
ax = Axis(f[1, 1]; xlabel="Nombre d'infections", ylabel="Nombre d'agents")
scatterlines!(ax, [get(nb_inxfn, i, 0) for i in Base.OneTo(maximum(keys(nb_inxfn)))], color=:black)
f

# **Figure 4:** Courbe du nombre d'agent infectieux en fonction du nombre
# d'agent qu'ils infectent.

# => en moyenne les agents contaminent 10 autres personnes. 
# (distribution normale)

f = Figure()
ax = Axis(f[1, 1]; xlabel="génération", ylabel="Nombre de mort")
lines!(ax, 1:tick, mort, label="mort", color=:black)
f

# **Figure 5:** Courbe du nombre de mortalité en fonction du temps.

f = Figure()
ax = Axis(f[1, 1]; xlabel="génération", ylabel="Nombre de test")
scatterlines!(ax, [get(dico_test,i , 0) for i in Base.OneTo(maximum(keys(dico_test)))], color=:black)
f

# **Figure 6:** Courbe de suivi des tests effectués.

nb_sauvé = countmap(values(dico_protegee))
f = Figure()
ax = Axis(f[1, 1]; xlabel="générations", ylabel="nombre de vaccin")
scatterlines!(ax, [get(dico_protegee, i, 0) for i in Base.OneTo(maximum(keys(dico_protegee)))], color=:black)
f

# **Figure 6:** Suivi du nombre d'agent vacciné.

# ## Hotspots
# Nous allons nous intéresser maintenant à la propagation spatio-temporelle de
# l'épidémie. Pour ceci, nous allons extraire l'information sur le temps et la
# position de chaque infection, puis les représenter dans un graphique:

t = [event.time for event in events];
pos = [(event.x, event.y) for event in events];

f = Figure()
ax = Axis(f[1, 1]; aspect=1, backgroundcolor=:grey97)
hm = scatter!(ax, pos, color=t, colormap=:navia, strokecolor=:black, strokewidth=1, colorrange=(0, tick), markersize=6)
Colorbar(f[1, 2], hm, label="Time of infection")
hidedecorations!(ax)
current_figure()

# **Figure 8:** Propagation spatio-temporelle de l'infection.

quand = [jour.time for jour in qui_meurt];
ou = [(jour.x, jour.y) for jour in qui_meurt];

f = Figure()
ax = Axis(f[1, 1]; aspect=1, backgroundcolor=:grey97)
hm = scatter!(ax, ou, color=quand, colormap=:navia, strokecolor=:black, strokewidth=1, colorrange=(0, tick), markersize=6)
Colorbar(f[1, 2], hm, label="Time of death")
hidedecorations!(ax)
current_figure()

# **Figure 9:** Suivi spatio-temporel des évenèments de mort.

date_test = [ag_test.time for ag_test in agent_teste];
endroit = [(ag_test.x, ag_test.y) for ag_test in agent_teste];

f = Figure()
ax = Axis(f[1, 1]; aspect=1, backgroundcolor=:grey97)
hm = scatter!(ax, endroit, color=date_test, colormap=:navia, strokecolor=:black, strokewidth=1, colorrange=(20, 26), markersize=20)
Colorbar(f[1, 2], hm, label="Time of test")
hidedecorations!(ax)
current_figure()

# **Figure 10:** Suivi spatio-temporel des test effectués

t = [event.time for event in events];
pos = [(event.x, event.y) for event in events];
date_test = [ag_test.time for ag_test in agent_teste];
endroit = [(ag_test.x, ag_test.y) for ag_test in agent_teste];

f = Figure()
ax1 = Axis(f[1, 1]; aspect=1, backgroundcolor=:grey97)
hm1 = scatter!(ax1, pos, color=t, colormap=:navia, strokecolor=:black, strokewidth=1, colorrange=(0, tick), markersize=6)
ax = Axis(f[1, 1]; aspect=1, backgroundcolor=:grey97)
hm = scatter!(ax, endroit, color=date_test, colormap=:navia, strokecolor=:white, strokewidth=1, colorrange=(0, tick), markersize=10)
Colorbar(f[1, 2], hm, label="Time")
hidedecorations!(ax)
current_figure()

# **Figure 10:** Suivi spatio-temporel des test effectués superposé
# au évènements d'inection.


# # Discussion

# Pour rappel, l'objectif de cette étude était d'évaluer l'efficacité d'une stratégie ciblée de 
# vaccination après dépistage aléatoire, pour limiter la propagation d'une maladie infectieuse dans un contexte
# de ressources limitées. L'hypothèse initiale était que cette approche permettrait de réduire le  
# nombre d'infections ainsi que la mortalité. Toutefois, les résultats obtenus suggèrent que 
# cette stratégie n'a pas permis de réduire ou de contrôler efficacement l'épidémie, 
# et donc l'hypothèse n'est pas supporté.


# Dans un premier temps, les résultats montrent une propagation importante de la maladie dans la
# population. En effet, la Figure 1 met en évidence une diminution marquée du nombre d'agents
# susceptibles au cours du temps, indiquant que la majorité des individus est progressivement
# infectée puis retirée de la population par mortalité. Cette tendance est confirmée aussi par 
# la diminution importante de la taille totale de la population (agents encore vivants), ce qui
# reflète indirectement une mortalité élevée puisque dans le modèle, les individus ne quittent la 
# population qu'au moment de leur décès suite à l'infection. La Figure 2 précise cette dynamique en montrant que le
# population qu'au moment de leur décès, suite à l'infection. La Figure 3 précise cette dynamique en montrant que le
# nombre de décès augmente jusqu'à atteindre un certain pic, puis diminue progressivement. Cette évolution
# suggère qu'il y a une diminution des nouveaux cas d'infections au cours du temps, ce qui est en lien avec la
# réduction du nombre d'individus susceptibles. En effet, si le nombre d'agents pouvant être infectés
# diminue, les interactions menant à de nouveaux cas d'infections deviennent moins fréquentes, 
# ce qui limite la propagation de la maladie et entraîne donc une diminution du nombre de décès 
# observés. De plus, la comparaison directe des courbes d'infection et de mortalité dans la Figure 3 permet de 
# mieux visualiser leur relation temporelle, où le pic de mortalité suit celui des infections, 
# ce qui reflète le délai entre l'infection et le décès dans le modèle. Cette interprétation est
# en fait cohérente avec la littérature sur les modèles épidémiologiques, qui démontre que la 
# croissance d'une épidémie ralentit quand les individus sont progressivement retirés du groupe
# d'agents susceptibles, ce qui mène à un ralentissement progressif de la transmission 
# @gomes2022individual. 

# De plus, la difficulté à contrôler l'épidémie peut s'expliquer en grande partie par la 
# faible efficacité des interventions qui ont été mises en place. La Figure 1 montre que le 
# nombre d'agents infectieux reste relativement faible, mais que les individus détectés et 
# protégés par la vaccination sont presque nuls.
# Cela indique que très peu d'individus sont effectivement identifiés ou protégés. Cette inefficacité
# peut s'expliquer par le caractère asymptomatique de la maladie simulée, rendant la détection des
# cas plus difficile en l'absence de dépistage systématique. De plus, l'échantillonage aléatoire
# des individus à tester réduit la probabilité de cibler les individus infectés ou même les 
# zones à risque. Ce résultat est cohérent avec les données de la littérature, selon lesquelles
# une proportion importante des infections peut rester asymptomatique, rendant leur détection
# plus difficile, tandis que les stratégies ciblées réduisent la transmission plus que des
# approches non ciblées @kucharski2020effectiveness.

# Cette limitation du dépistage est également illustrée par la Figure 4, où les tests sont 
# administrés seulement sur un nombre restreint de générations, indiquant une intervention
# de courte durée. De manière cohérente, la Figure 4 montre aussi que 
# le nombre d'agents vaccinés reste presque nul pendant la majorité de la simulation, ce qui reflète
# le faible nombre de cas détectés et limite fortement la protection de la population. Ainsi, 
# l'intensité et la durée insuffisantes de l'intervention contribuent directement à
# l'échec du contrôle de l'épidémie. Cette idée rejoint aussi les travaux de Hellewell et al. (2020),
# qui montrent que le contrôle d'une épidémie dépend fortement de la capacité à identifier
# une proportion suffisante des individus infectés @hellewell2020feasibility.

# En parallèle, la forte propagation observée s'explique également par la transmissibilité élevée de
# la maladie. La Figure 2 montre que chaque agent infecté transmet la maladie à un nombre relativement
# élevé d'autres agents, avec une moyenne d'environ 10 infections par individu. Cette capacité de 
# tranmission favorise une diffusion rapide de l'infection dans la population, ce qui contribue à la
# diminution importante du nombre d'individus susceptibles ainsi qu'à la mortalité élevée observée.
# Cela est aussi cohérent avec la littérature, qui montre que plus un individu infecté transmet la
# maladie à un grand nombre d'autres individus, plus la propagation de l'épidémie est rapide et 
# difficile à contrôler @avraam2025impact. 

# Enfin, l'analyse spatiale apporte une compréhension complémentaire de la dynamique observée. La
# Figure 5 montre que les infections sont largement dispersées dans l'espace, suggérant une propagation
# progressive à l'ensemble de la population plutôt qu'une zone limitée. Cette dispersion est favorisée
# par les déplacements aléatoires des agents, permettant à l'infection d'atteindre la majorité des
# régions. Cela est appuyée par la littérature, qui identifie la mobilité comme un facteur important
# de la propagation spatiale des épidémies @findlater2018human. La Figure 6 montre que les décès
# suivent une distribution spatiale similaire, suggérant que les zones de forte transmission deviennent 
# également des zones de forte mortalité, ce qui est cohérent avec la dynamique du modèle où les 
# individus infectés finissent par mourir. Ensuite, la Figure 7 met en évidence que les tests sont
# distribués de manière inégale dans l'espace et le temps, indiquant une couverture
# insuffisante du dépistage. Cette absence de couverture homogène permet à certaines zones de tranmission
# d'échapper à la détection, favorisant ainsi la persistance et la diffusion de l'épidémie dans l'ensemble
# de l'espace étudié. Cette observation est aussi confirmée par la Figure 8, où la superposition des tests
# et des événements d'infection montre que les tests ne sont pas réalisés dans les zones de plus forte
# transmission. Ainsi, le dépistage ne cible pas efficacement les zones d'infection, ce qui limite son
# impact sur la réduction de la propagation de la maladie. 

# Pour tenir compte de la variabilité liée aux processus aléatoires du modèle, trois simulations
# indépendantes ont été réalisées dans les mêmes conditions. Dans l'ensemble, la comparaison de ces
# trois simulations met en évidence des résultats similaires, caractérisés par une mortalité élevée et 
# une proportion faible d'individus protégés, malgré des légères variations. Cette cohérence suggère que
# la stratégie mise en place est globalement inefficace dans ce contexte. 

# Les différences observées entre
# les simulations s'expliquent toutefois par la nature stochastique du modèle. Autrement dit, certains
# mécanismes du modèle reposent sur des tirages aléatoires (contacts, déplacements, sélection des individus
# testés), ce qui peut générer des variations d'une simulation à l'autre malgré des conditions initiales
# identiques. En effet, la position intiale de l'agent infecté, les déplacements aléatoires des individus
# ainsi que la sélection aléatoire des agents testés influencent la dynamique de propagation et les interventions
# nécessaires. Ainsi, selon les trajectoires des agents et les interactions qui se produsent, certaines zones
# peuvent être touchées plus rapidement ou intensément que d'autres. Ces différences se reflètent dans les 
# figures associées aux simulations 2 et 3, où on observe de légères variations dans l'évolution des courbes 
# de la population, du nombre d'infectés et de la mortalité (Figures 1 et 3). D'un point de vue biologique,
# cela reflète la variabilité naturelle des interactions entre individus au sein d'une population, où
# les contacts ne sont pas parfaitement prévisibles. De même, les distributions
# du nombre d'infections par individu (Figure 2) restent globalement similaires entre les simulations, mais
# présentent quelques fluctuations dans la fréquence des agents qui transmettent fortement la maladie, ce
# qui correspond à l'existence d'une hétérogénéité individuelle dans la transmission. En effet, 
# certains individus peuvent infecter un grand nombre d'agents, tandis que d'autres infectent très peu Cela est
# un phénomène souvent associé aux événements de « super-propagation », où les variations individuelles
# de transmission jouent un rôle majeur dans la dynamique de propagation de l'épidémie @nielsen2023conterintuitive.
# Enfin les figures spatiales (Figures 5, 6 et 7) montrent que la localisation
# et l'intensité des zones d'infection varient d'une simulation à l'autre, malgré une propagation comparable.
# Biologiquement, cela traduit le fait que la propagation d'une maladie dépend fortement des mouvements individuels 
# et des contacts locaux, qui peuvent coréer des zones d'infections distinctes dans l'espace @findlater2018human. 
# Donc, même en présence de paramètres identiques, les dynamiques locales peuvent varier en fonction des
# interactions aléatoires entre individus, ce qui influence la formation et la dispersion des zones de 
# transmission.


# # Conclusion

# En conclusion, cette étude montre que la stratégie ciblée de dépistage et de vaccinaation n'a pas permis
# de contrôler efficacement la propagation de la maladie dans le contexte simulé, et donc ne soutient pas 
# l'hypothèse initiale. Malgré l'implémentation de cette stratégie, les niveaux de transmission et mortalité
# restent élevées, en raison notamment d'un dépistage insuffisant et d'une couverture vaccinale très limitée,
# qui ne permet pas d'arrêter les chaînes de transmission. Les résultats mettent également en évidence l'importance
# des processus stochastiques et de variabilité individuelle dans la dynamique de propagation, qui influencent la
# distribution spatiale et l'intensité de l'épidémie même quand les conditions initiales sont identiques. Ainsi,
# cette étude souligne que, pour être efficace, une stratégie d'intervention doit être non seulement ciblée, mais 
# aussi suffisament intensive et adaptée aux zones à risque pour limiter efficacement la propagation de la maladie. 
# Donc, l'ensemble de ces observations suggère que malgré les efforts de modélisation et de contrôle, une part
# d'imprévisibilité reste toujours présente dans la propagation des maladies, influencée par la complexité
# des interactions individuelles.


