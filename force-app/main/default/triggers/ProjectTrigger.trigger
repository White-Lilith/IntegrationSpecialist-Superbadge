trigger ProjectTrigger on Project__c (before update, before insert) {
    //Call the Billing Service callout logic here
    for(Project__c p : trigger.new){
        if(p.Status__c == 'Billable'){
            BillingCalloutService.callBillingService(p.ProjectRef__c, p.Billable_Amount__c);
        }
    }
}