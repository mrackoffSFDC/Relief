@isTest
public with sharing class WorkshopManager_Test {

    @TestSetup
    static void makeData(){

        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName
        );

        insert u;


        Id recordTypeIdAtelier = Utils_TestFactory.getRecordTypeIdForObject('Atelier__c', 'Atelier');
        Atelier__c atelier = new Atelier__c();
        atelier.RecordTypeId = recordTypeIdAtelier;
        atelier.Name = 'Test atelier';
        atelier.Atelier_Cost__c = 1;
        atelier.Start_time__c = Datetime.now();
        atelier.End_time__c = Datetime.now().addHours(8);
        atelier.Seats__c = 10; 
        insert atelier;
        
    }

    @isTest
    public static void updateCurrentUserDates() {

        Atelier__c atelier = [SELECT Id, Start_time__c, End_time__c FROM Atelier__c LIMIT 1];
        User u = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com' LIMIT 1];

        Test.startTest();

        System.runAs(u) {
            atelier.Start_time__c = Datetime.now().addHours(4);
            update atelier;
        }
       
        Test.stopTest();

        atelier = [SELECT Id, Start_time__c, TECHStartDateCurrentUser__c, TECHEndDateCurrentUser__c FROM Atelier__c LIMIT 1];

        System.assertNotEquals(null, atelier.TECHStartDateCurrentUser__c);
        System.assertNotEquals(null, atelier.TECHEndDateCurrentUser__c);

    }
    
    @isTest
    public static void testClassDates() {

        Atelier__c atelier = [SELECT Id, Start_time__c, End_time__c FROM Atelier__c LIMIT 1];
        User u = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com' LIMIT 1];

        Test.startTest();

        System.runAs(u) {
            atelier.Start_Date__c = Date.today();
        	update atelier;
        }
       
        Test.stopTest();

        atelier = [SELECT Id, Start_time__c, Date_Week_1__c, Date_Week_2__c FROM Atelier__c LIMIT 1];

        System.assertNotEquals(null, atelier.Date_Week_1__c);
        System.assertNotEquals(null, atelier.Date_Week_2__c);

    }
}