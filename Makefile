.PHONY: terraform

terraform:
	cd ./terraform && terraform apply

fix:
	cd ./terraform && terraform fmt -recursive