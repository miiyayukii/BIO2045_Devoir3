# ---
# title: Titre du travail
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

# La propagation rapide des maladies infectieuses constitue un défi majeur en santé publique, en raison de la complexité des interactions 
# entre individus et des dynamiques de transmission.  La compréhension de ces dynamiques est essentielle afin de mettre en place des 
# stratégies efficaces pour limiter la propagation d’un agent pathogène. La modélisation constitue un outil important en épidémiologie, 
# permettant de simplifier la réalité pour étudier l’impact de différents paramètres sur l’évolution d’une épidémie (Keeling & Rohani, 2008).

# Dans ce travail, nous simulons la propagation d’une maladie infectieuse au sein d’une population d’individus mobiles, qui entrent en contact 
# les uns avec les autres. La transmission survient lors de ces interactions, selon une probabilité fixe, ce qui permet de représenter 
# simplement le processus de contagion tout en conservant les mécanismes essentiels de propagation. Dans ce cas, la maladie est supposée 
# être toujours fatale après une durée déterminée, pour permettre de simplifier la dynamique du modèle et de se concentrer sur l’évolution 
# de l’infection dans la population.

# Plusieurs contraintes ont été intégrées à la simulation afin de représenter des conditions proches de la réalité. Premièrement, les 
# individus infectés sont asymptomatiques, ce qui signifie qu’ils peuvent être détectés seulement à l’aide de tests diagnostiques. En effet, 
# une proportion importante des infections peut se produire sans symptômes, rendant leur identification difficile sans dépistage (Oran et Topol, 2020). 
# De plus, les tests utilisés ne sont pas parfaitement fiables et peuvent produire des faux négatifs, ce qui introduit une incertitude 
# supplémentaire dans la prise de décision. Deuxièmement, la vaccination constitue le principal moyen d’intervention dans le modèle. Une fois 
# ative, elle empêche les individus de contracter la maladie et de contribuer à sa propagation. Toutefois, un délai est nécessaire avant 
# que la vaccination ne devienne active, ce qui correspond au temps requis pour que le système immunitaire développe une réponse protectrice 
# (Nikoloudis et al., 2025). Cette contrainte est essentielle parce qu’elle influence directement l’efficacité des stratégies mises en place. 
# Enfin, un budget limité est imposé pour la réalisation des tests et l’administration des vaccins. Cette contrainte reflète les réalités des 
# systèmes de santé, où selon l’Organisation mondiale de la santé, les ressources sont restreintes et doivent être utilisées de manière optimale. 
# Ainsi, les décisions de dépistage et de vaccination doivent être prises de façon stratégique afin de maximiser la réduction de la propagation 
# de la maladie. Dans ce contexe, nous adoptons une stratégie ciblée inspirée du traçage des contacts et de la vaccination en anneau. À partir du
# premier décès, les interventions sont concentrées dans les cellules spatiales contenaant des individus infectés, considérées comme des zones à risque
# de transmission. Les individus présents dans ces cellules sont testés, puis ceux qui obtiennent un résultat positif ont vaccinés. Des études ont en fait
# montré que le traçage des contacts permet de contrôler efficacement la propagation des épidémies en identifiant rapidement les chaînes de tranmissions 
# (Hellewell et al., 2020), et que la vaccination en anneau permet de limiter la propagation en ciblant les individus à haut risque autour des cas détectés 
# (Henao-Restrepo et al., 2015).

# La problématique de ce travail est de déterminer comment optimiser l'utilisation de ressources limitées pour réduire la propagation d'une maladie
# infectieuse, dans un contexte où les individus infectés sont difficilement détectables et où les interventions ont un coût. L’objectif de ce travail 
# est donc d’évaluer l’impact d’une stratégie de dépistage et de vaccination sur la propagation d’une maladie infectieuse, en tenant compte de 
# contraintes biologiques et économiques réalistes. Cette approche permet de mieux comprendre comment différentes décisions d’intervention influencent 
# l’évolution d’une épidémie. Nous posons l'hypothèse qu'une stratégie ciblée de dépistage et de vaccination, concentrée sur les zones à risques définies 
# par la présence d'individus infectés, permettra de réduire plus efficacement la mortalité qu'une stratégie aléatoire (Henao-Restrepo et al., 2015).
# Nous attendons à oberver une diminution significative du nombre d'individus infectés au cours du temps, ainsi qu'une réduction de la dispersion spatiale
# des événements d'infection, ce qui suggère une limitation de la propagation de la maladie.


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

budget_initiale = 21000
cout_vaccin = 17
cout_test = 4
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
    clock::Int64 = 21 #temps qui leur reste
    infectious::Bool = false
    id::UUIDs.UUID = UUIDs.uuid4() # identiffiant unique
    vaccine::Bool = false
    date_vaccin::Int64 = 0
    vaccin_actif = false
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
# soit facile a comprendre, nous allons donc ajouter une méthode à cette
# fonction:

Random.rand(::Type{Agent}, L::Landscape) = Agent(x=rand(L.xmin:L.xmax), y=rand(L.ymin:L.ymax))
Random.rand(::Type{Agent}, L::Landscape, n::Int64) = [rand(Agent, L) for _ in 1:n]

# Cette fonction nous permet donc de générer un nouvel agent dans un paysage:

agent = rand(Agent, L)

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
    finance!(vacc)

Cette fonction deduis le prix du test RAT ou du vaccin du budget quand on les utilises.

'vacc' est de type bool. vacc=true si on utilise un vaccin et vacc=false si c'est un test RAT. 
"""
function finance!(vacc)
    global budget_initiale, cout_test, cout_vaccin

    ## On verifie qu'on a assez d'argent et quel traitement, vaccin ou test, on fait puis on enlève le cout du traitement du budget

    if (budget_initiale >= cout_vaccin) & vacc
        budget_initiale -= cout_vaccin

        ## a enlever apres

        if budget_initiale< 17
            println("pas assez de fond")
        end

        ##

    end
    if (budget_initiale>= cout_test) & vacc == false
        budget_initiale -= cout_test

        ## a enlever apres

        if budget_initiale< 4
            println("pas assez de fond")
        end

        ##

    end
    return nothing 
end

"""
    isinfectious(agent::Agent)

Cette fonction permet de vérifier l'état infectieux de l'agent, et elle renvoie 'true' si l'agent est infecté.
    
'agent' doit être de type Agent.
"""
isinfectious(agent::Agent) = agent.infectious

# Et on peut donc vérifier si un agent est sain:

"""
    ishealthy(agent::Agent)

Cette fonction permet de vérifier l'état de santé de l'agent, et elle renvoie 'true' si l'agent est sain.

'agent' doit être de type Agent.
"""
ishealthy(agent::Agent) = !isinfectious(agent)

# On peut maintenant définir une fonction pour prendre uniquement les agents qui
# sont infectieux dans une population. Pour que ce soit clair, nous allons créer
# un _alias_, `Population`, qui voudra dire `Vector{Agent}`:

const Population = Vector{Agent}

"""
    infectious(pop::Population)

Cette fonction permet de filtrer les agents selon leurs états de santé. Elle selectionne tous les individus infecté de la population 'pop', créant un vecteur d'agent infecté.

'pop' doit être de type Population.
"""
infectious(pop::Population) = filter(isinfectious, pop)

"""
    healthy(pop::Population)

Cette fonction permet de filtrer les agents selon leurs états de santé. Elle selectionne tous les individus sain de la population 'pop', créant un vecteur d'agent non malade.

'pop' doit être de type Population.
"""
healthy(pop::Population) = filter(ishealthy, pop)

"""
    vaccineee(agent::Agent)

Cette fonction vérifie la fiche vaccination de l'agent. Elle renvoie 'true' si l'agent est déjà vacciné.

'agent' doit être de type Agent.
"""
vaccineee(agent::Agent) = agent.vaccine


"""
    vac_actif(agent::Agent)
Cette fonction vérifie la fiche vaccination de l'agent. Et elle renvoie 'true' si l'agent a un vaccin actif (donc vacciné depuis au moins deux jours).
'agent' doit être de type Agent.
"""
vac_actif(agent::Agent) = agent.vaccin_actif

"""
    protected(pop::Population)
Cette fonction permet de créer un vecteur contenant les individus ayant un vaccin actif, donc les individus protégé de tous dangers.
'pop' doit être de type Population.
"""
protected(pop::Population)= filter(vac_actif, pop)

"""
    nonvaccinee(agent::Agent)

Cette fonction vérifie la fiche vaccination de l'agent. Et elle renvoie 'true' si l'agent est non vacciné.

'agent' doit être de type Agent.
"""
nonvaccinee(agent::Agent) = !vaccineee(agent)

"""
    vaccinated(pop::Population)

Cette fonction permet de créer un vecteur contenant les individus vaccinés.

'pop' doit être de type Population.
"""
vaccinated(pop::Population) = filter(vaccineee, pop)

"""
    notVaccinated(pop::Population)

Cette fonction permet de créer un vecteur contenant les individus non vaccinés.

'pop' doit être de type Population.
"""
notVaccinated(pop::Population)= filter(nonvaccinee, pop)

"""
    RAT(agent::Agent, cout, Budget)

Cette fonction simule un test de dépistage de la maladie. Si l'agent est infecté, le test a 95% de chance de renvoyer true et 5% de chance de faire un faux négatif. 
Si l'agent est sain le test est toujours fiable (renvoie false).

'agent' doit être de type Agent.
"""
function RAT!(agent::Agent)
    finance!(false)
    if isinfectious(agent)
        if rand()<=0.05
            test= false
        else
            test= true            
        end
    else 
        test= false
    end
    return test
end

# Nous allons ajouter une fonction permettant d'administrer un vaccin aux individus. Le vaccin n'est pas 
# immédiatement efficace, un délai de 2 générations est nécessaire avant qu'il confère une immunité 
# complète. Cela reflète le temps requis pour que la réponse immunitaire se développe.

"""
    vaccinate!(agent::Agent, jour_vacc)

Cette fonction enlève les frais du vaccin du budget total. 
Mais aussi, elle inscrit dans la fiche de l'agent la date du vaccin et change son statue à vacciné.

'agent' doit être de type Agent.
'jour_vacc' doit être de type Int64.
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

"""
    activ_vaccin!(agent::Agent)

Cette fonction change l'état de santé de l'agent, de malade à guéri.
Et informe que le vaccin est maintenant actif.

'agent' doit être de type Agent.
"""
function activ_vaccin!(agent::Agent)
    
    ## activation du vaccin
    ## rétablissement de l'agent

    agent.vaccin_actif = true 
    agent.infectious = false
    
    return nothing  
end

## if faut suivre cette structure dans la simulation ## à enlever apres ##############
## t=tick

t=0 
while t<21
    t+=1
    if nonvaccinee(agent) # si non vaccinee on le vaccine donc date de vaccin unique
        vaccinate!(agent, t)
    end

    ## delais

    if t == (agent.date_vaccin +2)
        activ_vaccin!(agent)                       
    end

    ## println(agent)

end
###########################################

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
# choisir au hasard dans la population un agent qui devient malade :

rand(population).infectious = true

# Nous initialisons la simulation au temps 0, et nous allons la laisser se
# dérouler au plus 1000 pas de temps:

tick = 0
maxlength = 2000

# Pour étudier les résultats de la simulation, nous allons stocker la taille de
# populations à chaque pas de temps:

S = zeros(Int64, maxlength);
I = zeros(Int64, maxlength);
mort = zeros(Int64, maxlength);
retabli = zeros(Int64, maxlength);

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

struct MortEvent
    time::Int64
    who::UUIDs.UUID
    x::Int64
    y::Int64
end

qui_meurt = MortEvent[]

# Notez qu'on a contraint notre vecteur `events` a ne contenir _que_ des valeurs
# du bon type, et que nos `InfectionEvent` sont immutables.

# On defini le nombre de personne qui seront testés

nb_tirage =2600

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

            ## Probabilité de contagiant lors de l'exposition à un malade, contagiant non possible si l'agent est vacciné
            
            if (neighbor.vaccin_actif == false) & (rand() <= 0.4)
                neighbor.infectious = true

                ## Ajout de l'évènement d'infection à la fiche des évènements
                
                push!(events, InfectionEvent(tick, agent.id, neighbor.id, agent.x, agent.y))
            end
        end
    end

    ## Change in survival
    
    for agent in infectious(population)
        agent.clock -= 1
        if agent.clock ==0
            push!(qui_meurt,MortEvent(tick,agent.id, agent.x, agent.y))            
        end        
    end
    
    ## Enregistrement du nombre de mort 

    deadagent = filter(x -> x.clock == 0, population)
    mort[tick] = length(deadagent) 
    
    ## Remove agents that died
    
    population = filter(x -> x.clock > 0, population)

    ## debut compagne test et vaccination apres le premier mort qui indique la présence de cette maladie asymptomatiques    
    ## Stratégie pour tester et vacciné le monde

    if length(population) < 3750 

        ## On cére un vecteur avec les individus testés positifs apres verification qu'on a le font nécessaire

        populationAtester = StatsBase.sample(population, nb_tirage, replace=false)
        for personne in populationAtester
            if budget_initiale >= (cout_test* length(populationAtester))
                test_positif = filter(x-> RAT!(personne), populationAtester)
                for infecte in test_positif  

                    ## puis on trouve les personnes dans la même cellule spatiale que les individus positif (zone à risque)
                    
                    personnes = incell(infecte, population) 
                    for p in personnes 
                         if (budget_initiale >= cout_test) & !(p in test_positif)  
                            test = RAT!(p)
                            if test && nonvaccinee(p) && budget_initiale >= cout_vaccin #on vérifie tous les conditions: si le résultat du test est positif, si la personne est déjà vaccinée ou non, et le budget
                                vaccinate!(p, tick)
                            end
                        end
                    end
                end
            end
        end
        nb_tirage = round(Int,nb_tirage*0.2)
        
        ## activation du vaccin apres delais de 2 generation

        for personne in vaccinated(population) 
            if tick == (personne.date_vaccin + 2)
                activ_vaccin!(personne)
            end
        end
    end

    ## stockage du nombre de personn guérie après vaccination

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

#-

f = Figure()
ax = Axis(f[1, 1]; xlabel="Génération", ylabel="Population")
stairs!(ax, 1:tick, S, label="Susceptibles", color=:orange)
stairs!(ax, 1:tick, I, label="Infectieux", color=:red)
stairs!(ax, 1:tick, mort, label="mort", color=:black)
stairs!(ax, 1:tick, retabli, label="rétabli", color=:green)
axislegend(ax)
current_figure()

# ### Nombre de cas par individu infectieux

# Nous allons ensuite observer la distribution du nombre de cas créés par chaque
# individus. Pour ceci, nous devons prendre le contenu de `events`, et vérifier
# combien de fois chaque individu est représenté dans le champ `from`:
# parcourt tous les event dans le vecteur events et extrait .from de chaque élément, formant un nouveau vecteur des valeurs event.from 
# + countmap() prend ce vecteur et renvoie un dictionnaire Dict qui compte combien de fois chaque valeur apparaît

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
## figure qui donne la date de l'infection ?

f = Figure()
ax = Axis(f[1, 1]; aspect=1, backgroundcolor=:grey97)
hm = scatter!(ax, pos, color=t, colormap=:navia, strokecolor=:black, strokewidth=1, colorrange=(0, tick), markersize=6)
Colorbar(f[1, 2], hm, label="Time of infection")
hidedecorations!(ax)
current_figure()

## on veut suivre les morts
quand =[jour.time for jour in qui_meurt];
ou = [(jour.x, jour.y) for jour in qui_meurt];


f = Figure()
ax = Axis(f[1, 1]; aspect=1, backgroundcolor=:grey97)
hm = scatter!(ax, ou, color=quand, colormap=:navia, strokecolor=:black, strokewidth=1, colorrange=(0, tick), markersize=6)
Colorbar(f[1, 2], hm, label="Time of death")
hidedecorations!(ax)
current_figure()

#############################################################
# # Présentation des résultats

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
