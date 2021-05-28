
## Preconditions
- The Order to be tested must belong to an active Contract.
- The products to be added to the Order must belong to the 'Standard Price Book'.
- The custom URL for the web service for the Order is:  [Request Catcher](https://jahg.requestcatcher.com/), but can be changed in the Web Services Configuration Metadata Type (API: WebServicesConfiguration__mdt) in the field EndPoint (API:EndPoint__c), also you must add the new url to the Remote Sites (Setup→Remote Site Settings→New Remote Site)

## How to deploy this repository

1. Perform your initial git configuration (set username, email and login with your github account)
2. Clone the repository
> git clone https://github.com/jeissonalex/OrdersUseCase.git
3. Go to the folder where was cloned the repository and change to the master branch
>  git checkout master
4. Login to your target salesforce Org
> sfdx force:auth:device:login --setdefaultusername --setalias YOURALIAS
5. Deploy the metadata in your Salesforce Org
>  sfdx force:source:deploy -p '.\force-app\' -u YOURALIAS -l RunLocalTests
