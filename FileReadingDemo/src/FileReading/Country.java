package FileReading;

public class Country {

	private String name;
	private String income;
	private double internetPercent;
	private int population;
	private double unemployment;
	
	
	public Country(String name, String income, double internetPercent, int population, double unemployment) {
		this.name = name;
		this.income = income;
		this.internetPercent = internetPercent;
		this.population = population;
		this.unemployment = unemployment;
	}
	
	@Override
	public String toString() {
		return name + 
				"\npop: " + population + 
				"\nincome: " + income + 
				"\nunemployment: " + unemployment + "%" +
				"\nPercent with internet: " + internetPercent + "%";
	}
	
	public String getName() {
		return name;
	}
	public String getIncome() {
		return income;
	}
	public double getInternetPercent() {
		return internetPercent;
	}
	public int getPopulation() {
		return population;
	}
	public double getUnemployment() {
		return unemployment;
	}
	
}
