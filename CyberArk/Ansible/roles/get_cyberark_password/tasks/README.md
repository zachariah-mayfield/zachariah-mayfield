# Move up 4 levels:
# zachariah-mayfield/Tableau/Ansible/roles/check_active_cluster/tasks/ # This is where you are at now.
# tasks is where you are at now.
# ../ → roles/check_active_cluster/ # This is up one level
# ../../ → roles/ # This is up two levels
# ../../../ → Ansible/ # This is up three levels
# ../../../../ → Tableau/ # This is up four levels
# Now you are at zachariah-mayfield/
# From there, move into:
# CyberArk/Ansible/roles/get_cyberark_password/tasks/v2_get_cyberark_password.yaml

## - name: Include CyberArk password retrieval tasks
##   include_tasks: ../../../../../CyberArk/Ansible/roles/get_cyberark_password/tasks/v2_get_cyberark_password.yaml