OAS_PETS_FILE?=specs/pets.openapi.yaml
OAS_ADOPTIONS_FILE?=specs/adoptions.openapi.yaml


provider_mock_pets_prism: ## Runs a mock server with Prism, generated from the OpenAPI specification
	docker run --add-host=host.docker.internal:host-gateway -d --init --rm --name prismPets -v ${PWD}/specs:/specs -p 8086:4010 stoplight/prism:latest mock -h 0.0.0.0 "/${OAS_PETS_FILE}"

request-pets:
	curl "localhost:8086/pets?status=available&location=galway" --header "Accept: application/json"

provider_mock_adoptions_prism: ## Runs a mock server with Prism, generated from the OpenAPI specification
	docker run --add-host=host.docker.internal:host-gateway -d --init --rm --name prismAdoptions -v ${PWD}/specs:/specs -p 8087:4010 stoplight/prism:latest mock -h 0.0.0.0 "/${OAS_ADOPTIONS_FILE}"

request-adoptions:
	curl "localhost:8087/adoptions?status=requested&location=galway" --header "Accept: application/json"

itarazzo_client:
	mkdir -p reports
	docker run -t --rm \
		--add-host=host.docker.internal:host-gateway \
		-e ARAZZO_FILE=/itarazzo/specs/pet-adoptions.arazzo.yaml \
		-e ARAZZO_INPUTS_FILE=/itarazzo/specs/pet-adoptions-arazzo-inputs.json \
		-v $$PWD/specs:/itarazzo/specs \
		-v $$PWD/reports:/itarazzo/target/reports \
		leidenheit/itarazzo-client

itarazzo_client_error:
	mkdir -p reports
	docker run -t --rm \
		--add-host=host.docker.internal:host-gateway \
		-e ARAZZO_FILE=/itarazzo/specs/error-pet-adoptions.arazzo.yaml \
		-e ARAZZO_INPUTS_FILE=/itarazzo/specs/pet-adoptions-arazzo-inputs.json \
		-v $$PWD/specs:/itarazzo/specs \
		-v $$PWD/reports:/itarazzo/target/reports \
		leidenheit/itarazzo-client

prism-pets-logs:
	docker logs --tail 10 -f prismPets


mermaid-to-png:
	sh scripts/generate-images.sh