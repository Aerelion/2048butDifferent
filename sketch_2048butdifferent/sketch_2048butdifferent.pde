HashMap<Integer, Boolean> keyList = new HashMap<Integer, Boolean>();
boolean locked = false;
boolean update = false;
boolean addition = false;

int mapSize = 5;
int[][] map;
int[][] updateMap;
int[][] storMap;

int rot = 0;
int rotGoal = 0;
float falling = 0;
int mode = 0;
int phase = 0;

void setup() {
  size(600, 600);
  frameRate(30);
  map = new int[mapSize][mapSize];
  updateMap = new int[mapSize][mapSize];
  storMap = new int[mapSize][mapSize];
  for(int x = 0; x < mapSize; x++) {
    for(int y = 0; y < mapSize; y++) {
      map[x][y] = 0;
      updateMap[x][y] = 0;
      storMap[x][y] = 0;
    }
  }
  
  keyList.put(37, false);
  keyList.put(39, false);
}

void draw() {
  background(100);
  text(frameRate, 10, 10);
  strokeWeight(3);
  line(2, 2, 2, frameRate);
  
  pushMatrix();
  translate(300, 300);
  rotate(radians(rot));
  
  float scalor = 400.0 / float(mapSize);
  for(int x = 0; x < mapSize; x++) {
    for(int y = 0; y < mapSize; y++) {
      float xPos = (float(x) - float(mapSize)/2.0) * scalor;
      float yPos = (float(y) - float(mapSize)/2.0) * scalor;
      if (map[x][y] == 0) {
        fill(100);
      } else if (map[x][y] == 1) {
        fill(255, 0, 0);
      } else if (map[x][y] >= 2) {
        fill(120 + 20*(map[x][y]-1));
      }
      rect(xPos, yPos, scalor, scalor);
      fill(0);
      if (map[x][y] >= 0) {
        fill(0);
        text(map[x][y], xPos + scalor/2.0 - 5, yPos + scalor/2.0 + 5);
      }
    }
  }
  text("N", 0, -220);
  text("W", -220, 0);
  text("S", 220, 0);
  text("E", 0, 220);
  
  if (keyList.get(37) == true && locked == false) {
    rotGoal -= 90;
    mode -= 1;
    if (mode == -1) { mode = 3;}
    locked = true;
    update = true;
  }
  if (keyList.get(39) == true && locked == false) {
    rotGoal += 90;
    mode += 1;
    if (mode == 4) { mode = 0;}
    locked = true;
    update = true;
  }
  
  // UPDATE PHASE 1 - rotating the frame
  if (update == true && phase == 0) { //<>//
    int step = 0;
    if (rotGoal-rot > 90/frameRate) {
      step = int(90/frameRate);
    } else if (rotGoal-rot < -90/frameRate){
      step = int(-90/frameRate);
    } else if (rotGoal-rot > 0) {
      step = rotGoal-rot;
    } else if (rotGoal-rot < 0) {
      step = rotGoal-rot;
    } else {
      phase = 1;
    }
    rot += step;
    
  // UPDATE PHASE 2 - spawning new tile & resetting maps
  } else if (update == true && phase == 1) { //<>//
    for (int x = 0; x < mapSize; x++) {
      for (int y = 0; y < mapSize; y++) {
        if (map[x][y] == 1) {
          map[x][y] = 2;
        }
        updateMap[x][y] = 0;
        storMap[x][y] = 0;
      }
    }
    phase = 2;
    
  // UPDATE PHASE 3 - searching falling tiles
  } else if (update == true && phase == 2) { //<>//
    for (int x = 0; x < mapSize; x++) {
      for (int y = 0; y < mapSize; y++) {
        if (map[x][y] >= 2) {
          boolean canFall = false;
          boolean canMerge = false;
          int xP = 0;
          int yP = 0;
          if (mode == 0) {
            if (y+1 < mapSize) {
              yP = 1;
              if (map[x][y+1] == 0 || map[x][y+1] == 1) {
                canFall = true;
              } 
              if (map[x][y+1] == map[x][y]) {
                canMerge = true;
              }
            }
          } else if (mode == 1) {
            if (x+1 < mapSize) {
              xP = 1;
              if (map[x+1][y] == 0 || map[x+1][y] == 1) {
                canFall = true;
              } 
              if (map[x+1][y] == map[x][y]) {
                canMerge = true;
              }
            }
          } else if (mode == 2) {
            if (y-1 >= 0) {
              yP = -1;
              if (map[x][y-1] == 0 || map[x][y-1] == 1) {
                canFall = true;
              } 
              if (map[x][y-1] == map[x][y]) {
                canMerge = true;
              }
            }
          } else if (mode == 3) {
            if (x-1 >= 0) {
              xP = -1;
              if (map[x-1][y] == 0 || map[x-1][y] == 1) {
                canFall = true;
              } 
              if (map[x-1][y] == map[x][y]) {
                canMerge = true;
              }
            }
          }
          if (canMerge == true) {
            updateMap[x][y] = 2;
            updateMap[x+xP][y+yP] = 3;
          } else if (canFall == true) {
            if (updateMap[x][y] < 2) {
              updateMap[x][y] = 1;
            }
          } else {
            if (updateMap[x][y] == 0) {
              updateMap[x][y] = -1;
            }
          }
        }
      }
    }
        
    phase = 3;
    
  // PHASE 4 - letting those tiles fall!
  } else if (update == true && phase == 3) { //<>//
    for (int x = 0; x < mapSize; x++) {
      for (int y = 0; y < mapSize; y++) {
        if (updateMap[x][y] == 1 || updateMap[x][y] == 2) {
          float xPos = (float(x) - float(mapSize)/2.0) * scalor;
          float yPos = (float(y) - float(mapSize)/2.0) * scalor;
          
          fill(120 + 20*map[x][y]);
          if (updateMap[x][y] == 2) {
            fill(0, 0, 255);
          }
          if (mode == 0) {
            rect(xPos, yPos + falling, scalor, scalor);
          } else if (mode == 1) {
            rect(xPos + falling, yPos, scalor, scalor);
          } else if (mode == 2) {
            rect(xPos, yPos - falling, scalor, scalor);
          } else if (mode == 3) {
            rect(xPos - falling, yPos, scalor, scalor);
          }
        }
      }
    }
    if (falling < scalor) {
      falling += scalor/frameRate;
    } else {
      for (int x = 0; x < mapSize; x++) {
        for (int y = 0; y < mapSize; y++) {
          if (updateMap[x][y] == 1) {
            if (mode == 0) {
              storMap[x][y+1] = map[x][y];
            } else if (mode == 1) {
              storMap[x+1][y] = map[x][y];
            } else if (mode == 2) {
              storMap[x][y-1] = map[x][y];
            } else if (mode == 3) {
              storMap[x-1][y] = map[x][y];
            }
          } else if (updateMap[x][y] == 2) {
            if (mode == 0) {
              storMap[x][y+1] = map[x][y]+1;
            } else if (mode == 1) {
              storMap[x+1][y] = map[x][y]+1;
            } else if (mode == 2) {
              storMap[x][y-1] = map[x][y]+1;
            } else if (mode == 3) {
              storMap[x-1][y] = map[x][y]+1;
            }
          } else if (updateMap[x][y] == -1) {
            storMap[x][y] = map[x][y];
          }
        }
      }
      
      phase = 4;
      falling = 0;
    }
    
  // PHASE 5 - selecting new tile
  } else if (update == true && phase == 4) { //<>//
    int temp = 0;
    for (int x = 0; x < mapSize; x++) {
      for (int y = 0; y < mapSize; y++) {
        map[x][y] = storMap[x][y];
        if (map[x][y] == 0) {
          temp += 1;
        }
      }
    }
    
    if (temp > 0) {
      int select = int(random(0, temp));
      boolean found = false;
      for (int x = 0; x < mapSize; x++) {
        for (int y = 0; y < mapSize; y++) {
          if (map[x][y] == 0 && found == false) {
            if (select > 1) {
              select -= 1;
            } else {
              map[x][y] = 1;
              found = true;
            }
          }
        }
      }
    }
    
    update = false;
    locked = false;
    phase = 0;
  }
  // END OF Update cycles
  popMatrix();
}

void keyPressed() {
  keyList.put(keyCode, true);
  print(keyCode);
}

void keyReleased() {
  keyList.put(keyCode, false);
  print(keyCode);
}