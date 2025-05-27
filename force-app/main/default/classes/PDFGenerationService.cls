public without sharing class PDFGenerationService {
    
    @InvocableMethod
    public static void generatePDFReceipt(List<FlowInput> inputs) {
        //Flow Inputs
        FlowInput objInput = inputs.get(0);
        System.debug(JSON.serialize(objInput));
        // Create a new page reference
        System.debug('1');
        PageReference templatePDF = new PageReference('/apex/GeneratePDFReceipt');
        // Set the account id as a parameter
        System.debug('2');

        templatePDF.getParameters().put('opportunityId', objInput.opportunityId);
        templatePDF.getParameters().put('contactId', objInput.contactId);
        templatePDF.getParameters().put('atelierId', objInput.atelierId);
        System.debug('3');
        templatePDF.getParameters().put('rencontreId', objInput.rencontreId);
        templatePDF.getParameters().put('formationId', objInput.formationId);
        templatePDF.getParameters().put('chargentOrderId', objInput.chargentOrderId);
        templatePDF.getParameters().put('parentRecordId', objInput.parentRecordId);
        templatePDF.getParameters().put('templateName', objInput.templateName);
        templatePDF.getParameters().put('transactionId', objInput.transactionId);
        Blob templatePdfBlob;
        System.debug('4');

        try {
            templatePdfBlob = templatePDF.getContentAsPDF();
        }
        catch (Exception e) {
            templatePdfBlob = Blob.valueOf(e.getMessage());
        }
                System.debug('5');

        // Create a new PDF document and add the contents of the page reference to it
        ContentVersion newContentVersion = new ContentVersion();
        String day = string.valueOf(system.now().day());
        String month = string.valueOf(system.now().month());
        String hour = string.valueOf(system.now().hour());
        String year = string.valueOf(system.now().year());
        String minute = string.valueOf(system.now().minute());
        String second = string.valueOf(system.now().second());

        month = month.length() == 1 ? '0' + month : month;
        day = day.length() == 1 ? '0' + day : day;
        hour = hour.length() == 1 ? '0' + hour : hour;
        minute = minute.length() == 1 ? '0' + minute : minute;
        second = second.length() == 1 ? '0' + second : second;

        String strTime = year+'-'+month+'-'+day+' '+hour+':'+minute+':'+second ;
        newContentVersion.Title = 'Receipt PDF' + strTime;
        System.debug('6');
        newContentVersion.PathOnClient = 'Receipt_' + strTime + '.pdf';
        newContentVersion.VersionData = templatePdfBlob;
        newContentVersion.FirstPublishLocationId = objInput.parentRecordId;

        insert newContentVersion;  
        
        //Get the ContentDocument record for the inserted version
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :newContentVersion.Id].ContentDocumentId;

        // Create a new ContentDocumentLink
        List<ContentDocumentLink> checkCDL = [SELECT id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:  objInput.parentRecordId AND ContentDocumentId =:  contentDocumentId ];
        if(checkCDL.size() == 0 ){
            
            ContentDocumentLink newContentDocLink = New ContentDocumentLink();
            newContentDocLink.LinkedEntityId = objInput.parentRecordId;
            newContentDocLink.ContentDocumentId = contentDocumentId;
            insert newContentDocLink;
        }
    }
    //input details that comes to apex from flow
    public class FlowInput {
        @InvocableVariable
        public String templateName;
        @InvocableVariable
        public String parentRecordId;
        @InvocableVariable
        public String opportunityId;
        @InvocableVariable
        public String contactId;
        @InvocableVariable
        public String atelierId;
        @InvocableVariable
        public String rencontreId;
        @InvocableVariable
        public String formationId;
        @InvocableVariable
        public String chargentOrderId;
        @InvocableVariable
        public String transactionId;
    }
    
    public static EmailTemplate getEmailTemplate(string name) {  
        return [Select Id, Name, Subject, HtmlValue from EmailTemplate where name=:name LIMIT 1];
    }
}