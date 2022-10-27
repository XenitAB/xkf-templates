.ONESHELL:
SHELL := /bin/bash

all: fmt lint validate tfsec

.PHONY: fmt
.SILENT:
fmt:
	set -e

	tf_fmt () {
		set -e
		echo fmt: $${1}
		terraform fmt -recursive $${1}
	}

	export -f tf_fmt

	TF_MODULES=$$(find aws azure -maxdepth 1 -mindepth 1 -type d | grep -v \\.ci | grep -v \\.github)

	PARALLEL_JOBS=10
	printf '%s\n' $${TF_MODULES[@]} | parallel --halt now,fail=1 -j$${PARALLEL_JOBS} "tf_fmt {}"

.PHONY: lint
.SILENT:
lint:
	set -e
	echo lint: Start
	MODULE_GROUPS="azure aws"
	for MODULE_GROUP in $${MODULE_GROUPS}; do
		tflint --init -c $${MODULE_GROUP}/.tflint.hcl
		MODULES=$$(find $${MODULE_GROUP} -mindepth 1 -maxdepth 1 -type d | grep -v \\.ci | grep -v \\.github)
		for MODULE in $$MODULES; do
			echo lint: $${MODULE}
			tflint -c $${MODULE_GROUP}/.tflint.hcl $${MODULE}
		done
	done
	echo lint: Success

.PHONY: tfsec
.SILENT:
tfsec: clean
	set -e
	echo tfsec: Start
	find . -type d -name ".terraform"  -prune -exec rm -rf {} \;
	tfsec .
	echo tfsec: Success

.PHONY: validate
.SILENT:
validate:
	set -e

	tf_validate () {
		rm -f $$1/.terraform.lock.hcl
		terraform -chdir=$$1 init --backend=false 1>/dev/null 2>&1
		TEMP_FILE=$$(mktemp)
		
		set -e
		if ! terraform -chdir=$$1 validate 1>$${TEMP_FILE} 2>&1; then
			echo terraform-validate: $$1 failed 1>&2
			cat $${TEMP_FILE} 1>&2
			rm $${TEMP_FILE}
			return 1
		fi

		rm $${TEMP_FILE}
		echo terraform-validate: $$1 succeeded
	}

	export -f tf_validate

	TF_MODULES=$$(find azure aws -maxdepth 1 -mindepth 1 -type d | grep -v \\.ci | grep -v \\.github)

	PARALLEL_JOBS=10
	printf '%s\n' $${TF_MODULES[@]} | parallel --halt now,fail=1 -j$${PARALLEL_JOBS} "tf_validate {}"

.PHONY: init
.SILENT:
init:
	set -e
	CURRENT_DIR=$${PWD}
	MODULES=$$(find azure aws -mindepth 1 -maxdepth 1 -type d | grep -v \\.ci | grep -v \\.github)
	for MODULE in $$MODULES; do
		cd $${CURRENT_DIR}/$${MODULE}
		echo terraform-init: $${CURRENT_DIR}/$${MODULE}
		terraform init --backend=false 1>/dev/null
	done

.PHONY: clean
.SILENT:
clean:
	set -e
	find . -type d -name ".terraform" -prune -exec rm -rf {} \;
