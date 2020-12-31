This is an engine for the board game <a target="_blank" href="https://roxley.com/products/santorini">Santorini</a></font> written in the highly performant <a target="_blank" href="https://julialang.org">Julia</a> scripting language.  This game engine simulates roughly 5,000 randomly played games of Santorini a second.


<h4>Install Julia 0.7 (under "Older Releases")</h4>
https://julialang.org/downloads/

<h4>Run the game engine (default = 10,000 games per session, 12 sessions)</h4>

```
julia> push!(LOAD_PATH,pwd()); 
julia> include("sant.jl")
```
  
The built-in concurrency, once enabled, will likely double this app's speed in games per second given enough cores (concurrency currently disabled due to <a href="https://discourse.julialang.org/t/workers-do-not-find-packages-in-spite-of-everywhere-and-pkg-activate-commands/23441">this bug</a> - should be fixed when I get around to updating to newer versions of Julia)

<h4>Why?</h4>

I wrote this to gain experience in machine learning, specifically reinforcement learning, applied to a medium I am passionate about (board games!).  See <a target="_blank" href="https://github.com/clintrorick/dominion-game-engine">dominion-game-engine</a> for my second, more complete try at a reinforcement learning implementation using Kotlin coroutines and a Q-Table.