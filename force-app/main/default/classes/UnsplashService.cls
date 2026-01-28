public with sharing class UnsplashService {

    // Публичный Access Key для Unsplash
    private static final String ACCESS_KEY = 'zbl-rH_AiHUgr8EdGBpzeJ3uLK4MiwnMO33sfJhZTMI';
    private static final String PLACEHOLDER = 'https://via.placeholder.com/300x200?text=No+Image';

    @AuraEnabled
    public static String getImageUrl(String query) {
        if (String.isBlank(query)) return PLACEHOLDER;
        
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://api.unsplash.com/search/photos?query=' + EncodingUtil.urlEncode(query,'UTF-8') + '&per_page=1');
            req.setMethod('GET');
            req.setHeader('Authorization', 'Client-ID ' + ACCESS_KEY);

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> images = (List<Object>) result.get('results');
                if (!images.isEmpty()) {
                    Map<String,Object> firstImage = (Map<String,Object>) images[0];
                    Map<String,Object> urls = (Map<String,Object>) firstImage.get('urls');
                    return (String) urls.get('regular');
                }
            }
            return PLACEHOLDER;
        } catch (Exception e) {
            System.debug('Unsplash error: ' + e);
            return PLACEHOLDER;
        }
    }

    @AuraEnabled
    public static void updateItemImage(Id itemId, String imageUrl) {
        if (itemId == null) return;
        Item__c i = new Item__c(Id = itemId, Image__c = imageUrl != null ? imageUrl : PLACEHOLDER);
        update i;
    }
}