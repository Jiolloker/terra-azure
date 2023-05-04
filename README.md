# terra-azure

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

Then, we need to give permissions to the client we created so it can access the resources in azure.
```
In azure portal, go to subscriptions, select a subscription you want to use, then click Access Control (IAM), and finally Add > Add role assignment.

Firstly, specify a Role which grants the appropriate permissions needed for the Service Principal (for example, Contributor will grant Read/Write on all resources in the Subscription). 

Secondly, search for and select the name of the client created in Azure Active Directory to assign it this role - then press Save.
```
