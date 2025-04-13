import de.bezier.guido.*;

public int NUM_ROWS = 10;
public int NUM_COLS = 10;
public int NUM_MINES = 9;
public int cursorX, cursorY;
private int flashCounter = 0;
public int startCount = 0;
private MSButton[][] buttons;
private ArrayList<MSButton> mines;
public char state = 'R';
public boolean newGame = true;
public boolean foo = true;


void setup() {
    size(720, 720);
    textAlign(CENTER, CENTER);
    frameRate(60);
    cursorX = cursorY = 0;
    // state = GameState.PLAYING;
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
    background(#964B00);

    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            buttons[r][c].draw();
        }
    }

    isWon();

    if (state == 'W') { displayWinningMessage(); }

    if (state == 'L') { displayLosingMessage(); }

    if (state == 'P') {
        newGame = false;
        fill(#00ffff);
        rect(cursorX * 720 / NUM_COLS, cursorY * 720 / NUM_ROWS, 720 / NUM_COLS, 720 / NUM_ROWS);
    }

    if (state == 'R') { // if ready, reset the game

        if (newGame) {
            for (int r = 0; r < NUM_ROWS; r++) {
                for (int c = 0; c < NUM_COLS; c++) {
                    if (foo) buttons[r][c].myLabel = "CLICK";
                    else buttons[r][c].myLabel = "";
                }
            }
            if (startCount < 60) {
                startCount++;
            } else {
                foo = !foo;
                startCount = 0;
            }
        } else {
            mines = new ArrayList<MSButton>();

            for (int r = 0; r < NUM_ROWS; r++) {
                for (int c = 0; c < NUM_COLS; c++) {
                    buttons[r][c].clicked = false;
                    buttons[r][c].flagged = false;
                    buttons[r][c].myLabel = "";
                }
            }

            for (int i = 0; i < NUM_MINES; i++) { setMines(); }
        }

        if (mousePressed || keyPressed && key == ' ') {
            for (int r = 0; r < NUM_ROWS; r++) {
                for (int c = 0; c < NUM_COLS; c++) {
                    buttons[r][c].myLabel = "";
                }
            }
            state = 'P';
        }
    }
}


public boolean isWon() {
    if (state == 'R') return false;
    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            if (!buttons[r][c].clicked && !mines.contains(buttons[r][c])) {
                return false;
            }
        }
    }
    state = 'W';
    return true;
}


public void displayWinningMessage() {
    String[] winSequence = {"W", "I", "N", "", "WIN", "", "WIN"};
    int index = (flashCounter / 30) % winSequence.length; // Change every 30 frames

    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            buttons[r][c].setLabel(winSequence[index]);
        }
    }

    if (flashCounter < 180) { // Flash for 6 cycles (6 * 30 frames)
        flashCounter++;
    }
}


public void displayLosingMessage() {
    String[] loseSequence = {
        "≈iCz\n7oP^", "!2[a\nJ}∆Ω", "G¥&F\nåß$v", "Gﬂ_+\nTª#¶", "GA•∞\nB|@e",
        "GA◊e\n2™`~", "GAM‚\n<%Hq", "GAM›\n*&xd", "GAME\n⁄/X«", "GAME\n˝Ò¨",
        "GAME\nOÇ√Œ", "GAMe\nO¢as", "GaME\nOV¡≥", "GAME\nOV 8", "GAME\nOVE§",
        "G@ME\nOVEﬁ", "GAME\n0VER", "GAM3\nOVEr", "GAME\nO√ER", "", "", "GAME\nOVER",
        "gAWE\nOVER", "", "", "GAME\nOVER"
    };
    int index = (flashCounter / ((int)(Math.random() * 5)+25)) % loseSequence.length;

    for (int r = 0; r < NUM_ROWS; r++) {
        for (int c = 0; c < NUM_COLS; c++) {
            buttons[r][c].setLabel(loseSequence[index]);
        }
    }

    if (flashCounter < 460) {
        flashCounter++;
    }
}



public boolean isValid(int r, int c) {
    return r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS;
}

public void keyPressed() {
    if (state == 'W' || state == 'L') {
        if (key == ' ') {
            state = 'R';
        }
    } else if (state == 'P') {
        if (keyCode == LEFT) {
            cursorX = max(0, cursorX - 1);
        } else if (keyCode == DOWN) {
            cursorY = min(NUM_ROWS - 1, cursorY + 1);
        } else if (keyCode == UP) {
            cursorY = max(0, cursorY - 1);
        } else if (keyCode == RIGHT) {
            cursorX = min(NUM_COLS - 1, cursorX + 1);
        } else if (key == 'x') {
            buttons[cursorY][cursorX].mousePressed();
        } else if (key == 'z') {
            buttons[cursorY][cursorX].flagged = !buttons[cursorY][cursorX].flagged;
            if (!buttons[cursorY][cursorX].flagged) {
                buttons[cursorY][cursorX].myLabel = "";
            }
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
        width = 720 / NUM_COLS;
        height = 720 / NUM_ROWS;
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
            if (!flagged) myLabel = "";
        } else if (!flagged) {
            clicked = true;
            if (mines.contains(this)) {
                flashCounter = 0;
                state = 'L';
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
        if (state == 'L') {
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
        } else if (state == 'W') {
            if (mines.contains(this) && flagged) {
                fill(#00ff00); // green
            } else if (flagged) {
                fill(#ffa500); // orange
            } else if (clicked) {
                fill(200);
            } else {
                fill(150);
            }
        } else {
            if (flagged) {
                fill(#ffa500); // orange
                myLabel = "⚑";
            } else if (clicked && mines.contains(this)) {
                fill(#ff0000); // red
                myLabel = "☼";
            } else if (clicked) {
                fill(200);
            } else {
                fill(150);
            }
        }

        rect(x+width/9, y+width/9, width-width/9, height-height/9);
        fill(0);
        text(myLabel, x + 5 * width / 9, y + 5 * height / 9);
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
