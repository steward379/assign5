import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class assign5 extends PApplet {

PImage enemy;
int enemyCount = 8;

int[] enemyX = new int[enemyCount];
int[] enemyY = new int[enemyCount];

public void setup () {
	
	enemy = loadImage("img/enemy.png");
}

public void draw()
{
	addEnemy(0);
}

// 0 - straight, 1-slope, 2-dimond
public void addEnemy(int type)
{	
	for (int i = 0; i < enemyCount; ++i) {
		enemyX[i] = -1;
		enemyY[i] = -1;
	}

	switch (type) {
		case 0:
			addStraightEnemy();
			break;
		case 1:
			addSlopeEnemy();
			break;
		case 2:
			addDiamondEnemy();
			break;
	}
}

public void addStraightEnemy()
{
	float t = random(height - enemy.height);
	int h = PApplet.parseInt(t);
	for (int i = 0; i < 5; ++i) {

		enemyX[i] = (i+1)*-80;
		enemyY[i] = h;
	}

	println("addStraightEnemy");
}
public void addSlopeEnemy()
{
	float t = random(height - 40 * 5);
	int h = PApplet.parseInt(t);
	for (int i = 0; i < 5; ++i) {

		enemyX[i] = (i+1)*-80;
		enemyY[i] = h + i * 40;
	}
	println("addSlopeEnemy");
}
public void addDiamondEnemy()
{
	float t = random( 40 * 3 ,height - 40 * 3);
	int h = PApplet.parseInt(t);
	int x_axis = 1;
	for (int i = 0; i < 8; ++i) {
		if (i == 0 || i == 7) {
			enemyX[i] = x_axis*-80;
			enemyY[i] = h;
			x_axis++;
		}
		else if (i == 1 || i == 5){
			enemyX[i] = x_axis*-80;
			enemyY[i] = h + 1 * 40;
			enemyX[i+1] = x_axis*-80;
			enemyY[i+1] = h - 1 * 40;
			i++;
			x_axis++;
			
		}
		else {
			enemyX[i] = x_axis*-80;
			enemyY[i] = h + 2 * 40;
			enemyX[i+1] = x_axis*-80;
			enemyY[i+1] = h - 2 * 40;
			i++;
			x_axis++;
		}
		
	}
	println("addDiamondEnemy");

}
/* @pjs preload=
"img/bg1.png,
img/bg2.png,
img/end1.png,
img/end2.png,
img/enemy.png,
img/enemy2.png,
img/fighter.png,
img/flame1.png,
img/flame2.png,
img/flame3.png,
img/flame4.png,
img/flame5.png,
img/hp.png,
img/shoot.png,
img/start1.png,
img/start2.png,
img/treasure.png"; */
  public void settings() { 	size(640, 480) ; }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "assign5" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
