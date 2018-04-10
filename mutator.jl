module mutator
using gamestate.GameState
using player.MoveBuildMove

    function execute_buildmove(state::GameState, bm_tuple::MoveBuildMove)
        mbm::Tuple{Tuple{Int8,Int8},Tuple{Int8,Int8},Tuple{Int64,Int64}} = bm_tuple.mbm
        state.buildermatrix[mbm[1][1],mbm[1][2]] = Int8(0)
        state.buildermatrix[mbm[2][1],mbm[2][2]] = state.currentplayer
        state.structurematrix[mbm[3][1],mbm[3][2]] += Int8(1)
        state.currentplayer = Int8(3) - state.currentplayer # toggle between one and two
        state.num_turns_taken += Int8(1)
    end
end