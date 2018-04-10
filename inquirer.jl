module inquirer
using gamestate.GameState
using player.MoveBuildMove
using player.AvailableMoveBuildMoves
    export findCoordinatesWhereCurrPlayerHasBuilder
    function findCoordinatesWhereCurrPlayerHasBuilder(state :: GameState)
        # find each coordinate where the current player has a builder
        findmat((x)->x==state.currentplayer,state.buildermatrix)::Array{Tuple{Int8,Int8},1}
    end
    
    #refactor this giant turd of a method
     function availableMovesCurrPlayer(state::GameState)
        available_move_build_moves::AvailableMoveBuildMoves = AvailableMoveBuildMoves()
        
                # given game state, return all combinations of move-build that the current player can take with their builders
                # locate builder squares
                # represent move-build as array of 3 2-tuples [(builderdx,buildery),(buildernewx,buildernewy),(structurex,structurey)]
        
                # how to find possible moves?
                # check builderpos x-1,y-0 x+1,y-0 x-1,y-1 x-1,y+1 x+1,y-1 x+1,y+1 x-0,y+1, x-0,y-1
                # find builders for player 1
        buildercoordslist = findCoordinatesWhereCurrPlayerHasBuilder(state)
        for bpos::Tuple{Int8,Int8} in buildercoordslist
            for  ymod::Int8 in (Int8(-1),Int8(0),Int8(1)),xmod::Int8 in (Int8(-1),Int8(0),Int8(1))
                if !(xmod::Int8 == 0 && ymod::Int8 == 0)  ##can't move onto the spot you're standing
                    #println(xmod,ymod,bpos)
                    targetmovespace = (bpos[1] + ymod, bpos[2] + xmod)
                    if __is_move_to_pos_possible(bpos, targetmovespace, state)
                        for ybuildmod::Int8 in (Int8(-1),Int8(0),Int8(1)),xbuildmod::Int8 in (Int8(-1),Int8(0),Int8(1))
                            if (!(xbuildmod == Int8(0) && ybuildmod == Int8(0)))  ##can't build on the spot you're standing
                                targetbuildspace = (targetmovespace[1] + ybuildmod, targetmovespace[2] + xbuildmod)
                                if __can_build_on_target_space(bpos, targetbuildspace, state.structurematrix,state.buildermatrix)
                                    #maybe somehow use array views here to avoid creating new mbms everytime?
                                    addToAvailableMoves(available_move_build_moves, bpos, targetmovespace,targetbuildspace)
                                end 
                            end 
                        end 
                    end 
                end 
            end 
        end                   
                # prune to valid positions - no out of bounds, no jumps up more than 1 level, no builders on space
                # from each of those positions, check x-1,y-0 x+1,y-0 x-1,y-1 x-1,y+1 x+1,y-1 x+1,y+1 x-0,y+1, x-0,y-1
                # prune to valid building spaces - prune spaces with other builders, prune spaces with caps, prune out of bounds
                # 8^2 complexity - 64 potential moves, max per builder
        return available_move_build_moves::AvailableMoveBuildMoves
    end

     function addToAvailableMoves(available_move_build_moves::AvailableMoveBuildMoves, bpos::Tuple{Int8,Int8}, targetmovespace::Tuple{Int8,Int8}, targetbuildspace::Tuple{Int8,Int8})
        mbm::MoveBuildMove = MoveBuildMove(bpos,targetmovespace,targetbuildspace)
        push!(available_move_build_moves.moves,mbm)
    end

     function  __is_move_to_pos_possible(bpos :: Tuple{Int8,Int8}, targetcoord::Tuple{Int8,Int8}, state :: GameState )
        if (1 <= targetcoord[1] <= 5) && (1 <= targetcoord[2] <= 5)
            targetstructure = state.structurematrix[targetcoord[1], targetcoord[2]]
            if state.structurematrix[bpos[1], bpos[2]] - targetstructure >= -1
                ##target space isn't 2 floors higher
                if targetstructure != 4
                    ##target space isn't capped
                    if state.buildermatrix[targetcoord[1], targetcoord[2]] == 0
                        ##target space doesn't have a builder
                        return true
                    end
                end
            end
        end

        return false
    end

     function __can_build_on_target_space(bpos :: Tuple{Int8,Int8}, targetbuildspace :: Tuple{Int8,Int8}, structurematrix::Array{Int8,2}, buildermatrix::Array{Int8,2})
        if (1 <= targetbuildspace[1] <= 5) && (1 <= targetbuildspace[2] <= 5)
            if structurematrix[targetbuildspace[1], targetbuildspace[2]] != 4
                ##not capped
                if buildermatrix[targetbuildspace[1], targetbuildspace[2]] == 0 || targetbuildspace == bpos  # since we know we moved, we can build where we were prev standing
                    ##no builder on the spot
                    return true
                end
            end
        end

        return false
    end

     function raiseErrorIfGameStateInvalid(state :: GameState)
        # builders aren't standing on level 4
        # no more than 2 builders for each player
        # two builders on level 3
        player1buildercount :: Int8 = 0
        player2buildercount :: Int8 = 0
        buildersonlevel3 :: Int8 = 0
        #TODO priority 1
        for build_struct_tuple::Tuple{Int8,Int8} in zip(state.buildermatrix, state.structurematrix)
            if (!(Int8(0) <= build_struct_tuple[2] <= Int8(4)))
                throw(string("Structure Values must be between 0 and 4 inclusive"))
            end
            if (build_struct_tuple[2] == Int8(4) && build_struct_tuple[1] != Int8(0))
                throw(string("Builder is standing on a cap! Bad state!"))
            end
            if build_struct_tuple[1] == Int8(1)
                player1buildercount += Int8(1)
            end
            if build_struct_tuple[1] == Int8(2)
                player2buildercount += Int8(1)
            end
            if build_struct_tuple[1] == (Int8(1), Int8(2)) && build_struct_tuple[2] == Int8(3)
                buildersonlevel3 += Int8(1)
            end
        end
        if player1buildercount != Int8(2) || player2buildercount != Int8(2)
            throw(
                string("Invalid Number of Builders: P1:",string(player1buildercount),"P2:",string(player2buildercount),string(state)))
        end
        if buildersonlevel3 > Int8(1)
            throw(string("Too many builders on level 3. #=",string(buildersonlevel3)))
        end

        return true
    end
        using gamestate.GameState
     function didSomeoneWin_returnPlayerNum(state :: GameState)
        # is a builder on level 3
        # can our opponent not move+build
        #TODO priority 1
        raiseErrorIfGameStateInvalid(state)
        #TODO
        for bs_tuple::Tuple{Int8,Int8} in zip(state.buildermatrix, state.structurematrix)
            if  bs_tuple[Int8(2)] == Int8(3) && bs_tuple[1] in (Int8(1), Int8(2))
                return bs_tuple[1]
            end
        end

        return Int8(0)
    end

     function findmat(f, A::Array{Int8,2})
        m,n = size(A)
        out::Array{Tuple{Int8,Int8},1} = Array{Tuple{Int8,Int8},1}()
        for i in 1:m, j in 1:n
          f(A[i,j]) && push!(out,(i,j))
        end
        out
      end
    end