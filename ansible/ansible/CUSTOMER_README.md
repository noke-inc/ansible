# Please refer to latest cloud documetation in https://developer.wirepas.com
# Example on how to run without an inventory file:
###   ansible-playbook -i myinstance.mydnszone.com, cli_setup_host.yml

###   ansible-playbook -i myinstance.mydnszone.com, cli_update_host.yml
Note: Updating 3.0 to 4.0 in ubuntu18.04 will most likely result in package
conflicts which you will have to sort out. We recommend creating a backup and restoring that on a fresh install on 
Ubuntu22.04

Issues:

Please update instances periodically. E.g 2.0 -> 3.0 -> 4.0
