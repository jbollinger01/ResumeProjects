package tableTopGameHelper;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;
import javax.swing.JLabel;
import java.awt.BorderLayout;
import javax.swing.JButton;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import javax.swing.SwingConstants;
import java.awt.GridLayout;
import java.awt.Component;
import java.awt.Font;


public class MagicCounter extends JFrame {

	private static final long serialVersionUID = 1L;
	private JPanel contentPane;

	private int lifeTotal;
	
	public MagicCounter(String name, boolean commander) {

		lifeTotal = commander ? 40 : 20;
		
        setTitle(name);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);

        
		setBounds(100, 100, 280, 240);
		contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));

		setContentPane(contentPane);
		contentPane.setLayout(new BorderLayout(0, 0));
		
		JPanel panel = new JPanel();
		contentPane.add(panel, BorderLayout.NORTH);

		JLabel playerNameLabel = new JLabel(name);
		panel.add(playerNameLabel);

		JLabel playerLifeTotalLabel = new JLabel(String.valueOf(lifeTotal));
		playerLifeTotalLabel.setFont(new Font("Lucida Grande", Font.PLAIN, 36));
		playerLifeTotalLabel.setHorizontalAlignment(SwingConstants.CENTER);
		contentPane.add(playerLifeTotalLabel, BorderLayout.CENTER);
		
		JButton resetPlayerLifetotalButton = new JButton("Reset");
		panel.add(resetPlayerLifetotalButton);
		resetPlayerLifetotalButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				lifeTotal = commander ? 40 : 20;
				playerLifeTotalLabel.setText(String.valueOf(lifeTotal));			}
		});
		
		JPanel panel_1 = new JPanel();
		contentPane.add(panel_1, BorderLayout.WEST);
		
		JButton decrementLifeByOneButton = new JButton("-1");
		decrementLifeByOneButton.setAlignmentY(Component.TOP_ALIGNMENT);
		decrementLifeByOneButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				lifeTotal--;
				playerLifeTotalLabel.setText(String.valueOf(lifeTotal));
			}
		});
		
		JButton decrementLifeByFiveNewButton = new JButton("-5");
		decrementLifeByFiveNewButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				lifeTotal-=5;
				playerLifeTotalLabel.setText(String.valueOf(lifeTotal));			}
		});
		panel_1.setLayout(new GridLayout(0, 1, 0, 0));
		panel_1.add(decrementLifeByOneButton);
		panel_1.add(decrementLifeByFiveNewButton);
		
		JPanel panel_2 = new JPanel();
		contentPane.add(panel_2, BorderLayout.EAST);
		panel_2.setLayout(new GridLayout(0, 1, 0, 0));
		
		JButton incrementLifeByOneButton = new JButton("+1");
		incrementLifeByOneButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				lifeTotal++;
				playerLifeTotalLabel.setText(String.valueOf(lifeTotal));			}
		});
		panel_2.add(incrementLifeByOneButton);
		
		JButton incrementLifeByFiveNewButton = new JButton("+5");
		incrementLifeByFiveNewButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				lifeTotal+=5;
				playerLifeTotalLabel.setText(String.valueOf(lifeTotal));			}
		});
		panel_2.add(incrementLifeByFiveNewButton);
		
		JButton toolsButton = new JButton("Tools");
		toolsButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				MagicTools m = new MagicTools(name);
            	m.setVisible(true);
				
			}
		});
		contentPane.add(toolsButton, BorderLayout.SOUTH);
	}
	
}
