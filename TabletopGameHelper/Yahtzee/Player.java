package yatzee;

// back end is ready for player testing.


/*
 * =======================================
 * Scoring Rules
 * =======================================
 * 
 * upper section
 * for roll counts, just count the number
 *  -if player chooses aces only count aces and no other number
 *  -if upper section total score >=63 add 35 to score
 *  
 * lower section
 * -3 or 4 of a kind, add all dice
 * -full house +25
 * -sm straight +30
 * -lg straight +40
 * -yahtzee + 50 (first only) +100 all additional
 * 
 * grand total = lower score + upper score
 * 
 * */

public class Player {
	
	private int[] rolls = {0,0,0,0,0};
	private String name;
	
	// aces, 2, 3, 4, 5, 6
	private int[] upperSection = {0,0,0,0,0,0};
	
	// 3 kind, 4 kind, full, sm st, lg st, yahtzee, chance
	private int[] lowerSection = {0,0,0,0,0,0,0};
	
	private int yahtzeeCounter = 0;

	
	
	public Player(String name) {
		this.name = name;
	}
	
	/*
	 * =======================================
	 * Roll && sorting methods
	 * =======================================
	 * */
	
	public void roll() {
		for (int i = 0; i<rolls.length; i++) {
			rolls[i] = (int) (Math.random() * 6) + 1;
		}
	}
	
	// sort the rolls array.
	public void sortRolls() {
		int i = 1;
		int j, temp;
		while (i < rolls.length) {
			j = i;
			while (j > 0 && rolls[j-1] > rolls[j]) {
				temp = rolls[j];
				rolls[j] = rolls[j-1];
				rolls[j-1] = temp;
		        j--;
			}
			i++;
		}
	}
	
	// assumes the rolls have been sorted first
	public void reverseSortRolls() {
		int temp;
		int counter = 0;
		while(counter<rolls.length/2) {
			temp = rolls[counter];
			rolls[counter] = rolls[rolls.length-1-counter];
			rolls[rolls.length-1-counter] = temp;
			counter++;
		}
	}
	
	/*
	 * =======================================
	 * Scoring methods
	 * =======================================
	 * */
	

	public int calcScore() {
		return scoreUpper() + scoreLower();
	}
	
	public int scoreUpper() {
		int total = 0;
		
		for (int i = 0; i<upperSection.length; i++) {
			total+=upperSection[i];
		}
		
		if(total>63) {
			return total + 35;
		}else {
			return total;
		}
	}

	public int scoreLower() {
		int total = 0; 
		for (int i = 0; i<lowerSection.length; i++) {
			total+=lowerSection[i];
		}
		return total;
	}
	
	public void scoreSingleNumber(int number) {
		int total = 0;
		for(int i = 0; i<rolls.length; i++) {
			if(rolls[i] == number) {
				total+=number;
			}
		}
		upperSection[number-1]=total;
	}

	// this is used with 3 or 4 of a kind and chance
	public int addAllDice() {
		int sum = 0;
		for (int i = 0; i<rolls.length; i++) {
			sum+=rolls[i];
		}
		return sum;
	}

	public void scoreLowerRoll() {
		if(is3ofAKind()){
			lowerSection[0] = addAllDice();
		} else if(is4ofAKind()) {
			lowerSection[1] = addAllDice();
		} else if(isFullHouse()) {
			lowerSection[2] = 25;
		}else if(isSmallStraight()) {
			lowerSection[3] = 30;
		}else if(isLargeStraight()) {
			lowerSection[4] = 40;
		}else if(checkForYahtzee()) {
			lowerSection[5] = 50 + ((yahtzeeCounter-1)*100); // first yahtzee is 50.
		}
	}

	/*
	 * =======================================
	 * Checking methods
	 * =======================================
	 * */
	
	// check if 3 of a kind
	public boolean is3ofAKind() {
		int dice = 1;
		int counter = 0;
		
		while(dice<7) {
			for(int num : rolls) {
				if(dice == num) {
					counter++;
				}
			}
			if(counter >= 3) {
				return true;
			}else {
				counter = 0;
				dice++;
			}
		}
		
		return false;
	}
	
	// check if 4 of a kind
	public boolean is4ofAKind() {
		int dice = 1;
		int counter = 0;
		
		while(dice<7) {
			for(int num : rolls) {
				if(dice == num) {
					counter++;
				}
			}
			if(counter >= 4) {
				return true;
			}else {
				counter = 0;
				dice++;
			}
		}
		
		return false;
	}
	
	// check if full house
	public boolean isFullHouse() {
		sortRolls();
		// 3:2 split
		if(rolls[0] == rolls[1] && rolls[0] == rolls[2]) {
			if(rolls[3] == rolls[4]) {
				return true;
			}
		// 2:3 split
		}else if(rolls[0] == rolls[1]) {
			if(rolls[2] == rolls[3] && rolls[2] ==  rolls[4]) {
				return true;
			}
		}
		return false;
	}
	
	// check if small straight
	// this algorithm also works with gap rolls such as 
	// 1, 2, 3, 3, 4 returns true
	public boolean isSmallStraight() {
		sortRolls();
		int success = 0;
		
	    for (int i = 0; i < rolls.length - 1; i++) {
	        if (rolls[i] == rolls[i+1]) {
	            // Duplicate – neither helps nor hurts the straight; skip it
	            continue;
	        } else if (rolls[i] + 1 == rolls[i+1]) {
	            // Found the next number in sequence
	            success++;
	            if (success == 3) {
	                return true;    // four in a row found
	            }
	        } else {
	            // Gap of 2+ → break in the straight
	            success = 0;
	        }
	    }

		return false;
	}
	

	// check if large straight
	public boolean isLargeStraight() {
		sortRolls();
		int success = 0;		
		
		for (int i = 0; i < rolls.length - 1; i++) {
			if (rolls[i] == rolls[i+1]) {
	            return false;
			} 
			if (rolls[i] + 1 == rolls[i+1]) {
			    // Found the next number in sequence
				success++;
				if (success == 4) {
					return true;    // four in a row found
				}
			} else {
			    // Gap of 2+ → break in the straight
			success = 0;
			}
		}
		
		return false;
				
	}
	
	public boolean checkForYahtzee() {
		for (int i = 0; i<rolls.length-1; i++) {
			if(rolls[i] != rolls[i+1]) {
				return false;
			}
		}
		yahtzeeCounter++;
		return true;
	}
	
	
	/*
	 * =======================================
	 * getters and setters
	 * =======================================
	 * */
	
	public String getName() {
		return name;
	}

	public int getYahtzeeCounter() {
		return yahtzeeCounter;
	}
	
	public int[] getRolls() {
		return rolls;
	}
	
	
	
	/*
	 * =======================================
	 * Testing 
	 * =======================================
	 * */
	
	// TODO: Delete after testing
	// testing only
	public void printRolls() {
		String temp = "";
		
		for (int i = 0; i<rolls.length; i++) {
			temp+=rolls[i] + " | ";
		}
		
		System.out.println(temp);
	}
	
	// TODO: Delete after testing:
	// testing only
	public void setRolls(int[] rolls) {
		this.rolls = rolls;
	}
	
	public void setUpperSection(int[] upperSection) {
		this.upperSection = upperSection;
	}
	
	// TODO: Delete after testing:
	// testing only
	public void test() {
		sortRolls();
		printRolls();
		System.out.println("\n3 of a kind: " + is3ofAKind());
		System.out.println("4 of a kind: " + is4ofAKind());
		System.out.println("Yahtzee: " + checkForYahtzee());
		System.out.println("isFullHouse: " + isFullHouse());
		System.out.println("isSmallStraight: " + isSmallStraight());
		System.out.println("isLargeStraight: " + isLargeStraight());
		
		
	}
	
	/*
	 * =======================================
	 * END OF TESTING 
	 * =======================================
	 * */
	
	
} // end of class
