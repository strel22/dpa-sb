trigger CaseTrigger on Case (after insert) {
    switch on Trigger.operationType {
        when AFTER_INSERT {
            //CaseTriggerHelper.createNewSubCase(Trigger.new);
        }
    }
}