DOCKER ?= $(shell command -v docker 2> /dev/null)
JEKYLL_VERSION = 4.2.2
DOCKER_IMAGE = jekyll/jekyll:$(JEKYLL_VERSION)
SERVE_PORT = 4000
LIVERELOAD_PORT = 35729
TIMEZONE = Asia/Tokyo

.DEFAULT_GOAL = help

ifeq ($(OS),Windows_NT)
	ifeq ($(MSYSTEM),MINGW64)
		BASE_DIR = /$$PWD
	else ifeq ($(MSYSTEM),MINGW32)
		BASE_DIR = /$$PWD
	else ifeq ($(MSYSTEM),MSYS)
		BASE_DIR = /$$PWD
	else
		exit
	endif
else
	BASE_DIR = $$PWD
endif

.PHONY: bash
bash: ## open interactive shell (bash)
	docker run -it --rm \
		-e TZ=$(TIMEZONE) \
		-v $(BASE_DIR)/tools:/tools \
		-v $(BASE_DIR)/docs:/srv/jekyll \
		$(DOCKER_IMAGE) \
		bash

.PHONY: build
build: ## jekyll build
	docker run -it --rm \
		-e TZ=$(TIMEZONE) \
		-v $(BASE_DIR)/docs:/srv/jekyll \
		-e JEKYLL_ENV=production \
		$(DOCKER_IMAGE) \
		jekyll build

.PHONY: config_build
config_build: ## build config
	docker run -it --rm \
		-e TZ=$(TIMEZONE) \
		-v $(BASE_DIR)/tools:/tools \
		-v $(BASE_DIR)/docs:/srv/jekyll \
		$(DOCKER_IMAGE) \
		/tools/build_config.rb _config.template.yml _config.dev.yml development
	docker run -it --rm \
		-e TZ=$(TIMEZONE) \
		-v $(BASE_DIR)/tools:/tools \
		-v $(BASE_DIR)/docs:/srv/jekyll \
		$(DOCKER_IMAGE) \
		/tools/build_config.rb _config.template.yml _config.yml production

.PHONY: config_check
config_check: ## check config diff
	@diff -u docs/_config.dev.yml docs/_config.yml || true

.PHONY: owner
owner: ## change docs directory ownership
	docker run --rm \
		-e TZ=$(TIMEZONE) \
		-v $(BASE_DIR)/docs:/srv/jekyll \
		$(DOCKER_IMAGE) \
		chown -R jekyll:jekyll .

.PHONY: serve
serve: ## jekyll serve
	docker run -it --rm \
		-e TZ=$(TIMEZONE) \
		-v $(BASE_DIR)/docs:/srv/jekyll \
		-p $(SERVE_PORT):$(SERVE_PORT) \
		-p $(LIVERELOAD_PORT):$(LIVERELOAD_PORT) \
		$(DOCKER_IMAGE) \
		jekyll serve \
			--host 0.0.0.0 \
			--trace \
			--draft \
			--livereload \
			--config _config.dev.yml

.PHONY: help
help:
	@grep -E '^[A-Za-z_-]*:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf  "\033[36m%-20s\033[0m %s\n", $$1, $$2}'