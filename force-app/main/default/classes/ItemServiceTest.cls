@IsTest
public class ItemServiceTest {

    @IsTest
    static void testAssignUnsplashImages() {
        Test.setMock(HttpCalloutMock.class, new UnsplashMock());

        Item__c i = new Item__c(Name = 'Laptop');
        insert i;

        Test.startTest();
        ItemService.assignUnsplashImages(new Set<Id>{ i.Id });
        Test.stopTest();

        Item__c updated = [SELECT Image__c FROM Item__c WHERE Id = :i.Id];
        System.assert(updated.Image__c.contains('unsplash'));
    }

    @IsTest
    static void testItemTriggerAfterInsert() {
        Test.setMock(HttpCalloutMock.class, new UnsplashMock());

        Test.startTest();
        Item__c i = new Item__c(Name = 'Phone');
        insert i;
        Test.stopTest();

        Item__c updated = [SELECT Image__c FROM Item__c WHERE Id = :i.Id];
        System.assert(updated.Image__c.contains('unsplash'));
    }
}
