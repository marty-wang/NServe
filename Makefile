spec:
	@./node_modules/.bin/vows spec/*.coffee

test:
	@./node_modules/.bin/mocha \
		--reporter dot

.PHONY: spec test