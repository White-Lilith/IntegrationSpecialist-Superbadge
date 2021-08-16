@isTest
private class ProjectCalloutServiceTest {
  //Implement mock callout tests here
  @TestSetup
  static void makeData(){
    Account account = new Account(Name = 'TestAccount');
    insert account;
    Opportunity opportunity = new Opportunity(Type = 'New Project',
                                              StageName = 'Closed Won',
                                              Name = 'Opportunity1',
                                              CloseDate = System.today(),
                                              AccountId = account.Id,
                                              Amount = 1300);
    insert opportunity;  
    ServiceTokens__c token = new ServiceTokens__c(Name = 'ProjectServiceToken', Token__c = 'SomeToken');
    insert token;
  }
  @isTest
  static void testPositive(){
    List<Id> ids = new List<Id>(new Map<Id,Opportunity>([SELECT Id FROM Opportunity 
                                                          WHERE Type = 'New Project' 
                                                          AND StageName = 'Closed Won']).keySet());

    test.SetMock(HttpCalloutMock.class,new ProjectCalloutServiceMock());
    test.StartTest();
    ProjectCalloutService.PostOpportunityToPMS(ids);
    test.StopTest();
    Opportunity opportunity = [SELECT Id, StageName FROM Opportunity][0];
    System.assertEquals(opportunity.StageName, 'Submitted Project');
  }
  @isTest
  static void testNegative(){
    List<Id> ids = new List<Id>(new Map<Id,Opportunity>([SELECT Id FROM Opportunity 
                                                          WHERE Type = 'New Project' 
                                                          AND StageName = 'Closed Won']).keySet());

    test.SetMock(HttpCalloutMock.class,new ProjectCalloutServiceMockFailure());
    test.StartTest();
    ProjectCalloutService.PostOpportunityToPMS(ids);
    test.StopTest();
    Opportunity opportunity = [SELECT Id, StageName FROM Opportunity][0];
    System.assertEquals(opportunity.StageName, 'Resubmit Project');
  }
}