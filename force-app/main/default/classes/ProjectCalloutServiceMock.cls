public class ProjectCalloutServiceMock implements HttpCalloutMock{
   //Implement http mock callout here
   public HttpResponse respond(HttpRequest request){
      HttpResponse response = new HttpResponse();
      response.setStatusCode(201);
      return response;
   }
}