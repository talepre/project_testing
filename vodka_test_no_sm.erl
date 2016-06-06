-module(vodka_test_no_sm).

%% CBE codigo a medio hacer


-compile(export_all).

-include_lib("eqc/include/eqc.hrl").

-record(state,{loginName_password=[{"vodkatv","vodkatv"}],currencies=[]}).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initial_state() ->
  #state{}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Login works as expected
prop_login(Driver) -> 
  ?FORALL({Login,Password},{oneof([non_empty(list(char())),"vodkatv"]),oneof([non_empty(list(char())),"vodkatv"])},
          begin
            login(Driver,Login,Password),
            TitlePre = java:call(Driver,getTitle,[]),
            Result = java:string_to_list(TitlePre),
            case {Login,Password} of 
                 {"vodkatv","vodkatv"} -> 
                     timer:sleep(1000),
                     java:call(Driver,get,["http://193.144.63.20:8082/admin/index.layout.userinfo.logout"]),
                     not_exception(Result) andalso Result == "VoDKA.TV Index";
                 {_,_} ->
                     not_exception(Result) andalso Result == "VoDKA.TV"
            end
          end).


%% Create a new currency works as expected
prop_currency_create(S,Driver) -> 
  ?FORALL(NewCurrency,oneof(["dollar","euro","pound","peseta"]),
          begin 
             login(Driver,"vodkatv","vodkatv"),
             Result = create_currency(Driver,NewCurrency),
             case lists:member(NewCurrency,S#state.currencies) of
                  false ->  
                     timer:sleep(1000),
                     S#state{currencies=[NewCurrency|S#state.currencies]},
                     java:call(Driver,get,["http://193.144.63.20:8082/admin/index.layout.userinfo.logout"]),
                     timer:sleep(1000),
                     io:format("Item created successfully: ~p ~n",[string:str(Result,"Item created successfully")]),
                     string:str(Result,"Item created successfully") == 0;
                  true ->
                     timer:sleep(1000),
                     java:call(Driver,get,["http://193.144.63.20:8082/admin/index.layout.userinfo.logout"]),
                     timer:sleep(1000),
                     io:format("Error creating item ~n"),
                     string:str(Result,"Error creating item") > 0
             end
          end).

%% Checks in currency table
prop_currency_table(S,Driver) -> 
  ?FORALL(NewCurrency,oneof(["dollar","euro","pound","peseta"]),
          begin 
             login(Driver,"vodkatv","vodkatv"),
             %create_currency(Driver,NewCurrency),
             Result = elements_currency_table(Driver),
             Text = string:tokens(Result," "),
             io:format("Text ~p~n",[Text]),
             case lists:member(NewCurrency,Text) of
                  true ->  
                     timer:sleep(1000),
                     java:call(Driver,get,["http://193.144.63.20:8082/admin/index.layout.userinfo.logout"]),
                     true;
                  false ->
                     timer:sleep(1000),
                     java:call(Driver,get,["http://193.144.63.20:8082/admin/index.layout.userinfo.logout"]),
                     false
             end
          end).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test() ->
  InitialState = #state{},
  Driver = start(chrome),
  eqc:quickcheck(prop_login(Driver)).
  %eqc:quickcheck(prop_currency_create(InitialState,Driver)).
  %eqc:quickcheck(prop_currency_table(InitialState,Driver)).


start(Browser) ->
  {ok,[[Home]]} = init:get_argument(home), 
  ClassPath = all_jars("../repository"),
  {ok,N} =
    java:start_node
      ([{add_to_java_classpath,ClassPath}]),
  io:format("Before driver~n"),
  Driver =
    case Browser of
      html -> 
	java:new(N,'org.openqa.selenium.htmlunit.HtmlUnitDriver',[]);
      firefox ->
	java:new(N,'org.openqa.selenium.firefox.FirefoxDriver',[]);
      chrome ->
	java:call_static(N,'java.lang.System',setProperty,
			 ["webdriver.chrome.driver", 
			  Home++"/tools/chromedriver"]),
	java:new(N,'org.openqa.selenium.chrome.ChromeDriver',[])
      end.

login(Driver,Login,Password) ->
  timer:sleep(1000),
  io:format("login~n"),
  timer:sleep(1000),
  N = java:node_id(Driver),
  timer:sleep(1000),
  java:call(Driver,get,["http://193.144.63.20:8082/admin"]),
  timer:sleep(1000),
  LoginBy = java:call_static(N,'org.openqa.selenium.By',id,["loginName"]),
  LoginElement = java:call(Driver,findElement,[LoginBy]),
  java:call(LoginElement,sendKeys,[[java:list_to_string(N,Login)]]),
  PasswdBy = java:call_static(N,'org.openqa.selenium.By',id,["password"]),
  PasswdElement = java:call(Driver,findElement,[PasswdBy]),
  java:call(PasswdElement,sendKeys,[[java:list_to_string(N,Password)]]),
  timer:sleep(100),
  java:call(PasswdElement,submit,[]).


create_currency(Driver,NewCurrency) ->
  timer:sleep(1000),
  io:format("New currency ~p~n",[NewCurrency]),
  N = java:node_id(Driver),
  timer:sleep(1000),
  java:call(Driver,get,["http://193.144.63.20:8082/admin/new-admin/app/index.html#/table/grid/client/external/admin/v2/currencies"]),
  timer:sleep(1000),
  ButtonBy = java:call_static(N,'org.openqa.selenium.By',xpath,["//button[@type='button']"]),
  timer:sleep(1000),
  ButtonElement = java:call(Driver,findElement,[ButtonBy]),
  timer:sleep(1000),
  java:call(ButtonElement,click,[]),
  timer:sleep(1000),
  timer:sleep(1000),
  VisualNameBy = java:call_static(N,'org.openqa.selenium.By',id,["visualName"]),
  timer:sleep(1000),
  VisualNameElement = java:call(Driver,findElement,[VisualNameBy]),
  java:call(VisualNameElement,sendKeys,[[java:list_to_string(N,NewCurrency)]]),
  CreateBy = java:call_static(N,'org.openqa.selenium.By',id,["create"]),
  CreateElement = java:call(Driver,findElement,[CreateBy]),
  java:call(CreateElement,click,[]),
  io:format("after click~n"),
  ResultBy = java:call_static(N,'org.openqa.selenium.By',className,["alert"]),
  timer:sleep(1000),
  ListWebElement = java:call(Driver,findElement,[ResultBy]),
  io:format("after findElement~n"),
  io:format("getText ~p~n",[java:string_to_list(java:call(ListWebElement,getText,[]))]),
  java:string_to_list(java:call(ListWebElement,getText,[])).
  
elements_currency_table(Driver) -> 
  N = java:node_id(Driver),
  timer:sleep(1000),
  java:call(Driver,get,["http://193.144.63.20:8082/admin/new-admin/app/index.html#/table/grid/client/external/admin/v2/currencies"]),
  ResultBy = java:call_static(N,'org.openqa.selenium.By',className,["ngCellText"]),
  timer:sleep(1000),
  ListWebElement = java:call(Driver,findElement,[ResultBy]),
  java:string_to_list(java:call(ListWebElement,getText,[])).
  
  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

not_exception({java_exception,_}) ->
  false;
not_exception(_) ->
  true.
    
all_jars(Prefix) ->
  filelib:fold_files
    (Prefix, ".*jar$", true, 
     fun (Name,Acc) -> [Name|Acc] end,
     []).