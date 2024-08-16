-module(hello).
-include("ex11_lib.hrl").

-import(ex11_lib,
    [ xStart/1
    , xCreateWindow/10
    , eMapWindow/1
    , eListFonts/2
    , eDestroyWindow/1
    , xDo/2
    , xFlush/1
    , ePolyText8/5
    , xCreateGC/2
    , xColor/2
    , xEnsureFont/2
    , xCreateWindow/10
    ]).

-export([start/0,main/1,init/0,init2/1,loop/2,loop/3]).

main(Args) ->
    init().

start() ->
    spawn_link(fun init/0).

init() ->
    register(foo,self())
  , {ok, D} = xStart("3.1")
  , init2(D).
init2(D) ->
    W = xCreateVerySimpleWindow(D,100,100)
  , xDo(D,eMapWindow(W))
  , xFlush(D)
  , loop(D,W).

loop(D,W) ->
    Pen  = ex11_lib:xCreateGC(D, [{function, copy},
                        {font, tryFontList(D,["*-terminal-medium-*iso8859*","*"])},
                        {fill_style, solid},
                        {foreground, ex11_lib:xColor(D, 16#8B)}])
  , loop(D,W,[Pen]).

loop(D,W,Opts=[Pen|_]) ->
    xDo(D, ex11_lib:ePolyText8(W, Pen, 10, 35, "Hello World3"))
  , xFlush(D)
  , io:format("newloop3~n")
  , io:format("~p~n",[xDo(D, eListFonts(100,"*-terminal-*"))])
  , receive
          {cmd, Action} -> Action(D,W)
            , loop(D,W,Opts)
        ; update -> ?MODULE:loop(D,W,Opts)
        ; refresh ->  xDo(D,eDestroyWindow(W)), ?MODULE:init2(D)
        ; Any -> io:format("Message:~p~n",[Any])
            , loop(D,W,Opts)
    end.

xCreateVerySimpleWindow(Display,Width,Ht) ->
    xCreateWindow(Display, top, 0, 0, Width, Ht, 1, inputOutput, 0,[{eventMask,?EVENT_EXPOSURE},{backgroundPixel,16#FFFFFF}]).

tryFontList(D, [H|T]) ->
    case xDo(D, eListFonts(1,H)) of
        {ok, [FontName|_]} -> ex11_lib:xEnsureFont(D,FontName);
        {ok,[]} -> tryFontList(D,T)
    end.
