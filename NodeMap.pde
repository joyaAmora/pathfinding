/********************
  Énumération des directions
  possibles
  
********************/
enum Direction {
  EAST, SOUTH, WEST, NORTH
}

/********************
  Représente une carte de cellule permettant
  de trouver le chemin le plus court entre deux cellules
  
********************/
class NodeMap extends Matrix {
  Node start;
  Node end;
  ArrayList <Node> openList = new ArrayList<Node>();
  ArrayList <Node> closeList = new ArrayList<Node>();
  ArrayList <Node> path;
  ArrayList <Node> pathList = new ArrayList<Node>();
  
  boolean debug = false;
  
  NodeMap (int nbRows, int nbColumns) {
    super (nbRows, nbColumns);
  }
  
  NodeMap (int nbRows, int nbColumns, int bpp, int width, int height) {
    super (nbRows, nbColumns, bpp, width, height);
  }
  
  void init() {
    
    cells = new ArrayList<ArrayList<Cell>>();
    
    for (int j = 0; j < rows; j++){
      // Instanciation des rangees
      cells.add (new ArrayList<Cell>());
      
      for (int i = 0; i < cols; i++) {
        Cell temp = new Node(i * cellWidth, j * cellHeight, cellWidth, cellHeight);
        
        // Position matricielle
        temp.i = i;
        temp.j = j;
        
        cells.get(j).add (temp);
      }
    }
    
    println ("rows : " + rows + " -- cols : " + cols);
  }
  
  /*
    Configure la cellule de départ
  */
  void setStartCell (int i, int j) {
    
    if (start != null) {
      start.isStart = false;
      start.setFillColor(baseColor);
    } 
    
    start = (Node)cells.get(j).get(i);
    start.isStart = true;
    
    start.setFillColor(color (255, 255, 0));
  }
  
  /*
    Configure la cellule de fin
  */
  void setEndCell (int i, int j) {
    
    if (end != null) {
      end.isEnd = false;
      end.setFillColor(baseColor);
    }
    
    end = (Node)cells.get(j).get(i);
    end.isEnd = true;
    
    end.setFillColor(color (255, 0, 255));
  }
  
  /** Met a jour les H des cellules
  doit etre appele apres le changement du noeud
  de debut ou fin
  */
  void updateHs() {
    for (int j = 0; j < rows; j++) {
      for (int i = 0; i < cols; i++) {
        Node current = (Node)cells.get(j).get(i); 
        current.setH( calculateH(current));
      }
    }
  }
  
  // Permet de generer aleatoirement le cout de deplacement
  // entre chaque cellule
  void randomizeMovementCost() {
    for (int j = 0; j < rows; j++) {
      for (int i = 0; i < cols; i++) {
        
        int cost = parseInt(random (0, cols)) + 1;
        
        Node current = (Node)cells.get(j).get(i);
        current.setMovementCost(cost);
       
      }
    }
  }
  
  // Permet de generer les voisins de la cellule a la position indiquee
  void generateNeighbours(int i, int j) {
    Node c = (Node)getCell (i, j);
    if (debug) println ("Current cell : " + i + ", " + j);
    
    
    for (Direction d : Direction.values()) {
      Node neighbour = null;
      
      switch (d) {
        case EAST :
          if (i < cols - 1) {
            if (debug) println ("\tGetting " + d + " neighbour for " + i + ", " + j);
            neighbour = (Node)getCell(i + 1, j);
          }
          break;
        case SOUTH :
          if (j < rows - 1) {
            if (debug) println ("\tGetting " + d + " neighbour for " + i + ", " + j);
            neighbour = (Node)getCell(i, j + 1);
          }
          break;
        case WEST :
          if (i > 0) {
            if (debug) println ("\tGetting " + d + " neighbour for " + i + ", " + j);
            neighbour = (Node)getCell(i - 1, j);
          }
          break;
        case NORTH :
          if (j > 0) {
            if (debug) println ("\tGetting " + d + " neighbour for " + i + ", " + j);
            neighbour = (Node)getCell(i, j - 1);
          }
          break;
      }
      
      if (neighbour != null) {
        if (neighbour.isWalkable) {
          c.addNeighbour(neighbour);
        }
      }
    }
  }
  
  /**
    Génère les voisins de chaque Noeud
    Pas la méthode la plus efficace car ça
    prend beaucoup de mémoire.
    Idéalement, on devrait le faire au besoin
  */
  void generateNeighbourhood() {
    for (int j = 0; j < rows; j++) {
      for (int i = 0; i < cols; i++) {

        generateNeighbours(i, j);
      }
    }
  }
  
  /*
    Permet de trouver le chemin le plus court entre
    deux cellules
  */
  void findAStarPath () {
    // TODO : Complétez ce code
    
    if (start == null || end == null) {
      println ("No start and no end defined!");
      return;
    }
    
    // TODO : Complétez ce code
    openList.clear();
    closeList.clear();
    
    openList.add(start);
    start.setG(0);
    updateHs();
    
    Node currentNode = null;
    Node neighbors = null;
    
    while(openList.size() > 0){
      Node lowestCostNode = getLowestCost(openList);
      currentNode = lowestCostNode;
      
      if(!lowestCostNode.isEnd){
        
        openList.remove(lowestCostNode);
        closeList.add(lowestCostNode);
        
        for(int j =0; j < currentNode.neighbours.size(); j++)
       {
         neighbors = currentNode.neighbours.get(j);
         
         if(!closeList.contains(neighbors) && neighbors.isWalkable) {
           int tempG = currentNode.getG() + 10;
           if(!openList.contains(neighbors) || tempG < neighbors.getG()){
             neighbors.setParent(currentNode);
             neighbors.setG(tempG);
           }        
         }       
       }
     }
     else
       generatePath();
    }   
  }
  
  /*
    Permet de générer le chemin une fois trouvée
  */
  void generatePath () {
    // TODO : Complétez ce code ---------- Fait
    println(end);
    Node currentNode = end;
    int i = 0;
    while(!currentNode.isStart){
      pathList.add(currentNode);
      Node next = currentNode;
      currentNode = null;
      currentNode = next.getParent();
      i++;
      
      color c = color(255,0,175);
      for(int j = pathList.size()-1; j > 0; j--){
        Cell pathCell = pathList.get(j);
        pathCell.setFillColor(c);
      }
    }
  }
  
  /**
  * Cherche et retourne le noeud le moins couteux de la liste ouverte
  * @return Node le moins couteux de la liste ouverte
  */
  private Node getLowestCost(ArrayList<Node> openList) {
    // TODO : Complétez ce code ---------- Fait
    Node node = openList.get(0);
    
    for(int i = 1; i < openList.size(); i++){
      if(node.getF() > openList.get(i).getF());
        node = openList.get(i);
    }
    return node;
  }
  

  
 /**
  * Calcule le coût de déplacement entre deux noeuds
  * @param nodeA Premier noeud
  * @param nodeB Second noeud
  * @return
  */
  private int calculateCost(Cell nodeA, Cell nodeB) {
    // TODO : Complétez ce code ---------- Fait
    int cost = 0;
    int DX = abs(nodeB.i - nodeA.i);
    int DY = abs(nodeB.j - nodeA.j);
    cost = DX+DY * 10;

    return cost;
  }
  
  /**
  * Calcule l'heuristique entre le noeud donnée et le noeud finale
  * @param node Noeud que l'on calcule le H
  * @return la valeur H
  */
  private int calculateH(Cell node) {
    // TODO : Complétez ce code ---------- Fait
    int xDebut = node.x;
    int yDebut = node.y;
    int xFin = end.x;
    int yFin = end.y;
    int h = abs((xFin - xDebut))+abs((yFin-yDebut));
    return h*10;
  }
  
  String toStringFGH() {
    String result = "";
    
    for (int j = 0; j < rows; j++) {
      for (int i = 0; i < cols; i++) {

        Node current = (Node)cells.get(j).get(i);
        
        result += "(" + current.getF() + ", " + current.getG() + ", " + current.getH() + ") ";
      }
      
      result += "\n";
    }
    
    return result;
  }
  
  // Permet de créer un mur à la position _i, _j avec une longueur
  // et orientation données.
  void makeWall (int _i, int _j, int _length, boolean _vertical) {
    int max;
    
    if (_vertical) {
      max = _j + _length > rows ? rows: _j + _length;  
      
      for (int j = _j; j < max; j++) {
        ((Node)cells.get(j).get(_i)).setWalkable (false, 0);
      }       
    } else {
      max = _i + _length > cols ? cols: _i + _length;  
      
      for (int i = _i; i < max; i++) {
        ((Node)cells.get(_j).get(i)).setWalkable (false, 0);
      }     
    }
  }
}
