function findFirstUniqueNChars(filename, N)
    deltaN = N-1
    println(deltaN)
    open(filename) do f
        println("START")
        line = readline(f)
        for i in 1:length(line)-deltaN
            window = line[i:i+deltaN]
            # check if all 4 character in window are different
            if length(unique(window)) == N
                println("Found it at character number $i !")
                println("Answer: $window")
                println("$(i+deltaN) characters have been processed")
                break
            end
        end    
        println("END")
    end
end

# Solution 1
findFirstUniqueNChars("./22/inputs/006.txt", 4)
# Solution 2
findFirstUniqueNChars("./22/inputs/006.txt", 14)