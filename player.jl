 module player
 using gamestate.GameState
 mutable struct MoveBuildMove
    mbm::Tuple{Tuple{Int8,Int8},Tuple{Int8,Int8},Tuple{Int64,Int64}}
    MoveBuildMove(bpos::Tuple{Int8,Int8},targetmovespace::Tuple{Int8,Int8},targetbuildspace::Tuple{Int8,Int8}) = new((bpos,targetmovespace,targetbuildspace))
end

 mutable struct AvailableMoveBuildMoves
    moves::Array{MoveBuildMove,1}
    AvailableMoveBuildMoves() = new(Array{MoveBuildMove,1}())
end


 abstract type Player
    end
     struct CompetitivePlayer <: Player
    
    end
     struct RandomPlayer <: Player
        
    end
     struct UCTPlayer <: Player
    
    end

     function selectNextMove(player :: RandomPlayer, available_moves :: AvailableMoveBuildMoves, gs::GameState)
        selectedMove::Int8 = rand(1:length(available_moves.moves))
        return available_moves.moves[selectedMove]
    end

     function selectNextMove(player :: UCTPlayer, available_moves :: Array{Tuple})
        
    end
     function selectNextMove(player :: CompetitivePlayer, available_moves :: Array{Tuple})
        
    end

end
