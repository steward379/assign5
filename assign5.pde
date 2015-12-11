//setup & time
PImage startPlain, startHover, endPlain, endHover, bgOne, bgTwo;
PImage treasure, fighter, enemy, attack;
PImage [] booms = new PImage [5];
PImage healthFrame;
PFont board;
int scoreNum = 0;
int bullet = 0;
boolean [] attackLimit = new boolean[5];
int hpBar;
final int HP_PERCENT = 2;
final int HP_MAX = 100 * HP_PERCENT;
int timer;
int current;
int closestEnemyIndex;

//states
int gameState;
int enemyState;
final int GAME_START = 0;
final int GAME_RUN = 1;
final int GAME_LOSE = 2;
final int ENEMY_LINE = 0;
final int ENEMY_SLASH = 1;
final int ENEMY_QUAD = 2;

//locations
float treasureX;
float treasureY;
int fighterX;
int fighterY;
final int FIGHTER_X_START = 580;
final int FIGHTER_Y_START = 240;
int enemyCount = 8;
int[] enemyX = new int[enemyCount];
int[] enemyY = new int[enemyCount];
float [] attackX = new float [5];
float [] attackY = new float [5];
float boomsPlace [][] = new float [5][2]; 

//move
float scrollRight;
float fighterSpeed;
int attackSpeed;

//input
boolean upPressed = false;
boolean downPressed = false;
boolean leftPressed = false;
boolean rightPressed = false;

void setup () {  
  
  //basics
  size (640,480) ;
  frameRate(60);
  
  //load Images    
  startPlain = loadImage ("img/start2.png");
  startHover = loadImage ("img/start1.png");  
  bgOne = loadImage ("img/bg1.png");
  bgTwo = loadImage ("img/bg2.png");
  healthFrame = loadImage ("img/hp.png");
  treasure = loadImage ("img/treasure.png");
  fighter = loadImage ("img/fighter.png");
  enemy = loadImage ("img/enemy.png");  
  endPlain = loadImage ("img/end2.png");
  endHover = loadImage ("img/end1.png");
  attack = loadImage ("img/shoot.png");
  for ( int i = 0; i < 5; i++ ){
    booms[i] = loadImage ("img/flame" + (i+1) + ".png" );
  }
  
  //game-basics
  gameState = 0;
  enemyState = 0;
  hpBar = 20 * HP_PERCENT;
  fighterX = FIGHTER_X_START;
  fighterY = FIGHTER_Y_START ; 
  treasureX = floor( random(50, width - 40) );
  treasureY = floor( random(50, height - 60) );
  fighterSpeed = 6 ;
  attackSpeed = 5 ;
  
  //booms-escape
  timer = 0;
  current = 0;
  for ( int i = 0; i < boomsPlace.length; i ++){
    boomsPlace [i][0] = 1000;
    boomsPlace [i][1] = 1000;
  }

  //bullets-lockup
  for (int i =0; i < attackLimit.length ; i ++){
    attackLimit[i] = false;
  }
  
  //types-setup
  board = createFont("Arial", 24);
  textFont(board, 16);
  textAlign(LEFT);
  
  //Enemy-showup
  addEnemy(0);
}


void draw(){ 
  background(0) ;   
  
  switch (gameState) {
    
    case GAME_START:
    image (startPlain, 0, 0);
    if ( mouseX > 200 && mouseX < 460 && mouseY > 370 && mouseY < 420){
    image(startHover, 0, 0);  
    }
    break;  
    case GAME_RUN:
    
    //bg
    image (bgTwo, scrollRight, 0);
    image (bgOne, scrollRight - width, 0);
    image (bgTwo, scrollRight - width * 2, 0); 
    scrollRight += 2;
    scrollRight %= width * 2;
    
    //treasure
    image (treasure, treasureX, treasureY);    
    if(isHit(treasureX, treasureY, treasure.width, treasure.height,
             FIGHTER_X_START, FIGHTER_Y_START, fighter.width, fighter.height) == true){  
      treasureX = floor( random(50, width - 40) ); 
      treasureY = floor( random(50, height - 60) );  
    }        
    
    //fighter
    image(fighter, fighterX, fighterY);
    if (upPressed && fighterY > 0) {
      fighterY -= fighterSpeed ;
    }if (downPressed && fighterY < height - fighter.height) {
      fighterY += fighterSpeed ;
    }if (leftPressed && fighterX > 0) {
      fighterX -= fighterSpeed ;
    }if (rightPressed && fighterX < width - fighter.width) {
      fighterX += fighterSpeed ;
    }  
    
    //booms
    timer ++;  
    
    image(booms[current], boomsPlace[current][0], boomsPlace[current][1]);     
    if (timer % (60/10) == 0){
      current ++;
      if (current > 4){
        current = 0;
      } 
    } 
    if(timer > 31){
      for (int i = 0; i < 5; i ++){
        boomsPlace [i][0] = 1000;
        boomsPlace [i][1] = 1000;
      }
    }   
    
    //shoot
    for (int i = 0; i < 5; i ++){
      if (attackLimit [i] == true){
        image (attack, attackX [i], attackY [i]);
        attackX [i] -= attackSpeed;
      }
      if (attackX [i] < - attack.width){
            attackLimit[i] = false;
      }
    }
    
    //attack
    for(int i = 0; i < 5;i++){
      if(enemyX[0] > 0){
        if(closestEnemyIndex != -1 && enemyX[closestEnemyIndex] < attackX[i]){
          if(enemyY[closestEnemyIndex] > attackY[i] && enemyY[closestEnemyIndex] != -1000){
            attackY[i] += 3;
          }else if(enemyY[closestEnemyIndex] < attackY[i] && enemyY[closestEnemyIndex] != -1000){
            attackY[i] -= 3;
          }  
        }
      }
    }
    
    switch (enemyState) { 
    case ENEMY_LINE :
    
      drawEnemy();
      
      for (int i = 0; i < 5; i++){      
        for (int j = 0;  j < 5; j++){
            if (isHit(attackX[j], attackY[j], attack.width, attack.height,
              enemyX[i], enemyY[i], enemy.width, enemy.height) == true
              && attackLimit[j] == true){
              for (int k = 0;  k < 5; k++){
                boomsPlace [k][0] = enemyX[i];
                boomsPlace [k][1] = enemyY[i];
              }
              enemyY[i] = -1000;
              timer = 0;     
              attackLimit[j] = false;
              scoreChange(20);
              }
            }
            
            if (isHit(fighterX, fighterY ,fighter.width, fighter.height,
              enemyX[i], enemyY[i], enemy.width, enemy.height) == true){
              for (int j = 0;  j < 5; j++){
                boomsPlace [j][0] = enemyX[i];
                boomsPlace [j][1] = enemyY[i];
              }             
              enemyY[i] = -1000;
              timer = 0; 
              hpChange(-20);
            } else if (hpBar <= 0) {
              dieReset();
            }   
          }
          
          enemyChange(1);
          
        break ;             
        case ENEMY_SLASH :
        
        drawEnemy();

          for (int i = 0; i < 5; i++ ){
            for(int j = 0; j < 5; j++){
            if (isHit(attackX[j], attackY[j] ,attack.width, attack.height,
                enemyX[i], enemyY[i], enemy.width, enemy.height) == true
                && attackLimit[j] == true){
                for(int k = 0;  k < 5; k++ ){
                  boomsPlace [k][0] = enemyX[i];
                  boomsPlace [k][1] = enemyY[i];
                }     
                enemyY[i] = -1000;
                attackLimit[j] = false;
                timer = 0;
                scoreChange(20);
              }
            }

            if (isHit(fighterX, fighterY ,fighter.width, fighter.height
                ,enemyX[i], enemyY[i], enemy.width, enemy.height) == true){
              for (int j = 0;  j < 5; j++ ){
                 boomsPlace [j][0] = enemyX[i];
                 boomsPlace [j][1] = enemyY[i];
               }
              enemyY[i] = -1000;
              timer = 0; 
              hpChange(- 20);
            } else if (hpBar <= 0) {
              dieReset();
            }  
          }
         
          enemyChange(2);
          
        break ;         
        case ENEMY_QUAD :
          drawEnemy();
          
          for( int i = 0; i < 8; i++ ){    
            for( int j = 0; j < 5; j++ ){
              if (isHit(attackX[j], attackY[j] ,attack.width, attack.height
                ,enemyX[i],enemyY[i], enemy.width, enemy.height) == true
                && attackLimit[j] == true){
                for (int k = 0;  k < 5; k++){
                  boomsPlace [k][0] = enemyX[i];
                  boomsPlace [k][1] = enemyY[i];
                }
                enemyY[i] = -1000;
                attackLimit[j] = false;
                timer = 0; 
                scoreChange(20);
              }
            }       
                
            if (isHit(fighterX, fighterY ,fighter.width, fighter.height
                ,enemyX[i] ,enemyY[i], enemy.width, enemy.height) == true){
              for ( int j = 0;  j < 5; j++ ){
                boomsPlace [j][0] = enemyX[i];
                boomsPlace [j][1] = enemyY[i];
              }
              hpChange(-20);
              enemyY[i] = -1000;
              timer = 0; 
              
            } else if ( hpBar <= 0 ) {
              dieReset();
            }    
          }
                
          enemyChange(0);
          
        break ;
      }

     //HP_BAR_draw
      fill (#FF0000);
      rect (35, 15, hpBar, 30);
      image(healthFrame, 28, 15); 
      
      /* HP + 10 */         
        if (isHit(fighterX, fighterY ,fighter.width, fighter.height,treasureX ,treasureY , treasure.width, treasure.height) == true) {
          treasureX = floor( random(50,600) );         
          treasureY = floor( random(50,420) );
          if (hpBar < HP_MAX) {
              hpChange(10);
            }
        }  
        
    closestEnemy(fighterX, fighterY);
    
    fill(255);
    text("Score:" + scoreNum, 10, 470);       
    text("Closest Enemy Index:" + closestEnemyIndex, 100, 470);
    
    break ;     
    
    case GAME_LOSE :
      image(endPlain, 0, 0);  
        if ( mouseX > 200 && mouseX < 470 && mouseY > 300 && mouseY < 350){
        image(endHover, 0, 0);
        }
    break ;
  }  
}

void drawEnemy(){  
  for (int i = 0; i < enemyCount; ++i) {
    if (enemyX[i] != -1 || enemyY[i] != -1) {
      image(enemy, enemyX[i], enemyY[i]);
      enemyX[i]+=5;
    }
  }
}

void addEnemy(int type)
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

void addStraightEnemy()
{
  float t = random(height - enemy.height);
  int h = int(t);
  for (int i = 0; i < 5; ++i) {
    enemyX[i] = (i+1)*-80;
    enemyY[i] = h;
  }
}
void addSlopeEnemy()
{
  float t = random(height - enemy.height * 5);
  int h = int(t);
  for (int i = 0; i < 5; ++i) {
    enemyX[i] = (i+1)*-80;
    enemyY[i] = h + i * 40;
  }
}
void addDiamondEnemy(){
  float t = random( enemy.height * 3 ,height - enemy.height * 3);
  int h = int (t);
  int x_axis = 1;
  for (int i = 0; i < 8; ++ i) {
    if (i == 0 || i == 7) {
      enemyX [i] = x_axis * - 80;
      enemyY [i] = h;
      x_axis ++;
    }
    else if (i == 1 || i == 5){
      enemyX [i] = x_axis * - 80;
      enemyY [i] = h + 1 * 40;
      enemyX [i+1] = x_axis * - 80;
      enemyY [i+1] = h - 1 * 40;
      i++;
      x_axis++;
    }
    else {
      enemyX [i] = x_axis * - 80;
      enemyY [i] = h + 2 * 40;
      enemyX [i+1] = x_axis * - 80;
      enemyY [i+1] = h - 2 * 40;
      i ++;
      x_axis ++;
    }
  }
}

boolean isHit(float ax,float ay,float aw,float ah,float bx,float by,float bw,float bh){
  if (ax >= bx - aw && ax <= bx + bw && ay >= by - ah && ay <= by + bh){
  return true;
  }
  return false;  
}

void hpChange(int value){
  hpBar += value * HP_PERCENT;
}

void scoreChange(int value){
  scoreNum += value;
}

void enemyChange(int state){
  if (enemyX[5] == -1 && enemyX[4] > width + 200){        
    enemyState = state;
    addEnemy(state);
  }else if(enemyX[7] > width + 400){
    enemyState = state;
    addEnemy(state);
  }
}  

void dieReset(){
   gameState = 2 ;
   hpBar = 20 * HP_PERCENT;
   fighterX = FIGHTER_X_START;
   fighterY = FIGHTER_Y_START;
   treasureX = floor( random(50,600) );
   treasureY = floor( random(50,420) );
   scoreNum = 0;
}

int closestEnemy(int nowFighterX,int nowFighterY){
  float enemyDistance = 1000;
  if (enemyX[7] > width || enemyX [5] == -1 && enemyX[4] > width){
    closestEnemyIndex = -1;
  }else{    
    for( int g = 0; g < 8; g++ ){
      if ( enemyX[g] != -1 ) {        
        if( dist(nowFighterX, nowFighterY, enemyX [g], enemyY [g]) < enemyDistance){
          enemyDistance = dist(nowFighterX, nowFighterY, enemyX [g], enemyY [g]);
          closestEnemyIndex = g;
        }
      }
    }  
  }  
  return closestEnemyIndex;
}


void keyPressed (){
   if (key == CODED){ 
  switch ( keyCode ) {
    case UP :
      upPressed = true ;
      break ;
    case DOWN :
      downPressed = true ;
      break ;
    case LEFT :
      leftPressed = true ;
      break ;
    case RIGHT :
      rightPressed = true ;
      break ;
  }
   }
}
  
void keyReleased () {
 if (key == CODED){ 
  switch ( keyCode ) {
    case UP : 
      upPressed = false ;
      break ;
    case DOWN :
      downPressed = false ;
      break ;
    case LEFT :
      leftPressed = false ;
      break ;
    case RIGHT :
      rightPressed = false ;
      break ;
      }  
  }
  
  if (keyCode == ' '){
      if(gameState ==  1){
        if( attackLimit[bullet] == false ) {
          attackLimit[bullet] = true;
          attackX[bullet] = fighterX - 10;
          attackY[bullet] = fighterY + fighter.height/2;
          bullet ++;
        }   
        if( bullet > 4 ) {
          bullet = 0;
        }
      }
 }
}

void mousePressed (){
  if ( gameState == 0 
    && mouseX > 200 && mouseX < 460 && mouseY > 370 && mouseY < 420){
    if ( mouseButton == LEFT) {
      gameState = 1;
      mouseButton = RIGHT;
    } 
  } else if ( gameState == 2
    && mouseX > 200 && mouseX < 470 && mouseY > 300 && mouseY < 350){
      if( mouseButton == LEFT ){
        gameState = 1 ; 
        enemyState = 0;
        addEnemy(0);
        for (int i = 0; i < 5; i++ ){
          boomsPlace [i][0] = 1000;
          boomsPlace [i][1] = 1000;
          attackLimit[i] = false;       
        }
      }
  }
}

