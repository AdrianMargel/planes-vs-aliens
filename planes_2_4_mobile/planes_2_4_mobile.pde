
public class Vector {
  public float x;
  public float y;
  public Vector(float x, float y) {
    this.x=x;
    this.y=y;
  }
  public Vector(float a, float b,boolean angleInit) {
    if(angleInit){
      this.x=cos(a)*b;
      this.y=sin(a)*b;
    }else{
      this.x=a;
      this.y=b;
    }
  }
  public Vector(Vector vec) {
    this.x=vec.x;
    this.y=vec.y;
  }
  public void addVec(Vector vec) {
    x+=vec.x;
    y+=vec.y;
  }
  public void subVec(Vector vec) {
    x-=vec.x;
    y-=vec.y;
  }
  public void sclVec(float scale) {
    x*=scale;
    y*=scale;
  }
  public void nrmVec() {
    sclVec(1/getMag());
  }
  public void nrmVec(float mag) {
    sclVec(mag/getMag());
  }
  public void limVec(float lim) {
    float mag=getMag();
    if (mag>lim) {
      sclVec(lim/mag);
    }
  }
  public float getAng() {
    return atan2(y, x);
  }
  public float getAng(Vector vec) {
    return atan2(vec.y-y, vec.x-x);
  }
  public float getMag() {
    return sqrt(sq(x)+sq(y));
  }
  public float getMag(Vector vec) {
    return sqrt(sq(vec.x-x)+sq(vec.y-y));
  }
  public void rotVec(float rot) {
    float mag=getMag();
    float ang=getAng();
    ang+=rot;
    x=cos(ang)*mag;
    y=sin(ang)*mag;
  }
  public void rotVec(float rot,Vector pin) {//UNTESTED
    subVec(pin);
    float mag=getMag();
    float ang=getAng();
    ang+=rot;
    x=cos(ang)*mag;
    y=sin(ang)*mag;
    addVec(pin);
  }
  public void minVec(Vector min){
    x=min(x,min.x);
    y=min(y,min.y);
  }
  public void maxVec(Vector max){
    x=max(x,max.x);
    y=max(y,max.y);
  }
  public boolean inRange(Vector vec,float dist){
    float diffX=abs(vec.x-x);
    if(diffX>dist){
      return false;
    }
    float diffY=abs(vec.y-y);
    if(diffY>dist){
      return false;
    }
    return sqrt(sq(diffX)+sq(diffY))<=dist;
  }
  public void setVec(Vector vec){
    x=vec.x;
    y=vec.y;
  }
}

public class Cam{
  public Vector pos;
  public float zoom;
  public Cam(){
    pos=new Vector(0,0);
    zoom=1;
  }
}

public class Particle{
  int age;
  int ageMax;
  
  float size;
  
  Vector pos;
  
  Vector velo;
  float resistance=0.95;
  public Particle(Vector p, Vector v,int a,float s){
    pos=new Vector(p);
    velo=new Vector(v);
    age=a;
    ageMax=a;
    size=s;
  }
  public void run(){
    age--;
    velo.sclVec(resistance);
    pos.addVec(velo);
  }
  public void display(Cam c){
    /*PImage img=null;
    float a=(float)age/ageMax;
    if(a>0.9){
      img=loadImage("ps1.png");
    }else if(a>0.7){
      img=loadImage("ps2.png");
    }else if(a>0.6){
      img=loadImage("ps3.png");
    }else{
      img=loadImage("ps4.png");
    }
    image(img,pos.x-8-c.pos.x,pos.y-8-c.pos.y);*/
    noStroke();
    float a=pow(((float)age/ageMax),9);
    fill(a*255+(1-a)*200,
      a*100+(1-a)*200,
      a*0+(1-a)*200);
    ellipse((pos.x-c.pos.x)*cam.zoom,(pos.y-c.pos.y)*cam.zoom,((float)age/ageMax)*size*cam.zoom,((float)age/ageMax)*size*cam.zoom);
  }
}
class SpawnWarning extends Particle{
  SpawnWarning(Vector p, Vector v,int a,float s){
    super(p,v,a,s);
  }
  @Override
  public void display(Cam c){
    /*PImage img=null;
    float a=(float)age/ageMax;
    if(a>0.9){
      img=loadImage("ps1.png");
    }else if(a>0.7){
      img=loadImage("ps2.png");
    }else if(a>0.6){
      img=loadImage("ps3.png");
    }else{
      img=loadImage("ps4.png");
    }
    image(img,pos.x-8-c.pos.x,pos.y-8-c.pos.y);*/
    //noStroke();
    float a=(float)age/ageMax;
    noFill();
    stroke(120,175,0);
    strokeWeight(8*cam.zoom);
    ellipse((pos.x-c.pos.x)*cam.zoom,(pos.y-c.pos.y)*cam.zoom,((float)age/ageMax)*size*cam.zoom*a,((float)age/ageMax)*size*cam.zoom*a);
    stroke(170,255,0);
    strokeWeight(2*cam.zoom);
    ellipse((pos.x-c.pos.x)*cam.zoom,(pos.y-c.pos.y)*cam.zoom,((float)age/ageMax)*(size)*cam.zoom*a,((float)age/ageMax)*(size)*cam.zoom*a);
  }
}

public class Bullet{
  int age;
  int trailLength;
  boolean alive;
  
  Vector pos;
  ArrayList<Vector> lastPos;
  
  Vector velo;
  
  public Bullet(Vector p, Vector v,int a){
    alive=true;
    trailLength=3;
    lastPos = new ArrayList<Vector>();
    pos=new Vector(p);
    lastPos.add(new Vector(pos));
    velo=new Vector(v);
    age=a;
  }
  void setPos(Vector toSet){
    pos=new Vector(toSet);
  }
  public void kill(){
    alive=false;
  }
  public void run(){
    if(age>=1){
      age--;
    }else if(trailLength>0){
      trailLength--;
    }else{
      age=0;
    }
    //velo.y+=0.5;
    pos.addVec(velo);
  }
  public Vector getPos(){
    return new Vector(pos);
  }
  public boolean isAlive(){
    return alive;
  }
  public void display(Cam c){
    lastPos.add(new Vector(pos));
    for(int i=1;i<lastPos.size();i++){
      strokeWeight(8*c.zoom*((float)i/lastPos.size()));
      stroke(255,182,0,255*((float)i/lastPos.size()));
      line((lastPos.get(i-1).x-c.pos.x)*c.zoom,(lastPos.get(i-1).y-c.pos.y)*c.zoom
        ,(lastPos.get(i).x-c.pos.x)*c.zoom,(lastPos.get(i).y-c.pos.y)*c.zoom);
    }
    while(lastPos.size()>trailLength){
      lastPos.remove(0);
    }
    //ellipse((pos.x-c.pos.x)*cam.zoom,(pos.y-c.pos.y)*cam.zoom,15*cam.zoom,15*cam.zoom);
  }
}
public class Bomb extends Bullet{
  Bomb(Vector p,Vector v){
    super(p,v,1);
  }
  @Override
  public void run(){
    velo.addVec(new Vector(0,1));
    pos.addVec(velo);
    if(pos.y>waterline){
      age=0;
    }
  }
  @Override
  public void display(Cam c){
    float angle=velo.getAng()+PI/2;
    pushMatrix();
    translate((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom);
    rotate(angle);
    scale(c.zoom,c.zoom);
    if(cos(angle)<0)
      scale(1.0, -1.0);
    image(bomb,(-7)*1.5,-(14)*1.5/2,7*1.5,14*1.5);
    popMatrix();
    //ellipse((pos.x-c.pos.x)*cam.zoom,(pos.y-c.pos.y)*cam.zoom,15*cam.zoom,15*cam.zoom);
  }
}
public class Plasma extends Bullet{
  Plasma(Vector p, Vector v,int a){
    super(p,v,a);
  }
  @Override
  public void display(Cam c){
    lastPos.add(new Vector(pos));
    for(int i=1;i<lastPos.size();i++){
      strokeWeight(12*c.zoom*((float)i/lastPos.size()));
      stroke(120,175,0,255*((float)i/lastPos.size()));
      line((lastPos.get(i-1).x-c.pos.x)*c.zoom,(lastPos.get(i-1).y-c.pos.y)*c.zoom
        ,(lastPos.get(i).x-c.pos.x)*c.zoom,(lastPos.get(i).y-c.pos.y)*c.zoom);
        
      strokeWeight(6*c.zoom*((float)i/lastPos.size()));
      stroke(170,255,0,255*((float)i/lastPos.size()));
      line((lastPos.get(i-1).x-c.pos.x)*c.zoom,(lastPos.get(i-1).y-c.pos.y)*c.zoom
        ,(lastPos.get(i).x-c.pos.x)*c.zoom,(lastPos.get(i).y-c.pos.y)*c.zoom);
    }
    while(lastPos.size()>trailLength){
      lastPos.remove(0);
    }
    //ellipse((pos.x-c.pos.x)*cam.zoom,(pos.y-c.pos.y)*cam.zoom,15*cam.zoom,15*cam.zoom);
  }
}
public class PlasmaLight extends Bullet{
  PlasmaLight(Vector p, Vector v,int a){
    super(p,v,a);
  }
  @Override
  public void display(Cam c){
    //for(int i=1;i<lastPos.size();i++){
    //  strokeWeight(12*c.zoom*((float)i/lastPos.size()));
    //  stroke(120,175,0,255*((float)i/lastPos.size()));
    //  line((lastPos.get(i-1).x-c.pos.x)*c.zoom,(lastPos.get(i-1).y-c.pos.y)*c.zoom
    //    ,(lastPos.get(i).x-c.pos.x)*c.zoom,(lastPos.get(i).y-c.pos.y)*c.zoom);
        
    //  strokeWeight(6*c.zoom*((float)i/lastPos.size()));
    //  stroke(170,255,0,255*((float)i/lastPos.size()));
    //  line((lastPos.get(i-1).x-c.pos.x)*c.zoom,(lastPos.get(i-1).y-c.pos.y)*c.zoom
    //    ,(lastPos.get(i).x-c.pos.x)*c.zoom,(lastPos.get(i).y-c.pos.y)*c.zoom);
    //}
    //fill(170,255,0);
    //stroke(120,175,0);
    //strokeWeight(5*c.zoom);
    //ellipse((pos.x-c.pos.x)*cam.zoom,(pos.y-c.pos.y)*cam.zoom,10*cam.zoom,10*cam.zoom);
  }
}

public class NyanBullet extends Bullet{
  color col;
  NyanBullet connect;
  NyanBullet(Vector p,Vector v,int a,color c,NyanBullet con){
    super(p,v,a);
    col=c;
    trailLength=1;
    connect=con;
  }
   @Override
  public void run(){
    if(age>=1){
      age--;
    }
    velo.sclVec(0.99);
    pos.addVec(velo);
  }
  @Override
  public void display(Cam c){
    //lastPos.add(new Vector(pos));
    //for(int i=1;i<lastPos.size();i++){
    //  strokeWeight(12*c.zoom*((float)i/lastPos.size()));
    //  stroke(col,255*((float)i/lastPos.size()));
    //  line((lastPos.get(i-1).x-c.pos.x)*c.zoom,(lastPos.get(i-1).y-c.pos.y)*c.zoom
    //    ,(lastPos.get(i).x-c.pos.x)*c.zoom,(lastPos.get(i).y-c.pos.y)*c.zoom);
    //}
    //while(lastPos.size()>trailLength){
    //  lastPos.remove(0);
    //}
    strokeWeight(7*c.zoom);
    stroke(col);
    if(connect!=null&&connect.isAlive()){
      Vector conPos=connect.getPos();
      line((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom, (conPos.x-c.pos.x)*c.zoom,(conPos.y-c.pos.y)*c.zoom);
    }
  }
}
public class LightningBullet extends Bullet{
  LightningBullet connect;
  LightningBullet(Vector p,LightningBullet con){
    super(p,new Vector(0,0),2);
    trailLength=1;
    connect=con;
  }
   @Override
  public void run(){
    if(age>=1){
      age--;
    }
    velo.sclVec(0.99);
    pos.addVec(velo);
  }
  @Override
  public void display(Cam c){
    //lastPos.add(new Vector(pos));
    //for(int i=1;i<lastPos.size();i++){
    //  strokeWeight(12*c.zoom*((float)i/lastPos.size()));
    //  stroke(col,255*((float)i/lastPos.size()));
    //  line((lastPos.get(i-1).x-c.pos.x)*c.zoom,(lastPos.get(i-1).y-c.pos.y)*c.zoom
    //    ,(lastPos.get(i).x-c.pos.x)*c.zoom,(lastPos.get(i).y-c.pos.y)*c.zoom);
    //}
    //while(lastPos.size()>trailLength){
    //  lastPos.remove(0);
    //}
    strokeWeight(4*c.zoom);
    stroke(255,100,225);
    if(connect!=null&&connect.isAlive()){
      Vector conPos=connect.getPos();
      line((pos.x-c.pos.x)*c.zoom,(pos.y-c.pos.y)*c.zoom, (conPos.x-c.pos.x)*c.zoom,(conPos.y-c.pos.y)*c.zoom);
    }
  }
}

public class Cloud{
  float size;
  Vector pos;
  int type;
  ArrayList<Vector> points;
  ArrayList<Float> sizes;
  public Cloud(Vector p,int t){
    pos=new Vector(p);
    type=t;
    points=new ArrayList<Vector>();
    sizes=new ArrayList<Float>();
    
    if(pos.y<waterline){
      size=random(60,150);
      int size1=(int)random(2,4);
      int size2=(int)random(1,2);
      float x;
      x=0;
      for(int i=0;i<size1;i++){
        float addSize=random(80,200);
        Vector toAdd=new Vector(random(x,x+addSize/2),0);
        x+=addSize;
        //toAdd.x*=1.5;
        //toAdd.y=min(toAdd.y,-addSize*0.5);
        toAdd.sclVec(size2);
        toAdd.addVec(pos);
        points.add(toAdd);
        sizes.add(addSize*size2);
      }
      
      x=0;
      for(int i=0;i<size1;i++){
        float addSize=random(80,200);
        Vector toAdd=new Vector(random(x-addSize/2,x),0);
        x+=addSize;
        //toAdd.x*=1.5;
        //toAdd.y=min(toAdd.y,-addSize*0.5);
        toAdd.sclVec(size2);
        toAdd.addVec(pos);
        points.add(toAdd);
        sizes.add(addSize*size2);
      }
      size*=2;
    }else{
      size=0;
    }
  }
  public Cloud(Vector p,int t,boolean force){
    pos=new Vector(p);
    type=t;
    points=new ArrayList<Vector>();
    sizes=new ArrayList<Float>();
    
    if(force||pos.y<waterline){
      size=random(60,150);
      int size1=(int)random(2,4);
      int size2=(int)random(1,2);
      float x;
      x=0;
      for(int i=0;i<size1;i++){
        float addSize=random(80,200);
        Vector toAdd=new Vector(random(x,x+addSize/2),0);
        x+=addSize;
        //toAdd.x*=1.5;
        //toAdd.y=min(toAdd.y,-addSize*0.5);
        toAdd.sclVec(size2);
        toAdd.addVec(pos);
        points.add(toAdd);
        sizes.add(addSize*size2);
      }
      
      x=0;
      for(int i=0;i<size1;i++){
        float addSize=random(80,200);
        Vector toAdd=new Vector(random(x-addSize/2,x),0);
        x+=addSize;
        //toAdd.x*=1.5;
        //toAdd.y=min(toAdd.y,-addSize*0.5);
        toAdd.sclVec(size2);
        toAdd.addVec(pos);
        points.add(toAdd);
        sizes.add(addSize*size2);
      }
      size*=2;
    }else{
      size=0;
    }
  }
  public void move(Vector toMove){
    pos.addVec(toMove);
    for(int i=0;i<points.size();i++){
      points.get(i).addVec(toMove);
    }
  }
  public void display(Cam c){
    if(size>0){
      stroke(255);
      fill(255);
      arc((pos.x-c.pos.x)*cam.zoom,(pos.y-c.pos.y)*cam.zoom, size*cam.zoom,size*cam.zoom, PI,TWO_PI,CHORD);
      for(int i=0;i<points.size();i++){
        arc((points.get(i).x-c.pos.x)*cam.zoom,(points.get(i).y-c.pos.y)*cam.zoom, sizes.get(i)*cam.zoom,sizes.get(i)*cam.zoom, PI,TWO_PI,CHORD);
        //ellipse((points.get(i).x-c.pos.x)*cam.zoom,(points.get(i).y-c.pos.y)*cam.zoom,sizes.get(i)*cam.zoom,sizes.get(i)*cam.zoom);
      }
    }
  }
}

ArrayList<Particle> particles=new ArrayList<Particle>();
ArrayList<Bullet> bullets=new ArrayList<Bullet>();
ArrayList<Bullet> enemyBullets=new ArrayList<Bullet>();
ArrayList<Cloud> clouds=new ArrayList<Cloud>();

Plane p1=null;
//Alien p1;
//Plane p1=new Plane(new Vector(0,0),0);
ArrayList<Plane> bots;
Cam cam=new Cam();
int cloudRadius=4000;
float avrVelo=0;
float zoomMulti;
float waterline=1000;
boolean mouseDown=false;
float indicatorDist=80;
float indicatorWidth=20;
String mode="MENU";
Player player=new Player();
Menu menu;
Director alienArmada;
int deathTimer;
//used to make the game easier
float healthMutli=4;

//used to display captions
int captionTime=0;
String caption="";

int cloudTimer;

void startGame(Plane plane){
  waterline=1000;
  p1=plane;
  p1.health*=healthMutli;
  p1.maxHealth*=healthMutli;
  //p1.pos=new Vector(-3000,0);
  //p1=new FlagShip(new Vector(250,150));
  cam.pos=p1.getPos();
  mode="PLAY";
  deathTimer=0;
  bots=new ArrayList<Plane>();
  particles=new ArrayList<Particle>();
  bullets=new ArrayList<Bullet>();
  enemyBullets=new ArrayList<Bullet>();
  alienArmada=new Director();
  cam=new Cam();
  avrVelo=0;
  
  clouds=new ArrayList<Cloud>();
  for(int i=0;i<50;i++){
    float a=random(0,TWO_PI);
    float b=random(0,cloudRadius);
    clouds.add(new Cloud(new Vector(cos(a)*b,sin(a)*b),0));
  }
}
void startMenu(){
  bots=new ArrayList<Plane>();
  particles=new ArrayList<Particle>();
  bullets=new ArrayList<Bullet>();
  enemyBullets=new ArrayList<Bullet>();
  clouds=new ArrayList<Cloud>();
  mode="MENU";
  alienArmada=null;
  waterline=100000;
}
void setCaption(String cap,int time){
  captionTime=time;
  caption=cap;
}
void setup(){
  menu=new Menu();
  //player.pay(30000);
  noSmooth();
  fullScreen();
  
  loadImages();
  startMenu();
}

void draw(){
  zoomMulti=max(min(width/600f,1),0.2);
  if(mode.equals("MENU")){
    float menuH=min(400,height);
    float menuY=height-menuH;
    cloudTimer++;
    cam.pos=new Vector(0,0);
    cam.zoom=1;
    
    background(200,230,250);
    if(cloudTimer%200==0){
      float launchAng=random(0,PI);
      int spawnType=(int)random(0,5);
      Plane toAdd;
      if(spawnType==0){
        toAdd=new Plane(new Vector(width/2+random(-300,300),-100),launchAng);
      }else if(spawnType==1){
        toAdd=new Biplane(new Vector(width/2+random(-300,300),-100),launchAng);
      }else if(spawnType==2){
        toAdd=new WarPlane(new Vector(width/2+random(-300,300),-100),launchAng);
      }else if(spawnType==3){
        toAdd=new Bomber(new Vector(width/2+random(-300,300),-100),launchAng);
      }else{
        toAdd=new Helicopter(new Vector(width/2+random(-300,300),-100),launchAng);
      }
      toAdd.velo=new Vector(launchAng,10,true);
      toAdd.velo.y+=random(2,8);
      bots.add(toAdd);
    }
    if(cloudTimer%20==0){
      clouds.add(new Cloud(new Vector(random(-3000,3000),0),0,true));
    }
    for(int i=0;i<particles.size();i++){
      particles.get(i).run();
      if(particles.get(i).age<=0){
        particles.remove(i);
      }
    }
    
    for(int i=0;i<clouds.size();i++){
      clouds.get(i).display(cam);
      clouds.get(i).move(new Vector(2,3));
    }
    for(int i=clouds.size()-1;i>=0;i--){
      if(clouds.get(i).pos.y>height+300){
        clouds.remove(i);
      }
    }
    for(int i=0;i<particles.size();i++){
      particles.get(i).display(cam);
    }
    for(int i=0;i<bots.size();i++){
      bots.get(i).turn(cloudTimer%60<30);
      bots.get(i).run(particles);
      if(bots.get(i).pos.y>menuY+60)
      bots.get(i).health=0;
      bots.get(i).display(cam);
    }
    for(int i=bots.size()-1;i>=0;i--){
      if(bots.get(i).getHealth()<=0){
        explode2(bots.get(i).getPos(),40);
        bots.remove(i);
      }
    }
    menu.display(new Vector(0,menuY),new Vector(width,menuH));
    if(mouseDown){
      menu.click(new Vector(0,menuY),new Vector(width,menuH),getRealMousePos());
    }else{
      menu.unClick();
    }
    float logoX=(width-445)/2;
    float logoY=(menuY-106)/2;
    if(logoX<0){
      logoX=(width-229)/2;
      logoY=(menuY-168)/2;
      if(logoY>=0){
        image(logo2,logoX,logoY,229,168);
      }
    }else if(logoY>=0){
      image(logo,logoX,logoY,445,106);
    }
    fill(0);
    textAlign(TOP,RIGHT);
    textSize(20);
    text(player.money+" coins",10,10,width-20,50);
  }else if(mode.equals("PLAY")){
    //println("f"+frameRate);
    
    if(p1.isAlive()){
      p1.run(particles);
    }else{
      deathTimer++;
    }
    for(int i=0;i<bots.size();i++){
      bots.get(i).run(particles);
    }
    
    //if(mouseDown){
    //  p1.shoot(bullets);
    //}
    //if(mouseDown){
    //  p1.boost();
    //}
    //if(ADown){
    //  p1.turn(false);
    //}
    //if(DDown){
    //  p1.turn(true);
    //}
    if(p1.isAlive()){
      if(mouseDown){
        p1.shoot(bullets);
        p1.boost();
      
        float agile=p1.getAgility();
        Vector posDif=p1.getPos();
        posDif.subVec(getMousePos());
        float angDiff=nrm2Ang(posDif.getAng()-p1.getAngle()+PI);
        //println(posDif.getAng()-p1.getAngle());
        if(angDiff<-agile){
          p1.turn(false);
        }else if(angDiff>agile){
          p1.turn(true);
        }else{
          p1.setTurn(posDif.getAng());
        }
        //p1.move(getMousePos());
        //p1.face(getMousePos());
        //p1.shoot(bullets);
      }
    }else if(deathTimer==1){
      explode2(p1.getPos(),500);
    }
    
    //float repelDist=50;
    //float repelForce=1;
    //for(int i=0;i<bots.size();i++){
    //  for(int j=i+1;j<bots.size();j++){
    //    Vector posDiff=bots.get(i).getPos();
    //    posDiff.subVec(bots.get(j).getPos());
    //    float dist=posDiff.getMag();
    //    if(dist<repelDist){
    //      Vector push=new Vector(posDiff);
    //      push.nrmVec((repelDist-dist)/repelDist*repelForce);
    //      if(!(bots.get(i) instanceof FlagShip)){
    //        bots.get(i).velo.addVec(push);
    //      }
    //      if(!(bots.get(j) instanceof FlagShip)){
    //        bots.get(j).velo.subVec(push);
    //      }
    //    }
    //  }
    //}
    //for(int i=0;i<AIs.size();i++){
    //  AIs.get(i).run(p1,bullets,enemyBullets);
    //}
    alienArmada.run(p1,bullets,enemyBullets);
    for(int i=bots.size()-1;i>=0;i--){
      if(bots.get(i).getHealth()<=0){
        explode2(bots.get(i).getPos(),40);
        bots.remove(i);
      }
    }
    
    for(int i=0;i<particles.size();i++){
      particles.get(i).run();
      if(particles.get(i).age<=0){
        particles.remove(i);
      }
    }
    
    for(int i=enemyBullets.size()-1;i>=0;i--){
      enemyBullets.get(i).run();
      if(p1.hit(enemyBullets.get(i),false)&&p1.isAlive()){
        explode(enemyBullets.get(i).getPos(),10);
        enemyBullets.get(i).kill();
        enemyBullets.remove(i);
        continue;
      }
      if(enemyBullets.get(i).age<=0){
        enemyBullets.get(i).kill();
        enemyBullets.remove(i);
      }
    }
    bulletLoop:
    for(int i=bullets.size()-1;i>=0;i--){
      bullets.get(i).run();
      for(int j=0;j<bots.size();j++){
        if(bots.get(j).hit(bullets.get(i),true)){
          explode(bullets.get(i).getPos(),10);
        bullets.get(i).kill();
          bullets.remove(i);
          continue bulletLoop;
        }
      }
      if(bullets.get(i).age<=0){
        bullets.get(i).kill();
        bullets.remove(i);
      }
    }
    
    for(int i=clouds.size()-1;i>=0;i--){
      Vector test=new Vector(clouds.get(i).pos);
      Vector tempP=p1.getPos();
      test.subVec(tempP);
      if(test.getMag()>cloudRadius){
        clouds.remove(i);
        float a=random(0,TWO_PI);
        clouds.add(new Cloud(new Vector(tempP.x+cos(a)*cloudRadius,tempP.y+sin(a)*cloudRadius),0));
      }
    }
    
    //align camera
    cam.pos=p1.getPos();
    //cam.pos=new Vector(0,0);
    avrVelo=avrVelo*(49f/50)+p1.getVelo().getMag()*(1f/50);
    float tz=max(min((avrVelo-10)/(30-10),1),0.2);
    cam.zoom=(1-0.5*tz-0.2)*zoomMulti;
    //cam.zoom=1.5;
    cam.pos.x-=width/2/cam.zoom;
    cam.pos.y-=height/2/cam.zoom;
    
    float highDark=p1.heightEfficiency();
    float highLight=1-highDark;
    background(200*highDark+0*highLight,230*highDark+75*highLight,250*highDark+120*highLight);
    //fill(0,50);
    //rect(0,0,800,800);
    
    for(int i=0;i<clouds.size();i++){
      clouds.get(i).display(cam);
    }
    
    for(int i=0;i<particles.size();i++){
      particles.get(i).display(cam);
    }
    
    for(int i=0;i<bullets.size();i++){
      bullets.get(i).display(cam);
    }
    for(int i=0;i<enemyBullets.size();i++){
      enemyBullets.get(i).display(cam);
    }
    
    if(p1.isAlive()){
      p1.display(cam);
    }
    Vector centerPos=p1.dispPos(cam);
    stroke(200,0,0,50);
    noFill();
    strokeWeight(2);
    float circleDist=(indicatorDist*2+indicatorWidth);
    //ellipse(centerPos.x,centerPos.y,circleDist,circleDist);
    for(int i=0;i<bots.size();i++){
      bots.get(i).display(cam);
      Vector botPos=bots.get(i).dispPos(cam);
      float botAng=centerPos.getAng(botPos);
      
      Vector indicatorStart=new Vector(botAng,indicatorDist,true);
      indicatorStart.addVec(centerPos);
      Vector indicatorEnd=new Vector(botAng,indicatorDist+indicatorWidth,true);
      indicatorEnd.addVec(centerPos);
      stroke(200,0,0,150);
      strokeWeight(2);
      line(indicatorStart.x,indicatorStart.y,indicatorEnd.x,indicatorEnd.y);
    }
    noStroke();
    //fill(21,135,181,100);
    fill(0,135,188,130);
    rect(0,max((waterline-cam.pos.y)*cam.zoom,0),width,height);
    rect(0,max((waterline+150-cam.pos.y)*cam.zoom,0),width,height);
    rect(0,max((waterline+450-cam.pos.y)*cam.zoom,0),width,height);
    
    //display health bar
    float healthPercent=max(p1.getHealthPercent(),0);
    float hBarBorder=2;
    noStroke();
    fill(0,0,0);
    rect(10-hBarBorder,10-hBarBorder, width/2+hBarBorder*2, 20+hBarBorder*2);
    fill(0,230,100);
    rect(10,10, width/2*healthPercent, 20);
    
    //display money
    fill(0);
    textAlign(RIGHT,TOP);
    textSize(20);
    text(player.money+" coins",10,10,width-20,50);
    
    if(captionTime>0){
      fill(0,min(captionTime*4,255));
      textAlign(CENTER,CENTER);
      textSize(20);
      text(caption,0,height/2,width,150);
      captionTime--;
    }
    
    if(!p1.isAlive()){
      fill(255,min(deathTimer,50)/50f*120);
      noStroke();
      rect(0,0,width,height);
      fill(0);
      textAlign(CENTER,CENTER);
      textSize(20);
      int wave=alienArmada.getWave();
      String waveStr;
      if(wave<6){
        waveStr="WAVE "+wave+"";
      }else if(wave<10){
        waveStr="WAVE "+wave+"!";
      }else if(wave<50){
        waveStr="WAVE "+wave+"!!!";
      }else if(wave<250){
        waveStr="WAVE "+wave+"!?!!!";
      }else{
        waveStr="WAVE "+wave+"!!!?! HOW?!?!";
      }
      text("game over",0,height/2-20,width,50);
      text("You made it to "+waveStr,0,height/2,width,50);
      if(deathTimer>50){
        text("(click anywhere to continue)",0,height/2+30,width,50);
        if(mouseDown){
          startMenu();
        }
      }
    }
    
    //code for showing hitboxes
    //for(int x=0;x<400;x+=4){
    //  for(int y=0;y<400;y+=4){
    //    if(p1.hit(new Bullet(new Vector(x,y),new Vector(0,0),100),false)){
    //      //fill(255,0,0);
    //      noFill();
    //    }else{
    //      fill(0,255,0);
    //    }
    //    rect((x-cam.pos.x)*cam.zoom,(y-cam.pos.y)*cam.zoom,4*cam.zoom,4*cam.zoom);
    //  }
    //}
  }
}

Vector getMousePos(){
  Vector mPos=new Vector(mouseX,mouseY);
  //println(cam.pos);
  mPos.sclVec(1/cam.zoom);
  mPos.addVec(cam.pos);
  return mPos;
}
Vector getRealMousePos(){
  Vector mPos=new Vector(mouseX,mouseY);
  return mPos;
}
void explode(Vector pos,int power){
  for(int i=0;i<power;i++){
    particles.add(new Particle(new Vector(pos),new Vector(random(0,TWO_PI),10,true),40,30));
  }
}
void explode2(Vector pos,int power){
  for(int i=0;i<power;i++){
    Vector spawnAt=new Vector(random(0,20),random(0,TWO_PI),true);
    spawnAt.addVec(pos);
    particles.add(new Particle(spawnAt,new Vector(random(0,TWO_PI),random(5,20),true),(int)random(10,100),random(10,50)));
  }
}

float nrmAng(float ang){
  float newAng=ang;
  while(newAng<0){
    newAng+=TWO_PI;
  }
  while(newAng>TWO_PI){
    newAng-=TWO_PI;
  }
  return newAng;
}
float nrm2Ang(float ang){
  float newAng=ang;
  while(newAng<-PI){
    newAng+=TWO_PI;
  }
  while(newAng>PI){
    newAng-=TWO_PI;
  }
  return newAng;
}

boolean WDown=false;
boolean ADown=false;
boolean SDown=false;
boolean DDown=false;
boolean SPACEDown=false;
boolean SHIFTDown=false;

void mousePressed(){
  mouseDown=true;
}
void mouseReleased(){
  mouseDown=false;
}
void keyPressed(){
   if(key=='w'||key=='W'){
     WDown=true;
   }
   if(key=='a'||key=='A'){
     ADown=true;
   }
   if(key=='s'||key=='S'){
     SDown=true;
   }
   if(key=='d'||key=='D'){
     DDown=true;
   }
   if(key==' '){
     SPACEDown=true;
   }
   if(keyCode==SHIFT){
     SHIFTDown=true;
   }
}
void keyReleased(){
   if(key=='w'||key=='W'){
     WDown=false;
   }
   if(key=='a'||key=='A'){
     ADown=false;
   }
   if(key=='s'||key=='S'){
     SDown=false;
   }
   if(key=='d'||key=='D'){
     DDown=false;
   }
   if(key==' '){
     SPACEDown=false;
   }
   if(keyCode==SHIFT){
     SHIFTDown=false;
   }
}
