import de.bezier.guido.*;

int NUM_ROWS = 5;
int NUM_COLS = 5;
private MSButton[][] buttons;
// ArrayList of just the minesweeper buttons that are mined:
private ArrayList <MSButton> mines;

void setup() {
    size(400, 400);
    textAlign(CENTER,CENTER);

    // make the manager
    Interactive.make(this);

    buttons = new MSButton[NUM_ROWS][NUM_COLS];
    mines = new ArrayList<MSButton>();
    for (int i = 0; i < NUM_ROWS; i++) {
        for (int j = 0; j < NUM_COLS; j++) {
            buttons[i][j] = new MSButton(i, j);
        }
    }
    setMines();
}

public void setMines() {
    int row = (int)(Math.random() * NUM_ROWS);
    int col = (int)(Math.random() * NUM_COLS);
    if (!mines.contains(buttons[row][col])) mines.add(buttons[row][col]);
}

public void draw() {
    background(0);
    if (isWon()) displayWinningMessage();
}

public boolean isWon() {
    // TODO
    return false;
}

public void displayLosingMessage() {
    // TODO
}

public void displayWinningMessage() {
    // TODO
}

public boolean isValid(int r, int c) {
    if (r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS) return true;
    else return false;
}

public int countMines(int row, int col) {
    int numMines = 0;
    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            if (isValid(row+i, col+j) && i != j) {
                if (mines.contains(buttons[row+i][col+j])) numMines++;
            }
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
        clicked = true;
        if (mouseButton == RIGHT) flagged = !flagged;
        if (!flagged) clicked = false;
        else if (mines.contains(this)) displayLosingMessage();
        else if (countMines(myRow, myCol) > 0) {
            setLabel(countMines(myRow, myCol));
        }
        // else mousePressed(); // FIXME
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
