-module(online_test_gs).
-behaviour(gen_server).

-export([init/1,handle_call/3,terminate/2]).

%Functions for testing, unødvendig??
%-export([new/1, get/1, set/2, delete/1]).

% GenServer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

init(_) ->
	Driver = start(),
	{ok, Driver}.

handle_call({login, Driver, Username, Password}, _From, State) ->
	login(Driver,Username,Password),
	{reply, ok, State}.


% Interaction (Maybe duplicates?)
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