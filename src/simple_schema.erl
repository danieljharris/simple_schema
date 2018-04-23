-module(simple_schema).

-ifdef(TEST).
-compile([export_all]).
-endif.

%% API
-export([filter_params/2]).


% TODO: Remove the use of Acc and just use tail recursion

-spec filter_params(Schema :: [term()], Params :: [term()]) ->
    {error, Reason :: binary()} | {ok, [term()]}.

filter_params(Schema, Params) -> filter_params(Schema, Params, []).

filter_params([], _Params, Acc) -> {ok, Acc};
filter_params([{Field, DefaultOrRequired, Allowed = Schema} | Tail], Params, Acc) ->
    Return = case is_param_list(Field) of
        false -> filter_param_normal(Field, DefaultOrRequired, Allowed, Params);
        true  -> filter_param_list(Field, DefaultOrRequired, Schema, Params)
    end,
    case Return of
        {error, _} = Error -> Error;
        [] -> filter_params(Tail, Params, Acc);
        {NewField, Value} -> filter_params(Tail, Params, jsn:set(NewField, Acc, Value))
    end.


filter_param_normal(Field, DefaultOrRequired, Allowed, Params) ->
    {Default, Required} = default_or_required(DefaultOrRequired),
    case jsn:get(Field, Params, Default) of
        undefined ->
            case Required of
                true -> {error, binary_to_atom(<<"missing_", Field/binary>>, utf8)};
                false -> []
            end;
        Value when Allowed == [] ->
            {Field, Value};
        Value ->
            case lists:member(Value, Allowed) of
                true -> {Field, Value};
                false -> {error, binary_to_atom(<<"invalid_", Field/binary>>, utf8)}
            end
    end.


filter_param_list(Field0, DefaultOrRequired, Schema, Params) ->
    % Drop the : from the end of the field
    Field = erlang:list_to_binary(lists:droplast(erlang:binary_to_list(Field0))),
    {Default, Required} = default_or_required(DefaultOrRequired),
    case jsn:get(Field, Params, Default) of
        undefined ->
            case Required of
                true -> {error, binary_to_atom(<<"missing_", Field/binary>>, utf8)};
                false -> []
            end;
        [] ->
            case Required of
                true -> {error, binary_to_atom(<<"empty_", Field/binary>>, utf8)};
                false -> []
            end;
        Value when is_list(Value) ->
            case filter_list_params(Schema, Value, []) of
                {ok, ReturnList} -> {Field, ReturnList};
                {error, Reason} ->
                    BinaryReason = erlang:list_to_binary(Reason),
                    {error, binary_to_atom(<<BinaryReason/binary, "_in_", Field/binary>>, utf8)}
            end;
        _Other ->
            {error, binary_to_atom(<<"unexpected_", Field/binary>>, utf8)}
    end.


filter_list_params(_Schema, [], Acc) -> {ok, Acc};
filter_list_params(Schema, [Params | Tail], Acc) ->
    case filter_params(Schema, Params) of
        {ok, FilteredParams} ->
            filter_list_params(Schema, Tail, [{FilteredParams} | Acc]);
        {error, _} = Error -> Error
    end.


default_or_required(DefaultOrRequired) ->
    case DefaultOrRequired of
        required ->
            {undefined, true};
        optional ->
            {undefined, false};
        Default ->
            {Default, false}
    end.


is_param_list(Field0) ->
    Field = erlang:binary_to_list(Field0),
    [Colon] = ":",
    lists:member(Colon, Field).
