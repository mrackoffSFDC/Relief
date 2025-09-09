public class GeneratePDFReceiptController {
    public String templateName;
    public String parentRecordId;
    public String opportunityId;
    public String contactId;
    public String atelierId;
    public String rencontreId;
    public String formationId;
    public String chargentOrderId;
    public String emailBody;
    public String transactionId;
    public String notesId;
    public String individualSupportId;

    public Boolean isTestRunning = false;
    
    public GeneratePDFReceiptController() {
        templateName = Apexpages.currentPage().getParameters().get('templateName');
        parentRecordId = Apexpages.currentPage().getParameters().get('parentRecordId');
        opportunityId = Apexpages.currentPage().getParameters().get('opportunityId');
        contactId = Apexpages.currentPage().getParameters().get('contactId');
        atelierId = Apexpages.currentPage().getParameters().get('atelierId');
        rencontreId = Apexpages.currentPage().getParameters().get('rencontreId');
        formationId = Apexpages.currentPage().getParameters().get('formationId');
        chargentOrderId = Apexpages.currentPage().getParameters().get('chargentOrderId');
        transactionId = Apexpages.currentPage().getParameters().get('transactionId');
        notesId = Apexpages.currentPage().getParameters().get('notesId');
        individualSupportId = Apexpages.currentPage().getParameters().get('individualSupportId');
    }
    
    public String getEmailBody() {
        EmailTemplate template = [Select Id, Name, Subject, HtmlValue from EmailTemplate where Name = :templateName LIMIT 1];
        //EmailTemplate template = [Select Id, Name, Subject, HtmlValue from EmailTemplate where Name = 'Courriel participant - Reçu officiel atelier - FR-EN' LIMIT 1];
        System.debug('template '+template);
        emailBody = template.HtmlValue;
        emailBody = emailBody.replace('[CurrentDate]', String.valueOf(Date.Today().year()));
        emailBody = emailBody.replace('{!$Label.CopyrightYear}', System.Label.CopyrightYear);
        emailBody = setMergeFields(emailBody);
        return emailBody;
    }
    
    public String setMergeFields(String emailBody) {
        Map<String, Map<String, String>> mapSObjectToMergeFieldValues = new Map<String, Map<String, String>>();
        Map<String, Map<String, String>> mapSObjectToLeadingCharacterValues = new Map<String, Map<String, String>>();
        // Custom Metadata Type query
        List<PDF_Receipt_Configuration__mdt > listMergeFieldConfigurations = [SELECT sObject__c, MergeField__c, ValueField__c, Leading_Character__c FROM PDF_Receipt_Configuration__mdt WHERE EmailTemplateName__c =:templateName];
        System.debug('listMergeFieldConfigurations '+listMergeFieldConfigurations);
        for(PDF_Receipt_Configuration__mdt  pdfConfig : listMergeFieldConfigurations) {
            if(!mapSObjectToMergeFieldValues.containsKey(pdfConfig.sObject__c)) {
                mapSObjectToMergeFieldValues.put(pdfConfig.sObject__c, new Map<String, String>());
            }
            mapSObjectToMergeFieldValues.get(pdfConfig.sObject__c).put(pdfConfig.MergeField__c, pdfConfig.ValueField__c);

            if (pdfConfig.Leading_Character__c != null && pdfConfig.Leading_Character__c != '') {
                if(!mapSObjectToLeadingCharacterValues.containsKey(pdfConfig.sObject__c)) {
                    mapSObjectToLeadingCharacterValues.put(pdfConfig.sObject__c, new Map<String, String>());
                }
                mapSObjectToLeadingCharacterValues.get(pdfConfig.sObject__c).put(pdfConfig.MergeField__c, pdfConfig.Leading_Character__c);
            }
        }
        System.debug('==mapSObjectToMergeFieldValues===' + JSON.serializePretty(mapSObjectToMergeFieldValues));
        Map<String, Object> mapMergeFieldToFieldValue = new Map<String, Object>();
        // Get Opportunity Merge Fields
        if(opportunityId != NULL && mapSObjectToMergeFieldValues.containsKey('Opportunity')) {
            Map<String, String> mapMergeFieldValues = mapSObjectToMergeFieldValues.get('Opportunity');
            Map<String, String> mergeFieldToLeadingCharacter = mapSObjectToLeadingCharacterValues.get('Opportunity');
            String queryFields = String.join(mapMergeFieldValues.values(), ', ');
            String query = 'SELECT ' + queryFields + ' FROM Opportunity WHERE Id=\'' + opportunityId + '\' LIMIT 1';
            Opportunity opp = System.Database.query(query);
            
            for(String mergeField : mapMergeFieldValues.keySet()) {
                if (opp.get(mapMergeFieldValues.get(mergeField)) == null) {
                    mapMergeFieldToFieldValue.put(mergeField, '');
                } else {
                    String leadingCharacter = '';
                    if (mergeFieldToLeadingCharacter != null && mergeFieldToLeadingCharacter.get(mergeField) != null) {
                        leadingCharacter = mergeFieldToLeadingCharacter.get(mergeField);
                    }
    
                    mapMergeFieldToFieldValue.put(mergeField, (leadingCharacter == null ? '' : leadingCharacter) + opp.get(mapMergeFieldValues.get(mergeField)));
                }
            }
        }
        
        // Get Contact Merge Fields
        if(contactId != NULL && mapSObjectToMergeFieldValues.containsKey('Contact')) {
            Map<String, String> mapMergeFieldValues = mapSObjectToMergeFieldValues.get('Contact');
            Map<String, String> mergeFieldToLeadingCharacter = mapSObjectToLeadingCharacterValues.get('Contact');

            String queryFields = String.join(mapMergeFieldValues.values(), ', ');
            String query = 'SELECT ' + queryFields + ' FROM Contact WHERE Id=\'' + contactId + '\' LIMIT 1';
            Contact con = System.Database.query(query);
            
            for(String mergeField : mapMergeFieldValues.keySet()) {
                if (con.get(mapMergeFieldValues.get(mergeField)) == null) {
                    mapMergeFieldToFieldValue.put(mergeField, '');
                } else {
                    String leadingCharacter = '';
                    if (mergeFieldToLeadingCharacter != null && mergeFieldToLeadingCharacter.get(mergeField) != null) {
                        leadingCharacter = mergeFieldToLeadingCharacter.get(mergeField);
                    }
                    mapMergeFieldToFieldValue.put(mergeField, (leadingCharacter == null ? '' : leadingCharacter) + con.get(mapMergeFieldValues.get(mergeField)));
                }
            }
        }
        
        // Get Transaction Merge Fields
        if(transactionId != NULL && mapSObjectToMergeFieldValues.containsKey('ChargentOrders__Transaction__c')) {
            Map<String, String> mapMergeFieldValues = mapSObjectToMergeFieldValues.get('ChargentOrders__Transaction__c');
            Map<String, String> mergeFieldToLeadingCharacter = mapSObjectToLeadingCharacterValues.get('ChargentOrders__Transaction__c');

            String queryFields = String.join(mapMergeFieldValues.values(), ', ');
            String query = 'SELECT ' + queryFields + ' FROM ChargentOrders__Transaction__c  WHERE Id=\'' + transactionId + '\' LIMIT 1';
            ChargentOrders__Transaction__c chargeOrderTransaction = System.Database.query(query);
            
            for(String mergeField : mapMergeFieldValues.keySet()) {
                if (chargeOrderTransaction.get(mapMergeFieldValues.get(mergeField)) == null) {
                    mapMergeFieldToFieldValue.put(mergeField, '');
                } else {
                    String leadingCharacter = '';
                    if (mergeFieldToLeadingCharacter != null && mergeFieldToLeadingCharacter.get(mergeField) != null) {
                        leadingCharacter = mergeFieldToLeadingCharacter.get(mergeField);
                    }

                    mapMergeFieldToFieldValue.put(mergeField, (leadingCharacter == null ? '' : leadingCharacter) + chargeOrderTransaction.get(mapMergeFieldValues.get(mergeField)));
                }
            }
        }
        
        // Get Atelier Merge Fields
        if(atelierId != NULL && mapSObjectToMergeFieldValues.containsKey('Atelier__c')) {
            Map<String, String> mapMergeFieldValues = mapSObjectToMergeFieldValues.get('Atelier__c');
            Map<String, String> mergeFieldToLeadingCharacter = mapSObjectToLeadingCharacterValues.get('Atelier__c');

            String queryFields = String.join(mapMergeFieldValues.values(), ', ');
            String query = 'SELECT ' + queryFields + ' FROM Atelier__c WHERE Id=\'' + atelierId + '\' LIMIT 1';
            Atelier__c atl = System.Database.query(query);
            String objectName = 'Atelier__c';
            String fieldName =  '';
            for(String mergeField : mapMergeFieldValues.keySet()) {
                if (atl.get(mapMergeFieldValues.get(mergeField)) == null) {
                    mapMergeFieldToFieldValue.put(mergeField, '');
                } else {
                    fieldName = mapMergeFieldValues.get(mergeField);
                    String leadingCharacter = '';
                    if (mergeFieldToLeadingCharacter != null && mergeFieldToLeadingCharacter.get(mergeField) != null) {
                        leadingCharacter = mergeFieldToLeadingCharacter.get(mergeField);
                    }
                    Schema.DisplayType type = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getType();
    
                    if(type == Schema.DisplayType.Date) {
                        System.debug(' atl.get( mapMergeFieldValues.get(mergeField))'+  atl.get( mapMergeFieldValues.get(mergeField)));
                        mapMergeFieldToFieldValue.put(mergeField, (leadingCharacter == null ? '' : leadingCharacter) + atl.get(mapMergeFieldValues.get(mergeField)));
                    }
                    else {
                        mapMergeFieldToFieldValue.put(mergeField, (leadingCharacter == null ? '' : leadingCharacter) + atl.get(mapMergeFieldValues.get(mergeField)));
                    }
                }
            }
        }
        
        // Get Rencontre Merge Fields
        if(rencontreId != NULL && mapSObjectToMergeFieldValues.containsKey('Meeting__c')) {
            Map<String, String> mapMergeFieldValues = mapSObjectToMergeFieldValues.get('Meeting__c');
            Map<String, String> mergeFieldToLeadingCharacter = mapSObjectToLeadingCharacterValues.get('Meeting__c');

            String queryFields = String.join(mapMergeFieldValues.values(), ', ');
            String query = 'SELECT ' + queryFields + ' FROM Meeting__c WHERE Id=\'' + rencontreId + '\' LIMIT 1';
            Meeting__c rencontre = System.Database.query(query);
            
            for(String mergeField : mapMergeFieldValues.keySet()) {
                if (rencontre.get(mapMergeFieldValues.get(mergeField)) == null) {
                    mapMergeFieldToFieldValue.put(mergeField, '');
                } else {
                    String leadingCharacter = '';
                    if (mergeFieldToLeadingCharacter != null && mergeFieldToLeadingCharacter.get(mergeField) != null) {
                        leadingCharacter = mergeFieldToLeadingCharacter.get(mergeField);
                    }
    
                    mapMergeFieldToFieldValue.put(mergeField, (leadingCharacter == null ? '' : leadingCharacter) + rencontre.get(mapMergeFieldValues.get(mergeField)));
                }
            }
        }
        
        // Get Formation Merge Fields
        if(formationId != NULL && mapSObjectToMergeFieldValues.containsKey('Formation__c')) {
            Map<String, String> mapMergeFieldValues = mapSObjectToMergeFieldValues.get('Formation__c');
            Map<String, String> mergeFieldToLeadingCharacter = mapSObjectToLeadingCharacterValues.get('Formation__c');

            String queryFields = String.join(mapMergeFieldValues.values(), ', ');
            String query = 'SELECT ' + queryFields + ' FROM Formation__c WHERE Id=\'' + formationId + '\' LIMIT 1';
            Formation__c formation = System.Database.query(query);
            
            for(String mergeField : mapMergeFieldValues.keySet()) {
                if (formation.get(mapMergeFieldValues.get(mergeField)) == null) {
                    mapMergeFieldToFieldValue.put(mergeField, '');
                } else {
                    String leadingCharacter = '';
                    if (mergeFieldToLeadingCharacter != null && mergeFieldToLeadingCharacter.get(mergeField) != null) {
                        leadingCharacter = mergeFieldToLeadingCharacter.get(mergeField);
                    }
    
                    mapMergeFieldToFieldValue.put(mergeField, (leadingCharacter == null ? '' : leadingCharacter) + formation.get(mapMergeFieldValues.get(mergeField)));
                }
            }
        }
        
        // Get Chargent Order Merge Fields
        if(chargentOrderId != NULL && mapSObjectToMergeFieldValues.containsKey('ChargentOrders__ChargentOrder__c')) {
            Map<String, String> mapMergeFieldValues = mapSObjectToMergeFieldValues.get('ChargentOrders__ChargentOrder__c');
            Map<String, String> mergeFieldToLeadingCharacter = mapSObjectToLeadingCharacterValues.get('ChargentOrders__ChargentOrder__c');

            String queryFields = String.join(mapMergeFieldValues.values(), ', ');
            String query = 'SELECT ' + queryFields + ' FROM ChargentOrders__ChargentOrder__c WHERE Id=\'' + chargentOrderId + '\' LIMIT 1';
            System.debug(query);
            ChargentOrders__ChargentOrder__c chargentOrder = System.Database.query(query);
            
            for(String mergeField : mapMergeFieldValues.keySet()) {
                if (chargentOrder.get(mapMergeFieldValues.get(mergeField)) == null) {
                    mapMergeFieldToFieldValue.put(mergeField, '');
                } else {
                    String leadingCharacter = '';
                    if (mergeFieldToLeadingCharacter != null && mergeFieldToLeadingCharacter.get(mergeField) != null) {
                        leadingCharacter = mergeFieldToLeadingCharacter.get(mergeField);
                    }
    
                    mapMergeFieldToFieldValue.put(mergeField, (leadingCharacter == null ? '' : leadingCharacter) + chargentOrder.get(mapMergeFieldValues.get(mergeField)));
                }
            }
        }

        if(individualSupportId != NULL && mapSObjectToMergeFieldValues.containsKey('IndividualSupport__c')) {
            Map<String, String> mapMergeFieldValues = mapSObjectToMergeFieldValues.get('IndividualSupport__c');
            Map<String, String> mergeFieldToLeadingCharacter = mapSObjectToLeadingCharacterValues.get('IndividualSupport__c');

            String queryFields = String.join(mapMergeFieldValues.values(), ', ');
            String query = 'SELECT ' + queryFields + ' FROM IndividualSupport__c WHERE Id=\'' + individualSupportId + '\' LIMIT 1';
            System.debug(query);
            IndividualSupport__c individualSupport = System.Database.query(query);
            
            for(String mergeField : mapMergeFieldValues.keySet()) {
                if (individualSupport.get(mapMergeFieldValues.get(mergeField)) == null) {
                    mapMergeFieldToFieldValue.put(mergeField, '');
                } else {
                    String leadingCharacter = '';
                    if (mergeFieldToLeadingCharacter != null && mergeFieldToLeadingCharacter.get(mergeField) != null) {
                        leadingCharacter = mergeFieldToLeadingCharacter.get(mergeField);
                    }
    
                    mapMergeFieldToFieldValue.put(mergeField, (leadingCharacter == null ? '' : leadingCharacter) + individualSupport.get(mapMergeFieldValues.get(mergeField)));
                }
            }
        }
 
        if(notesId != NULL && mapSObjectToMergeFieldValues.containsKey('Notes__c')) {
            Map<String, String> mapMergeFieldValues = mapSObjectToMergeFieldValues.get('Notes__c');
            Map<String, String> mergeFieldToLeadingCharacter = mapSObjectToLeadingCharacterValues.get('Notes__c');

            String queryFields = String.join(mapMergeFieldValues.values(), ', ');
            String query = 'SELECT ' + queryFields + ' FROM Notes__c WHERE Id=\'' + notesId + '\' LIMIT 1';
            System.debug(query);
            Notes__c note = System.Database.query(query);
            
            for(String mergeField : mapMergeFieldValues.keySet()) {
                System.debug('current merge field = '+ mergeField);
                String value;
                if(mapMergeFieldValues.get(mergeField).contains('.')){
                    System.debug(mapMergeFieldValues.get(mergeField));
                    String objPath = mapMergeFieldValues.get(mergeField).split('\\.')[0];
                    String fieldPath = mapMergeFieldValues.get(mergeField).split('\\.')[1];
                    if (!isTestRunning){
                        value = String.valueOf(note.getSobject(objPath).get(fieldPath));
                    }
                } else{
                    value = String.valueOf(note.get(mapMergeFieldValues.get(mergeField)));
                }
                if (value == null) {
                    mapMergeFieldToFieldValue.put(mergeField, '');
                } else {
                    String leadingCharacter = '';
                    if (mergeFieldToLeadingCharacter != null && mergeFieldToLeadingCharacter.get(mergeField) != null) {
                        leadingCharacter = mergeFieldToLeadingCharacter.get(mergeField);
                    }
    
                    mapMergeFieldToFieldValue.put(mergeField, (leadingCharacter == null ? '' : leadingCharacter) + value);
                }
            }
        }
        
        
        System.debug('==FINAL FIELD MAPPING===' + mapMergeFieldToFieldValue);
        System.debug('==Email Body===' + emailBody);
        Integer currentYear = System.Today().year();
        
        for(String mergeField : mapMergeFieldToFieldValue.keySet()) {
            String year = '0';
            String fullDate = '';
            String inputString = String.valueOf(mapMergeFieldToFieldValue.get(mergeField));
            if(inputString != null && inputString.length() >10){
                    year = inputString.substring(0,4);
                    fullDate = inputString.substring(0,10);
                    System.debug('year ' + year);
                    System.debug('fullDate ' + fullDate);  
                    System.debug('mergeField ' + mergeField);
                    System.debug('inputString ' + inputString);
            }
            if(year == String.valueOf(currentYear) || year == String.valueOf(currentYear + 1)) {
                emailBody = emailBody.replace(mergeField,fullDate);
            } else if(mapMergeFieldToFieldValue.get(mergeField) != null) {
                emailBody = emailBody.replace(mergeField, String.valueOf(mapMergeFieldToFieldValue.get(mergeField)));
            } else {
                emailBody = emailBody.replace(mergeField, '');
            }
        }
        
        return emailBody;
    }
}