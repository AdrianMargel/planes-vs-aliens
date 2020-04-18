class Player{
  int money;
  Player(){
    money=0;
  }
  void pay(int amount){
    money+=amount;
  }
}
class Menu{
  ArrayList<PlaneSlot> planes;
  int selected;
  boolean clicked;
  float sideBarWidth;
  Menu(){
    sideBarWidth=200;
    planes=new ArrayList<PlaneSlot>();
    planes.add(new JetSlot());
    planes.add(new BiplaneSlot());
    planes.add(new WarPlaneSlot());
    planes.add(new BomberSlot());
    planes.add(new HeliSlot());
    planes.add(new BalloonSlot());
    planes.add(new FortSlot());
    planes.add(new TriebSlot());
    planes.add(new PodRacerSlot());
    planes.add(new NyanSlot());
    planes.add(new DragonSlot());
  }
  void unClick(){
    clicked=false;
  }
  void click(Vector pos,Vector size,Vector clickPos){
    if(clicked)
      return;
    clicked=true;
    float barWidth=min(sideBarWidth,size.x/4);
    
    if(clickPos.x>pos.x&&clickPos.x<pos.x+barWidth && clickPos.y>pos.y&&clickPos.y<pos.y+size.y){
      moveSelected(-1);
      return;
    }
    if(clickPos.x>pos.x+size.x-barWidth&&clickPos.x<pos.x+size.x && clickPos.y>pos.y&&clickPos.y<pos.y+size.y){
      moveSelected(1);
      return;
    }
    planes.get(selected).click(pos,size,clickPos);
  }
  void moveSelected(int change){
    selected+=change;
    if(selected<0){
      selected+=planes.size();
    }
    if(selected>=planes.size()){
      selected-=planes.size();
    }
  }
  void display(Vector pos,Vector size){
    float barWidth=min(sideBarWidth,size.x/4);
    fill(255);
    stroke(0);
    strokeWeight(7);
    rect(pos.x,pos.y,size.x,size.y);
    fill(0);
    rect(pos.x,pos.y,barWidth,size.y);
    rect(pos.x+size.x-barWidth,pos.y,barWidth,size.y);
    
    stroke(255);
    strokeWeight(5);
    {
      Vector triPos=new Vector(pos.x+barWidth/2,pos.y+size.y/2);
      Vector tri1=new Vector(-25,0);
      tri1.addVec(triPos);
      Vector tri2=new Vector(25,25);
      tri2.addVec(triPos);
      Vector tri3=new Vector(25,-25);
      tri3.addVec(triPos);
      line(tri1.x,tri1.y,tri2.x,tri2.y);
      line(tri1.x,tri1.y,tri3.x,tri3.y);
    }
    {
      Vector triPos=new Vector(pos.x+size.x-barWidth/2,pos.y+size.y/2);
      Vector tri1=new Vector(25,0);
      tri1.addVec(triPos);
      Vector tri2=new Vector(-25,25);
      tri2.addVec(triPos);
      Vector tri3=new Vector(-25,-25);
      tri3.addVec(triPos);
      line(tri1.x,tri1.y,tri2.x,tri2.y);
      line(tri1.x,tri1.y,tri3.x,tri3.y);
    }
    Vector slotPos=new Vector(pos);
    slotPos.addVec(new Vector(barWidth,0));
    Vector slotSize=new Vector(size);
    slotSize.subVec(new Vector(barWidth*2,0));
    planes.get(selected).display(slotPos,slotSize);
  }
}
abstract class PlaneSlot{
  String name;
  String description;
  int price;
  boolean unlocked;
  PImage icon;
  PImage lockedIcon;
  PlaneSlot(){
    unlocked=false;
  }
  void tryBuy(){
    if(player.money>=price){
      player.money-=price;
      unlock();
    }
  }
  void unlock(){
    unlocked=true;
  }
  void click(Vector pos,Vector size,Vector clickPos){
    Vector buttonPos=new Vector(pos.x+(size.x-200)/2,pos.y+size.y-100);
    if(clickPos.x>buttonPos.x&&clickPos.x<buttonPos.x+200 && clickPos.y>buttonPos.y&&clickPos.y<buttonPos.y+50){
      if(unlocked){
        startGame(getSpawn());
      }else{
        tryBuy();
      }
      //rect(pos.x+(size.x-200)/2,pos.y+size.y-100,200,50);
    }
  }
  void display(Vector pos,Vector size){
    float margin=20;
    fill(200,230,250);
    noStroke();
    rect(pos.x,pos.y,size.x,size.y);
    float sizeLim=min(size.x,size.y-margin*2);
    if(unlocked){
      image(icon,pos.x+(size.x-sizeLim)/2,pos.y+(size.y-sizeLim)/2,sizeLim,sizeLim);
    }else{
      image(lockedIcon,pos.x+(size.x-sizeLim)/2,pos.y+(size.y-sizeLim)/2,sizeLim,sizeLim);
    }
    
    fill(0);
    textAlign(CENTER,TOP);
    textSize(40);
    text(name,pos.x,pos.y+margin,size.x,size.y-margin*2);
    textSize(18);
    float titleSize=50;
    text(description,pos.x+margin,pos.y+titleSize+margin,size.x-margin*2,size.y-titleSize-margin*2);
    
    if(!unlocked){
      fill(250,200,0);
    }else{
      fill(40,220,80);
    }
    noStroke();
    rect(pos.x+(size.x-200)/2,pos.y+size.y-100,200,50);
    fill(0);
    textAlign(CENTER,CENTER);
    textSize(20);
    if(!unlocked){
      text("BUY "+price,pos.x+(size.x-200)/2,pos.y+size.y-100,200,50);
    }else{
      text("PLAY",pos.x+(size.x-200)/2,pos.y+size.y-100,200,50);
    }
  }
  abstract Plane getSpawn();
}
class JetSlot extends PlaneSlot{
  JetSlot(){
    super();  
    name="Fighter Jet";
    description="It's a plane";
    price=0;
    unlocked=true;
    icon=loadImage("icon_plane.png");
    lockedIcon=loadImage("iconlock_plane.png");
  }
  Plane getSpawn(){
    return new Plane(new Vector(0,0),0);
  }
}
class BomberSlot extends PlaneSlot{
  BomberSlot(){
    super();  
    name="Stealth Bomber";
    description="More bombs, less stealth";
    price=250;
    icon=loadImage("icon_bomber.png");
    lockedIcon=loadImage("iconlock_bomber.png");
  }
  Plane getSpawn(){
    return new Bomber(new Vector(0,0),0);
  }
}
class NyanSlot extends PlaneSlot{
  NyanSlot(){
    super();  
    name="Nyan Cat";
    description="nyan nyan nyan nyan nyan nyan nyan nyan...";
    price=8000;
    icon=loadImage("icon_nyan.png");
    lockedIcon=loadImage("iconlock_nyan.png");
  }
  Plane getSpawn(){
    return new NyanCat(new Vector(0,0),0);
  }
}
class DragonSlot extends PlaneSlot{
  DragonSlot(){
    super();  
    name="Dragon";
    description="A bullet breathing dragon";
    price=10000;
    icon=loadImage("icon_dragon.png");
    lockedIcon=loadImage("iconlock_dragon.png");
  }
  Plane getSpawn(){
    return new Dragon(new Vector(0,0),0);
  }
}
class BalloonSlot extends PlaneSlot{
  BalloonSlot(){
    super();  
    name="Hot Air Balloon";
    description="A slow relaxing balloon ride";
    price=650;
    icon=loadImage("icon_balloon.png");
    lockedIcon=loadImage("iconlock_balloon.png");
  }
  Plane getSpawn(){
    return new Balloon(new Vector(0,0),0);
  }
}
class TriebSlot extends PlaneSlot{
  TriebSlot(){
    super();  
    name="Triebflugel";
    description="German engineering at its finest";
    price=1800;
    icon=loadImage("icon_trieb.png");
    lockedIcon=loadImage("iconlock_trieb.png");
  }
  Plane getSpawn(){
    return new Triebflugel(new Vector(0,0),0);
  }
}
class FortSlot extends PlaneSlot{
  FortSlot(){
    super();  
    name="Flying Fortress";
    description="More guns, less aim";
    price=800;
    icon=loadImage("icon_fort.png");
    lockedIcon=loadImage("iconlock_fort.png");
  }
  Plane getSpawn(){
    return new FlyingFortress(new Vector(0,0),0);
  }
}
class PodRacerSlot extends PlaneSlot{
  PodRacerSlot(){
    super();  
    name="Pod Racer";
    description="Rated safe for kids";
    price=3000;
    icon=loadImage("icon_pod.png");
    lockedIcon=loadImage("iconlock_pod.png");
  }
  Plane getSpawn(){
    return new PodRacer(new Vector(0,0),0);
  }
}
class BiplaneSlot extends PlaneSlot{
  BiplaneSlot(){
    super();  
    name="Biplane";
    description="Two wings, twice the guns";
    price=50;
    icon=loadImage("icon_biplane.png");
    lockedIcon=loadImage("iconlock_biplane.png");
  }
  Plane getSpawn(){
    return new Biplane(new Vector(0,0),0);
  }
}
class WarPlaneSlot extends PlaneSlot{
  WarPlaneSlot(){
    super();  
    name="Old War Plane";
    description="A relic of the past";
    price=150;
    icon=loadImage("icon_warplane.png");
    lockedIcon=loadImage("iconlock_warplane.png");
  }
  Plane getSpawn(){
    return new WarPlane(new Vector(0,0),0);
  }
}
class HeliSlot extends PlaneSlot{
  HeliSlot(){
    super();  
    name="Helicopter";
    description="Proof wings are optional";
    price=400;
    icon=loadImage("icon_heli.png");
    lockedIcon=loadImage("iconlock_heli.png");
  }
  Plane getSpawn(){
    return new Helicopter(new Vector(0,0),-PI/2);
  }
}
