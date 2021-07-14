public class Printer {
    String textToPrint;
    public Printer(String text) {
        this.textToPrint = text;
    }

    public void printText() {
        System.debug('textToPrint = ' + textToPrint);
    }
    
    
    public Integer hashCode() {
        return (31 * textToPrint.hashCode());
    }
    
    public Boolean equals(Object obj) {
        if (obj instanceof Printer) {
            Printer p = (Printer)obj;
            return (textToPrint.equals(p.textToPrint));
        }
        return false;
    }
}
