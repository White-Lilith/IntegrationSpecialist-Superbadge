@isTest
private class ProjectRESTServiceTest {
  //Implement Apex REST service tests here
  @TestSetup
  static void makeData(){
    Opportunity opportunity = new Opportunity(Type = 'New Project',
                                              StageName = 'Closed Won',
                                              Name = 'Opportunity1',
                                              CloseDate = System.today(),
                                              Amount = 1300);
    insert opportunity;  
  }
  @isTest 
  private static void postProjectDataTestPositive(){
    Opportunity opportunity = [SELECT Id FROM Opportunity][0];
    String postingResult = ProjectRESTService.postProjectData('ProjectRef', 'ProjectName', opportunity.Id, 
                                                              System.today(), System.today(), 123, null);
    System.assertEquals(postingResult, 'OK');

  } 
  @isTest
  private static void postProjectDataTestNegative(){
    String postingResult = ProjectRESTService.postProjectData('ProjectRef', 'ProjectName', null, 
                                                              System.today(), System.today(), 123, null);
    System.assertNotEquals(postingResult, 'OK');
  } 
}