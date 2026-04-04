# ---
# title: Titre du travail
# repository: tpoisot/BIO245-modele
# auteurs:
#    - nom: Auteur
#      prenom: Premier
#      matricule: XXXXXXXX
#      github: premierAuteur
#    - nom: Auteur
#      prenom: Deuxième
#      matricule: XXXXXXXX
#      github: DeuxiAut
# ---

# # Introduction

# La propagation rapide des maladies infectieuses constitue un défi majeur en santé publique, en raison de la complexité des interactions 
# entre individus et des dynamiques de transmission.  La compréhension de ces dynamiques est essentielle afin de mettre en place des 
# stratégies efficaces pour limiter la propagation d’un agent pathogène. La modélisation constitue un outil important en épidémiologie, 
# permettant de simplifier la réalité pour d’étudier l’impact de différents paramètres sur l’évolution d’une épidémie (Keeling & Rohani, 2008).

# Dans ce travail, nous simulons la propagation d’une maladie infectieuse au sein d’une population d’individus mobiles, qui entrent en contact 
# les uns avec les autres. La transmission survient lors de ces interactions, selon une probabilité fixe, ce qui permet de représenter 
# simplement le processus de contagion tout en conservant les mécanismes essentiels de propagation. Dans ce cas, la maladie est supposée 
# être toujours fatale après une durée déterminée, pour permettre de simplifier la dynamique du modèle et de se concentrer sur l’évolution 
# de l’infection dans la population.

# Plusieurs contraintes ont été intégrées à la simulation afin de représenter des conditions proches de la réalité. Premièrement, les 
# individus infectés sont asymptomatiques, ce qui signifie qu’ils peuvent être détectés seulement à l’aide de tests diagnostiques. En effet, 
# une proportion importante des infections peut se produire sans symptômes, rendant leur identification difficile sans dépistage (Oran et Topol, 2020). 
# De plus, les tests utilisés ne sont pas parfaitement fiables et peuvent produire des faux positifs ou des faux négatifs, ce qui introduit une incertitude 
# supplémentaire dans la prise de décision. Deuxièmement, la vaccination constitue le principal moyen d’intervention dans le modèle. Une fois 
# efficace, elle empêche les individus de contracter la maladie et de contribuer à sa propagation. Toutefois, un délai est nécessaire avant 
# que la vaccination ne devienne active, ce qui correspond au temps requis pour que le système immunitaire développe une réponse protectrice 
# (Nikoloudis et al., 2025). Cette contrainte est essentielle parce qu’elle influence directement l’efficacité des stratégies mises en place. 
# Enfin, un budget limité est imposé pour la réalisation des tests et l’administration des vaccins. Cette contrainte reflète les réalités des 
# systèmes de santé, où selon l’Organisation mondiale de la santé, les ressources sont restreintes et doivent être utilisées de manière optimale. 
# Ainsi, les décisions de dépistage et de vaccination doivent être prises de façon stratégique afin de maximiser la réduction de la propagation 
# de la maladie.

# L’objectif de ce travail est donc d’évaluer l’impact d’une stratégie de dépistage et de vaccination sur la propagation d’une maladie infectieuse, 
# en tenant compte de contraintes biologiques et économiques réalistes. Cette approche permet de mieux comprendre comment différentes décisions 
# d’intervention influencent l’évolution d’une épidémie.


# # Présentation du modèle

# # Implémentation

# ## Packages nécessaires

import Random
Random.seed!(123456)
using CairoMakie
CairoMakie.activate!(px_per_unit=6.0)
using StatsBase

# ## Inclure du code

# Tous les fichiers dans le dossier `code` peuvent être ajoutés au travail
# final. C'est par exemple utile pour déclarer l'ensemble des fonctions du
# modèle hors du document principal.

# Le contenu des fichiers est inclus avec `include("code/nom_fichier.jl")`.

# Attention! Il faut que le code soit inclus au bon endroit (avant que les
# fonctions déclarées soient appellées).

include("code/01_test.jl")

# ## Variables
Budget_initiale = 21000
Cout_vaccin = 17
Cout_test = 4
duree_maladie = 21 
delai_vaccin = 2 #2 jours avant que ça devient actif


#############################################################

# Puisque nous allons identifier des agents, nous utiliserons des UUIDs pour
# leur donner un indentifiant unique:

import UUIDs
UUIDs.uuid4()

# ## Création des types

# Le premier type que nous avons besoin de créer est un agent. Les agents se
# déplacent sur une lattice, et on doit donc suivre leur position. On doit
# savoir si ils sont infectieux, et dans ce cas, combien de jours il leur reste:

Base.@kwdef mutable struct Agent
    x::Int64 = 0
    y::Int64 = 0
    clock::Int64 = 20 #temps qui leur reste
    infectious::Bool = false
    id::UUIDs.UUID = UUIDs.uuid4() # identiffiant unique
    vaccine::Bool = false
end

# On peut créer un agent pour vérifier:

Agent()

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
# soit facile a comprendre, nous allons donc ajouter une méthode à cette
# fonction:

Random.rand(::Type{Agent}, L::Landscape) = Agent(x=rand(L.xmin:L.xmax), y=rand(L.ymin:L.ymax))
Random.rand(::Type{Agent}, L::Landscape, n::Int64) = [rand(Agent, L) for _ in 1:n]

# Cette fonction nous permet donc de générer un nouvel agent dans un paysage:

rand(Agent, L)

# Mais aussi de générer plusieurs agents:

rand(Agent, L, 3)

# On peut maintenant exprimer l'opération de déplacer un agent dans le paysage.
# Puisque la position de l'agent va changer, notre fonction se termine par `!`:

"""
    move!(A::Agent, L::Landscape; torus=true)

Cette fonction fait bouger les agents au fils en mettant à jour leurs positions dans l'environnement à chaque pas de temps.

'A' doit être de type Agent.
'L' doit être de type Landscape.
'torus' est de type bool et par défaut true.
"""
function move!(A::Agent, L::Landscape; torus=true)
    A.x += rand(-1:1)
    A.y += rand(-1:1)
    if torus
        A.y = A.y < L.ymin ? L.ymax : A.y # si A.y < L.ymin alors A.y = L.ymax sinon reste A.y
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
# simplifier la rédaction du code. Par exemple, on peut vérifier si un agent est
# infectieux:

"""
    isinfectious(agent::Agent)

Cette fonction renvoie true si l'agent est infecté, elle permet de vérifier l'état infectieux de l'agent.
    
'agent' doit être de type Agent.
"""
isinfectious(agent::Agent) = agent.infectious

# Et on peut donc vérifier si un agent est sain:

"""
    ishealthy(agent::Agent)

Cette fonction renvoie true si l'agent est sain, elle permet de vérifier l'état de santé de l'agent.

'agent' doit être de type Agent
"""
ishealthy(agent::Agent) = !isinfectious(agent)

# On peut maintenant définir une fonction pour prendre uniquement les agents qui
# sont infectieux dans une population. Pour que ce soit clair, nous allons créer
# un _alias_, `Population`, qui voudra dire `Vector{Agent}`:

const Population = Vector{Agent}

"""
    infectious(pop::Population)

Cette fonction permet de filtrer les agents selon leurs états de santé et ne garde en mémoir que les individus infectés.

'pop' doit être de type Population.
"""
infectious(pop::Population) = filter(isinfectious, pop)

"""
    healthy(pop::Population)

Cette fonction permet de filtrer les agents selon leurs états de santé et ne garde en mémoir que les individus sains.

'pop' doit être de type Population.
"""
healthy(pop::Population) = filter(ishealthy, pop)

# Nous allons enfin écrire une fonction pour trouver l'ensemble des agents d'une
# population qui sont dans la même cellule qu'un agent:

"""
   incell(target::Agent, pop::Population)
 
Cette fonction permet de  trouver l'ensemble des agents d'une population qui sont dans la même cellule qu'un agent donné.

'target' doit être de type Agent.
'pop' doit être de type Population.
"""
incell(target::Agent, pop::Population) = filter(ag -> (ag.x, ag.y) == (target.x, target.y), pop)

# ## Paramètres initiaux

# Notez qu'on peut réutiliser notre _alias_ pour écrire une fonction beaucoup plus
# expressive pour générer une population:

"""
    Population(L::Landscape, n::Integer)

Cette fonction permet de générer aléatoirement n agents différents dans l'espace L.

'L' doit être de type Landscape.
'n' doit être de type Integer.
"""
function Population(L::Landscape, n::Integer)
    return rand(Agent, L, n)
end

# On en profite pour simplifier l'affichage de cette population:

Base.show(io::IO, ::MIME"text/plain", p::Population) = print(io, "Une population avec $(length(p)) agents")

# Et on génère notre population initiale:

population = Population(L, 3750)

# Pour commencer la simulation, il faut identifier un cas index, que nous allons
# choisir au hasard dans la population:

rand(population).infectious = true

# Nous initialisons la simulation au temps 0, et nous allons la laisser se
# dérouler au plus 1000 pas de temps:

tick = 0
maxlength = 2000

# Pour étudier les résultats de la simulation, nous allons stocker la taille de
# populations à chaque pas de temps:

S = zeros(Int64, maxlength);
I = zeros(Int64, maxlength);

# Mais nous allons aussi stocker tous les évènements d'infection qui ont lieu
# pendant la simulation:

struct InfectionEvent
    time::Int64
    from::UUIDs.UUID
    to::UUIDs.UUID
    x::Int64
    y::Int64
end

events = InfectionEvent[]

# Notez qu'on a contraint notre vecteur `events` a ne contenir _que_ des valeurs
# du bon type, et que nos `InfectionEvent` sont immutables.

# ## Simulation

while (length(infectious(population)) != 0) & (tick < maxlength)

    ## On spécifie que nous utilisons les variables définies plus haut
    global tick, population

    tick += 1

    ## Movement
    for agent in population
        move!(agent, L; torus=false)
    end

    ## Infection
    for agent in Random.shuffle(infectious(population))
        neighbors = healthy(incell(agent, population))
        for neighbor in neighbors
            if rand() <= 0.4
                neighbor.infectious = true
                push!(events, InfectionEvent(tick, agent.id, neighbor.id, agent.x, agent.y))
            end
        end
    end

    ## Change in survival
    for agent in infectious(population)
        agent.clock -= 1
    end

    ## Remove agents that died
    population = filter(x -> x.clock > 0, population)

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

#-

f = Figure()
ax = Axis(f[1, 1]; xlabel="Génération", ylabel="Population")
stairs!(ax, 1:tick, S, label="Susceptibles", color=:black)
stairs!(ax, 1:tick, I, label="Infectieux", color=:red)
axislegend(ax)
current_figure()

# ### Nombre de cas par individu infectieux

# Nous allons ensuite observer la distribution du nombre de cas créés par chaque
# individus. Pour ceci, nous devons prendre le contenu de `events`, et vérifier
# combien de fois chaque individu est représenté dans le champ `from`:

infxn_by_uuid = countmap([event.from for event in events]);

# La commande `countmap` renvoie un dictionnaire, qui associe chaque UUID au
# nombre de fois ou il apparaît:

# Notez que ceci nous indique combien d'individus ont été infectieux au total:

length(infxn_by_uuid)

# Pour savoir combien de fois chaque nombre d'infections apparaît, il faut
# utiliser `countmap` une deuxième fois:

nb_inxfn = countmap(values(infxn_by_uuid))

# On peut maintenant visualiser ces données:

f = Figure()
ax = Axis(f[1, 1]; xlabel="Nombre d'infections", ylabel="Nombre d'agents")
scatterlines!(ax, [get(nb_inxfn, i, 0) for i in Base.OneTo(maximum(keys(nb_inxfn)))], color=:black)
f

# ### Hotspots

# Nous allons enfin nous intéresser à la propagation spatio-temporelle de
# l'épidémie. Pour ceci, nous allons extraire l'information sur le temps et la
# position de chaque infection:

t = [event.time for event in events];
pos = [(event.x, event.y) for event in events];

#

f = Figure()
ax = Axis(f[1, 1]; aspect=1, backgroundcolor=:grey97)
hm = scatter!(ax, pos, color=t, colormap=:navia, strokecolor=:black, strokewidth=1, colorrange=(0, tick), markersize=6)
Colorbar(f[1, 2], hm, label="Time of infection")
hidedecorations!(ax)
current_figure()


#############################################################
# # Présentation des résultats

# La figure suivante représente des valeurs aléatoires:

hist(randn(1000), color=:grey80)

# # Discussion

# On peut aussi citer des références dans le document `references.bib`, qui doit
# être au format BibTeX. Les références peuvent être citées dans le texte avec
# `@` suivi de la clé de citation. Par exemple: @ermentrout1993cellular -- la
# bibliographie sera ajoutée automatiquement à la fin du document.

# Le format de la bibliographie est American Physics Society, et les références
# seront correctement présentées dans ce format. Vous ne devez/pouvez pas éditer
# la bibliographie à la main.
