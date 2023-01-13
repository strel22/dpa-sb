trigger BROrderItemTrigger on OrderItem (after update, after insert, after delete, after undelete) {

    if (Trigger.isAfter) {
        if (Trigger.isDelete) {
            BROrderItemTriggerHelper.refreshOrderItems(Trigger.old, 'ON_DELETE'); 
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            BROrderItemTriggerHelper.refreshOrderItems(Trigger.new, 'ON_INSERT');
        }
    }

}