trigger PrimaryOrderTrigger on Primary_Order__c (before insert, before update) {
    for (Primary_Order__c po : Trigger.new) {
        Primary_Order__c oldPo = (Trigger.isUpdate && Trigger.oldMap != null) ? Trigger.oldMap.get(po.Id) : null;
        
        // 1. Ensure Tax Percentage defaults to 18% if not provided
        if (po.Tax_Percentage__c == null) {
            po.Tax_Percentage__c = 18.0;
        }
        
        // 2. Determine Paid Cases (Distributor Purchase Quantity)
        Decimal paidCases = (po.Paid_Cases__c != null && po.Paid_Cases__c > 0) ? po.Paid_Cases__c : 
                           ((po.Total_Cases__c != null && po.Total_Cases__c > 0) ? po.Total_Cases__c : 0);
        
        String company = po.Product_Company__c != null ? po.Product_Company__c.toLowerCase() : '';
        Boolean isItcOrUnibic = company.contains('itc') || company.contains('sunfeast') || company.contains('unibic');
        
        // 3. Automatic Scheme Jumping based on Paid Cases
        // Britannia/Parle/Cadbury/Nestle/Amul/PepsiCo/Marico:
        // Tier 1: 5 cases -> 1 Free Case (Buy 5 Cases, Get 1 Case Free)
        // Tier 2: 10 cases -> 2 Free Cases (Buy 10 Cases, Get 2 Cases Free)
        // Tier 3: 20 cases -> 5 Free Cases (Buy 20 Cases, Get 5 Cases Free)
        // ITC / Unibic:
        // Tier 1: 4 cases -> 1 Free Case (Buy 4 Cases, Get 1 Case Free)
        // Tier 2: 8 cases -> 2 Free Cases (Buy 8 Cases, Get 2 Cases Free)
        // Tier 3: 16 cases -> 4 Free Cases (Buy 16 Cases, Get 4 Cases Free)
        
        Decimal freeCases = 0;
        String autoScheme = null;
        
        if (isItcOrUnibic) {
            if (paidCases >= 16) {
                freeCases = 4;
                autoScheme = 'Buy 16 Cases, Get 4 Cases Free';
            } else if (paidCases >= 8) {
                freeCases = 2;
                autoScheme = 'Buy 8 Cases, Get 2 Cases Free';
            } else if (paidCases >= 4) {
                freeCases = 1;
                autoScheme = 'Buy 4 Cases, Get 1 Case Free';
            }
        } else {
            if (paidCases >= 20) {
                freeCases = 5;
                autoScheme = 'Buy 20 Cases, Get 5 Cases Free';
            } else if (paidCases >= 10) {
                freeCases = 2;
                autoScheme = 'Buy 10 Cases, Get 2 Cases Free';
            } else if (paidCases >= 5) {
                freeCases = 1;
                autoScheme = 'Buy 5 Cases, Get 1 Case Free';
            }
        }
        
        // Apply automatic scheme & free cases if paidCases entered
        if (paidCases > 0) {
            po.Paid_Cases__c = paidCases;
            po.Free_Cases__c = freeCases;
            po.Total_Cases__c = paidCases + freeCases;
            if (autoScheme != null) {
                po.Primary_Scheme_Applied__c = autoScheme;
            } else if (po.Primary_Scheme_Applied__c != null && po.Primary_Scheme_Applied__c.contains('Buy') && paidCases < 4) {
                po.Primary_Scheme_Applied__c = null;
            }
        }
        
        // 4. GST-inclusive calculation (Per_Case_Price__c is Total Amount inclusive of GST)
        // Price charged is ONLY for Paid_Cases__c (Free cases are ₹0!)
        Decimal billableCases = (po.Paid_Cases__c != null && po.Paid_Cases__c > 0) ? po.Paid_Cases__c : po.Total_Cases__c;
        if (po.Per_Case_Price__c != null && billableCases != null && billableCases > 0) {
            Boolean priceOrCasesChanged = (oldPo == null) 
                || (po.Per_Case_Price__c != oldPo.Per_Case_Price__c) 
                || (po.Total_Cases__c != oldPo.Total_Cases__c)
                || (po.Paid_Cases__c != oldPo.Paid_Cases__c);
            
            Decimal totalIncGst = (po.Per_Case_Price__c * billableCases).setScale(2, System.RoundingMode.HALF_UP);
            Decimal taxRate = po.Tax_Percentage__c != null ? po.Tax_Percentage__c : 18.0;
            
            // Auto-calculate Tax Amount (18% of Total)
            if (po.Tax_Amount__c == null || priceOrCasesChanged) {
                po.Tax_Amount__c = (totalIncGst * (taxRate / 100.0)).setScale(2, System.RoundingMode.HALF_UP);
            }
            
            // Auto-calculate Base Price (Gross Amount = Total - Tax Amount)
            if (po.Gross_Amount__c == null || priceOrCasesChanged) {
                po.Gross_Amount__c = (totalIncGst - po.Tax_Amount__c).setScale(2, System.RoundingMode.HALF_UP);
            }
            
            // Auto-calculate Final Total Amount
            if (po.Payment_Status__c == 'Partially Paid' && po.Partially_Paid_Amount__c != null && po.Partially_Paid_Amount__c > 0) {
                po.Total_Amount__c = (totalIncGst - po.Partially_Paid_Amount__c).setScale(2, System.RoundingMode.HALF_UP);
            } else {
                po.Total_Amount__c = (po.Gross_Amount__c + po.Tax_Amount__c).setScale(2, System.RoundingMode.HALF_UP);
            }
        } else if (po.Gross_Amount__c != null) {
            Decimal tax = po.Tax_Amount__c != null ? po.Tax_Amount__c : 0;
            Decimal fullTotal = po.Gross_Amount__c + tax;
            if (po.Payment_Status__c == 'Partially Paid' && po.Partially_Paid_Amount__c != null && po.Partially_Paid_Amount__c > 0) {
                po.Total_Amount__c = (fullTotal - po.Partially_Paid_Amount__c).setScale(2, System.RoundingMode.HALF_UP);
            } else {
                po.Total_Amount__c = fullTotal.setScale(2, System.RoundingMode.HALF_UP);
            }
        }
    }
}