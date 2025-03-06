trigger WorkshopTrigger on Atelier__c (before insert, before update) {
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        WorkshopManager.updateCurrentUserDates(Trigger.new, Trigger.oldMap);
        // set dates for upcoming classes
        WorkshopManager.updateClassDates(Trigger.new, Trigger.oldMap);
    }
}