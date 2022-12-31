# Command is a struct that represents a single command
struct Command
    direction::Char
    numSteps::Int
end

# Knot is a struct that represents the head or tail of the rope
mutable struct Knot
    name::String
    i::Int
    j::Int
end

# conversions from directions to deltas for easy movement
directionDeltas = Dict{Char, Tuple{Int,Int}}('R' => (1,0), 'L' => (-1,0), 'U' => (0,1), 'D' => (0,-1))

# parse the input file into a vector of commands for easy iteration
function read_file(filename)
    commands = Vector{Command}()
    open(filename) do file
        for line in eachline(file)
            direction = line[1]
            numSteps = parse(Int, line[2:end])
            push!(commands, Command(direction, numSteps))
        end
    end
    return commands
end

# move the head one step in the given direction
function move_head_one_step!(head::Knot, direction::Char)
    head.i += directionDeltas[direction][1]
    head.j += directionDeltas[direction][2]
end

# move the k-1th knot based on where the kth knot
function move_knot_one_step!(knot::Knot, precedingKnot::Knot)
    di, dj = precedingKnot.i - knot.i, precedingKnot.j - knot.j
    # if the knot is already within one step to the precending knot (including diagonals)
    # don't move it 
    if (abs(di) <= 1 && abs(dj) <= 1)
        return
    end

    # handles if the preceding knot is up 2 and over 1 or vice versa
    # allows the knot to close the gap in one step
    if abs(di) > abs(dj)
        knot.i = precedingKnot.i - sign(di)
        knot.j = precedingKnot.j
    elseif abs(dj) > abs(di)
        knot.j = precedingKnot.j - sign(dj)
        knot.i = precedingKnot.i
    # handles if the preceding knot is up 2 and over 2
    # allows the knot to move diagonally
    else
        knot.i = precedingKnot.i - sign(di)
        knot.j = precedingKnot.j - sign(dj)
    end
end

# quick function to draw the grid to the console
function draw(knots)
    gridSize = 15
    # Base.run(`clear`) # clear the terminal, very slow
    for j in gridSize:-1:-gridSize
        for i in -gridSize:gridSize
            # if a knot is at this grid point draw its name
            # otherwise draw a "." to represent an empty space
            if any(knot -> knot.i == i && knot.j == j, knots)
                print(knots[findfirst(knot -> knot.i == i && knot.j == j, knots)].name)
            elseif i == 1 && j == 1
                print("s")
            else
                print(".")
            end
        end
        println()
    end
end

function solve(part::String)
    # commands = read_file("./22/inputs/009test.txt")
    # commands = read_file("./22/inputs/009test2.txt")
    commands = read_file("./22/inputs/009.txt")
    tailTracker = Set{Tuple{Int,Int}}()

    if part == "part1"
        knots = [Knot("H", 1, 1), Knot("T", 1, 1)]
        println("PART 1")
    else
        knots = Vector{Knot}()
        push!(knots, Knot("H", 1, 1))
        [push!(knots, Knot(string(i), 1, 1)) for i in 1:9]
        push!(tailTracker, (knots[end].i, knots[end].j))
        println("PART 2")
    end
    push!(tailTracker, (knots[end].i, knots[end].j))

    # draw(knots)
    # println("Start")
    # sleep(4)
    for command in commands
        # println("Move $(command.direction) $(command.numSteps) steps")
        for _ in 1:command.numSteps
            move_head_one_step!(knots[1], command.direction)
            for i in 2:length(knots)
                move_knot_one_step!(knots[i], knots[i-1])
            end
            push!(tailTracker, (knots[end].i, knots[end].j)) # set automatically removes duplicates
        end
        # draw(knots)
        # sleep(4)
    end
    # draw(knots)
    println("Number of unique places the tail went: $(length(tailTracker))")

end

solve("part1")
# Number of unique places the tail went: 5874
solve("part2")
# Number of unique places the tail went: 2467