package yatzee;

/*
 * 
 * TODO
 * - in player button
 * -- create player object
 * 
 * */


import javax.swing.*;
import java.awt.*;

import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;

public class YatzeeMain extends JFrame {

	private static final long serialVersionUID = 1L;
	private JPanel contentPane;
	private JTextField txtEnterPlayerName;



	
	
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					YatzeeMain frame = new YatzeeMain();
					frame.setVisible(true);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}

	/**
	 * Create the frame.
	 */
	public YatzeeMain() {
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(100, 100, 450, 300);
		contentPane = new JPanel();

		setContentPane(contentPane);
		contentPane.setLayout(null);
		
		JPanel topPanel = new JPanel();
		topPanel.setBounds(5, 5, 440, 53);
		FlowLayout flowLayout = (FlowLayout) topPanel.getLayout();
		flowLayout.setHgap(40);
		contentPane.add(topPanel);
		
		JLabel titleLabel = new JLabel("Yatzee");
		titleLabel.setFont(new Font("Lucida Grande", Font.PLAIN, 36));
		titleLabel.setHorizontalAlignment(SwingConstants.LEFT);
		topPanel.add(titleLabel);
		
		JPanel centerPanel = new JPanel();
		centerPanel.setBounds(15, 58, 430, 209);
		contentPane.add(centerPanel);
		centerPanel.setLayout(null);
		
		txtEnterPlayerName = new JTextField();
		txtEnterPlayerName.setHorizontalAlignment(SwingConstants.LEFT);
		txtEnterPlayerName.setText("Enter Player Name");
		txtEnterPlayerName.setBounds(54, 6, 332, 49);
		centerPanel.add(txtEnterPlayerName);
		txtEnterPlayerName.setColumns(10);
		
		JButton createPlayerButton = new JButton("Add Player");
		createPlayerButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				
				// TODO add player Object
				
			}
		});
		createPlayerButton.setBounds(242, 160, 182, 43);
		centerPanel.add(createPlayerButton);
	}

}
