# simple_schema

Very simple json schema validation

```erlang
%                      |         Field         |  Required/Default  | Allowed Values |
-define(TESTING_ABCDE, [{<<"true_empty">>,      required,            []},
                        {<<"false_empty">>,     optional,            []},
                        {<<"true_allowed">>,    required,            [<<"a">>, <<"b">>]},
                        {<<"false_allowed">>,   optional,            [<<"a">>, <<"b">>]},
                        {<<"default">>,         <<"test_data_one">>, []},
                        {<<"default_allowed">>, <<"a">>,             [<<"a">>, <<"b">>]},

                        {<<"indent.true_empty">>,      required,            []},
                        {<<"indent.false_empty">>,     optional,            []},
                        {<<"indent.true_allowed">>,    required,            [<<"a">>, <<"b">>]},
                        {<<"indent.false_allowed">>,   optional,            [<<"a">>, <<"b">>]},
                        {<<"indent.default">>,         <<"test_data_two">>, []},
                        {<<"indent.default_allowed">>, <<"b">>,             [<<"a">>, <<"b">>]},

                        {<<"list:">>,           required,                ?TESTING_LIST_}
                        ]).

%                      |         Field         |  Required/Default  | Allowed Values |
-define(TESTING_LIST_, [{<<"true_empty">>,      required,            []},
                        {<<"false_empty">>,     optional,            []},
                        {<<"true_allowed">>,    required,            [<<"a">>, <<"b">>]},
                        {<<"false_allowed">>,   optional,            [<<"a">>, <<"b">>]},
                        {<<"default">>,         <<"test_data_one">>, []},
                        {<<"default_allowed">>, <<"a">>,             [<<"a">>, <<"b">>]}
                        ]).
```
# How to use:
ValidatedJson = simple_schema:filter_params(?TESTING_ABCDE, JsonInput).

<!--- vim: sw=4 et ts=4 -->
