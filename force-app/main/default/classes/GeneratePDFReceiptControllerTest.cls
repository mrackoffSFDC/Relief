@isTest
public with sharing class GeneratePDFReceiptControllerTest {
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

        ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(
            ChargentOrders__Card_Type__c = 'Visa'
        );
        insert order;

        ChargentOrders__Transaction__c tran = new ChargentOrders__Transaction__c(
            ChargentOrders__Amount__c = 100,
            ChargentOrders__Order__c = order.Id
        );
        insert tran;

        IndividualSupport__c support = new IndividualSupport__c();
        insert support;

        Notes__c note = new Notes__c(
            Type_de_soutien__c = 'Soutien ponctuel par courriel'
        );
        insert note;

        Meeting__c meeting = new Meeting__c(
            Date_heure_rencontre__c = Date.today(),
            Thematique__c = 'Filtres',
            individualSupport__c = support.Id
        );
        insert meeting;

    }

    @isTest
    private static void GeneratePDFReceiptControllerTest_accompagnement() {
        Contact testCon = [SELECT Id FROM Contact LIMIT 1];
        Formation__c testForm = [SELECT Id FROM Formation__c LIMIT 1];
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        ChargentOrders__Transaction__c testTran = [SELECT Id FROM ChargentOrders__Transaction__c LIMIT 1];
        IndividualSupport__c testIndiv = [SELECT Id FROM IndividualSupport__c LIMIT 1];
        Notes__c testNote = [SELECT Id FROM Notes__c LIMIT 1];



        GeneratePDFReceiptController controller = new GeneratePDFReceiptController();
        controller.templateName = 'Courriel participant - Reçu officiel formation - FR';
        controller.parentRecordId = testCon.Id;
        controller.opportunityId = testOpp.Id;
        controller.contactId = testCon.Id;
        controller.formationId = testForm.Id;
        controller.transactionId = testTran.Id;
        controller.individualSupportId = testIndiv.Id;
        controller.notesId = testNote.Id;

        Test.startTest();
            String returnString = controller.getEmailBody();
        Test.stopTest();
    }

    @isTest
    private static void GeneratePDFReceiptControllerTest_formation() {
        Contact testCon = [SELECT Id FROM Contact LIMIT 1];
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        ChargentOrders__Transaction__c testTran = [SELECT Id FROM ChargentOrders__Transaction__c LIMIT 1];
        ChargentOrders__ChargentOrder__c order = [SELECT Id FROM ChargentOrders__ChargentOrder__c LIMIT 1];
        Meeting__c meeting = [SELECT Id FROM Meeting__c LIMIT 1];

        GeneratePDFReceiptController controller = new GeneratePDFReceiptController();
        controller.templateName = 'Courriel participant - Reçu officiel accompagnement - FR';
        controller.parentRecordId = testCon.Id;
        controller.opportunityId = testOpp.Id;
        controller.contactId = testCon.Id;
        controller.transactionId = testTran.Id;
        controller.chargentOrderId = order.Id;
        controller.rencontreId = meeting.Id;

        Test.startTest();
            String returnString = controller.getEmailBody();
        Test.stopTest();
    }


    @isTest
    private static void GeneratePDFReceiptControllerTest_Bilan_demarche() {
        Contact testCon = [SELECT Id FROM Contact LIMIT 1];
        Formation__c testForm = [SELECT Id FROM Formation__c LIMIT 1];
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        ChargentOrders__Transaction__c testTran = [SELECT Id FROM ChargentOrders__Transaction__c LIMIT 1];
        IndividualSupport__c testIndiv = [SELECT Id FROM IndividualSupport__c LIMIT 1];
        Notes__c testNote = [SELECT Id FROM Notes__c LIMIT 1];



        GeneratePDFReceiptController controller = new GeneratePDFReceiptController();
        controller.templateName = 'Courriel participant - Bilan démarche FR-EN';
        controller.parentRecordId = testCon.Id;
        controller.opportunityId = testOpp.Id;
        controller.contactId = testCon.Id;
        controller.formationId = testForm.Id;
        controller.transactionId = testTran.Id;
        controller.individualSupportId = testIndiv.Id;
        controller.notesId = testNote.Id;
        controller.isTestRunni
        ng = true;
        Test.startTest();
            String returnString = controller.getEmailBody();
        Test.stopTest();
    }
}