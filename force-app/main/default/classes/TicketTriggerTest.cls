@isTest
private class TicketTriggerTest {
    @isTest
    static void testTicketSyncAndDefaults() {
        Geography__c geo = new Geography__c(
            Name = 'Bengaluru South Test Geo 3',
            Nation__c = 'India',
            State__c = 'Karnataka',
            District__c = 'Bengaluru',
            Town__c = 'Bengaluru',
            Municipal__c = 'BBMP'
        );
        insert geo;

        Outlet__c outlet = new Outlet__c(
            Name = 'Central Retail Depot',
            Geography__c = geo.Id,
            Outlet_Name__c = 'Central Retail Depot',
            Contact_No__c = '9876543211'
        );
        insert outlet;

        // Test 1: Insert with Outlet__c Lookup - verifies Outlet_Name__c sync and Status__c default
        Ticket__c t1 = new Ticket__c(
            Outlet__c = outlet.Id,
            Ticket_Subject__c = 'Chiller Display Not Cooling',
            Description__c = 'The visi-cooler in store is running at 18 degrees Celsius and needs urgent gas refill.',
            Image__c = 'https://images.unsplash.com/photo-1584992236310-6edddc08acff?w=600'
        );
        insert t1;

        Ticket__c insertedT1 = [SELECT Id, Name, Outlet_Name__c, Status__c, Ticket_Num__c, Ticket_Subject__c, Subject__c, Description__c, Image__c FROM Ticket__c WHERE Id = :t1.Id];
        System.assertEquals('Central Retail Depot', insertedT1.Outlet_Name__c);
        System.assertEquals('New', insertedT1.Status__c);
        System.assertEquals(insertedT1.Name, insertedT1.Ticket_Num__c);
        System.assertEquals('Chiller Display Not Cooling', insertedT1.Subject__c);

        // Test 2: Insert with Outlet_Name__c text - verifies lookup resolution
        Ticket__c t2 = new Ticket__c(
            Outlet_Name__c = 'Central Retail Depot',
            Ticket_Subject__c = 'Damaged Biscuit Carton Delivery',
            Description__c = 'Three boxes of Bourbon Chocolate received with damaged packaging.',
            Image__c = 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=600'
        );
        insert t2;

        Ticket__c insertedT2 = [SELECT Id, Outlet__c, Outlet_Name__c, Status__c FROM Ticket__c WHERE Id = :t2.Id];
        System.assertEquals(outlet.Id, insertedT2.Outlet__c);
        System.assertEquals('Central Retail Depot', insertedT2.Outlet_Name__c);

        // Test 3: Update ticket
        t2.Status__c = 'In Progress';
        update t2;

        Ticket__c updatedT2 = [SELECT Id, Status__c FROM Ticket__c WHERE Id = :t2.Id];
        System.assertEquals('In Progress', updatedT2.Status__c);
    }
}