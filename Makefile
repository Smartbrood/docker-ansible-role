.PHONY: run ansible_config syntax_check test-role test_idempotency host 

#Func and simply expanded variables
ROLE := $(shell basename ${PWD})

ansible_config:
	printf '[defaults]\nroles_path=../\n[privilege_escalation]\nbecome=True\nbecome_method=sudo\nbecome_user=root' > ./ansible.cfg

syntax_check: ansible_config
	ansible-playbook ./tests/test.yml -i ./tests/inventory --syntax-check

test-role: syntax_check
	ansible-playbook ./tests/test.yml -i ./tests/inventory --connection=local

test_idempotency: test-role
	ansible-playbook ./tests/test.yml -i ./tests/inventory --connection=local \
		| tee /tmp/output.txt; grep -q 'changed=0.*failed=0' /tmp/output.txt \
		|| (echo "Exit status not 0" && exit 1)

host: test_idempotency
	rm -f ./ansible.cfg
	@echo "All fine."



