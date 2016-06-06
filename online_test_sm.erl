-module(online_test_sm).

-include_lib("eqc/include/eqc.hrl").
-include_lib("eqc/include/eqc_statem.hrl").

-compile(export_all).

-record(state,{started=false, driver, logged_in=false}).

initial_state() -> #state{}.

start_pre(State) -> 
  	not(State#state.started).
start_args(_State) ->
	[].
start() ->
	online_test:start().
start_next(State,Result,_) ->
	State#state{started=true,driver=Result}.

login_pre(State) ->
	not(State#state.logged_in) and State#state.started.
login_args(State) ->
	[State#state.driver,"talep", "OnlineErlang"].
login(Driver, Username, Password) ->
	online_test:login(Driver, Username, Password).
login_next(State,_Result,_) ->
	State#state{started=true, driver=State#state.driver, logged_in=true}.

%logout_pre(State) ->
%	State#state.logged_in and State#state.started.
%logout_args(State) ->
%	[State#state.driver]
%logout(Driver) -> online_test:logout(Driver).
%logout_next(State,_Result,_) ->
%	State#state{started=true, driver=State#state.driver, logged_in=false}.

%access_restricted_event_pre(State) ->
%	State#state.logged_in and State#state.started.
%access_restricted_event_args(State) ->
%	[State#state.driver,"Julebord"].
%access_restricted_event(Driver, EventName) ->
%	online_test:access_restricted_event(Driver,EventName).

export_events_user_pre(State) ->
	State#state.started andalso State#state.logged_in.
export_events_user_args(State) ->
	[State#state.driver].
export_events_user(Driver) -> 
	online_test:export_events(Driver).
export_events_user_post(_State,_,Result) -> 
	io:format("ICS: ~p~n", [Result]),
	Result == 2.

export_events_pre(State) ->
	State#state.started andalso not(State#state.logged_in).
export_events_args(State) ->
	[State#state.driver].
export_events(Driver) -> 
	online_test:export_events(Driver).
export_events_post(_State,_,Result) -> 
	io:format("ICS: ~p~n", [Result]),
	Result == 1.

%wiki_access_pre(State) ->
%	State#state.started andalso not(State#state.logged_in).
%wiki_access_args(State) ->
%	[State#state.driver].
%wiki_access(Driver) -> 
%	online_test:title_restricted_wiki(Driver).
%wiki_access_post(_State,_,Result) -> 
%	Result == "Logg inn - Online".

%wiki_access_user_pre(State) ->
%	State#state.started andalso State#state.logged_in.
%wiki_access_user_args(State) ->
%	[State#state.driver].
%wiki_access_user(Driver) -> 
%	online_test:title_restricted_wiki(Driver).
%wiki_access_user_post(_State,_,Result) -> 
%	Result == "Komiteer".

%dashboard_events_pre(State) ->
%	State#state.started andalso State#state.logged_in.
%dashboard_events_args(State) ->
%	[State#state.driver].
%dashboard_events(Driver) ->
%	online_test:title_dashboard_events(Driver).
%dashboard_events_post(_State,_,Result) ->
%	Result == "Event index - Dashboard - Online".

%dashboard_marks_pre(State) ->
%	State#state.started andalso State#state.logged_in.
%dashboard_marks_args(State) ->
%	[State#state.driver].
%dashboard_marks(Driver) ->
%	online_test:title_dashboard_marks(Driver).
%dashboard_marks_post(_State,_,Result) ->
%	Result == "Permission denied - Online".
	
% DOES NOT WORK BECAUSE OF STATUS_EVENT
%status_event_user_pre(State) ->
%	State#state.logged_in and State#state.started.
%status_event_user_args(State) ->
%	[State#state.driver].
%status_event_user(Driver) -> online_test:status_event(Driver).
%status_event_user_post(_State,_,Result) ->
%	not_exception(Result) andalso Result == "Påmeldingen er ikke lenger åpen.".

% DOES NOT WORK BECAUSE OF STATUS_EVENT
%status_event_pre(State) -> 
%	not(State#state.logged_in) andalso State#state.started.
%status_event_args(State) ->
%	[State#state.driver].
%status_event(Driver) -> online_test:status_event(Driver).
%status_event_post(_State,_,Result) ->
%	not_exception(Result) andalso Result == "Du må være logget inn for å se din status.".

filter_articles_pre(State) ->
	State#state.started.
filter_articles_args(State) ->
	[State#state.driver].
filter_articles(Driver) -> online_test:filter_articles(Driver).




% General code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eqc() ->
  eqc:quickcheck(?MODULE:prop_s1()).

prop_s1() ->
  ?FORALL(Cmds,commands(?MODULE),
	  begin 
	    {H,S,Res} = run_commands(?MODULE,Cmds),
            pretty_commands(?MODULE, Cmds, {H, S, Res},
                            Res == ok)
	  end).
