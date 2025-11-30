package tableTopGameHelper;

import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import javax.swing.GroupLayout.Alignment;
import javax.swing.LayoutStyle.ComponentPlacement;

public class TableTopGameHelperMain extends JFrame {

    private static final long serialVersionUID = 1L;
    private JTextField playerNameTextField;

	public TableTopGameHelperMain() {
        setTitle("M:TG Player Maker");
        setSize(435, 150);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null); // Center the window
        
        playerNameTextField = new JTextField();
        playerNameTextField.setColumns(10);

        JButton createPlayerButton = new JButton("Create Player");
        JCheckBox commanderCheckBox = new JCheckBox("Commander");
        
        
        createPlayerButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                
            	MagicCounter m = new MagicCounter(playerNameTextField.getText(), commanderCheckBox.isSelected());
            	m.setVisible(true);

            }
        });
        
        commanderCheckBox.addActionListener(new ActionListener() {
        	public void actionPerformed(ActionEvent e) {
        		if(commanderCheckBox.isSelected()) {
        			createPlayerButton.setText("Create Commander");
        		}else {
        			createPlayerButton.setText("Create Player");
        		}
        	}
        });
        
        
        JPanel panel = new JPanel();
        getContentPane().add(panel);
        
        
        GroupLayout gl_panel = new GroupLayout(panel);
        gl_panel.setHorizontalGroup(
        	gl_panel.createParallelGroup(Alignment.LEADING)
        		.addGroup(gl_panel.createSequentialGroup()
        			.addContainerGap()
        			.addGroup(gl_panel.createParallelGroup(Alignment.LEADING)
        				.addGroup(gl_panel.createSequentialGroup()
        					.addComponent(playerNameTextField, GroupLayout.PREFERRED_SIZE, 230, GroupLayout.PREFERRED_SIZE)
        					.addGap(18)
        					.addComponent(createPlayerButton))
        				.addComponent(commanderCheckBox))
        			.addContainerGap(21, Short.MAX_VALUE))
        );
        gl_panel.setVerticalGroup(
        	gl_panel.createParallelGroup(Alignment.LEADING)
        		.addGroup(gl_panel.createSequentialGroup()
        			.addContainerGap()
        			.addGroup(gl_panel.createParallelGroup(Alignment.BASELINE)
        				.addComponent(playerNameTextField, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
        				.addComponent(createPlayerButton))
        			.addPreferredGap(ComponentPlacement.RELATED)
        			.addComponent(commanderCheckBox)
        			.addContainerGap(218, Short.MAX_VALUE))
        );
        panel.setLayout(gl_panel);
    }

    public static void main(String[] args) {
        // Ensure Swing operations are performed on the Event Dispatch Thread
        SwingUtilities.invokeLater(() -> {
        	TableTopGameHelperMain mainWindow = new TableTopGameHelperMain();
            mainWindow.setVisible(true);
        
        });
        
        
    }
}

class NewWindow extends JFrame {

    private static final long serialVersionUID = 1L;

	public NewWindow() {
        setTitle("New Window");
        setSize(300, 200);
        // Set a different default close operation if desired, e.g., DISPOSE_ON_CLOSE
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE); 
        setLocationRelativeTo(null); // Center the window

        JLabel label = new JLabel("This is a new window!");
        JPanel panel = new JPanel();
        panel.add(label);
        add(panel);
    }
}
