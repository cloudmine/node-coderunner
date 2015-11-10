#
#
#
#


run:
	node coffee_bridge.js

unit:
	./node_modules/mocha/bin/_mocha \
	--compilers coffee:coffee-script/register \
	./test/unit


integration:
	./node_modules/mocha/bin/_mocha \
	--compilers coffee:coffee-script/register \
	./test/integration
security:
	./node_modules/.bin/snyk test

test:
	$(MAKE) unit
	$(MAKE) integration
	$(MAKE) travis-cov
	$(MAKE) lint
	$(MAKE) check-dependencies
	$(MAKE) security

compile:
	./node_modules/coffee-script/bin/coffee -o bin -c lib/*.coffee

lint:
	@./node_modules/coffeelint/bin/coffeelint \
	./lib ./test

travis-cov:
	@./node_modules/mocha/bin/_mocha \
	--compilers coffee:coffee-script/register \
	--require ./node_modules/blanket-node/bin/index.js \
	-R travis-cov \
	./test/unit \
	./test/integration

check-dependencies:
	@./node_modules/david/bin/david.js

.PHONY: test
