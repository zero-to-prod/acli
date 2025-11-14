.PHONY: help build test push clean install run shell version

# Configuration
IMAGE := davidsmith3/acli
TAG := latest
PLATFORMS := linux/amd64,linux/arm64

help: ## Show this help message
	@echo "ACLI Docker Image - Available Commands"
	@echo "======================================="
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

build: ## Build Docker image locally
	@echo "Building $(IMAGE):$(TAG)..."
	docker build -t $(IMAGE):$(TAG) .
	@echo "✓ Build complete!"

build-multiarch: ## Build multi-architecture image (requires buildx)
	@echo "Building multi-architecture image for $(PLATFORMS)..."
	docker buildx build \
		--platform $(PLATFORMS) \
		--tag $(IMAGE):$(TAG) \
		--load \
		.
	@echo "✓ Multi-arch build complete!"

test: build ## Run tests on the image
	@echo "Running tests on $(IMAGE):$(TAG)..."
	@./test.sh $(IMAGE):$(TAG)

run: ## Run ACLI with help command
	@docker run --rm -it $(IMAGE):$(TAG)

shell: build ## Open shell in the container
	@docker run --rm -it --entrypoint /bin/sh $(IMAGE):$(TAG)

version: build ## Show ACLI version
	@docker run --rm $(IMAGE):$(TAG) --version

push: test ## Push image to Docker Hub (requires authentication)
	@echo "Pushing $(IMAGE):$(TAG) to Docker Hub..."
	docker push $(IMAGE):$(TAG)
	@echo "✓ Push complete!"

push-multiarch: ## Push multi-architecture image to Docker Hub
	@echo "Building and pushing multi-architecture image..."
	docker buildx build \
		--platform $(PLATFORMS) \
		--tag $(IMAGE):$(TAG) \
		--push \
		.
	@echo "✓ Multi-arch push complete!"

clean: ## Remove local image
	@echo "Removing $(IMAGE):$(TAG)..."
	-docker rmi $(IMAGE):$(TAG)
	@echo "✓ Cleanup complete!"

install: ## Install ACLI wrapper locally
	@echo "Running installation script..."
	@./install.sh

size: build ## Show image size
	@echo "Image size for $(IMAGE):$(TAG):"
	@docker image inspect $(IMAGE):$(TAG) --format='Size: {{.Size}} bytes ({{div .Size 1048576}} MB)'

pull: ## Pull latest image from Docker Hub
	@echo "Pulling $(IMAGE):$(TAG)..."
	docker pull $(IMAGE):$(TAG)
	@echo "✓ Pull complete!"

dev: ## Set up development environment
	@echo "Setting up development environment..."
	@chmod +x acli.sh install.sh test.sh
	@echo "✓ Scripts made executable"
	@make build
	@echo "✓ Development environment ready!"
