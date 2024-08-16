
MODS = hello

.SUFFIXES: .erl .beam .yrl

.erl.beam:
	erlc -W $<

all: ${MODS:%=%.beam}
	erl -pa ../ex11 -s hello start
