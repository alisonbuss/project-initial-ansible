
#-----------------------|DOCUMENTATION|-----------------------#
# @descr: Makefile for running a kubernetes cluster.
# @fonts: https://www.gnu.org/software/make/
# @example:
#       $ make help
#   OR
#       $ make provide-ping \
#              provide-facts \
#              provide-admin-client \
#              provide-cluster-all;
#   OR
#       $ make plan provide-all LEVEL_INF="-vv"
#-------------------------------------------------------------#

# DEFAULT VARIABLES - STRUCTURAL

WORKING_DIRECTORY ?= `pwd`
ENVIRONMENT       ?= development
PLAYBOOK_DIR      ?= $(WORKING_DIRECTORY)
INVENTORY_FILE    ?= $(PLAYBOOK_DIR)/inventories/$(ENVIRONMENT)/hosts
# Parameter that defines the amount of information that will be shown 
# on the screen while the playbook runs, and can go up to -vvvv (1-4v).
#LEVEL_INF        ?= -v 
LEVEL_INF         ?= 

# VIEW DETAILS

plan: 
	@echo "The default values to be used by this Makefile:";
	@echo "";
	@echo "    --> MAKECMDGOALS: 'make $(MAKECMDGOALS)'";
	@echo "    --> ENVIRONMENT: $(ENVIRONMENT)";
	@echo "    --> WORKING_DIRECTORY: $(WORKING_DIRECTORY)";
	@echo "    --> PLAYBOOK_DIR: $(PLAYBOOK_DIR)";
	@echo "    --> INVENTORY_FILE: $(INVENTORY_FILE)";
	@echo "    --> LEVEL_INF: $(LEVEL_INF)";
	@echo "";

# PROVISIONING ENV

provide-ping: 
	@echo "Initiating the testing of 'ping' on all host on the infrastructure...";
	-@ansible-playbook --inventory="$(INVENTORY_FILE)" $(PLAYBOOK_DIR)/provide-setup.yml \
	                   --tags="ping" \
	                   --verbose $(LEVEL_INF);
	@echo "Execution Completed!"; 

provide-facts: 
	@echo "Initiating the execution of the "setup" ansible command...";
	-@ansible-playbook --inventory="$(INVENTORY_FILE)" $(PLAYBOOK_DIR)/provide-setup.yml \
	                   --tags="setup" \
	                   --verbose $(LEVEL_INF);
	-@echo -n "--Facts generated:" && ls -R ~/.ansible/custom-fact-caching;
	@echo "Execution Completed!"; 

provide-reboot: 
	@echo "Initiating system reboot of all hosts...";
	-@ansible-playbook --inventory="$(INVENTORY_FILE)" $(PLAYBOOK_DIR)/provide-setup.yml \
	                   --tags="reboot" \
	                   --verbose $(LEVEL_INF);
	@echo "Execution Completed!";

provide-info: 
	@echo "Initiating collecting basic information from the entire infrastructure...";
	-@ansible-playbook --inventory="$(INVENTORY_FILE)" $(PLAYBOOK_DIR)/provide-setup.yml \
	                   --tags="info" \
	                   --verbose $(LEVEL_INF);
	@echo "Execution Completed!";

# PROVISIONING SERVER

provide-admin-client:
	@echo "Initiating the installation of the administrators clients...";
	@ansible-playbook --inventory="$(INVENTORY_FILE)" $(PLAYBOOK_DIR)/provide-admin-client.yml \
	                  --tags="admin-client" \
	                  --verbose $(LEVEL_INF) --ask-become-pass;
	@echo "Execution Completed!";

provide-cluster-all:
	@echo "Initiating the customization of all hosts...";
	@ansible-playbook --inventory="$(INVENTORY_FILE)" $(PLAYBOOK_DIR)/provide-cluster-all.yml \
	                  --tags="cluster-all" \
	                  --verbose $(LEVEL_INF);
	@echo "Execution Completed!";

provide-all: plan provide-facts provide-admin-client provide-cluster-all

# VIEW DOCUMENTATION

#FONT: https://github.com/ceph/ceph-container/blob/master/Makefile#L128
help:
	@echo ' '
	@echo 'Usage: make <TARGETS> ... [OPTIONS]'
	@echo ' '
	@echo 'TARGETS:'
	@echo ' '
	@echo '  Provisioning from setup initial:'
	@echo '     provide-ping      Starts the testing of "ping" on all host on the infrastructure.'
	@echo '     provide-facts     Starts the execution of the "setup" ansible command.'
	@echo '     provide-reboot    Starts the execution system reboot of all hosts.'
	@echo '     provide-info      Starts the collecting basic information from the entire infrastructure.'
	@echo ' '
	@echo '  Provisioning Server:'
	@echo '     provide-admin-client      Starts the installation of the administrators clients.'
	@echo '     provide-cluster-all       Starts the customization, configuration of all hosts.'
	@echo '     provide-all               Starts the provisioning of the all cluster.'
	@echo ' '
	@echo '  View details:'
	@echo '     plan    The default values to be used by this Makefile.'
	@echo ' '
	@echo '  Help:'
	@echo '     help    Print this help message.'
	@echo ' '
	@echo 'OPTIONS:'
	@echo ' '
	@echo '   ENVIRONMENT          Specifies the type of environment variable for the Kubernetes deployment, the default is [development].'
	@echo '   WORKING_DIRECTORY    Specify the current working directory, the default is [`pwd`].'
	@echo '   PLAYBOOK_DIR         Specifies the base path of the playbooks.'
	@echo '   INVENTORY_FILE       Specifies the inventory path according to the deployment environment variable.'
	@echo '   LEVEL_INF            Parameter that defines the amount of information that will be shown on the screen'  
	@echo '                        while the playbook runs, and can go up to -vvvv (1-4v), the default is [EMPTY].'
	@echo ' '
