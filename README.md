# terra-azure

# Credentials
To obtain the values for subscription_id, client_id, client_secret, and tenant_id in the Azure portal, follow these steps:
```
Sign in to the Azure portal at https://portal.azure.com/.

Select the Azure Active Directory (AAD) icon from the left-hand menu.

Click on the "App registrations" option from the AAD menu.

Click on the "New registration" button to create a new app registration.

Enter a name for the new app registration in the "Name" field.

Select the "Accounts in this organizational directory only" option in the "Supported account types" section.

Leave the "Redirect URI" field blank.

Click on the "Register" button to create the app registration.

Once the app registration is created, copy the value of the "Application (client) ID" field. This value is your client_id.

Click on the "Certificates & secrets" option in the left-hand menu.

Click on the "New client secret" button.

Enter a description for the new client secret in the "Description" field.

Select the desired expiration period for the client secret.

Click on the "Add" button to create the client secret.

Once the client secret is created, copy the value of the "Value" field. This value is your client_secret.

Click on the "Overview" option in the left-hand menu.

Copy the value of the "Directory (tenant) ID" field. This value is your tenant_id.

Click on the "Subscriptions" option in the left-hand menu.

Select the desired subscription from the list of subscriptions.

Copy the value of the "Subscription ID" field. This value is your subscription_id.
```
These values, must be stored as variables in terraform cloud, store them as sensitive variables.

![Alt text](https://github.com/Jiolloker/terra-azure/blob/master/img/variables.JPG)

Then, we need to give permissions to the client we created so it can access the resources in azure.
```
In azure portal, go to subscriptions, select a subscription you want to use, then click Access Control (IAM), and finally Add > Add role assignment.

Firstly, specify a Role which grants the appropriate permissions needed for the Service Principal (for example, Contributor will grant Read/Write on all resources in the Subscription). 

Secondly, search for and select the name of the client created in Azure Active Directory to assign it this role - then press Save.
```



Current infrastructure diagram

![Alt text](https://github.com/Jiolloker/terra-azure/blob/master/img/azure%20diagram.JPG)


# Despliegue
```
Se depliega a traves de terraform cloud, creando un nuevo workspace y linkeando el repositorio al workspace.
Luego se debe asignar las variables requeridas por el codigo.
```

![Alt text](https://github.com/Jiolloker/terra-azure/blob/master/img/variables2.JPG)


```
Y con esto ya esta listo para desplegar.
```
# Ansible
```
Instalar AZURE CLI 

Login a az, usando az login

Instalar modulos requeridos por ansible para conectarse a Azure.

pip install msrest

pip install msrestazure

pip install azure-common

export env variables para conectarse a azure

export AZURE_CLIENT_ID=********************

export AZURE_SECRET=********************

export AZURE_SUBSCRIPTION_ID=********************

export AZURE_TENANT=********************

Luego ya podemos ver si podemos recursos de azure.

ansible-inventory --graph
ansible-inventory --list
ansible all -m ping
ansible-playbook playbook.yml
```

# Resultados
Terraform Cloud
![Alt text](https://github.com/Jiolloker/terra-azure/blob/master/img/terraform%20cloud%20deploy1.JPG)
![Alt text](https://github.com/Jiolloker/terra-azure/blob/master/img/terraform%20cloud%20deploy2.JPG)


Azure Portal
![Alt text](https://github.com/Jiolloker/terra-azure/blob/master/img/azure%20rg%20confirm.JPG)
![Alt text](https://github.com/Jiolloker/terra-azure/blob/master/img/1.jpg)
![Alt text](https://github.com/Jiolloker/terra-azure/blob/master/img/2.JPG)

Ansible output
![Alt text](https://github.com/Jiolloker/terra-azure/blob/master/img/ping.JPG)
![Alt text](https://github.com/Jiolloker/terra-azure/blob/master/img/playbook.JPG)

