package FileReading;

/*
 * 
 * I made this to help processing .txt files.
 * 
 * it takes a .txt file of info and converts it into an array of values
 * int[], double[], String[]
 * 
 * Counts number of lines in a file.
 * 
 * */


import java.io.File;
import java.io.IOException;
import java.util.Scanner;


public class FileBuilder {

	// convert a file of numbers into a int[];
    public static int[] toIntArray(String fileName) throws IOException {
        File file = new File(fileName);
        
        // Pass 1: count how many numbers
        // used to determine the size of the list.
        int count = countValues(fileName);

        // Pass 2: actually read and store numbers
        int[] numbers = new int[count]; // create a new list
        Scanner reader = new Scanner(file);
        int index = 0; // required to load the temp list
        while (reader.hasNextInt()) {
            numbers[index] = reader.nextInt();
            index++;
        }
        reader.close();

        return numbers;
    }
    
	// convert a file of numbers into a double[];
    public static double[] toDoubleArray(String fileName) throws IOException {
        File file = new File(fileName);
        
        
        // Pass 1: count how many numbers
        // used to determine the size of the list.
        int count = countValues(fileName);

        // Pass 2: actually read and store numbers
        double[] numbers = new double[count]; // create a new list
        Scanner reader = new Scanner(file);
        int index = 0; // required to load the temp list
        while (reader.hasNextDouble()) {
            numbers[index] = reader.nextDouble();
            index++;
        }
        reader.close();

        return numbers;
    }
    
	// convert a file of numbers into a double[];
    public static String[] toStringArray(String fileName) throws IOException {
        File file = new File(fileName);
        
        
        // Pass 1: count how many numbers
        // used to determine the size of the list.
        int count = countValues(fileName);

        // Pass 2: actually read and store lines of text
        String[] lines = new String[count]; // create a new list
        Scanner reader = new Scanner(file);
        int index = 0; // required to load the temp list
        while (reader.hasNext()) {
            lines[index] = reader.nextLine();
            index++;
        }
        reader.close();

        return lines;
    }
    
	// count the number of lines in a text file.
	public static int countValues(String fileName) throws IOException {   
	    // file and scanner objects  
		File file = new File(fileName);
		Scanner scanner = new Scanner(file);
		    
		int counter = 0;
		while(scanner.hasNext()){
		  scanner.nextLine();
		  counter++;
		}
		scanner.close();
		return counter;
	}

}
