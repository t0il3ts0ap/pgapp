%%%-------------------------------------------------------------------
%%% @author David N. Welton <davidw@dedasys.com>
%%% @copyright (C) 2015, David N. Welton
%%% @doc
%%%
%%% @end
%%% Created : 20 Feb 2015 by David N. Welton <davidw@dedasys.com>
%%%-------------------------------------------------------------------
-module(pgapp).

%% API
-export([connect/1, equery/2, squery/1]).

%%%===================================================================
%%% API
%%%===================================================================

connect(Settings) ->
    PoolSize = proplists:get_value(size, Settings, 5),
    MaxOverflow = proplists:get_value(max_overflow, Settings, 5),
    pgapp_sup:add_pool(epgsql_pool,
                       [{name, {local, epgsql_pool}},
                        {worker_module, pgapp_worker},
                        {size, PoolSize},
                        {max_overflow, MaxOverflow}],
                       Settings).

-spec equery(Sql::epgsql:sql_query(),
             Params :: list(epgsql:bind_param())) -> epgsql:reply(epgsql:equery_row()).
equery(Sql, Params) ->
    poolboy:transaction(epgsql_pool,
                        fun(Worker) ->
                                gen_server:call(Worker, {equery, Sql, Params})
                        end).

-spec squery(Sql::epgsql:sql_query()) -> epgsql:reply(epgsql:squery_row()) |
                                         [epgsql:reply(epgsql:squery_row())].
squery(Sql) ->
    poolboy:transaction(epgsql_pool,
                        fun(Worker) ->
                                gen_server:call(Worker, {squery, Sql})
                        end).

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
