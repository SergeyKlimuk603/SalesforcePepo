/*
 * Класс содержит Id Lead, Id Account в который был сконвертирован Lead
 * и список изменений произведенных в этом Lead.
 */

public class LeadChanges {
    
	private Id leadId;
    private Id convertedAccountId;
    private Map<String, String> listOfChanges = new Map<String, String>();
    
    
    // Constructors
    public LeadChanges() {}
    
    public LeadChanges(Id leadId, Id convertedAccountId) {
        this.leadId = leadId;
        this.convertedAccountId = convertedAccountId;
    }
    
    
    // Getters and setters
    public Id getLeadId() {
        return leadId;
    }
    public void setLeadId(Id leadId) {
        this.leadId = leadId;
    } 
     public Id getConvertedAccountId() {
        return convertedAccountId;
    }
    public void setConvertedAccountId(Id convertedAccountId) {
        this.convertedAccountId = convertedAccountId;
    }
    public Map<String, String> getListOfChanges() {
        return listOfChanges;
    }
    public void setListOfChanges(Map<String, String> listOfChanges) {
        this.listOfChanges = listOfChanges;
    }
}