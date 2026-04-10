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
#      github: DeuxiAut
#    - nom: Auteur
#      prenom: troiseme
#      matricule: XXXXXXXX
#      github: TroisiAut
# ---

# # Introduction

# La propagation rapide des maladies infectieuses constitue un défi majeur en
# santé publique, en raison de la complexité des interactions entre individus et
# des dynamiques de transmission.  La compréhension de ces dynamiques est
# essentielle afin de mettre en place des stratégies efficaces pour limiter la
# propagation d’un agent pathogène. La modélisation constitue un outil important
# en épidémiologie, permettant de simplifier la réalité pour étudier l’impact de
# différents paramètres sur l’évolution d’une épidémie (@keeling2008modeling).

# Dans ce travail, nous simulons la propagation d’une maladie infectieuse au
# sein d’une population d’individus mobiles, qui entrent en contact les uns avec
# les autres. La transmission survient lors de ces interactions, selon une
# probabilité fixe, ce qui permet de représenter simplement le processus de
# contagion tout en conservant les mécanismes essentiels de propagation. Dans ce
# cas, la maladie est supposée être toujours fatale après une durée déterminée,
# pour permettre de simplifier la dynamique du modèle et de se concentrer sur
# l’évolution de l’infection dans la population.

# Plusieurs contraintes ont été intégrées à la simulation afin de représenter
# des conditions proches de la réalité. Premièrement, les individus infectés
# sont asymptomatiques, ce qui signifie qu’ils peuvent être détectés seulement à
# l’aide de tests diagnostiques. En effet, une proportion importante des
# infections peut se produire sans symptômes, rendant leur identification
# difficile sans dépistage (@oran2020prevalence). De plus, les tests utilisés ne
# sont pas parfaitement fiables et peuvent produire des faux négatifs, ce qui
# introduit une incertitude supplémentaire dans la prise de décision.
# Deuxièmement, la vaccination constitue le principal moyen d’intervention dans
# le modèle. Une fois ative, elle empêche les individus de contracter la maladie
# et de contribuer à sa propagation. Toutefois, un délai est nécessaire avant
# que la vaccination ne devienne active, ce qui correspond au temps requis pour
# que le système immunitaire développe une réponse protectrice (@nikoloudis2025delayed).
# Cette contrainte est essentielle parce qu’elle influence
# directement l’efficacité des stratégies mises en place. Enfin, un budget
# limité est imposé pour la réalisation des tests et l’administration des
# vaccins. Cette contrainte reflète les réalités des systèmes de santé, où selon
# l’Organisation mondiale de la santé, les ressources sont restreintes et
# doivent être utilisées de manière optimale. Ainsi, les décisions de dépistage
# et de vaccination doivent être prises de façon stratégique afin de maximiser
# la réduction de la propagation de la maladie. Dans ce contexe, nous adoptons
# une stratégie ciblée inspirée du traçage des contacts et de la vaccination en
# anneau. À partir du premier décès, les interventions sont concentrées dans les
# cellules spatiales contenaant des individus infectés, considérées comme des
# zones à risque de transmission. Les individus présents dans ces cellules sont
# testés, puis ceux qui obtiennent un résultat positif ont vaccinés. Des études
# ont en fait montré que le traçage des contacts permet de contrôler
# efficacement la propagation des épidémies en identifiant rapidement les
# chaînes de tranmissions (@hellewell2020@feasibility), et que la vaccination en
# anneau permet de limiter la propagation en ciblant les individus à haut risque
# autour des cas détectés (@henao2015efficacy).

# La problématique de ce travail est de déterminer comment optimiser
# l'utilisation de ressources limitées pour réduire la propagation d'une maladie
# infectieuse, dans un contexte où les individus infectés sont difficilement
# détectables et où les interventions ont un coût. L’objectif de ce travail est
# donc d’évaluer l’impact d’une stratégie de dépistage et de vaccination sur la
# propagation d’une maladie infectieuse, en tenant compte de contraintes
# biologiques et économiques réalistes. Cette approche permet de mieux
# comprendre comment différentes décisions d’intervention influencent
# l’évolution d’une épidémie. Nous posons l'hypothèse qu'une stratégie ciblée de
# dépistage et de vaccination, concentrée sur les zones à risques définies par
# la présence d'individus infectés, permettra de réduire plus efficacement la
# mortalité qu'une stratégie aléatoire (@henao2015efficacy). Nous
# attendons à oberver une diminution significative du nombre d'individus
# infectés au cours du temps, ainsi qu'une réduction de la dispersion spatiale
# des événements d'infection, ce qui suggère une limitation de la propagation de
# la maladie.


# # Présentation du modèle

# # Implémentation

# ## Packages nécessaires

import Random
using CairoMakie
CairoMakie.activate!(px_per_unit=6.0)
using StatsBase
import UUIDs

# point de départ initié pour assurer la réplication des résultats

Random.seed!(123456)

# ## Inclure du code

# Tous les fichiers dans le dossier `code` peuvent être ajoutés au travail
# final. C'est par exemple utile pour déclarer l'ensemble des fonctions du
# modèle hors du document principal.

# Le contenu des fichiers est inclus avec `include("code/nom_fichier.jl")`.

# Attention! Il faut que le code soit inclus au bon endroit (avant que les
# fonctions déclarées soient appellées).

include("code/01_test.jl")

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

agent = Agent()

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
# générations et 'detecte' pour les agents testé avec le RAT et qui ont été
# declarés malade : 

S = zeros(Int64, maxlength);
I = zeros(Int64, maxlength);
mort = zeros(Int64, maxlength);
retabli = zeros(Int64, maxlength);
detecte = zeros(Int64, maxlength);
nb_test = zeros(Int64, maxlength); ## a enlever

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

# évènement de mort

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

# evenement de test positif

struct TestPositif
    time::Int64
    who::UUIDs.UUID
    x::Int64
    y::Int64
end

positif_test = TestPositif[]

# On defini le nombre de personne qui seront testés : 'nb_tirage'. Pour limiter
# la propagation de la maladie, on veut tester le plus de personnes possible
# pour avoir une idée de la prévalence de la maladie, tout en ne dépassant pas
# un budget fixé (environ la moitié du budget initiale) pour laisser assez
# d'argent aux vaccins.

nb_tirage = 900
test_positif = zeros(Int64, maxlength);

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

    ## début compagne test et vaccination après le premier mort qui indique la présence de cette maladie asymptomatiques   

    if length(population) < 3750

        ## Stratégie utilisé : 
        ## On tire alétoirement un nombre d'agent qu'on va tester      

        populationAtester = StatsBase.sample(population, nb_tirage, replace=false)
        for personne in populationAtester

            ## On cére un vecteur avec les individus testés positifs après vérification qu'on a le font nécessaire
            ## et on veut que le vecteur soit present en dehors de la boucle pour extraire les donnée qu'il contient

            if budget_initiale >= (cout_test * length(populationAtester))

                global test_positif

                agent_test_positif = filter(x -> RAT!(personne, tick), populationAtester)
                test_positif[tick] = length(agent_test_positif)

                for infecte in agent_test_positif

                    push!(positif_test, TestPositif(tick, infecte.id, infecte.x, infecte.y))

                    ## on vaccine les personnes testés positif si elles ne sont pas déja vaccinées
                    ## et seulement si on a l'argent pour le vaccin

                    if (nonvaccinee(infecte)) & (budget_initiale >= cout_vaccin)
                        vaccinate!(infecte, tick)
                    end

                    ## puis on trouve les personnes dans la même cellule spatiale que les individus positif (zone à risque)

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

# ## Analyse des résultats
# ### Série temporelle
# Avant toute chose, nous allons couper les séries temporelles au moment de la
# dernière génération:

S = S[1:tick];
I = I[1:tick];
mort = mort[1:tick];
retabli = retabli[1:tick];
test_positif = test_positif[1:tick];

#-Courbe de suivis du nombre d'individus dans la population 
# Courbe orange pour les agents enore à risque
# Courbe rouge pour tous les agents véritablement infectieux
# Courbe jaune pour les agents infectieux détecté 
# Courbe noire pour les agents mort suite à la maladie
# Courbe verte pour les agents qui ont pu être protégé grace au vaccin

f = Figure()
ax = Axis(f[1, 1]; xlabel="Génération", ylabel="Population")
stairs!(ax, 1:tick, S, label="Susceptibles", color=:orange)
stairs!(ax, 1:tick, I, label="Infectieux", color=:red)
stairs!(ax, 1:tick, test_positif, label="Malade détecté", color=:yellow)
stairs!(ax, 1:tick, mort, label="mort", color=:black)
stairs!(ax, 1:tick, retabli, label="rétabli", color=:green)
axislegend(ax)
current_figure()

# Suivi du nombre total d'agent au fil des générations

f = Figure()
ax = Axis(f[1, 1]; xlabel="Génération", ylabel="taille population")
lines!(ax, 1:tick, S, label="mort", color=:black)
axislegend(ax)
current_figure()

# ### Nombre de cas par individu infectieux
# Nous allons ensuite observer la distribution du nombre de cas créés par chaque
# individus. Pour ceci, nous devons prendre le contenu de `events`, et vérifier
# combien de fois chaque individu est représenté dans le champ `from`: parcourt
# tous les event dans le vecteur events et extrait .from de chaque élément,
# formant un nouveau vecteur des valeurs event.from 
# + countmap() prend ce vecteur et renvoie un dictionnaire Dict qui compte
#   combien de fois chaque valeur apparaît

infxn_by_uuid = countmap([event.from for event in events]);

# On compte également combien de personne meurt, est protégé par le vaccin 
# et combien de test sont fait à chaque generation

dico_mort = countmap([corp.time for corp in qui_meurt]);
dico_protegee = countmap([gueri.time for gueri in protegee]);
dico_test = countmap([rat.time for rat in agent_teste])

# La commande `countmap` renvoie un dictionnaire, qui associe chaque UUID au
# nombre de fois ou il apparaît:
# Notez que ceci nous indique combien d'individus ont été infectieux au total:

length(infxn_by_uuid)

length(dico_mort)
length(dico_protegee)
length(dico_test)

# Pour savoir combien de fois chaque nombre d'infections apparaît, il faut
# utiliser `countmap` une deuxième fois:

nb_inxfn = countmap(values(infxn_by_uuid))

# On peut maintenant visualiser ces données:

# 

f = Figure()
ax = Axis(f[1, 1]; xlabel="Nombre d'infections", ylabel="Nombre d'agents")
scatterlines!(ax, [get(nb_inxfn, i, 0) for i in Base.OneTo(maximum(keys(nb_inxfn)))], color=:black)
f

# en moyenne les agents contaminent 10 autres personnes. 
#(distribution normale)

# mortalité au fil des générations

f = Figure()
ax = Axis(f[1, 1]; xlabel="temps", ylabel="Nombre de mort")
lines!(ax, 1:tick, mort, label="mort", color=:black)
f

#

# Pas possible d'afficher la figure suivante vu qu'il n'y a aucun individus
# protégé
#nb_sauvé = countmap(values(dico_protegee))
#f = Figure()
#ax = Axis(f[1, 1]; xlabel="Nombre de protégé", ylabel="temps")
#scatterlines!(ax, [get(nb_sauvé, i, 0) for i in Base.OneTo(maximum(keys(nb_sauvé)))], color=:black)
#f

#

# marche pas => 

f = Figure()
ax = Axis(f[1, 1]; xlabel="Nombre de test", ylabel="temps")
scatterlines!(ax, [get(dico_test, , 0) for i in Base.OneTo(maximum(keys(dico_test)))], color=:black)
f

# ### Hotspots
# Nous allons enfin nous intéresser à la propagation spatio-temporelle de
# l'épidémie. Pour ceci, nous allons extraire l'information sur le temps et la
# position de chaque infection:

t = [event.time for event in events];
pos = [(event.x, event.y) for event in events];

## figure qui donne la date de l'infection 

f = Figure()
ax = Axis(f[1, 1]; aspect=1, backgroundcolor=:grey97)
hm = scatter!(ax, pos, color=t, colormap=:navia, strokecolor=:black, strokewidth=1, colorrange=(0, tick), markersize=6)
Colorbar(f[1, 2], hm, label="Time of infection")
hidedecorations!(ax)
current_figure()

## suivie des testes effectués 

date_test = [ag_test.time for ag_test in agent_teste];
endroit = [(ag_test.x, ag_test.y) for ag_test in agent_teste];
f = Figure()
ax = Axis(f[1, 1]; aspect=1, backgroundcolor=:grey97)
hm = scatter!(ax, endroit, color=date_test, colormap=:navia, strokecolor=:black, strokewidth=1, colorrange=(0, tick), markersize=6)
Colorbar(f[1, 2], hm, label="Time of test")
hidedecorations!(ax)
current_figure()

## on veut suivre les morts

quand = [jour.time for jour in qui_meurt];
ou = [(jour.x, jour.y) for jour in qui_meurt];

f = Figure()
ax = Axis(f[1, 1]; aspect=1, backgroundcolor=:grey97)
hm = scatter!(ax, ou, color=quand, colormap=:navia, strokecolor=:black, strokewidth=1, colorrange=(0, tick), markersize=6)
Colorbar(f[1, 2], hm, label="Time of death")
hidedecorations!(ax)
current_figure()

## affichage des informations pertinante 
# tel que l'argent restant et les dépensense totales

println( "Ce qui reste du budget de 21 000 est : ", budget_initiale )
println( "L'argent total dépensé dans des tests est:", sum_rat_prix )
println( "L'argent total dépensé dans des vaccins est:", sum_vacc_prix )

# Mais aussi le nombre restant d'agents dans la population

println("Le nombre d'agent encore vivant est ", length(population))

#=
# # Présentation des résultats

# Avant tout intervention, a la fin de la simulation on obtenais 1730 infections
# au total, 2894 morts et une population finale de seulement 856 agents encore
# vivant.
#

# La figure suivante représente des valeurs aléatoires:
#hist(randn(1000), color=:grey80)
# # Discussion
# On peut aussi citer des références dans le document `references.bib`, qui doit
# être au format BibTeX. Les références peuvent être citées dans le texte avec
# `@` suivi de la clé de citation. Par exemple: @ermentrout1993cellular -- la
# bibliographie sera ajoutée automatiquement à la fin du document.
# Le format de la bibliographie est American Physics Society, et les références
# seront correctement présentées dans ce format. Vous ne devez/pouvez pas éditer
# la bibliographie à la main.
=#

