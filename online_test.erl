-module(online_test).

-compile(export_all).

-include_lib("eqc/include/eqc.hrl").


% Start test cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test() ->
	Driver = start(),
	filter_articles(Driver).
	%eqc:quickcheck(prop_dashboard_access(Driver)).

% Test cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check login
prop_login(Driver) -> 
	?FORALL({Login,Password},{oneof([non_empty(list(char())),"talep"]),oneof([non_empty(list(char())),"OnlineErlang"])},
		begin
			login(Driver,Login,Password),
			TitlePre = java:call(Driver,getTitle,[]),
			Result = java:string_to_list(TitlePre),
			case {Login,Password} of 
				{"talep","OnlineErlang"} ->
					java:call(Driver,get,["https://online.ntnu.no/auth/logout/"]),
					not_exception(Result) andalso Result == "Online, linjeforeningen for informatikk ved NTNU";
				{_,_} ->
					not_exception(Result) andalso Result == "Logg inn - Online"
			end
		end).

% Check title of restricted event 
prop_event_access(Driver) ->
	?FORALL(Login,oneof([true, false]),
		begin
			io:format("Case: ~p~n", [Login]),
			case Login of 
				true ->
					login(Driver,"talep","OnlineErlang"),
					io:format("Get title~n"),
					Title = title_restricted_event(Driver),
					io:format("Case: ~p~n", [Title]),
					java:call(Driver,get,["https://online.ntnu.no/auth/logout/"]),
					not_exception(Title) andalso Title == "Julebord - Online";
				false ->
					io:format("Get title~n"),
					Title = title_restricted_event(Driver),
					io:format("Case: ~p~n", [Title]),
					not_exception(Title) andalso Title == "Arrangementsarkiv - Online"
			end
		end).

% Check title of wiki page
prop_wiki_access(Driver) ->
	?FORALL(Login,oneof([true, false]),
		begin
			io:format("Case: ~p~n", [Login]),
			case Login of 
				true ->
					login(Driver,"talep","OnlineErlang"),
					Title = title_restricted_wiki(Driver),
					java:call(Driver,get,["https://online.ntnu.no/auth/logout/"]),
					not_exception(Title) andalso Title == "Komiteer";
				false ->
					Title = title_restricted_wiki(Driver),
					not_exception(Title) andalso Title == "Logg inn - Online"
			end
		end).

% Certifies nr of ICS elements in export list
prop_export_events(Driver) ->
	?FORALL(Login,oneof([true, false]),
		begin
			io:format("Case: ~p~n", [Login]),
			case Login of 
				true ->
					login(Driver,"talep","OnlineErlang"),
					ICSElements = export_events(Driver),
					java:call(Driver,get,["https://online.ntnu.no/auth/logout/"]),
					ICSElements == 2;
				false ->
					ICSElements = export_events(Driver),
					ICSElements == 1
			end
		end).	

% Check dashboard access
prop_dashboard_access(Driver) ->
	?FORALL(Accesspoint,oneof(["Prikker", "Arrangement"]),
		begin
			login(Driver,"talep","OnlineErlang"),
			case Accesspoint of 
				"Prikker" ->
					Title = title_dashboard_marks(Driver),
					java:call(Driver,get,["https://online.ntnu.no/auth/logout/"]),
					Title == "Permission denied - Online";
				"Arrangement" ->
					Title = title_dashboard_events(Driver),
					java:call(Driver,get,["https://online.ntnu.no/auth/logout/"]),
					Title == "Event index - Dashboard - Online"
			end
		end).	

% DOES NOT WORK BECAUSE OF STATUS_EVENT
% See the different statuses
%prop_status_event(Driver) ->
%	?FORALL(Login,oneof([true, false]),
%		begin
%			io:format("Case: ~p~n", [Login]),
%			case Login of 
%				true ->
%					login(Driver,"talep","OnlineErlang"),
%					io:format("Get status~n"),
%					Status = status_event(Driver),
%					io:format("Case: ~p~n", [Status]),
%					java:call(Driver,get,["https://online.ntnu.no/auth/logout/"]),
%					not_exception(Status) andalso Status == "Påmeldingen er ikke lenger åpen.";
%				false ->
%					io:format("Get status~n"),
%					Status = status_event(Driver),
%					io:format("Case: ~p~n", [Status]),
%					not_exception(Status) andalso Status == "Du må være logget inn for å se din status."
%			end
%		end).


% DOES NOT WORK BECAUSE OF IS_ELEMENT_PRESENT
%prop_filter_articles(Driver) ->
%	?FORALL(Linktext,oneof([non_empty(list(char())),"Fadderukene 2013"]),
%		begin
%			N = java:node_id(Driver),
%			filter_articles(Driver),
%			LinktextBy = java:call_static(N,'org.openqa.selenium.By',linkText,[Linktext]),
%			case Linktext of 
%				"Fadderukene 2013" ->
%					LinktextElement = java:call(Driver,findElement,[LinktextBy]),
%					timer:sleep(2000),
%					java:call(LinktextElement,click,[])
%			end
%		end).


% Interaction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

login(Driver,Login,Password) ->
	io:format("login~n"),
	N = java:node_id(Driver),
	java:call(Driver,get,["https://online.ntnu.no/auth/login/"]),
	% Write username
	timer:sleep(1000),
	UsernameBy = java:call_static(N,'org.openqa.selenium.By',xpath,["(//input[@id='id_username'])[2]"]),
	UsernameElement = java:call(Driver,findElement,[UsernameBy]),
	java:call(UsernameElement,sendKeys,[[java:list_to_string(N,Login)]]),
	% Write password
	PasswdBy = java:call_static(N,'org.openqa.selenium.By',xpath,["(//input[@id='id_password' or @id='password'])[2]"]),
	PasswdElement = java:call(Driver,findElement,[PasswdBy]),
	java:call(PasswdElement,sendKeys,[[java:list_to_string(N,Password)]]),
	% Click login button
	ButtonBy = java:call_static(N,'org.openqa.selenium.By',cssSelector,["button.btn.btn-success"]),
	ButtonElement = java:call(Driver,findElement,[ButtonBy]),
	java:call(ButtonElement,click,[]).

logout(Driver) ->
	java:call(Driver,get,["https://online.ntnu.no/auth/logout/"]).

title_restricted_event(Driver) ->
	java:call(Driver,get,["https://online.ntnu.no/events/211/julebord/"]),
	timer:sleep(1000),
	TitlePre = java:call(Driver,getTitle,[]),
	io:format("Title list: ~p~n", [TitlePre]),
	Title = java:string_to_list(TitlePre),
	io:format("Title: ~p~n", [Title]),
	Title.

search_restricted_event(Driver,EventName) ->
	N = java:node_id(Driver),
	java:call(Driver,get,["https://online.ntnu.no/events"]),
	% Search for restricted event
	SearchBy = java:call_static(N,'org.openqa.selenium.By',id,["search"]),
	SearchElement = java:call(Driver,findElement,[SearchBy]),
	java:call(SearchElement,sendKeys,[[java:list_to_string(N,EventName)]]),
	% Click checkbox for future events
	ChbFutureEventsBy = java:call_static(N,'org.openqa.selenium.By',id,["future"]),
	ChbFutureEventsElement = java:call(Driver,findElement,[ChbFutureEventsBy]),
	java:call(ChbFutureEventsElement,click,[]).

access_restricted_event(Driver,EventName) ->
	N = java:node_id(Driver),
	search_restricted_event(Driver,EventName),
	% Access restricted event
	timer:sleep(2000),
	AccessEventBy = java:call_static(N,'org.openqa.selenium.By',linkText,["Julebord"]),
	AccessEventElement = java:call(Driver,findElement,[AccessEventBy]),
	java:call(AccessEventElement,click,[]).

filter_articles(Driver) ->
	N = java:node_id(Driver),
	java:call(Driver,get,["https://online.ntnu.no/article/archive/"]),
	% Filter articles
	FilterBy = java:call_static(N,'org.openqa.selenium.By',linkText,["fadderuker"]),
	FilterElement = java:call(Driver,findElement,[FilterBy]),
	java:call(FilterElement,click,[]).

title_restricted_wiki(Driver) ->
	java:call(Driver,get,["https://online.ntnu.no/wiki/komiteer/"]),
	timer:sleep(1000),
	TitlePre = java:call(Driver,getTitle,[]),
	io:format("Title list: ~p~n", [TitlePre]),
	Title = java:string_to_list(TitlePre),
	io:format("Title: ~p~n", [Title]),
	Title.

export_events(Driver) ->
	N = java:node_id(Driver),
	java:call(Driver,get,["https://online.ntnu.no/events/"]),
	% Press export button
	ExportBtnBy = java:call_static(N,'org.openqa.selenium.By',xpath,["//button[@type='button']"]),
	ExportBtnElement = java:call(Driver,findElement,[ExportBtnBy]),
	java:call(ExportBtnElement,click,[]),
	% Find ICS elements
	ICSBy = java:call_static(N,'org.openqa.selenium.By',linkText,["ICS"]),
	ICSElements = java:call(Driver,findElements,[ICSBy]),
	java:call(ICSElements,size,[]).

title_dashboard_marks(Driver) ->
	N = java:node_id(Driver),
	java:call(Driver,get,["https://online.ntnu.no/dashboard/"]),
	timer:sleep(1000),
	% Access marks module
	MarksBy = java:call_static(N,'org.openqa.selenium.By',linkText,["Prikker"]),
	MarksElement = java:call(Driver,findElement,[MarksBy]),
	java:call(MarksElement,click,[]),
	% Get title
	TitlePre = java:call(Driver,getTitle,[]),
	Title = java:string_to_list(TitlePre),
	Title.

title_dashboard_events(Driver) ->
	N = java:node_id(Driver),
	java:call(Driver,get,["https://online.ntnu.no/dashboard/"]),
	timer:sleep(1000),
	% Access marks module
	EventsBy = java:call_static(N,'org.openqa.selenium.By',xpath,["//a[contains(text(),'Arrangement')]"]),
	EventsElement = java:call(Driver,findElement,[EventsBy]),
	java:call(EventsElement,click,[]),
	% Get title
	TitlePre = java:call(Driver,getTitle,[]),
	Title = java:string_to_list(TitlePre),
	Title.

% DOES NOT WORK AND I DONT KNOW HOW TO FIX
%is_element_present(Driver,By) ->
%	Element = java:call(Driver,findElement,[By]),
%	not_exception(Element).
%
	

% DOES NOT WORK AND I DONT KNOW HOW TO FIX
%status_event(Driver) ->
%	N = java:node_id(Driver),
%	java:call(Driver,get,["https://online.ntnu.no/events/152/17-mai-middag/"]),
%
%	StatusBy = java:call_static(N,'org.openqa.selenium.By',className,["status-text"]),
%	StatusElement = java:call(Driver,findElement,[StatusBy]),
%
%	StatusPre = java:call(StatusElement,getText,[]),
%	io:format("Status list: ~p~n", [StatusPre]),
%	Status = java:string_to_list(StatusPre),
%	io:format("Status: ~p~n", [Status]),
%	Status.


% General code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start() -> 
	{ok,[[Home]]} = init:get_argument(home), 
	ClassPath = all_jars("repository"),
	{ok,N} = java:start_node([{add_to_java_classpath,ClassPath},{call_timeout,60000}]),
	java:call_static(N,'java.lang.System',setProperty, ["webdriver.chrome.driver", Home++"/Tools/chromedriver/chromedriver.exe"]),
	Driver = java:new(N,'org.openqa.selenium.chrome.ChromeDriver',[]).

not_exception({java_exception,_}) ->
  false;
not_exception(_) ->
  true.

all_jars(Prefix) ->
	filelib:fold_files
		(Prefix, ".*jar$", true, 
		fun (Name,Acc) -> [Name|Acc] end,
		[]).