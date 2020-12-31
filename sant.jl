#order matters with include... find easy way to include files in the same folder

# gs = GameState()
# bcl = findCoordinatesWhereCurrPlayerHasBuilder(gs)
# println(gs.buildermatrix)
# println(bcl)

using Distributed 
@everywhere using gamestate
@everywhere using player
@everywhere using inquirer
@everywhere using mutator
@everywhere using gamingsession
@everywhere using player.RandomPlayer
@everywhere using player.Player
@everywhere using gamingsession.GamingSession
@everywhere using gamingsession.runGamingSession

      const jobs = RemoteChannel(()->Channel{Int}(32));
      const results = RemoteChannel(()->Channel{Dict{UInt64,Array{Int64,1}}}(32));
      
    @everywhere function initGamingSession(gamesPerSession::Int, jobs::RemoteChannel, results::RemoteChannel)
        while true
            println("in initgamingsession")
            job_id = take!(jobs)
            p1::Player = RandomPlayer()
            p2::Player = RandomPlayer()
            gamingSession = GamingSession(p1,p2)
            state_value_timesvisited_tree = runGamingSession(gamesPerSession,gamingSession)
            put!(results,state_value_timesvisited_tree)
        end
    end
    
    function setUpChannelsExecuteParallelRun(gamesPerSession::Int)
        num_gaming_sessions = 12

        master_state_value_timevisited_dict = Dict{UInt64,Array{Int64,1}}()
        sizehint!(master_state_value_timevisited_dict,10^6)
        make_jobs(num_gaming_sessions); # feed the jobs channel with jobs - this can be async via schedule since workers will wait for jobs anyway
        for worker in workers() # start tasks on the workers to process requests in parallel
            @async remote_do(initGamingSession, worker, gamesPerSession, jobs, results)
        end
        
        @elapsed while num_gaming_sessions > 0 # print out results for each gaming session
            state_value_timevisited_dict = take!(results)
            combine_dicts_from_multi_gaming_sessions!(state_value_timevisited_dict,master_state_value_timevisited_dict)
            println("unique states visited across all gaming sessions:", length(master_state_value_timevisited_dict))
            num_gaming_sessions = num_gaming_sessions - 1
        end

    end
    function make_jobs(n)
        for i in 1:n
            put!(jobs, i)
        end
    end;

     #potential performance bottleneck... might need merge algorithm better than brute force
     function combine_dicts_from_multi_gaming_sessions!(tree::Dict{UInt64,Array{Int64,1}}, master::Dict{UInt64,Array{Int64,1}})
        emptyarr = Int64[0,0]
        new_states_counter = 0
        dupe_states_counter = 0
        for (keya,valuea) in tree
            masterlookup = get(master,keya,emptyarr)
            if (masterlookup == emptyarr)
                # println("!!!!")
                # println(keya)
                master[keya]= valuea
                new_states_counter += 1
            else
                # println("####")
                # println(keya)
                # println(master[keya])
                # println(valuea)
                master[keya] = master[keya]+valuea
               # println(master[keya])
                dupe_states_counter += 1
            end
        end
        println("new states this session:",new_states_counter,"dupe states this session:",dupe_states_counter)
        println("% of states from this gaming session that were already in the master tree:",dupe_states_counter/(new_states_counter+dupe_states_counter))
    end

    @time setUpChannelsExecuteParallelRun(10000)
    #Profile.print(format=:flat,sortedby=:count)
    
