%.js: %.coffee
	coffee -c -m $<

all: $(addsuffix .js, $(basename $(wildcard *.coffee)))

clean:
	rm *.js
	rm *.map

watch:
	make ;\
	while true ;\
	    do inotifywait -e modify -e move -e create -e delete *.coffee ;\
	    make ;\
	done

runtests:
	./node_modules/jasmine-node/bin/jasmine-node --coffee test/
