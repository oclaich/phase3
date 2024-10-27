import Base.show
using DataStructures

include("../phase2/node_pointer.jl")

function voisins(graph::Graph{T,S},node_pointer::node_pointer{T}) where {T,S}
    node=node_pointer.child
    voisins=Vector{Node{T}}()
    for edge in graph.Edges
        if edge.node1 == node
            push!(voisins,edge.node2)
        elseif edge.node2 == node
            push!(voisins,edge.node1)
        end
    end
    return voisins
end

function prim(graph::Graph{T,S},départ::Node{T}) where {T,S}

    "Création du vecteur des noeuds considérés dans l'arbre de recouvrement"
    "Initialisation du poids"
    A=Vector{node_pointer{T}}()
    total_weight=0
    "Création de la file de priorité, avec en clé des Float64 représentant le poids minimal"
    priority_queue=PriorityQueue{node_pointer,Float64}()
    "Pour chaque noeud, on crée un node_pointer faisant figurer le parent initialisé à nothing."
    for node in graph.Nodes
        node_pointer=node_pointer(node)
        node_pointer.parent=nothing
        "Le poids minimal du noeud de départ est 0"
        "On l'ajoute à la file de priorité avec cette clé"
        if node == départ
            départ_element=(node_pointer,0)
            enqueue!(priority_queue,départ_element)
        else
        "Pour les autres noeuds, le poids minimal est Inf"
        "On les ajoute aussi à la file de priorité"
            priority_element=(node_pointer,Inf)
            enqueue!(priority_queue,priority_element)  
        end
    end
    "On sort l'élémént de plus basse priorité de la file"
    "On l'ajoute ensuite au vecteur des noeuds considérés"
    "Et on augmente le poids total_weight"
    while !priority_queue.is_empty()
        node_pointer,min_weight=dequeue_pair!(priority_queue)
        push!(A,node_pointer)
        total_weight+=min_weight
        "On met à jour les éléments restants de la file de priorité"
        for k in voisins(node_pointer)
            "k est un node ici, pas un node_pointer"
            "On récupère l'arête du graph entre node_pointer.child et k (il n'y en a qu'une
            car graph non-orienté)"
            edge_weight=(graph.Edges(findfirst(edge-> (edge.node1 == node_pointer.child && edge.node2 == k) || (edge.node1 == k && edge.node2 == node_pointer.child),graph.Edges))).data
            "On parcourt la file de priorité à la recherche du node_pointer dont le child
            est k (le voisin du noeud qu'on vient d'ajouter à l'arbre)"
            for node_pointer_a_actualiser in priority_queue
                "Une fois qu'on l'a trouvé, si sa priorité est plus grande que
                la valeur de l'arête edge_weight, on met à jour la priorité"
                if node_pointer_a_actualiser.child == k && edge_weight < priority_queue[node_pointer_a_actualiser]
                    setindex!(priority_queue,edge_weight,node_pointer_a_actualiser)
                    "Et on met à jour le parent du node_pointer qui vient
                    d'avoir son min_weight modifié"
                    node_pointer_a_actualiser.parent=node_pointer.child
                end
            end
        end
        "A la fin du parcours du for dans les voisins de node_pointer, tous les voisins
        de node_pointer ont, si leur distance à node_pointer est plus faible que
        leur min_weight, été mis à jour avec changement de min_weight et de parent"
    end
    "A la fin du while, la file de priorité est normalement vide, tous les noeuds
    (sous forme de node_pointer) sont présents dans A, et le poids total est à jour"
    return A,total_weight
end