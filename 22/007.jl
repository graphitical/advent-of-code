mutable struct Node{T}
    name::T
    isDirectory::Bool
    size::Int
    children::Union{Nothing,Dict{T, Node{T}}}
    parent::Union{Nothing,Node{T}}
end

function process_command(command, root, currentNode)
    words = split(command)
    if words[2] == "cd"
        if words[3] == ".."
            currentNode = currentNode.parent
        elseif words[3] == "/"
            currentNode = root
        else
            if (haskey(currentNode.children, words[3]))
                currentNode = currentNode.children[words[3]]
            end
        end
    end
    # do nothing for 'ls' command
    return currentNode
end

function process_file(command, currentNode)
    words = split(command)
    if !haskey(currentNode.children, words[2])
        size = 0
        isDir = true
        if (words[1] != "dir")
            size = parse(Int, words[1])
            isDir = false
        end
        currentNode.children[words[2]] = Node{String}(words[2], isDir, size, Dict(), currentNode)
    end
end

function update_directory_size(node)
    if !node.isDirectory
        return node.size
    end

    subDirectorySize = 0
    for child in values(node.children)
        subDirectorySize += update_directory_size(child)
    end
    node.size = subDirectorySize
    return subDirectorySize
end

function sum_directory_size_less_than_threshold(node, threshold, totalSize)
    if !node.isDirectory
        return totalSize
    end

    for child in values(node.children)
        totalSize = sum_directory_size_less_than_threshold(child, threshold, totalSize)
    end
    if node.size <= threshold
        return node.size + totalSize
    end
    return totalSize 
end

# node: the current node we are looking at
# candidateNode: the current smallest directory we have found
# size: the min size we are looking for
function find_smallest_directory_greater_than_size(node, candidateNode, size)
    # if the node is a file we don't care about it
    if !node.isDirectory
        return candidateNode
    end

    # if the node is a directory we need to check its children for a smaller directory
    # and compare it to the current smallest candidate directory
    for child in values(node.children)
        candidateNode = find_smallest_directory_greater_than_size(child, candidateNode, size)
    end

    if (node.size < size)
        return candidateNode
    end

    if( isnothing(candidateNode) || node.size < candidateNode.size)
        return node
    end
    return candidateNode
end

function solve(filename::String,part::String)
    root = Node{String}("/", true, 0, Dict(), nothing)
    currentNode = root
    open(filename) do file
        while (!eof(file))
            line = readline(file)
            if (line[1] == '$')
                currentNode = process_command(line, root, currentNode)
            else
                process_file(line, currentNode)
            end
        end
    end
    totalSize = update_directory_size(root)
    println("Total size: $totalSize")
    if part == "part1"
        thresholdSize = sum_directory_size_less_than_threshold(root, 100000, 0)
        println("Sum of sizes less than 100000: $thresholdSize")
    else
        totalSpace  = 70000000
        neededSpace = 30000000
        currentlyFreeSpace = totalSpace - totalSize
        moreSpaceNeeded = neededSpace - currentlyFreeSpace
        node = find_smallest_directory_greater_than_size(root, nothing, moreSpaceNeeded)
        # println(node)
        println("Total space: $totalSpace")
        println("Needed space: $neededSpace")
        println("Currently free space: $currentlyFreeSpace")
        println("Smallest directory greater than $moreSpaceNeeded: $(node.name)")
        println("Size of $(node.name): $(node.size)")
        println("After deleting this leaves $(currentlyFreeSpace + node.size) free space")
    end
end


# filename = "./22/inputs/007test.txt"
filename = "./22/inputs/007.txt"
solve(filename,"part1")
solve(filename,"part2")