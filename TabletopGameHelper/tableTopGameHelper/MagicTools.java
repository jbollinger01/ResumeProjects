package tableTopGameHelper;


import javax.swing.*;
import java.awt.*;
import java.util.Enumeration;

import javax.swing.border.EmptyBorder;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;

public class MagicTools extends JFrame {

	private static final long serialVersionUID = 1L;
	private JPanel contentPane;


	public MagicTools(String name) {
		
		setTitle(name + " Tools");
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
		
		setBounds(100, 100, 378, 274);
		contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));

		setContentPane(contentPane);
		contentPane.setLayout(new BorderLayout(0, 0));
		
		JPanel panelSouth = new JPanel();
		contentPane.add(panelSouth, BorderLayout.SOUTH);
		panelSouth.setLayout(new GridLayout(2, 2, 0, 0));
		
		JPanel panelSouthTop = new JPanel();
		FlowLayout flowLayout = (FlowLayout) panelSouthTop.getLayout();
		flowLayout.setHgap(0);
		panelSouth.add(panelSouthTop);
		
		JLabel sumOfResultsLabel = new JLabel("0 0 0 0 0");
		JLabel everyResultLabel = new JLabel("");
		
		ButtonGroup diceSelector = new ButtonGroup();

		JRadioButton d4Selector = new JRadioButton("d4");
		diceSelector.add(d4Selector);
		panelSouthTop.add(d4Selector);

		JRadioButton d6Selector = new JRadioButton("d6");
		diceSelector.add(d6Selector);
		panelSouthTop.add(d6Selector);

		JRadioButton d8Selector = new JRadioButton("d8");
		diceSelector.add(d8Selector);
		panelSouthTop.add(d8Selector);

		JRadioButton d10Selector = new JRadioButton("d10");
		diceSelector.add(d10Selector);
		panelSouthTop.add(d10Selector);

		JRadioButton d12Selector = new JRadioButton("d12");
		diceSelector.add(d12Selector);
		panelSouthTop.add(d12Selector);

		JRadioButton d20Selector = new JRadioButton("d20");
		d20Selector.setSelected(true);
		diceSelector.add(d20Selector);
		panelSouthTop.add(d20Selector);

		// --------------------------
		
		JPanel panelSouthBottom = new JPanel();
		panelSouth.add(panelSouthBottom);
		panelSouthBottom.setLayout(new GridLayout(0, 3, 0, 0));
		
		Integer[] values = {1,2,3,4,5,6};
		JComboBox<Integer> comboBox = new JComboBox<>(values) ;
		panelSouthBottom.add(comboBox);
		
		JButton btnNewButton = new JButton("Roll");
		panelSouthBottom.add(btnNewButton);
		btnNewButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				int[] rolls = getValuesRolled(comboBox.getSelectedIndex()+1, getSelectedButton(diceSelector));
				sumOfResultsLabel.setText(String.valueOf(getSumOfValuesRolled(rolls)));
				everyResultLabel.setText(getStringOfValuesRolled(rolls));
				
			}
		});
		
		JButton coinFlipButton = new JButton("Flip Coin");
		panelSouthBottom.add(coinFlipButton);
		coinFlipButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				int flip = (int) (Math.random() * 2) + 1;
				
				if(flip == 1) {
					sumOfResultsLabel.setText("Heads");
				} else {
					sumOfResultsLabel.setText("Tails");

				}
				everyResultLabel.setText("");
			}
		});
		
		JPanel panel = new JPanel();
		contentPane.add(panel, BorderLayout.CENTER);
		panel.setLayout(new GridLayout(0, 1, 0, 0));
		
		

		sumOfResultsLabel.setFont(new Font("Lucida Grande", Font.PLAIN, 36));
		sumOfResultsLabel.setHorizontalAlignment(SwingConstants.CENTER);
		panel.add(sumOfResultsLabel);
		
		everyResultLabel.setVerticalAlignment(SwingConstants.BOTTOM);
		everyResultLabel.setHorizontalAlignment(SwingConstants.RIGHT);
		
		panel.add(everyResultLabel);
	}
	
	
	private int getSumOfValuesRolled(int[] values) {
		int sum = 0;
		for (int i = 0; i<values.length; i++) {
			sum+=values[i];
		}
		return sum;
	}
	
	private String getStringOfValuesRolled(int[] values) {
		String temp = "";
		for (int i = 0; i<values.length-1; i++) {
			temp+=values[i] + " , ";
		}
		temp+=values[values.length-1];
		return temp;
	}
	
	private int[] getValuesRolled(int numRolls, int dice) {
		int[] temp = new int[numRolls];
		for(int i = 0; i<temp.length; i++) {
			temp[i] = (int) (Math.random() * dice) + 1;
		}
		return temp;
	}
	
	
	private int getSelectedButton(ButtonGroup diceSelector) {
		
		Enumeration<AbstractButton> buttons = diceSelector.getElements();
		while (buttons.hasMoreElements()) {
			AbstractButton button = buttons.nextElement();
			if(button.isSelected()) {
				if(button.getText() == "coin") {
					return 2;
				}
				
				String name = button.getText();
				name = name.replaceAll("[^0-9]", "");
				return Integer.parseInt(name);
			}
		}
		return 0;

	}

}
