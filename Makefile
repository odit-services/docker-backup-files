IMAGE ?= ghcr.io/odit-services/docker-backup-files:latest
BIN_DIR ?= $(CURDIR)/.bin
SHIKAI ?= $(BIN_DIR)/shikai
SHIKAI_ARGS ?=

.PHONY: docker-build release install-shikai

docker-build:
	docker build -t $(IMAGE) .

install-shikai: $(SHIKAI)

$(SHIKAI):
	mkdir -p $(BIN_DIR)
	GOBIN=$(BIN_DIR) go install github.com/nicolaiort/shikai@latest

release: $(SHIKAI)
	$(SHIKAI) $(SHIKAI_ARGS)
