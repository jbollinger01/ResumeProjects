package FileReading;
// TODO
/*
 * remove the unused methods
 * clean and document
 * make sure there's nothing unused
 * */

// takes the file data uses and makes an Array of Country objects.
/*
 * These methods are all calling the toString(int x) method 
 * which is currently set to System.out the desired result.
 * 
 * */



import java.io.IOException; 
import java.util.ArrayList;

public class ProjectManager {

	private Country[] countryData;
	private String[] namesData;
	
	public ProjectManager(String countryFile, String incomeFile, String internetPercentageFile, String populationFile, String unemploymentFile)  throws IOException {
		countryData = createCountry(countryFile, incomeFile, internetPercentageFile, populationFile, unemploymentFile);
		this.namesData = FileBuilder.toStringArray(countryFile);
	}
	
	public Country[] createCountry(String countryFile, String incomeFile, String internetPercentageFile, String populationFile, String unemploymentFile)  throws IOException {
		
		String[] namesData = FileBuilder.toStringArray(countryFile);
		String[] incomeData = FileBuilder.toStringArray(incomeFile);
		int[] populationData = FileBuilder.toIntArray(populationFile);
		double[] internetData = FileBuilder.toDoubleArray(internetPercentageFile);
		double[] unemploymentData = FileBuilder.toDoubleArray(unemploymentFile);
		
		Country[] tempCountry = new Country[namesData.length];
		
		for(int i = 0; i<tempCountry.length; i++) {
			tempCountry[i] = new Country(namesData[i], incomeData[i], internetData[i], populationData[i], unemploymentData[i]); 
		}
	
		return tempCountry;
	}

	// this was cool, but there's a built in method that is used instead... 
	public int findCountryIndex(String target) {

	    int low = 0;
	    int high = namesData.length - 1;

	    while (low <= high) {
	        int mid = low + (high - low) / 2;  // avoids overflow

	        int cmp = namesData[mid].compareTo(target); // or compareToIgnoreCase

	        if (cmp < 0) {
	            // mid element is "less than" key -> search right half
	            low = mid + 1;
	        } else if (cmp > 0) {
	            // mid element is "greater than" key -> search left half
	            high = mid - 1;
	        } else {
	            // found exact match
	            return mid;
	        }
	    }

	    return -1;

	}
	
	public void printCountryInfo(int index) {
		
		// TODO should this control the updating of the labels???
		
		System.out.println(countryData[index].getName());
		System.out.println(countryData[index].getIncome());
		System.out.println(countryData[index].getInternetPercent());
		System.out.println(countryData[index].getPopulation());
		System.out.println(countryData[index].getUnemployment());
		
	}
	
	
	
	
	public void getCountryInfo(String name) {
		for(int i = 0; i<countryData.length; i++) {
			if(countryData[i].getName().equals(name)) {
				toString(i);
				break;
			}
		}
	}
	
	
	// TODO Test me!
	public int getIncomeTypeCount(String type) {
		int counter = 0;
		for (int i = 0; i<countryData.length; i++) {
			if(countryData[i].getIncome().equals(type)) {
				counter++;
			}
		}
		
		return counter;
	}
	
	// TODO Test Me!
	public ArrayList<String> getIncomeTypeName(String type){
		ArrayList<String> names = new ArrayList<String>();
		for (int i = 0; i<countryData.length; i++) {
			if(countryData[i].getIncome().equals(type)) {
				names.add(countryData[i].getName());
			}
		}
		
		return names; 
	}
	
	public void getLowestInternetPercentage() {
		double temp = countryData[0].getInternetPercent();
		int currentChoice = 0;
		for(int i = 0; i<countryData.length; i++) {
			if(countryData[i].getInternetPercent() < temp) {
				temp = countryData[i].getInternetPercent();
				currentChoice = i;
			}
		}
		toString(currentChoice);
		
	}
	
	public void getHighestInternetPercentage() {
		double temp = countryData[0].getInternetPercent();
		int currentChoice = 0;
		for(int i = 0; i<countryData.length; i++) {
			if(countryData[i].getInternetPercent() > temp) {
				temp = countryData[i].getInternetPercent();
				currentChoice = i;
			}
		}
		toString(currentChoice);
	}
	
	public void getLowestPopulation() {
		int temp = countryData[0].getPopulation();
		int currentChoice = 0;
		for(int i = 0; i<countryData.length; i++) {
			if(countryData[i].getPopulation() < temp) {
				temp = countryData[i].getPopulation();
				currentChoice = i;
			}
		}
		toString(currentChoice);
	}
	
	public void getHighestPopulation() {
		int temp = countryData[0].getPopulation();
		int currentChoice = 0;
		for(int i = 0; i<countryData.length; i++) {
			if(countryData[i].getPopulation() > temp) {
				temp = countryData[i].getPopulation();
				currentChoice = i;
			}
		}
		toString(currentChoice);
	}

	public void getLowestUnemployment() {
		double temp = countryData[0].getUnemployment();
		int currentChoice = 0;
		for(int i = 0; i<countryData.length; i++) {
			if(countryData[i].getUnemployment() < temp) {
				temp = countryData[i].getUnemployment();
				currentChoice = i;
			}
		}
		toString(currentChoice);
	}
	
	public void getHighestUnemployment() {
		double temp = countryData[0].getUnemployment();
		int currentChoice = 0;
		for(int i = 0; i<countryData.length; i++) {
			if(countryData[i].getUnemployment() > temp) {
				temp = countryData[i].getUnemployment();
				currentChoice = i;
			}
		}
		toString(currentChoice);
	}
	
	public  void toString(int selection) {
		System.out.println(countryData[selection]);
	}

	public int getPopulation(int index) {
		return countryData[index].getPopulation();
	}
	public String getIncome(int index) {
		return countryData[index].getIncome();
	}
	public double getInternetPercent(int index) {
		return countryData[index].getInternetPercent();
	}

	public double getUnemployment(int index) {
		return countryData[index].getUnemployment();
	}
	
}
