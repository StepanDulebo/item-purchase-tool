@IsTest
public class ItemControllerTest {

    @testSetup
    static void setupData() {
        List<Item__c> items = new List<Item__c>{
            new Item__c(
                Name = 'iPhone',
                Description__c = 'Apple phone',
                Type__c = 'Hardware',
                Family__c = 'Electronics',
                Price__c = 999
            ),
            new Item__c(
                Name = 'Galaxy',
                Description__c = 'Samsung phone',
                Type__c = 'Service',
                Family__c = 'Electronics',
                Price__c = 899
            ),
            new Item__c(
                Name = 'Office Chair',
                Description__c = 'Comfortable chair',
                Type__c = 'Hardware',
                Family__c = 'Clothing',
                Price__c = 199
            )
        };
        insert items;
    }

    

    @IsTest
    static void testGetItemsNoFilters() {
        Test.startTest();
        List<Item__c> result = ItemController.getItems(null, null, null);
        Test.stopTest();

        System.assertEquals(3, result.size(), 'Should return all items');
    }

    @IsTest
    static void testGetItemsWithTypeFilter() {
        Test.startTest();
        List<Item__c> result = ItemController.getItems('Hardware', null, null);
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Should filter by Type__c');
    }

    @IsTest
    static void testGetItemsWithFamilyFilter() {
        Test.startTest();
        List<Item__c> result = ItemController.getItems(null, 'Electronics', null);
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Should filter by Family__c');
    }

    @IsTest
    static void testGetItemsWithSearchKey() {
        Test.startTest();
        List<Item__c> result = ItemController.getItems(null, null, 'Apple');
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should search by Name or Description');
        System.assertEquals('iPhone', result[0].Name);
    }

    

    @IsTest
    static void testGetFilterOptions() {
        Test.startTest();
        Map<String, List<String>> options = ItemController.getFilterOptions();
        Test.stopTest();

        System.assert(options.containsKey('type'), 'Type options should exist');
        System.assert(options.containsKey('family'), 'Family options should exist');

        System.assert(options.get('type').contains('Hardware'));
        System.assert(options.get('type').contains('Service'));

        System.assert(options.get('family').contains('Clothing'));
        System.assert(options.get('family').contains('Electronics'));
    }

    

    @IsTest
    static void testUpdateItemImageSuccess() {
        Item__c item = [SELECT Id FROM Item__c LIMIT 1];

        Test.startTest();
        ItemController.updateItemImage(item.Id, 'https://test.com/image.jpg');
        Test.stopTest();

        Item__c updated = [
            SELECT Image__c
            FROM Item__c
            WHERE Id = :item.Id
        ];

        System.assertEquals('https://test.com/image.jpg', updated.Image__c);
    }

    @IsTest
    static void testUpdateItemImageWithInvalidInput() {
        
        Test.startTest();
        ItemController.updateItemImage(null, null);
        ItemController.updateItemImage(null, ' ');
        Test.stopTest();

        System.assert(true, 'Method should safely return without exception');
    }
}
