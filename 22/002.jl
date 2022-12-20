# dict to convert player 1 and player 2 moves to easy comparison points
# Player 1: A->Rock->1, B->Paper->2, C->Scissors->3
# Player 2: X->Rock->1, Y->Paper->2, Z->Scissors->3
RPS = Dict{Char,Int}('A'=>1,'B'=>2,'C'=>3,
                     'X'=>1,'Y'=>2,'Z'=>3)

# judge a single round of RPS based on original rules
function judgeRound(player1, player2)
    # draw, base points = 3 + player 2's move
    if RPS[player1] == RPS[player2]
        return RPS[player2] + 3
    # player 1 wins, only return player 2's move
    # player1 wins, rock beats scissors
    elseif RPS[player1] == 1 && RPS[player2] == 3
        return RPS[player2]
    # player1 wins, paper beats rock
    elseif RPS[player1] == 2 && RPS[player2] == 1
        return RPS[player2]
    # player1 wins, scissors beats paper
    elseif RPS[player1] == 3 && RPS[player2] == 2
        return RPS[player2]
    # player2 wins, base points = 6 + player 2's move
    else
        return RPS[player2] + 6
    end
end

println("Start tests provided on AoC website")
println(judgeRound('A','Y') == 8)
println(judgeRound('B','X') == 1)
println(judgeRound('C','Z') == 6)
println("End tests")

# tally the scores for a single file
function tallyScores(fileName, judgementFunction)
    totalScore = 0
    open(fileName) do file
        while (! eof(file))
            line = readline(file)
            if length(line) > 0
                # println(line)
                totalScore+=judgementFunction(line[1],line[3])
            
            end
        end
    end
    return totalScore
end

finalScore = tallyScores("./22/inputs/002.txt", judgeRound)
println("final score is $finalScore")

# Part 2 ======================================

function judgeNewRound(player1Move, player2Directions)
    # Player 2 throws the round
    if player2Directions == 'X'
        if player1Move == 'A'
            return 3
        elseif player1Move == 'B'
            return 1
        else
            return 2
        end
    # Player 2 draws the round
    elseif player2Directions == 'Y'
        if player1Move == 'A'
            return 4
        elseif player1Move == 'B'
            return 5
        else
            return 6
        end
    # Player 2 wins the round
    elseif player2Directions == 'Z'
        if player1Move == 'A'
            return 8
        elseif player1Move == 'B'
            return 9
        else
            return 7
        end
    # Bad inputs
    else
        throw("bad input") 
    end
end

println("Start tests provided on AoC website")
println(judgeNewRound('A','Y') == 4)
println(judgeNewRound('B','X') == 1)
println(judgeNewRound('C','Z') == 7)
println("End tests")

finalScore = tallyScores("./22/inputs/002.txt", judgeNewRound)
println("final score is $finalScore")