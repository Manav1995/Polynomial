import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Map;
import java.util.TreeMap;

public class Polynomial {
	private Map<Integer, Double> polyMap;

	public Polynomial() {
		polyMap = new TreeMap<Integer, Double>();
	}

	public Polynomial(Map<Integer, Double> polyMap) {
		this.polyMap = polyMap;
	}

	public Map<Integer, Double> createPolyMap(String exps, String coeffs) {
		Map<Integer, Double> polyMap = new TreeMap<Integer, Double>();
		String exp[] = exps.split(" ");
		String coeff[] = coeffs.split(" ");
		for (int i = 0; i < exps.length(); i++) {
			polyMap.put(Integer.parseInt(exp[i]), Double.parseDouble(coeff[i]));
		}
		return polyMap;
	}

	private Polynomial createPolynomial(String fileName) throws IOException {
		File file = new File(fileName);
		BufferedReader br = new BufferedReader(new FileReader(file));
		String exp = br.readLine();
		String coeff = br.readLine();
		br.close();
		return new Polynomial(createPolyMap(exp, coeff));	
	}

	public static void main(String args[]) throws IOException {
		Polynomial A = (new Polynomial()).createPolynomial(args[0]);
		Polynomial B = (new Polynomial()).createPolynomial(args[1]);
		
		Polynomial C = A.add(B);
		Polynomial D = A.subtract(B);
		Polynomial E = A.multiply(B);
		
		C.toString();
		D.toString();
		E.toString();
		
		C.toHTML();
		D.toHTML();
		E.toHTML();
		
		C.toLatex();
		D.toLatex();
		E.toLatex();
	}
	

	/*Manipulation Functions*/
	public Polynomial add(Polynomial p) {
			int outDegree = Math.max(p.getDegree(), this.getDegree());
			Map<Integer,Double> newMap = new TreeMap<Integer,Double>();
			Polynomial output = new Polynomial(newMap);
			
			/*Adding the coefficients till the lower degree*/
			for (Map.Entry<Integer,Double> entry : this.map.entrySet())
			{
			    output.getMap().put(entry.getKey(), entry.getValue());
			}
			for (Map.Entry<Integer,Double> entry : p.map.entrySet())
			{
			    output.getMap().replace(entry.getKey(), output.getMap().get(entry.getKey())+entry.getValue());
			}
			return output;
	}
	
	public Polynomial subtract(Polynomial p){
		int outDegree = Math.max(p.getDegree(), this.getDegree());
		Map<Integer,Double> newMap = new TreeMap<Integer,Double>();
		Polynomial output = new Polynomial(newMap);
		
		/*Adding the coefficients till the lower degree*/
		for (Map.Entry<Integer,Double> entry : this.map.entrySet())
		{
		    output.getMap().put(entry.getKey(), entry.getValue());
		}
		for (Map.Entry<Integer,Double> entry : p.map.entrySet())
		{
		    output.getMap().replace(entry.getKey(), output.getMap().get(entry.getKey())-entry.getValue());
		}
		return output;
}
	public void multiply(Polynomial p){
		
	}
	
	/*Polynomial output format functions*/
	public String toString(){
		String s="";
		for(Map.Entry<Integer,Double> entry : this.getMap().entrySet()) {
			
			if(entry.getValue()==0) 
				continue; /*Don't print the part since it's coefficient is 0*/
			else {
				if(entry.getValue()>1) {
					s+=entry.getKey()+"*"+this.varName+"^"+entry.getValue(); /*Add the powers if greater than 1*/
				} else if(entry.getValue()==1) {
					s+=entry.getKey()+"*"+this.varName; /*Add the variable only if equal to 1*/
				}
				
			}
			
			
		}
		return s;
	}
	
	public String getCoefficientString(int num){
		String s="";
			return s+=num;
		 
	}
	public String toLatex(){
		return null;
	}
	public String toHTML(){
		return null;
	}
	
	public Map<Integer,Double> getMap(){
		return this.map;
	}
	
	public static void toHTML(String s) throws IOException
	{
       BufferedWriter bw=null;
        
        try 
        {
            bw = new BufferedWriter( new FileWriter("C:\\Desktop\\Polynomial.html"));
            String line="<html><title>Polynomial</title><body>";
            String[] datainfo = s.split("^");
            String line1="";
            for(int i=0;datainfo[i]!=null;i++)
            {
            	line1+=datainfo[i]+"<sup>"+datainfo[i+1]+"</sup>";
            }
            String line2="</body></html>";
            bw.write(line+line2);
            bw.newLine();

        }
        catch(IOException e)
        {
        	
        }
        finally
        {
        	if(bw!=null)
                bw.close();

        }
        
		
	}
}
