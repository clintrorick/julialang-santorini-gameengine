module gamestate   
   mutable struct GameState
        states_visited_player1 :: Dict{UInt64,Int64}
        states_visited_player2 :: Dict{UInt64,Int64}
        currentplayer :: Int64
        num_turns_taken :: Int64
        structurematrix :: Array{Int8,2}
        buildermatrix :: Array{Int8,2}
        GameState() = new(
            Dict{UInt64,Int64}(),
            Dict{UInt64,Int64}(),
            rand(1:2),
            0,
            Int8[0 0 0 0 0; 
                 0 0 0 0 0; 
                 0 0 0 0 0; 
                 0 0 0 0 0; 
                 0 0 0 0 0],
            Int8[0 0 0 0 0; 
                 0 1 0 2 0; 
                 0 0 0 0 0; 
                 0 2 0 1 0; 
                 0 0 0 0 0])
    end

     function print(state::GameState)
        strrep :: String = string("\n####GAMESTATE####","\nCurrentPlayer="
        ,string(state.currentplayer)
        ,"\nStructureMatrix"
        , "\n---------------\n"
        , string(state.structurematrix)
      ,"\n\nBuilderMatrix"
       , "\n-------------\n"
        ,string(state.buildermatrix))
        println(strrep)
    end

end