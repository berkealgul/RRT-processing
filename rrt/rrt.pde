
// map of the 
int[][] map;

final int mapW = 50;

final int OBS = -1;
final int EMPTY = 0;
final int DESTINATION = 1;
final int VISITED = 2;
final int START = 3;
final int SUCCESS = 1;
final int CYCLE_LIMIT = 200;

int cycles = 0;
int cellW;
int nodeCircleDia;

boolean solving = false;

Node root, destinationNode;

void setup()
{
  size(800,800);
  map = new int[mapW][mapW];
  cellW = width / mapW;
  nodeCircleDia = 10;
  
  // constant destination - start locations
  map[mapW/2][5] = START;
  map[mapW/2][45] = DESTINATION;
}

void draw()
{
  background(#F0EDED);
  drawMap();
  
  if(solving)
  {
    cycles++;
    int result = rrt_cycle();
    if(result == SUCCESS || cycles == CYCLE_LIMIT)
      solving = false;
    drawPath(root);
  }
  else if(destinationNode != null)
   drawGoldenPath(destinationNode);
  else
    drawPath(root);
    
  
}

void startSolving()
{
 root = new Node(5, mapW/2);
 solving = true;
 destinationNode = null;
 cycles = 0;
}

void keyPressed()
{
  if(solving)
    return;
    
  if(key == 'q')
   startSolving(); 
  else if(key == 'e')
    setRandomMapObs(); //<>//
}

void setRandomMapObs()
{
  for(int i = 0; i < mapW; i++)
    for(int j = 0; j < mapW; j++)
    {
      int cellStatus = map[j][i];
      if(cellStatus == START || cellStatus == DESTINATION)
        continue;
        
      if((int)random(7) == 0)
       map[j][i] = OBS;
      else
       map[j][i] = EMPTY;
    }
}

void drawGoldenPath(Node node)
{    
  noStroke();
  fill(#F0E50F);
  int cx = (cellW*(2*node.x+1))/2;
  int cy = (cellW*(2*node.y+1))/2;
  ellipse(cx,cy,nodeCircleDia,nodeCircleDia);
  
  if(node.parent != null)
  {
    stroke(#F0E50F);
    int cx1 = (cellW*(2*node.parent.x+1))/2;
    int cy1 = (cellW*(2*node.parent.y+1))/2;
    line(cx, cy, cx1, cy1);
    drawGoldenPath(node.parent);
  }

  
}

void drawPath(Node node)
{
  if(node == null)
    return;
    
  if(solving)
    
  noStroke();
  fill(#F50F67);
  int cx = (cellW*(2*node.x+1))/2;
  int cy = (cellW*(2*node.y+1))/2;
  ellipse(cx,cy,nodeCircleDia,nodeCircleDia);
 
 for(Node n : node.neighbors)
 {
    stroke(#F50F67);
    int cx1 = (cellW*(2*n.x+1))/2;
    int cy1 = (cellW*(2*n.y+1))/2;
    line(cx, cy, cx1, cy1);
    drawPath(n);
 }
}

void drawMap()
{
  //draw cells
  noStroke();
  for(int i = 0; i < mapW; i++)
  {
    for(int j = 0; j < mapW; j++)
    {
      int cellStatus = map[i][j];
      if(cellStatus == EMPTY || cellStatus == VISITED)
        continue;
      else if(cellStatus == OBS)
        fill(0);
      else if(cellStatus == DESTINATION)
        fill(#1FFF28);
      else if(cellStatus == START)
        fill(#0FF5F3);

      rect(j*cellW, i*cellW, cellW, cellW);
    }    
  }
  //draw outlines
  stroke(0);
  for(int i = 0; i < mapW; i++)
  {
     int s = cellW*i;
     
     line(s, 0, s, height);
     line(0,s,width,s);
  }
}


void mouseClicked()
{
  int i = mouseX/cellW;
  int j = mouseY/cellW;

  if(mouseButton == LEFT)
  {
   toggleObs(i,j); //<>//
  }
}

void toggleObs(int i,int j)
{
  int cellStatus = map[j][i];
  if(cellStatus != START && cellStatus != DESTINATION)
  {
    if(cellStatus == EMPTY)
      map[j][i] = OBS;
    else
      map[j][i] = EMPTY;
  }
}


int rrt_cycle()
{
  int x = (int)random(mapW);
  int y = (int)random(mapW);
  
  int cellStatus = map[y][x];
  
  if(cellStatus == OBS || cellStatus == VISITED || cellStatus == START)
    return 0;
    
  Node n = new Node(x,y);
  NodeDisPair closest = find_closest(root, n);
  Node cn = closest.n;
  cn.add_neighbor(n);
  
  map[y][x] = VISITED;
  
  if(cellStatus  == DESTINATION)
  {
    destinationNode = n;
    return SUCCESS;
  }
  else
    return 0;
}


NodeDisPair find_closest(Node root, Node node)
{
  int closest_dis = root.node_dist(node);
  NodeDisPair closest = new NodeDisPair(root, closest_dis);
  
  for(Node n : root.neighbors)
  {
    NodeDisPair ns = find_closest(n, node);
    
    if(closest.isSmaller(ns))
      closest = ns;
  }
  
  return closest;
}


class NodeDisPair
{
 Node n;
 int dis;
  
  NodeDisPair(Node n_, int dis_)
  {
   n = n_;
   dis = dis_;
  }
  
  boolean isSmaller(NodeDisPair ns)
  {
     return ns.dis < dis; 
  }
}


class Node
{
 int x, y;
 Node parent = null;
 
 ArrayList<Node> neighbors;
 
 Node(int x_, int y_)
 {
  x = x_;
  y = y_;
  neighbors = new ArrayList<Node>();
 }
  
 void add_neighbor(Node n)
 {
   n.parent = this;
   neighbors.add(n);
 }
 
 int node_dist(Node n)
 {
   int dx = x-n.x;
   int dy = y-n.y;
   return dx*dx+dy*dy;
 }
}
