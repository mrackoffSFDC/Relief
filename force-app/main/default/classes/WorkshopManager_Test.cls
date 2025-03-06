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

        System.assertNotEquals(null, atelier.TECHStartDateCurrentUser__c, 'week should not be null for type + workshop theme') ;
        System.assertNotEquals(null, atelier.TECHEndDateCurrentUser__c, 'week should not be null for type + workshop theme');

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

        System.assertNotEquals(null, atelier.Date_Week_1__c, 'week should not be null for type + workshop theme');
        System.assertNotEquals(null, atelier.Date_Week_2__c, 'week should not be null for type + workshop theme');

    }


    @isTest
    public static void testClassDatesChangeWorkshopType() {

        Atelier__c atelier = [SELECT Id, Start_time__c, End_time__c FROM Atelier__c LIMIT 1];
        User u = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com' LIMIT 1];
        Atelier__c atelierAfterUpdate1;
        Atelier__c atelierAfterUpdate2;  
        Test.startTest();
            System.runAs(u) {
                atelier.Start_Date__c = Date.today();
                atelier.Type__c ='Atelier d’autogestion virtuel'; 
                atelier.WorkshopTheme__c ='Bipolarity (anglais)';
                update atelier;

                atelierAfterUpdate1 = [SELECT Id, WorkshopTheme__c, Type__c, Start_time__c,Date_Week_8__c,Date_Week_9__c, Date_Week_10__c, Date_Week_11__c, Date_Week_12__c,Date_Week_13__c  FROM Atelier__c LIMIT 1];
                atelier.WorkshopTheme__c = 'Anxiété - cégep';
                atelier.Type__c ='Atelier d\'autogestion en présentiel'; 
                update atelier; 
            }
        Test.stopTest();

        atelierAfterUpdate2 = [SELECT Id, WorkshopTheme__c, Type__c, Start_time__c,Date_Week_8__c,Date_Week_9__c, Date_Week_10__c, Date_Week_11__c, Date_Week_12__c,Date_Week_13__c  FROM Atelier__c LIMIT 1];
        system.assertNotEquals(null, atelierAfterUpdate1.Date_Week_8__c, 'week should not be null for type + workshop theme  atelierAfterUpdate1.Date_Week_8__c + ' + atelierAfterUpdate1.WorkshopTheme__c + ' ' + atelierAfterUpdate1.Type__c);
        system.assertNotEquals(null, atelierAfterUpdate1.Date_Week_9__c, 'week should not be null for type + workshop theme  atelierAfterUpdate1.Date_Week_9__c + ' + atelierAfterUpdate1.WorkshopTheme__c + ' ' + atelierAfterUpdate1.Type__c);
        system.assertNotEquals(null, atelierAfterUpdate1.Date_Week_10__c, 'week should not be null for type + workshop theme  atelierAfterUpdate1.Date_Week_10__c + ' + atelierAfterUpdate1.WorkshopTheme__c + ' ' + atelierAfterUpdate1.Type__c);
        system.assertNotEquals(null, atelierAfterUpdate1.Date_Week_11__c, 'week should not be null for type + workshop theme  atelierAfterUpdate1.Date_Week_11__c + ' + atelierAfterUpdate1.WorkshopTheme__c + ' ' + atelierAfterUpdate1.Type__c);
        system.assertNotEquals(null, atelierAfterUpdate1.Date_Week_12__c, 'week should not be null for type + workshop theme  atelierAfterUpdate1.Date_Week_12__c + ' + atelierAfterUpdate1.WorkshopTheme__c + ' ' + atelierAfterUpdate1.Type__c);
        system.assertNotEquals(null, atelierAfterUpdate1.Date_Week_13__c, 'week should not be null for type + workshop theme  atelierAfterUpdate1.Date_Week_13__c + ' + atelierAfterUpdate1.WorkshopTheme__c + ' ' + atelierAfterUpdate1.Type__c);

        system.assertNotEquals(null, atelierAfterUpdate2.Date_Week_8__c, 'week should not be null for type + workshop theme atelierAfterUpdate2.Date_Week_8__c + ' + atelierAfterUpdate2.WorkshopTheme__c + ' ' + atelierAfterUpdate2.Type__c);
        system.assertEquals(null, atelierAfterUpdate2.Date_Week_9__c, 'week should be null for type + workshop theme atelierAfterUpdate2.Date_Week_9__c + ' + atelierAfterUpdate2.WorkshopTheme__c + ' ' + atelierAfterUpdate2.Type__c);
        system.assertEquals(null, atelierAfterUpdate2.Date_Week_10__c, 'week should be null for type + workshop theme atelierAfterUpdate2.Date_Week_10__c + ' + atelierAfterUpdate2.WorkshopTheme__c + ' ' + atelierAfterUpdate2.Type__c);
        system.assertEquals(null, atelierAfterUpdate2.Date_Week_11__c, 'week should be null for type + workshop theme atelierAfterUpdate2.Date_Week_11__c + ' + atelierAfterUpdate2.WorkshopTheme__c + ' ' + atelierAfterUpdate2.Type__c);
        system.assertEquals(null, atelierAfterUpdate2.Date_Week_12__c, 'week should be null for type + workshop theme atelierAfterUpdate2.Date_Week_12__c + ' + atelierAfterUpdate2.WorkshopTheme__c + ' ' + atelierAfterUpdate2.Type__c);
        system.assertEquals(null, atelierAfterUpdate2.Date_Week_13__c, 'week should be null for type + workshop theme atelierAfterUpdate2.Date_Week_13__c + ' + atelierAfterUpdate2.WorkshopTheme__c + ' ' + atelierAfterUpdate2.Type__c);
        //After update 1 week 10 should be set, weeks 11,12,13 should not be set
    }
}