package tableTopGameHelper;

public class Player {

	private String name;
	private int score;
	
	
	private static int players = 0;
	
	
	public Player(String name, int score) {
		this.name = name;
		this.score = score;
		players++;
	}
	
	
	public String getName() {
		return name;
	}
	public int getScore() {
		return score;
	}
	
	public int getPlayers() {
		return players;
	}
	
	public void setName(String name) {
		this.name = name;
	}
	public void setScore(int score) {
		this.score = score;
	}
	public void incrementScore(int amnt) {
		this.score+=amnt;
	}
	
}
