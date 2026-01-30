@IsTest
public class UnsplashServiceTest {

    @IsTest
    static void testGetImageUrl() {
        Test.setMock(HttpCalloutMock.class, new UnsplashMock());

        Test.startTest();
        String url = UnsplashService.getImageUrl('apple');
        Test.stopTest();

        System.assert(url.contains('unsplash'));
    }

    @IsTest
    static void testUpdateItemImage() {
        Item__c i = new Item__c(Name = 'Test Item');
        insert i;

        Test.startTest();
        UnsplashService.updateItemImage(i.Id, 'https://test.com/img.jpg');
        Test.stopTest();

        Item__c updated = [SELECT Image__c FROM Item__c WHERE Id = :i.Id];
        System.assertEquals('https://test.com/img.jpg', updated.Image__c);
    }
}
