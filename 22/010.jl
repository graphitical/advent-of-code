using Printf

struct Instruction
    op::String # operation
    args::Int  # arguments
end

mutable struct CPU
    counter::Int # instruction counter
    cycle::Int # cycle counter
    registers::Dict{Char, Int}
    instructions::Vector{Instruction}
    executing::Bool
end

function CPU()
    # Register X is for the problem
    # Register S is for us to track the signal strength
    CPU(0, 0, Dict{Char, Int}('X'=>1, 'S'=>0), Instruction[], true)
end

function load_instructions!(cpu::CPU, filename::String)
    println("Loading instructions from $filename")
    open(filename) do f
        for line in eachline(f)
            # try blocks are hard scoped so we define op and args here
            op, args = nothing, nothing
            try
                op, args = split(line, " ")
                args = parse(Int, args)
            catch
                op, args = line, 0
            end
            push!(cpu.instructions, Instruction(op, args))
        end
    end
end

# increments the counter and returns the next instruction
# this means the user never has to worry about the counter
function fetch_instruction!(cpu::CPU)
    cpu.instructions[cpu.counter+=1]
end

# noop takes 1 cycle and then returns true because it is complete
function execute_noop!(cpu::CPU)
    cpu.cycle += 1
    return true
end

# addx takes 2 cycles and then returns true because it is complete
function execute_addx!(cpu::CPU, args::Int, currentCycle::Int)
    # on first cycle, do nothing
    if currentCycle == cpu.cycle
        cpu.cycle += 1
        return false
    end
    # on second cycle, do the add
    cpu.registers['X'] += args
    cpu.cycle += 1
    return true
end

function print_cpu_state(cpu::CPU)
    println()
    println("Executing: $(cpu.executing)")
    println("Cycle: $(cpu.cycle)")
    println("Counter: $(cpu.counter)")
    println("Registers: $(cpu.registers)")
    println("Current instruction: $(cpu.instructions[cpu.counter])")
    # println("Instructions: $(cpu.instructions)")
    println()
end

mutable struct CRT
    screen::BitVector
    pixelBeingDrawn::BitVector
end

function CRT()
    # 240 pixels wide, 6 rows of 40 pixels
    # window is the pixel we are currently drawing
    # it will get shifted right every cycle
    # and .& with the sprite location to determine if we draw a pixel
    local window = falses(240)
    window[1] = true
    # the screen gets initialized to OFF
    CRT(falses(240), window)
end

# Returns a 40 pixel wide BitVector representing the sprite at the current X register
# The sprite is 3 pixels wide 
# Register X only specifies the horizonal location of the sprite
# We infer the row from the cycle number
function sprite_location(cpu::CPU)
    location = falses(40)
    location[1:3] .= true
    # logical shift to get the sprite in the correct location
    location = location >>> (cpu.registers['X']-1)
    return location
end

# Draws a 240 pixel wide BitVector in 6 rows of 40 pixels
function draw_array(arr::BitVector)
    for i in 1:6
        println(join(map(x -> x ? "#" : ".", arr[(i-1)*40+1:i*40])))
    end
end

# draw screen in 6 rows of 40 pixels
function draw_screen(crt::CRT)
    draw_array(crt.screen)
end

function update_screen!(crt::CRT, cpu::CPU)
    sprite = sprite_location(cpu)
    # Pad sprite with 0s to make it 240 pixels wide
    sprite = vcat(sprite, falses(240-length(sprite)))
    # Shift sprite to the right by the number of lines we're on
    sprite = sprite >>> (40 * (cpu.cycle ÷ 40))
    # Update the screen
    # We only draw a pixel if the pixel being drawn and the sprite overlap
    # we then or that with the screen to keep all previously drawn pixels
    crt.screen = (crt.pixelBeingDrawn .& sprite) .| crt.screen
end

function execute_instruction!(cpu::CPU, instruction::Instruction, crt::CRT)
    complete = false
    # Used to determine if we are on the first or second cycle of an instruction
    startCycle = deepcopy(cpu.cycle)

    op, args = instruction.op, instruction.args
    # First cycle begins here
    while !complete
        # Screen gets updated in the middle of a cycle
        update_screen!(crt, cpu)

        # Update the signal strength every at the 20, 60, 80... up to 240th cycle
        # Also happens in the middle of a cycle
        if (cpu.cycle - 19) % 40 == 0
            cpu.registers['S'] += cpu.registers['X']*(cpu.cycle+1)
            # println("Incrementing S by $(cpu.registers['X']*(cpu.cycle+1)) to $(cpu.registers['S'])")
        end

        # Execute the instruction
        if op == "noop"
            complete = execute_noop!(cpu)
        elseif op == "addx"
            complete = execute_addx!(cpu, args, startCycle)
        else
            error("Unknown instruction: $op")
        end
        
        # Pixel to draw shifts right every cycle
        crt.pixelBeingDrawn = crt.pixelBeingDrawn >>> 1
    end
    # Last cycle ends here

    # End when we are out of instructions
    if cpu.counter == length(cpu.instructions)
        cpu.executing = false
    end
end

function solve()
    println("START")
    cpu = CPU()
    crt = CRT()
    # cpu.instructions = [Instruction("noop", 0), Instruction("addx", 3), Instruction("addx", -5)]
    # load_instructions!(cpu, "./22/inputs/010test.txt")
    load_instructions!(cpu, "./22/inputs/010.txt")
    while cpu.executing
        execute_instruction!(cpu, fetch_instruction!(cpu), crt)
    end
    # Total signal strength: 14920
    println("PART 1")
    println("Total signal strength: $(cpu.registers['S'])")
    println("PART 2")
    draw_screen(crt)
    println("BUCACBUZ")
    println("END")
end

solve()