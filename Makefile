#
#
#
#


run:
	node coffee_bridge.js

unit:
	./node_modules/mocha/bin/_mocha \
	--exit \
	--require coffee-script/register \
	./test/unit/**/*.coffee


integration:
	./node_modules/mocha/bin/_mocha \
	--exit \
	--require coffee-script/register \
	./test/integration/**/*.coffee

test:
	$(MAKE) unit
	$(MAKE) integration
	$(MAKE) travis-cov
	$(MAKE) lint
	$(MAKE) check-dependencies || true #Can't always update deps. Allow build to pass.


compile:
	./node_modules/coffee-script/bin/coffee -o bin -c lib/*.coffee

lint:
	@./node_modules/coffeelint/bin/coffeelint \
	./lib ./test

travis-cov:
	@./node_modules/mocha/bin/_mocha \
	--exit \
	--require coffee-script/register \
	--require blanket \
	-R travis-cov \
	./test/unit/*.coffee \
	./test/integration/*.coffee

check-dependencies:
	@./node_modules/david/bin/david.js

.PHONY: test
