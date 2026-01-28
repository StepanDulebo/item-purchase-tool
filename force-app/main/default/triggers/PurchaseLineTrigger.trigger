trigger PurchaseLineTrigger on 	PurchaseLine__c (after insert, after update, after delete, after undelete) {
    Set<Id> purchaseIds = new Set<Id>();

    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (PurchaseLine__c line : Trigger.new) {
            purchaseIds.add(line.PurchaseId__c);
        }
    }
    if (Trigger.isDelete) {
        for (PurchaseLine__c line : Trigger.old) {
            purchaseIds.add(line.PurchaseId__c);
        }
    }

    List<Purchase__c> purchasesToUpdate = [SELECT Id, TotalItems__c, GrandTotal__c,
                                           (SELECT Amount__c, UnitCost__c FROM PurchaseLines__r)
                                           FROM Purchase__c
                                           WHERE Id IN :purchaseIds];

    for (Purchase__c purchase : purchasesToUpdate) {
        Integer totalItems = 0;
        Decimal grandTotal = 0;
        for (PurchaseLine__c line : purchase.PurchaseLines__r) {
            totalItems += (line.Amount__c != null ? line.Amount__c.intValue() : 0);
            grandTotal += (line.Amount__c != null && line.UnitCost__c != null ? line.Amount__c * line.UnitCost__c : 0);
        }
        purchase.TotalItems__c = totalItems;
        purchase.GrandTotal__c = grandTotal;
    }

    if (!purchasesToUpdate.isEmpty()) {
        update purchasesToUpdate;
    }
}