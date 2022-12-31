# read in a file that contains rows of integers, 
# and return a matrix of those integers
# input: filename
# output: a matrix of integers
function readfile(filename::String)
    data = nothing
    open(filename) do file
        lines = readlines(file)
        data = Array{Int}(undef, length(lines), length(lines[1]))
        [data[i,:] = parse.(Int, split(lines[i],"")) for i in eachindex(lines)]
    end
    return data
end

# input: a vector of tree heights
# output: a vector of booleans, where true means that tree is visible
#         from the left
function map_tree_heights(treeLine)
    tallestTreeSoFar = -1
    visibleTreeLine = falses(length(treeLine))
    for i in eachindex(treeLine)
        if treeLine[i] > tallestTreeSoFar
            tallestTreeSoFar = treeLine[i]
            visibleTreeLine[i] = true
        end
    end
    return visibleTreeLine
end

# find the next tree that is as tall or taller than the current tree
# and return the distance between the two trees, including the that tree
# inputs: a vector of tree heights, and the height of the current tree
# output: the distance to the next tree that is as tall 
#         or taller than the current tree, including that tree
function viewing_distance(treeLine, currentTreeHeight)
    distance = 0
    for i in eachindex(treeLine)
        distance+=1
        if treeLine[i] >= currentTreeHeight
            break
        end
    end
    return distance
end

# inputs: a forest, and a location in the forest
# output: the scenic score for that location
#         the scenic score is the product of the distances to the next
#         tallest tree in each direction, including that tree
function scenic_score(forest, i, j)
    currentTreeHeight = forest[i,j]
    return viewing_distance(forest[i,j+1:end], currentTreeHeight) * viewing_distance(forest[i,j-1:-1:1], currentTreeHeight) * viewing_distance(forest[i-1:-1:1,j], currentTreeHeight) * viewing_distance(forest[i+1:end,j], currentTreeHeight)
end

function solve(part::String)
    # forest = readfile("./22/inputs/008test.txt")
    forest = readfile("./22/inputs/008.txt")

    if (part == "part1")
        println("PART 1")
        visibleTrees = falses(size(forest))
        for i in 0:3
            # rotate the forest 90 degrees to the left
            # because we're going to be looking at the forest from all four sides
            forest = rotl90(forest)
            visibleTrees = rotl90(visibleTrees)
            for i in eachindex(forest[:,1])
                visibleTrees[i,:] = visibleTrees[i,:] .| map_tree_heights(forest[i,:])
            end
        end
        # println("FOREST")
        # display(forest)
        # println("TREE MAP")
        # display(visibleTrees)
        # Total visible trees = 1703
        println("Total visible trees = $(sum(visibleTrees))")
    else
        println("PART 2")
        bestScore = 0
        bestLocation = (0,0)
        for i in eachindex(forest[:,1])
            for j in eachindex(forest[1,:])
                score = scenic_score(forest, i, j)
                if score > bestScore
                    bestScore = score
                    bestLocation = (i,j)
                end
            end
        end
        # Best score = 496650 at (16, 44)
        println("Best score = $(bestScore) at $(bestLocation)")
    end
end

solve("part1")
solve("part2")