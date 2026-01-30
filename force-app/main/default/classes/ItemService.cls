public with sharing class ItemService {

    @future(callout=true)
    public static void assignUnsplashImages(Set<Id> itemIds) {
        List<Item__c> itemsToUpdate = [
            SELECT Id, Name, Image__c
            FROM Item__c
            WHERE Id IN :itemIds AND (Image__c = NULL OR Image__c = '')
        ];

        List<Item__c> updates = new List<Item__c>();

        for (Item__c item : itemsToUpdate) {
            String img = UnsplashService.getImageUrl(item.Name);
            item.Image__c = img;
            updates.add(item);
        }

        if (!updates.isEmpty()) {
            update updates;
        }
    }

}
