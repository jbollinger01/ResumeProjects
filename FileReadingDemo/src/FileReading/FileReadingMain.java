package FileReading;

import java.io.IOException;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;
import javax.swing.JLabel;
import javax.swing.JButton;
import javax.swing.JList;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import javax.swing.GroupLayout;
import javax.swing.GroupLayout.Alignment;
import javax.swing.SwingConstants;


public class FileReadingMain extends JPanel {
	
	static String countryFile = "CountryInfo/countries.txt";
	static String incomeFile = "CountryInfo/incomes.txt";
	static String internetPercentFile = "CountryInfo/internetpercent.txt";
	static String populationsFile = "CountryInfo/populations.txt";
	static String unemploymentFile = "CountryInfo/unemployment.txt";
	ProjectManager pm = new ProjectManager(countryFile, incomeFile, internetPercentFile, populationsFile, unemploymentFile);
	
	
	private static final long serialVersionUID = 1L; 
	
	static String[] countries;


	public FileReadingMain() throws IOException {
		
        try {
            countries = FileBuilder.toStringArray(countryFile);
            System.out.println("Loaded " + countries.length + " countries.");
        } catch (IOException e) {
            e.printStackTrace();
            countries = new String[0]; // fallback to empty list
        }
		
        JLabel countryLabel = new JLabel("Country");
        countryLabel.setHorizontalAlignment(SwingConstants.CENTER);
        countryLabel.setBounds(80, 20, 60, 20);
        
        JLabel populationLabel = new JLabel("Population");
        populationLabel.setBounds(30, 80, 130, 20);
        
        JLabel populationAmntLabel = new JLabel("000000");
        populationAmntLabel.setBounds(30, 100, 100, 16);
        
        JLabel incomeLabel = new JLabel("Income");
        incomeLabel.setBounds(30, 130, 130, 20);
        
        JLabel incomeTypeLabel = new JLabel("000000");
        incomeTypeLabel.setBounds(30, 150, 160, 16);
        
        JLabel unemploymentLabel = new JLabel("Percent Unemployed");
        unemploymentLabel.setBounds(30, 180, 130, 20);
        
        JLabel unemploymentAmntLabel = new JLabel("000000");
        unemploymentAmntLabel.setBounds(30, 200, 100, 20);
        
        JLabel internetPercentLabel = new JLabel("Percent with Internet");
        internetPercentLabel.setBounds(30, 230, 130, 20);
        
        JLabel internetPercentAmntLabel = new JLabel("000000");
        internetPercentAmntLabel.setBounds(30, 250, 100, 20);
        
		
		JComboBox<String> comboBox = new JComboBox<>(countries);
		comboBox.setBounds(10, 40, 210, 30);
		comboBox.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				populationAmntLabel.setText(String.valueOf(pm.getPopulation(comboBox.getSelectedIndex())));
				incomeTypeLabel.setText(pm.getIncome(comboBox.getSelectedIndex()));
				unemploymentAmntLabel.setText(String.valueOf(pm.getUnemployment(comboBox.getSelectedIndex())) + "%");
				internetPercentAmntLabel.setText(String.valueOf(pm.getInternetPercent(comboBox.getSelectedIndex())) + "%");
			}
		});
		setLayout(null);
		add(countryLabel);
		add(populationLabel);
		add(populationAmntLabel);
		add(incomeLabel);
		add(incomeTypeLabel);
		add(unemploymentLabel);
		add(unemploymentAmntLabel);
		add(internetPercentLabel);
		add(internetPercentAmntLabel);
		add(comboBox);
		
		comboBox.setSelectedIndex(204);
		populationAmntLabel.setText(String.valueOf(pm.getPopulation(204)));
		incomeTypeLabel.setText("test");
		unemploymentAmntLabel.setText(String.valueOf(pm.getUnemployment(204)) + "%");
		internetPercentAmntLabel.setText(String.valueOf(pm.getInternetPercent(204)) + "%");
		
	
	} // end of the swing setup class


	public static void main(String[] args) throws IOException{
		System.out.println("Hello, World from File Reading Swing Demo Main!");
		countries = FileBuilder.toStringArray(countryFile);
		
		SwingUtilities.invokeLater(() -> {
	        try {
	            JFrame frame = new JFrame("File Reading Demo");
	            frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	            frame.setResizable(false);

	            FileReadingMain panel = new FileReadingMain();
	            frame.setContentPane(panel);

	            frame.setSize(230, 320);  
	            frame.setLocationRelativeTo(null); // center on screen
	            frame.setVisible(true);
	            
	            


	        } catch (Exception e) {
	            e.printStackTrace();
	        } // end try catch
		}); // end lambda
		
	} // end of the main
} // end of the class
