public with sharing class PurchaseService {

    @AuraEnabled
    public static Id createPurchase(Id accountId, List<Map<String, Object>> cartItems) {
        if (accountId == null || cartItems == null || cartItems.isEmpty()) {
            throw new AuraHandledException('Invalid input: accountId or cartItems missing');
        }

        Purchase__c purchase = new Purchase__c(
            ClientId__c = accountId
            // Name заполнится автоматически если Auto Number
        );
        insert purchase;

        List<PurchaseLine__c> lines = new List<PurchaseLine__c>();
        for (Map<String, Object> item : cartItems) {
            lines.add(new PurchaseLine__c(
                PurchaseId__c = purchase.Id,
                ItemId__c = (Id) item.get('Id'),
                Amount__c = item.get('quantity') != null ? (Decimal) item.get('quantity') : 1,
                UnitCost__c = (Decimal) item.get('Price__c')
            ));
        }
        insert lines;

        // Trigger сам обновит TotalItems и GrandTotal
        return purchase.Id;
    }
}