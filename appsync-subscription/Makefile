ALL: build/gql-proxy web/build/index.html

build/gql-proxy:
	go build -o $@ ./cmd/gql-proxy/

web/build/index.html: terraform/.envrc.secure
	source $< && cd web && npm run build

terraform/.envrc.secure: terraform/.terraform/plan.out
	terraform -chdir=terraform apply .terraform/plan.out
	touch terraform/.envrc.secure

terraform/.terraform/plan.out:
	terraform -chdir=terraform init
	terraform -chdir=terraform plan -out .terraform/plan.out
