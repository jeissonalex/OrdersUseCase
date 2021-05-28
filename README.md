
## Preconditions
- The Order to be tested must belong to an active Contract and the PriceBook of the Contract must be 'Standard Price Book'.
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
>  sfdx force:source:deploy -p '.\force-app\ ' -u YOURALIAS -l RunLocalTests
6. Assign as Org Default the Order Ligthning Record Page
> Setup→Object Manager→Order→Lighting Record pages→Order Record Page→Edit→Activation...→Assign as Org Default→Desktop and Phone→Save
7. Activate 'Standard Price Book'
> Go to App Launcher→Price Books→Select the 'Standard Price Book' and tick the field 'Active'→Save
8. Create a new Contract with 'Standard Price Book'
> Go to App Launcher→Contracts→New→Fill all mandatory fields and in Pricebook field select the 'Standard Price Book' value→Save
9.Activate Contract 
> Go to App Launcher→Contracts→Select contract created on last item and change the Status to 'Activate'→Save
10. Create an Order
> Go to App Launcher→Orders→New→Fill all mandatory fields, on Contract Number field select the Contract created in the last items, on Account Name select the same Account that you selected in the Contract creation→Save
11. Have fun and test the functionalities requested :)
