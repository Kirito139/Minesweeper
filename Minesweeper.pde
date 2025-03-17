import de.bezier.guido.*;

public int NUM_ROWS = 4;
public int NUM_COLS = 4;
public int numMines = 1;
private MSButton[][] buttons; // 2d array of minesweeper buttons
private ArrayList <MSButton> mines; // ArrayList of just the minesweeper buttons that are mined
public enum GameState {READY, PLAYING, WON, LOST};
GameState state;

void setup() {
  size(400, 400);
  textAlign(CENTER,CENTER);
  state = GameState.PLAYING;
  mines = new ArrayList<MSButton>();

  // make the manager
  Interactive.make(this);

  buttons = new MSButton[NUM_ROWS][NUM_COLS];
  for (int r = 0; r < NUM_ROWS; r++) {
    for (int c = 0; c < NUM_COLS; c++) {
      buttons[r][c] = new MSButton(r, c);
    }
  }
  for (int i = 0; i < numMines; i++) {
    setMines();
  }
}

public void setMines() {
  int row = (int)(Math.random()*NUM_ROWS);
  int col = (int)(Math.random()*NUM_COLS);
  if (!mines.contains(buttons[row][col])) mines.add(buttons[row][col]);
  // else setMines();
}

public void draw() {
  background(0);
  if (state == GameState.WON) displayWinningMessage();
  else if (state == GameState.LOST) displayLosingMessage();
  else if (state == GameState.PLAYING) {
    for (int r = 0; r < NUM_ROWS; r++) {
      for (int c = 0; c < NUM_COLS; c++) {
        buttons[r][c].draw();
      }
    }
    if (isWon()) state = GameState.WON;
  }
  else if (state == GameState.READY) {
    mines = new ArrayList<MSButton>();
    for (int i = 0; i < numMines; i++) {
      setMines();
    }
  }
}

public boolean isWon() {
  for (MSButton m : mines) if (!m.isFlagged()) return false;
  return true;
}

public void displayLosingMessage() {
  // your code here
}

public void displayWinningMessage() {
  for (MSButton m : mines) fill(0, 255, 0);
  state = GameState.READY;
}

public boolean isValid(int r, int c) {
  if (r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS) return true;
  else return false;
}

public int countMines(int row, int col) {
  int numMines = 0;
  for (int r = row - 1; r <= row + 1; r++) {
    for (int c = col - 1; c <= col + 1; c++) {
      if (isValid(r, c) && mines.contains(buttons[r][c])) numMines++;
    }
  }
  return numMines;
}

public class MSButton {
  private int myRow, myCol;
  private float x, y, width, height;
  private boolean clicked, flagged;
  private String myLabel;

  public MSButton (int row, int col) {
    width = 400 / NUM_COLS;
    height = 400 / NUM_ROWS;
    myRow = row;
    myCol = col; 
    x = myCol * width;
    y = myRow * height;
    myLabel = "";
    flagged = clicked = false;
    Interactive.add(this); // register it with the manager
  }

  // called by manager
  public void mousePressed() {
    if (!flagged) clicked = true;
    if (mouseButton == RIGHT) flagged = !flagged;
    else if (mines.contains(this)) state = GameState.LOST;
    else if (countMines(myRow, myCol) > 0) {
      setLabel(countMines(myRow, myCol));
    } else {
      // recursively call mousePressed with the valid, unclicked,
      // neighboring buttons in all 8 directions
      for (int r = myRow - 1; r <= myRow + 1; r++) {
        for (int c = myCol - 1; c <= myCol + 1; c++) {
          if (isValid(r, c) && !buttons[r][c].clicked)
            buttons[r][c].mousePressed();
        }
      }
    }
  }

  public void draw () {
    if (flagged)
      fill(0);
    else if( clicked && mines.contains(this) ) 
      fill(255,0,0);
    else if (clicked) fill(200);
    else fill(100);

    rect(x, y, width, height);
    fill(0);
    text(myLabel, x + width / 2, y + height / 2);
  }

  public void setLabel(String newLabel) {
    myLabel = newLabel;
  }

  public void setLabel(int newLabel) {
    myLabel = "" + newLabel;
  }

  public boolean isFlagged() {
    return flagged;
  }
}

