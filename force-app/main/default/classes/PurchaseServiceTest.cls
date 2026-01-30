@IsTest
public class PurchaseServiceTest {

    @IsTest
    static void testCreatePurchaseAndTrigger() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Item__c item = new Item__c(
            Name = 'Mouse',
            Price__c = 10
        );
        insert item;

        List<Map<String, Object>> cart = new List<Map<String, Object>>();
        Map<String, Object> row = new Map<String, Object>{
            'Id' => item.Id,
            'quantity' => 2,
            'Price__c' => 10
        };
        cart.add(row);

        Test.startTest();
        Id purchaseId = PurchaseService.createPurchase(acc.Id, cart);
        Test.stopTest();

        Purchase__c p = [
            SELECT TotalItems__c, GrandTotal__c
            FROM Purchase__c
            WHERE Id = :purchaseId
        ];

        System.assertEquals(2, p.TotalItems__c);
        System.assertEquals(20, p.GrandTotal__c);
    }

    @IsTest
    static void testPurchaseLineDelete() {
        Account acc = new Account(Name = 'Acc');
        insert acc;

        Item__c item = new Item__c(
            Name = 'Keyboard',
            Price__c = 15
        );
        insert item;

        Purchase__c p = new Purchase__c(ClientId__c = acc.Id);
        insert p;

        PurchaseLine__c line = new PurchaseLine__c(
            PurchaseId__c = p.Id,
            ItemId__c = item.Id,
            Amount__c = 3,
            UnitCost__c = 5
        );
        insert line;

        delete line;

        Purchase__c updated = [
            SELECT TotalItems__c, GrandTotal__c
            FROM Purchase__c
            WHERE Id = :p.Id
        ];

        System.assertEquals(0, updated.TotalItems__c);
        System.assertEquals(0, updated.GrandTotal__c);
    }
}
