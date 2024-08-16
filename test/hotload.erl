
-module(hotload).
-export([server/1, upgrade/1]).

server(State) ->
    io:format("state:~p~n",[State]),
    receive
        update ->
            NewState = ?MODULE:upgrade(State),
            io:format("rebuilding, count:~p~n",[State]),
            ?MODULE:server(NewState);  %% loop in the new version of the module
        SomeMessage ->
            %% do something here
            server(State)  %% stay in the same version no matter what.
    end.

upgrade(OldState) -> spawn_link(fun () -> runner:flush_loop("file") end).
    %% transform and return the state here.
