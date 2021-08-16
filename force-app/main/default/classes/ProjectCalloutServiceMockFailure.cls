public class ProjectCalloutServiceMockFailure implements HttpCalloutMock{
   //Implement http mock callout failure here 
   public HttpResponse respond(HttpRequest request){
      HttpResponse response = new HttpResponse();
      response.setStatusCode(500);
      return response;
   }
}