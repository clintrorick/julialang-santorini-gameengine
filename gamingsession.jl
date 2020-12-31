 module gamingsession
    using gamestate.GameState
    using player.Player
    using player.RandomPlayer
    using player.selectNextMove
    using player.MoveBuildMove
    using player.AvailableMoveBuildMoves
    using mutator.execute_buildmove
    using inquirer.availableMovesCurrPlayer
    using inquirer.didSomeoneWin_returnPlayerNum
    
    mutable struct GamingSession
        players::Tuple{Player,Player}
        state_Value_Timevisited::Dict{UInt64,Array{Int64,1}}
        GamingSession() = new([],Dict{UInt64,Array{Int64,1}}())
        GamingSession(player1::Player,player2::Player) = new((player1::Player,player2::Player),Dict{UInt64,Array{Int64,1}}())
    end
    

    function acceptMoveFromPlayer_ReturnWhoWon(move::MoveBuildMove, state::GameState)
         execute_buildmove(state,move)
        return  didSomeoneWin_returnPlayerNum(state)
    end
 
    function runGamingSession(numgames :: Int64, gamingsession::GamingSession)
        last_size_of_states = 0
        for game_num = 1:numgames
            ##TODO
            gamestate::GameState, whoWon::Int8 = playSingleGame(gamingsession.players)
             backfill_state_value_timesvisited_dict(gamestate,whoWon,gamingsession)
            new_states_this_game = length(gamingsession.state_Value_Timevisited) - last_size_of_states
            last_size_of_states = length(gamingsession.state_Value_Timevisited)
        end
        println(string("Number of unique states visited in this gaming session:",length(gamingsession.state_Value_Timevisited)))
        return gamingsession.state_Value_Timevisited
    end
        
    function playSingleGame(players::Tuple{Player,Player})
        gamestate::GameState = GameState()
        for turn=1:1000
            currentplayer::Player = players[gamestate.currentplayer]
            availablemoves::AvailableMoveBuildMoves = availableMovesCurrPlayer(gamestate) ############TODO
            if isempty(availablemoves.moves)
                return gamestate, Int8(3)-gamestate.currentplayer
            end
            move::MoveBuildMove =  selectNextMove(currentplayer,availablemoves,gamestate)
            ##TODO
            whoWon::Int8 = acceptMoveFromPlayer_ReturnWhoWon(move,gamestate)
            ###accept move from player changes the current player!
             updateStatesVisitedDict_withCurrentState(gamestate)
            
            if whoWon != false
                #print(gamestate)
                #println(string("Player ",whoWon," won!"))
                return gamestate, whoWon
            end
        end
    end
    
        
    function updateStatesVisitedDict_withCurrentState(state :: GameState)
        statehash =  getHashFromGameState(state)
        if (state.currentplayer == 1)
            stateentry = get(state.states_visited_player1, statehash,0)
            state.states_visited_player1[statehash] = stateentry + 1
        end
        if (state.currentplayer == 2)
            stateentry = get(state.states_visited_player2, statehash,0)
            state.states_visited_player2[statehash] = stateentry + 1
        end
    end
        
    function backfill_state_value_timesvisited_dict(state :: GameState, whoWon :: Int8, gamingsession::GamingSession)
         #loop through visited state dicts, update master dict with times visited for each state
        #for player that won, increment total value of each visited state by Int8(1)
        for (key,value) in state.states_visited_player2
            totalValueTimesVisitedP2 = get(gamingsession.state_Value_Timevisited,key,[0,0])
            if totalValueTimesVisitedP2 != [0,0]
                # println(string("p2 encountered dupe state ",key,string(totalValueTimesVisitedP2)))
            end
            totalValueTimesVisitedP2[2] += 1 #same state can never be entered more than once
            if whoWon == Int8(2)
                totalValueTimesVisitedP2[1] += Int8(1)
                gamingsession.state_Value_Timevisited[key] = totalValueTimesVisitedP2
            end
        end

        for (key,value) in state.states_visited_player1
            totalValueTimesVisited = get(gamingsession.state_Value_Timevisited,key,[0,0])
            if totalValueTimesVisited != [0,0]
                # println(string("p1 encountered dupe state ",key,string(totalValueTimesVisited)))
            end
            totalValueTimesVisited[2] += 1 #same state can never be entered more than once
            if whoWon == Int8(1)
                totalValueTimesVisited[1] += Int8(1)
                gamingsession.state_Value_Timevisited[key] = totalValueTimesVisited
            end
        end
    end
        
    function getHashFromGameState(state :: GameState)
        shash::UInt64 = hash(state.structurematrix::Array{Int8})
        bhash::UInt64 = hash(state.buildermatrix::Array{Int8})

        currplayerhash::UInt64 = hash(state.currentplayer::Int64)
        statehash::UInt64 = currplayerhash + shash + bhash
        return statehash
    end
    
end