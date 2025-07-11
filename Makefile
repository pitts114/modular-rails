# Makefile for managing Docker secrets on a remote host and building docker images

REGISTRY ?= 147.135.5.142:5000/pullman14/
IMAGE_NAME ?= arbius-command-center
GIT_COMMIT := $(shell git rev-parse --short HEAD)

FULL_IMAGE_NAME := $(REGISTRY)$(IMAGE_NAME):$(GIT_COMMIT)

# Usage:
# make set-secret SECRET_NAME=your_secret_name SECRET_VALUE=your_secret_value

set-secret:
	echo "$(SECRET_VALUE)" | docker -H ssh://ubuntu@acc.justinpitts.dev secret create $(SECRET_NAME) - || echo "Secret already exists or failed"

# Example for deploying a stack remotely:
# make deploy-stack

rm-secret:
	docker -H ssh://ubuntu@acc.justinpitts.dev secret rm $(SECRET_NAME) || echo "Secret does not exist or could not be removed"

deploy-stack:
	docker -H ssh://ubuntu@acc.justinpitts.dev stack deploy --compose-file docker-compose.prod.yml arbius-command-center --with-registry-auth

prodconsole:
	ssh ubuntu@acc.justinpitts.dev -t 'docker exec -it $$(docker container ls  | grep '"'"'arbius-command-center_admin'"'"' | awk '"'"'{print $$1}'"'"') /bin/bash'

prodrailsconsole:
	ssh ubuntu@acc.justinpitts.dev -t 'docker exec -it $$(docker container ls  | grep '"'"'arbius-command-center_admin'"'"' | awk '"'"'{print $$1}'"'"') bundle exec rails c -e production'

prodssh:
	ssh ubuntu@acc.justinpitts.dev

# Usage:
# make docker-build
# make docker-push

docker-build:
	docker buildx build --platform linux/amd64 -t $(FULL_IMAGE_NAME) --load .

docker-push:
	docker push $(FULL_IMAGE_NAME)
