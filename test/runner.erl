-module(runner).

%-import(hello,[start/0]).
-import(fs,[start_link/2,subscribe/1]).

-export([start/0,known/1,loop/1]).

start() ->
    io:format("starting~n",[]),
    fs:start_link(fs_watcher,"."),
    fs:subscribe(fs_watcher),
    register(runThing,self()),
    process_flag(trap_exit, true),
    loop(hello:start()).

known("runner.erl") -> runner;
known("hello.erl") -> hello;
known(X=[$/|[_|_]]) -> known(filename:basename(X));
known(_) -> unknown.

loop(P) ->
    code:soft_purge(runner),
    receive
        exitt -> exit(toldto)
      ; {'EXIT', P, Msg} -> io:format("watched proc exited because ~p",[Msg]), loop(nuffin)
      ; {_,{fs,file_event},{File,Reason}} ->
          case filename:extension(File) of
            ".erl"->
              io:format("file:~p, reason:~p~n",[File,Reason]),
              case known(File) of
                unknown -> runner:loop(P);
                _ -> flush_loop(P,File)
              end;
            _ -> loop(P)
          end
      ; update -> runner:loop(P)
    end.

flush_loop(P,File) ->
    receive
        {_,{fs,file_event},{File,_}} -> flush_loop(P,File)
    after 100 ->
        io:format("~p rebuilding~n",[File]),
        NewP = try
            code:soft_purge(known(File))
          , {ok,Mod} = compile:file(File)
          , {module,M}= code:load_file(Mod)
          , M
        of
            hello -> case P of
                  nuffin -> hello:start()
                ; _ -> P!update, P
              end
          ; _ -> P
        catch
          error:Err -> io:format("Compilation/Loading Error : ~p~n",[Err]),P
        end,
        runner:loop(NewP)
   end.
