public class MyContactController {
	
    private Contact cont = new Contact();
    private final Account acct;
    
    public MyContactController(ApexPages.StandardController stdController) {
        this.acct = (Account) stdController.getRecord();
    }
    
    public Contact getCont() {
        return cont;
    }
    
    public PageReference saveContact() {
        cont.AccountId = acct.Id;
        try {
            insert cont;
        } catch (Exception ex) {
            String error = System.Label.CreateContactError + '<br/>' + ex.getMessage();
            ApexPages.Message message = new ApexPages.Message(ApexPages.Severity.Error, error);
            ApexPages.addMessage(message);
            return null;
        }
        PageReference createdContactPage = new ApexPages.StandardController(cont).view();
        return createdContactPage;
    }
}