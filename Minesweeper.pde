// TODO: fix text display
import de.bezier.guido.*;

public int NUM_ROWS = 9;
public int NUM_COLS = 9;
public int NUM_MINES = 10;
public int cursorX, cursorY;
private MSButton[][] buttons; // 2d array of minesweeper buttons
private ArrayList<MSButton> mines; // ArrayList of just the minesweeper buttons that are mined
public enum GameState {READY, PLAYING, WON, LOST};
GameState state;


void setup() {
  size(400, 400);
  textAlign(CENTER, CENTER);
  cursorX = cursorY = 0;
  state = GameState.PLAYING;
  mines = new ArrayList<MSButton>();
  buttons = new MSButton[NUM_ROWS][NUM_COLS];

  // make the manager
  Interactive.make(this);

  // Initialize buttons
  for (int r = 0; r < NUM_ROWS; r++) {
    for (int c = 0; c < NUM_COLS; c++) {
      buttons[r][c] = new MSButton(r, c);
    }
  }

  // Initialize mines
  for (int i = 0; i < NUM_MINES; i++) {
    setMines();
  }
}


public void setMines() {
  int row = (int)(Math.random()*NUM_ROWS);
  int col = (int)(Math.random()*NUM_COLS);

  // If the button at [row][col] isn't already mined, mine it. Else try again.
  if (!mines.contains(buttons[row][col])) {
    mines.add(buttons[row][col]);
  } else {
    setMines();
  }
}


public void draw() {
  background(0);

  if (isWon()) { // if won, change state to WON
    state = GameState.WON;
  }

  if (state == GameState.PLAYING) { // if playing, update buttons
    for (int r = 0; r < NUM_ROWS; r++) {
      for (int c = 0; c < NUM_COLS; c++) {
        buttons[r][c].draw();
      }
    }
  }

  if (state == GameState.WON) { // if WON, display winning message
    displayWinningMessage();
  }

  if (state == GameState.LOST) { // if lost, display losing message
    displayLosingMessage();
  }

  if (state == GameState.PLAYING) {
    fill(#00ffff);
    rect(cursorX * 400 / NUM_COLS, cursorY * 400 / NUM_ROWS, 400 / NUM_COLS, 400 / NUM_ROWS);
  }

  // if (state == GameState.READY) { // if ready, reset the game
  //   mines = new ArrayList<MSButton>();

  //   for (int r = 0; r < NUM_ROWS; r++) {
  //     for (int c = 0; c < NUM_COLS; c++) {
  //       buttons[r][c].clicked = false;
  //       buttons[r][c].flagged = false;
  //     }
  //   }

  //   for (int i = 0; i < NUM_MINES; i++) {
  //     setMines();
  //   }
  // }
}


public boolean isWon() {
  for (int r = 0; r < NUM_ROWS; r++) {
    for (int c = 0; c < NUM_COLS; c++) {
      if (!buttons[r][c].clicked && !mines.contains(buttons[r][c])) {
        return false;
      }
    }
  }
  return true;
}


public void displayLosingMessage() {
  for (int r = 0; r < NUM_ROWS; r++) {
    for (int c = 0; c < NUM_COLS; c++) {
      buttons[r][c].draw();
    }
  }
  textSize(128);
  fill(#00ffff);
  text("GAME OVER", width / 2, width / 2);
  textSize(32);
  fill(#d8bfd8);
  text("press any key to play again", width / 2, width / 2 + 50);
}


public void displayWinningMessage() {
  for (int r = 0; r < NUM_ROWS; r++) {
    for (int c = 0; c < NUM_COLS; c++) {
      buttons[r][c].unFlag();
      buttons[r][c].draw();
    }
  }
  textSize(128);
  fill(#00ffff);
  text("YOU WON!", width / 2, width / 2);
  textSize(32);
  fill(#d8bfd8);
  text("press any key to play again", width / 2, width / 2 + 50);
}


public boolean isValid(int r, int c) {
  return r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS;
}

public void keyPressed() {
  if (state == GameState.WON || state == GameState.LOST) {
    if (key == ' ') {
      state = GameState.READY;
    }
  } else if (state == GameState.PLAYING) {
    if (key == 'h') {
      cursorX = max(0, cursorX - 1);
    } else if (key == 'j') {
      cursorY = min(NUM_ROWS - 1, cursorY + 1);
    } else if (key == 'k') {
      cursorY = max(0, cursorY - 1);
    } else if (key == 'l') {
      cursorX = min(NUM_COLS - 1, cursorX + 1);
    } else if (key == 'z') {
      buttons[cursorY][cursorX].mousePressed();
    } else if (key == 'x') {
      buttons[cursorY][cursorX].flagged = !buttons[cursorY][cursorX].flagged;
    }
  }
}

public int countMines(int row, int col) {
  int NUM_MINES = 0;
  for (int r = row - 1; r <= row + 1; r++) {
    for (int c = col - 1; c <= col + 1; c++) {
      if (isValid(r, c) && mines.contains(buttons[r][c])) NUM_MINES++;
    }
  }
  return NUM_MINES;
}


public class MSButton {
  private int myRow, myCol;
  private float x, y, width, height;
  private boolean clicked, flagged;
  private String myLabel;


  public MSButton(int row, int col) {
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
    if (mouseButton == RIGHT) {
      flagged = !flagged;
    } else if (!flagged) {
      clicked = true;
      if (mines.contains(this)) {
        state = GameState.LOST;
      } else if (countMines(myRow, myCol) > 0) {
        setLabel(countMines(myRow, myCol));
      } else {
        for (int r = myRow - 1; r <= myRow + 1; r++) {
          for (int c = myCol - 1; c <= myCol + 1; c++) {
            if (isValid(r, c) && !buttons[r][c].clicked) {
              buttons[r][c].mousePressed();
            }
          }
        }
      }
    }
  }


  public void draw() {
    if (state == GameState.LOST) {
      if (mines.contains(this)) {
        if (flagged) { // if the button is mined and flagged
          fill(#00ff00); // green
        } else { // if the button is mined but not flagged
          fill(#ff0000); // red
        }
      } else if (flagged) { // if the button is incorrectly flagged
        fill(#ffa500); // orange
      } else if (clicked) {
        fill(200);
      } else {
        fill(150);
      }
    } else if (state == GameState.WON) {
      if (mines.contains(this) && flagged) {
        fill(#00ff00); // green
      } else if (flagged) {
        fill(#ffa500); // orange
      } else if (clicked) {
        fill(200);
      } else {
        fill(150);
      }
    } else if (state == GameState.PLAYING) {
      if (flagged) {
        fill(#ffa500); // orange
      } else if (clicked && mines.contains(this)) {
        fill(#ff0000); // red
      } else if (clicked) {
        fill(200);
      } else {
        fill(150);
      }
    }

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


  public void unFlag() {
    flagged = false;
  }
}
