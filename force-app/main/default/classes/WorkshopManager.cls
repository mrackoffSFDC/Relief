public with sharing class WorkshopManager {

    public static void updateCurrentUserDates(List<Atelier__c> newWorks, Map<Id,Atelier__c> oldWorks) {

        TimeZone tz = UserInfo.getTimeZone();

        for(Atelier__c a : newWorks) {

            if(oldWorks == null || (a.Start_time__c != oldWorks.get(a.Id).Start_time__c || a.End_time__c != oldWorks.get(a.Id).End_time__c)) {
                if(a.Start_time__c != null && a.End_time__c != null) {
                    a.TECHStartDateCurrentUser__c = a.Start_time__c.addHours( ( tz.getOffset(a.Start_time__c) / (60 * 60 * 1000) ) );
                    a.TECHEndDateCurrentUser__c = a.End_time__c.addHours( ( tz.getOffset(a.End_time__c) / (60 * 60 * 1000) ) );
                }
            }
               
        }

    }
    
    // Check date validty i.e. if Workshop date falling on holiday
    public static Date getValidWorkshopDate(Set<Date> setHolidayDates, Date workshopDate) {
        if(setHolidayDates.contains(workshopDate)) {
           workshopDate = getValidWorkshopDate(setHolidayDates, workshopDate + 7);
        }
        return workshopDate;
    }
    
    // calculate Date - Week fields considering defined holidays
    public static void updateClassDates(List<Atelier__c> newAtelier, Map<Id,Atelier__c> oldAtelier) {
        // Fetch all holidays in system
        List<Holiday> listHolidays = [SELECT Id, ActivityDate FROM Holiday];
        Set<Date> setHolidayDates = new Set<Date>();	// set of all holiday dates
        for(Holiday holiday : listHolidays) {
            setHolidayDates.add(holiday.ActivityDate);
        }
        
        for(Atelier__c a : newAtelier) {
            if(a.Start_Date__c != NULL && (oldAtelier == null || (a.Start_Date__c != oldAtelier.get(a.Id).Start_Date__c))) {
                // Set dates
                a.Date_Week_1__c = getValidWorkshopDate(setHolidayDates, a.Start_Date__c);	// week 1
                a.Date_Week_2__c = getValidWorkshopDate(setHolidayDates, a.Date_Week_1__c + 7);	// week 2
                a.Date_Week_3__c = getValidWorkshopDate(setHolidayDates, a.Date_Week_2__c + 7);	// week 3
                a.Date_Week_4__c = getValidWorkshopDate(setHolidayDates, a.Date_Week_3__c + 7);	// week 4
                a.Date_Week_5__c = getValidWorkshopDate(setHolidayDates, a.Date_Week_4__c + 7);	// week 5
                a.Date_Week_6__c = getValidWorkshopDate(setHolidayDates, a.Date_Week_5__c + 7);	// week 6
                a.Date_Week_7__c = getValidWorkshopDate(setHolidayDates, a.Date_Week_6__c + 7);	// week 7
                a.Date_Week_8__c = getValidWorkshopDate(setHolidayDates, a.Date_Week_7__c + 7);	// week 8
                a.Date_Week_9__c = getValidWorkshopDate(setHolidayDates, a.Date_Week_8__c + 7);	// week 9
                a.Date_Week_10__c = getValidWorkshopDate(setHolidayDates, a.Date_Week_9__c + 7);	// week 10
                a.Date_Week_11__c = a.Date_Week_12__c = a.Date_Week_13__c = NULL;
                // week 11
                if(a.WorkshopTheme__c != 'Bipolarité' && a.WorkshopTheme__c != 'Bipolarity (anglais)' && (a.Type__c == 'Atelier d’autogestion virtuel')) {
                    a.Date_Week_11__c = getValidWorkshopDate(setHolidayDates, a.Date_Week_10__c + 7);
                }
                if((a.WorkshopTheme__c == 'Bipolarité' || a.WorkshopTheme__c == 'Bipolarity (anglais)') && (a.Type__c == 'Atelier d’autogestion virtuel' || a.Type__c == 'Atelier d\'autogestion en présentiel')) {
                    a.Date_Week_11__c = getValidWorkshopDate(setHolidayDates, a.Date_Week_10__c + 7);
                }
                // week 12
                if((a.WorkshopTheme__c == 'Bipolarité' || a.WorkshopTheme__c == 'Bipolarity (anglais)') && (a.Type__c == 'Atelier d’autogestion virtuel' || a.Type__c == 'Atelier d\'autogestion en présentiel')) {
                    a.Date_Week_12__c = getValidWorkshopDate(setHolidayDates, a.Date_Week_11__c + 7);
                }
                // week 13
                if((a.WorkshopTheme__c == 'Bipolarité' || a.WorkshopTheme__c == 'Bipolarity (anglais)') && a.Type__c == 'Atelier d’autogestion virtuel') {
                    a.Date_Week_13__c = getValidWorkshopDate(setHolidayDates, a.Date_Week_12__c + 7);
                }
            } 
        }
    }
}