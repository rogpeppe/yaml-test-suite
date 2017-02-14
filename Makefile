.PHONY: data doc
ALL_TML := $(shell echo test/*.tml)
ALL_DATA := $(ALL_TML:test/%.tml=data/%)
ALL_VIEWS := \
	js-yaml-json \
	java-json \
	libyaml-event \
	nimyaml-event \
	perl5-pegex-event \
	perl5-pm-pl \
	perl5-pm-json \
	perl5-pp-event \
	perl5-syck-pl \
	perl5-syck-json \
	perl5-tiny-pl \
	perl5-tiny-json \
	perl5-xs-pl \
	perl5-xs-json \
	perl6-json \
	perl6-p6 \
	pyyaml-event \
	ruby-json \

ALL_MATRIX := $(ALL_VIEWS:%=matrix-%)

default: help

help:
	@echo 'all - doc data'
	@echo 'doc - Generate the docs'
	@echo 'data - Generate data/ files from test/ files'
	@echo 'help - Show help'

all: doc data

doc: ReadMe.pod

ReadMe.pod: doc/yaml-test-suite.swim
	swim --to=pod --complete --wrap < $< > $@

#------------------------------------------------------------------------------
.PHONY: matrix
matrix: gh-pages data $(ALL_MATRIX)

$(ALL_MATRIX):
	mkdir -p matrix
	bash -c "printf '%.0s-' {1..80}; echo";
	YAML_EDITOR=$$PWD/../yaml-editor time ./bin/run-framework-tests $(@:matrix-%=%)
	./bin/create-matrix
	rm -fr gh-pages/*.html gh-pages/css/
	cp -r matrix/html/*.html matrix/html/css/ gh-pages/

perl5-%:
	YAML_EDITOR=$$PWD/../yaml-editor ./bin/run-framework-tests $@
	./bin/create-matrix
	rm -fr gh-pages/*.html gh-pages/css/
	cp -r matrix/html/*.html matrix/html/css/ gh-pages/

gh-pages:
	git clone $$(git config remote.origin.url) -b $@ $@

matrix-push:
	@[ -z "$$(cd gh-pages; git status --short)" ] || { \
	    cd gh-pages; \
	    git add -Af .; \
	    git commit -m 'Regenerated matrix files'; \
	    git push --force origin gh-pages; \
	}

#------------------------------------------------------------------------------
.PHONY: data
data: clean-data $(ALL_DATA)

clean-data:
	@[ -d data ] || { \
	    git clone $$(git config remote.origin.url) -b data data; \
	    sleep 1; \
	    touch test/*.tml; \
	}
	rm -fr data/*

data/%: test/%.tml
	@rm -fr $@
	perl bin/generate-data $<
	@touch $@

data-status:
	@(cd data; git add -Af .; git status --short)

data-diff:
	@(cd data; git add -Af .; git diff --cached)

data-push:
	@[ -z "$$(cd data; git status --short)" ] || { \
	    cd data; \
	    git add -Af .; \
	    git commit -m 'Regenerated data files'; \
	    git push --force origin data; \
	}

#------------------------------------------------------------------------------
clean:
	rm -fr data matrix
	git clean -dxf

.PHONY: test
test:
	@echo "We don't run tests here."
