@isTest
private class BillingCalloutServiceTest {
  //Implement mock callout tests here
  @TestSetup
  static void makeData(){
    ServiceCredentials__c credentials = new ServiceCredentials__c(Name = 'BillingServiceCredential',
                                                                  Username__c = 'username',
                                                                  Password__c = 'password');
    insert credentials;

    Account account = new Account(Name = 'TestAccount');
    insert account;

    Opportunity opportunity = new Opportunity(Type = 'New Project',
                                              StageName = 'Closed Won',
                                              Name = 'Opportunity',
                                              CloseDate = System.today(),
                                              AccountId = account.Id,
                                              Amount = 1300);
    insert opportunity;

    Project__c project = new Project__c(Name = 'Project',
                                        Opportunity__c = opportunity.Id,
                                        ProjectRef__c = 'ProjectRef',
                                        Billable_Amount__c = 120,
                                        Status__c = 'Running');
    insert project;
  }
  @isTest
  static void testPositive(){
    Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());
    Test.startTest();
    Project__c project = [SELECT Id, Status__c FROM Project__c][0];
    project.Status__c = 'Billable';
    Database.UpsertResult upsertResult = Database.upsert(project, false);
    Test.stopTest();

    System.assert(upsertResult.isSuccess());
    project = [SELECT Id, Status__c FROM Project__c][0];
    System.assertEquals('Billed', project.Status__c);
  }
  @isTest
  static void testNegative(){
    Test.setMock(WebServiceMock.class, new BillingCalloutServiceMockFailure());
    Test.startTest();
    Project__c project = [SELECT Id, Status__c FROM Project__c][0];
    project.Status__c = 'Billable';
    Database.UpsertResult upsertresult = Database.upsert(project, false);
    Test.stopTest();

    System.assert(upsertResult.isSuccess());
    project = [SELECT Id, Status__c FROM Project__c][0];
    System.assertEquals('Billable', project.Status__c);
  }
}