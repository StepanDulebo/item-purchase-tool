public with sharing class ItemController {

    @AuraEnabled(cacheable=true)
    public static List<Item__c> getItems(
        String typeFilter,
        String familyFilter,
        String searchKey
    ) {
        String soql =
            'SELECT Id, Name, Description__c, Type__c, Family__c, Price__c, Image__c ' +
            'FROM Item__c WHERE Id != null';

        if (String.isNotBlank(typeFilter)) {
            soql += ' AND Type__c = :typeFilter';
        }

        if (String.isNotBlank(familyFilter)) {
            soql += ' AND Family__c = :familyFilter';
        }

        if (String.isNotBlank(searchKey)) {
            String likeKey = '%' + searchKey + '%';
            soql += ' AND (Name LIKE :likeKey OR Description__c LIKE :likeKey)';
        }

        soql += ' ORDER BY Name';

        return Database.query(soql);
    }

    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getFilterOptions() {
        Map<String, List<String>> options = new Map<String, List<String>>();
        
        
        List<AggregateResult> typeResults = [
            SELECT Type__c 
            FROM Item__c 
            WHERE Type__c != null 
            GROUP BY Type__c 
            ORDER BY Type__c
        ];
        
        List<String> typeOptions = new List<String>();
        typeOptions.add(''); 
        for (AggregateResult ar : typeResults) {
            typeOptions.add((String)ar.get('Type__c'));
        }
        options.put('type', typeOptions);
        
        
        List<AggregateResult> familyResults = [
            SELECT Family__c 
            FROM Item__c 
            WHERE Family__c != null 
            GROUP BY Family__c 
            ORDER BY Family__c
        ];
        
        List<String> familyOptions = new List<String>();
        familyOptions.add(''); 
        for (AggregateResult ar : familyResults) {
            familyOptions.add((String)ar.get('Family__c'));
        }
        options.put('family', familyOptions);
        
        return options;
    }




 @AuraEnabled
    public static void updateItemImage(Id itemId, String imageUrl) {
        if (itemId == null || String.isBlank(imageUrl)) return;
        Item__c i = new Item__c(Id = itemId, Image__c = imageUrl);
        update i;
    }


}