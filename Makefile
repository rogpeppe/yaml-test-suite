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
	ruamel-event \
	ruby-json \

ifneq (,$(wildcard $(PWD)/../../yaml-editor))
    YAML_EDITOR ?= $(PWD)/../../yaml-editor
endif
ifneq (,$(wildcard $(PWD)/../yaml-editor))
    YAML_EDITOR ?= $(PWD)/../yaml-editor
endif
ifeq (,$(YAML_EDITOR))
    $(error Cannot locate yaml-editor. Please set YAML_EDITOR)
endif
export YAML_EDITOR


#------------------------------------------------------------------------------
build: $(ALL_VIEWS)

$(ALL_VIEWS): gh-pages data matrix
	@bash -c "printf '%.0s-' {1..80}; echo";
	time ./bin/run-framework-tests $@
	./bin/create-matrix
	rm -fr gh-pages/*.html gh-pages/css/
	cp -r matrix/html/*.html matrix/html/css/ gh-pages/

matrix:
	mkdir -p $@

data gh-pages:
	git clone $$(git config remote.origin.url) -b $@ $@

status:
	@(cd gh-pages; git status --short)

push:
	@[ -z "$$(cd gh-pages; git status --short)" ] || { \
	    cd gh-pages; \
	    git add -Af .; \
	    git commit -m 'Regenerated matrix files'; \
	    git push --force origin gh-pages; \
	}

clean:
	rm -fr data gh-pages matrix
	git clean -dxf
