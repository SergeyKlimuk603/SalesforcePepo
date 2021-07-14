public class LeadManager {

    public static List<Lead> getLeadsByIds(Set<String> fieldAPINames, Set<Id> leadIds) {
        String query = 'SELECT ' + fieldAPINames.toString().substringBetween('{', '}')
            + ' FROM Lead WHERE Id IN:leadIds';
        return Database.query(query);
       }
}
