trigger ItemTrigger on Item__c (after insert) {
    Set<Id> ids = new Set<Id>();
    for (Item__c i : Trigger.new) {
        if (i.Image__c == null || i.Image__c == '') {
            ids.add(i.Id);
        }
    }
    if (!ids.isEmpty()) {
        ItemService.assignUnsplashImages(ids);
    }
}
