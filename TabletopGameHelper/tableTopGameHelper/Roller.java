package tableTopGameHelper;

public class Roller {

	// assumes a d6
	public static int roll() {
		return (int) (Math.random() * 6) + 1;
	}
	public static int roll(int sides) {
		return (int) (Math.random() * sides) + 1;
	}
	public static int roll(int sides, int modifier) {
		return (int) (Math.random() * sides) + modifier;
	}
	
	// takes an array of sides and returns the total
	// ex1 2d10, 1d6+3 should be entered as [10, 10, 6], 3
	// ex2 3d4+1, 2d6+3 should be entered as [4, 4, 4,, 6, 6], 4
	public static int roll(int[] sides) {
		int total = 0;
		for (int i = 0; i<sides.length; i++) {
			total+=roll(sides[i]);
		}
		return total;
	}
	
	public static int roll(int[] sides, int modifier) {
		int total = modifier;
		for (int i = 0; i<sides.length; i++) {
			total+=roll(sides[i]);
		}
		return total;
	}
	
	// assumes advantage
	public static int advantage() {
		int roll1 = roll(20);
		int roll2 = roll(20);

		return (roll1 > roll2) ? roll1 : roll2;
	}
	// send true if advantage false if with disadvantage
	public static int advantage(boolean with) {
		int roll1 = roll(20);
		int roll2 = roll(20);
		
		if(with) {
			return (roll1 > roll2) ? roll1 : roll2;
		} else {
			return (roll1 < roll2) ? roll1 : roll2;

		}
	}
	
	
}
