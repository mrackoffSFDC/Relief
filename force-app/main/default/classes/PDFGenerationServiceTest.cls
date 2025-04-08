@isTest
public class PDFGenerationServiceTest {
	@TestSetup
    static void makeData(){
        Contact testContact = new Contact(
            Email = 'testEmail@testmail.com',
            lastname = 'test'
        );
        insert testContact;

        Formation__c formation = new Formation__c(
            Name = 'formation'
        );
        insert formation;
        
        Opportunity opp = new Opportunity(
            Name = 'test',
            StageName = 'test',
            CloseDate = Date.today()
        );
        insert opp;
        
        ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c();
        insert order;

        ChargentOrders__Transaction__c tran = new ChargentOrders__Transaction__c(
            ChargentOrders__Amount__c = 100,
            ChargentOrders__Order__c = order.Id
        );
        insert tran;
    }

    @isTest 
    private static void generatePDFReceiptTest() {
        Contact testCon = [SELECT Id FROM Contact LIMIT 1];
        Formation__c testForm = [SELECT Id FROM Formation__c LIMIT 1];
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        ChargentOrders__Transaction__c testTran = [SELECT Id FROM ChargentOrders__Transaction__c LIMIT 1];
		
        PDFGenerationService.FlowInput input = new PDFGenerationService.FlowInput();
        input.parentRecordId = testCon.Id;
        input.formationId = testForm.Id;
        input.opportunityId = testOpp.Id;
        input.contactId = testCon.Id;
        input.templateName = 'Courriel participant - Reçu officiel formation - FR';
        input.transactionId = testTran.Id;

        
        Test.startTest();
            PDFGenerationService.generatePDFReceipt(new List<PDFGenerationService.FlowInput> {input});
        Test.stopTest();
    }
}