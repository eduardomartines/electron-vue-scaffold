SHELL := /bin/bash

docker_compose_command = docker-compose run app

# If the first argument is "yarn"...
ifeq (yarn,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "yarn"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif

prepare-host:
	xhost +

pack-windows:
	docker run --rm -it \
		--env-file <(env | grep -iE 'DEBUG|NODE_|ELECTRON_|YARN_|NPM_|CI|CIRCLE|TRAVIS_TAG|TRAVIS|TRAVIS_REPO_|TRAVIS_BUILD_|TRAVIS_BRANCH|TRAVIS_PULL_REQUEST_|APPVEYOR_|CSC_|GH_|GITHUB_|BT_|AWS_|STRIP|BUILD_') \
		--env ELECTRON_CACHE="/root/.cache/electron" \
		--env ELECTRON_BUILDER_CACHE="/root/.cache/electron-builder" \
		-v $(shell pwd):/project \
		-v $(notdir $(shell pwd))-node-modules:/project/node_modules \
		-v ~/.cache/electron:/root/.cache/electron \
		-v ~/.cache/electron-builder:/root/.cache/electron-builder \
		electronuserland/builder:wine yarn build --win

pack-linux:
	@$(docker_compose_command) yarn build

yarn:
	@${MAKE} prepare-host
	@$(docker_compose_command) yarn $(RUN_ARGS)
