global class LeadCountryFromPhoneBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts, Database.Stateful {
    
    private String query = 'SELECT Id, Phone FROM Lead WHERE NeedToProcess__c = true';
    
    private List<Id> allUpdatedRecordsIds = new List<Id>();
    private List<Id> allErrorRecordsIds = new List<Id>();
    private Map<String, String> localCountriesStorage = new Map<String, String>();
    
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(this, 2);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Lead> leads) {
        updateCountry(leads);
    }
    
    public void finish(Database.BatchableContext bc) {
        if (allUpdatedRecordsIds.isEmpty() && allErrorRecordsIds.isEmpty()) {
            return;
        }
        String[] emails = new String[] { 'sergey_klimuk@mail.ru' };
        sendEmail(emails);
    }
    
    private void updateCountry(List<Lead> leads) {
        List<Lead> updatedLeads = new List<Lead>();
        List<Id> errorRecordsIds = new List<Id>();
        try {
            for (Lead lead : leads) {
            	String country = getCountryFromPhone(lead.Phone);
            	if (country == '') {
                	errorRecordsIds.add(lead.Id);
            	} else {
                	lead.Country = country;
                	lead.NeedToProcess__c = false;
                	updatedLeads.add(lead);
            	}
        	}
        	update updatedLeads;
            for (Lead lead : updatedLeads) {
                allUpdatedRecordsIds.add(lead.Id);
            }
            allErrorRecordsIds.addAll(errorRecordsIds);
            createErrorObject(errorRecordsIds);
            
        } catch (Exception ex) {
            errorRecordsIds.clear();
            for (Lead lead : leads) {
                errorRecordsIds.add(lead.Id);
            }
            allErrorRecordsIds.addAll(errorRecordsIds);
            createErrorObject(ex, errorRecordsIds);
        }     
    }
    
    private String getCountryFromPhone(String phone) {
        if (phone == null || phone == '') {
            return '';
        }
        String countryCode = getCountryCodeFromPhone(phone);
        String country = getCountry(countryCode);
        return country;
    }
    
    private String getCountryCodeFromPhone(String phone) {
        String code = phone.substringBefore('-');
        if (code.length() > 4 || code.length() < 1) {
            return '';
        }
        return code;
    }
    
    private String getCountry(String countryCode) {
        String country = '';
        if (countryCode != '') {
            country = localCountriesStorage.get(countryCode);
            if (country == null) {
                country = getCountryFromRemoteStorage(countryCode);
                if (country != '') {
                    localCountriesStorage.put(countryCode, country);
                    return country;
                }
            }
        }
        return '';
    }
    
    private String getCountryFromRemoteStorage(String countryCode) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://restcountries.eu/rest/v2/callingcode/' + countryCode);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if (response.getStatusCode() != 200) {
            return '';
        }
        List<Object> jsonBody = (List<Object>)JSON.deserializeUntyped(response.getBody());
        Map<String, Object> codeMap = (Map<String, Object>)jsonBody.get(0);
        String country = (String) codeMap.get('name');
        if (country == null) {
            return '';
        }
        return country;
    }

    private void createErrorObject(Exception ex, List<Id> errorIds) {
        Errors_Log__c error = new Errors_Log__c(Name = '' + System.now());
        if (!errorIds.isEmpty()) {
        	error.ErrorRecordsIds__c = String.join(errorIds, ', ');
            if (ex != null) {
            error.Message__c = ex.getMessage().substring(0, 250);
            error.StackTrace__c = ex.getStackTraceString();
        }
        insert error;
        }   
    }
    
    private void createErrorObject(List<Id> errorIds) {
        createErrorObject(null, errorIds);
    }
    
    private void sendEmail(String[] emails) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emails;
        message.subject = 'LeadCountryFromPhoneBatch message';
        message.plaintextbody = 'Successfull records (' + allUpdatedRecordsIds.size() + '):\n' 
            + String.join(allUpdatedRecordsIds, ', ') + '\n\n' + 'Error records (' + allErrorRecordsIds.size() 
            + '):\n' + String.join(allErrorRecordsIds, ', ');
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.sendEmail(messages);
    }
}