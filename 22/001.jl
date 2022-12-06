# find the 1st through kth largest values in array a
function maxk(a, k)
    b = partialsortperm(a, 1:k, rev=true)
    return collect(zip(b, a[b]))
end

calorieList = zeros(1)
open("./inputs/001.txt") do f
    elfNum = 1
    while ! eof(f)
        s = readline(f)
        if length(s) > 0
            calorieList[elfNum]+=parse(Int64, s)
        else
            elfNum+=1
            append!(calorieList,0)
        end
    end
end

numElves = 3
topElves = maxk(calorieList, numElves)

println("the elves carrying the most calories are:")
for i in eachindex(topElves)
    println("elf $(topElves[i][1]) is carrying $(topElves[i][2]) calories")
end

# totalCalories = sum(topElves)
totalCalories = sum(collect(zip(topElves...))[2])
println("together they are carrying $totalCalories")

