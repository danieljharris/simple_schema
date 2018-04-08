PROJECT       = simple_schema
REBAR         = ./rebar3

.PHONY: all deps compile test doc eunit

all: compile

me:
	$(REBAR) compile

compile: $(REBAR_SCRIPTS)

eunit:
	env ERL_FLAGS="-config `pwd`/eunit.config" $(REBAR) eunit

ct:
	$(REBAR) ct -v
