-module(simple_schema_tests).

-ifdef(TEST).
-compile([export_all]).

-include("simple_schema.hrl").
-include("simple_schema_test.hrl").

-include_lib("eunit/include/eunit.hrl").

-import(simple_schema, [filter_params/2]).

% TODO: Make checks for defaults being set manually
% TODO: Tidy up code where possible
% TODO: Integrate this into current "dummy" tickets to see if it slots in well

filter_test() ->
    InputParams = [{<<"true_empty">>, <<"random">>},
                   {<<"true_allowed">>, <<"a">>},
                   {<<"indent">>, [{<<"true_empty">>, <<"random">>},
                                   {<<"true_allowed">>, <<"b">>}]},
                   {<<"list">>, [
                                 {
                                  [{<<"true_empty">>, <<"random">>},
                                   {<<"true_allowed">>, <<"a">>}]
                                 }
                                ]}
                  ],

    OutputParams = {[{<<"true_empty">>, <<"random">>},
                    {<<"true_allowed">>, <<"a">>},
                    {<<"default">>, <<"test_data_one">>},
                    {<<"default_allowed">>, <<"a">>},
                    {<<"indent">>, {[{<<"true_empty">>, <<"random">>},
                                    {<<"true_allowed">>, <<"b">>},
                                    {<<"default">>, <<"test_data_two">>},
                                    {<<"default_allowed">>, <<"b">>}]}},
                    {<<"list">>, [
                                  {
                                   [{<<"true_empty">>, <<"random">>},
                                    {<<"true_allowed">>, <<"a">>},
                                    {<<"default">>, <<"test_data_one">>},
                                    {<<"default_allowed">>, <<"a">>}]
                                  }
                                 ]}
                   ]},

    Return = filter_params(?TESTING_ABCDE, InputParams),

    ct:pal("Return: ~p", [Return]),

    ?assertMatch({ok, OutputParams}, Return).


filter_error_test() ->
    InputParams = [{<<"true_allowed">>, <<"a">>},
                   {<<"indent">>, [{<<"true_empty">>, <<"random">>},
                                   {<<"true_allowed">>, <<"b">>}]},
                   {<<"list">>, [
                                 {
                                  [{<<"true_empty">>, <<"random">>},
                                   {<<"true_allowed">>, <<"a">>}]
                                 }
                                ]}
                  ],

    Return = filter_params(?TESTING_ABCDE, InputParams),

    ct:pal("Return: ~p", [Return]),

    ?assertMatch({error,missing_true_empty}, Return).

filter_error_indent_test() ->
    InputParams = [{<<"true_empty">>, <<"random">>},
                   {<<"true_allowed">>, <<"a">>},
                   {<<"indent">>, [{<<"true_allowed">>, <<"b">>}]},
                   {<<"list">>, [
                                 {
                                  [{<<"true_empty">>, <<"random">>},
                                   {<<"true_allowed">>, <<"a">>}]
                                 }
                                ]}
                  ],

    Return = filter_params(?TESTING_ABCDE, InputParams),

    ct:pal("Return: ~p", [Return]),

    ?assertMatch({error,'missing_indent.true_empty'}, Return).

filter_error_list_test() ->
    InputParams = [{<<"true_empty">>, <<"random">>},
                   {<<"true_allowed">>, <<"a">>},
                   {<<"indent">>, [{<<"true_empty">>, <<"random">>},
                                   {<<"true_allowed">>, <<"b">>}]},
                   {<<"list">>, [
                                 {
                                  [{<<"true_allowed">>, <<"a">>}]
                                 }
                                ]}
                  ],

    Return = filter_params(?TESTING_ABCDE, InputParams),

    ct:pal("Return: ~p", [Return]),

    ?assertMatch({error,'missing_true_empty_in_list'}, Return).

-endif.
