public class BillingCalloutService {
    //Implement business and callout logic methods here
    @future(Callout = true)
    public static void callBillingService(String projectRef, Decimal amount){
        ServiceCredentials__c credentials = ServiceCredentials__c.getValues('BillingServiceCredential');

        BillingServiceProxy.project billingProxyProject = new BillingServiceProxy.project();

        billingProxyProject.projectid = projectRef;
        billingProxyProject.billAmount = amount;
        billingProxyProject.username = credentials.Username__c;
        billingProxyProject.password = credentials.Password__c;

        BillingServiceProxy.InvoicesPortSoap11 callInvoicing = new BillingServiceProxy.InvoicesPortSoap11();
        String responseStatus = callInvoicing.billProject(billingProxyProject);
        if(responseStatus == 'OK'){
            List<Project__c> projects = [SELECT Status__c FROM Project__c WHERE ProjectRef__c = :projectRef];
            for(Project__c p : projects){
                p.Status__c = 'Billed';
            }
            if(projects.size() > 0){
                update projects;
            }
        }
    }
}