@IsTest
global class UnsplashMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody(
            '{"results":[{"urls":{"regular":"https://images.unsplash.com/test.jpg"}}]}'
        );
        return res;
    }
}
