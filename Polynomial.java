import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Scanner;
import java.util.TreeMap;

class Polynomial {
	
	/*Coefficients, degree and Variable name are the properties of polynomial*/
	//private List<Double> coefficients;
	//private List<Integer> exponents;
	private Map<Integer,Double> map ;
	private String varName;
	
	/*Pass the coefficients and degree to construtor to create the function*/
	public Polynomial(Map<Integer,Double> m) {
		map = m;
		this.varName = "x";
	}
	
	/*All the get Functions*/
	public Map<Integer,Double> getMap(){
		return this.map;
	}
	
	public String getVariableName(){
		return this.varName;
	}
	public int getDegree() {
		return map.size();
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
	public static void main(String[] args) {
		Scanner input = new Scanner(System.in);
	
	}
}