class SpawnQueue{
  int time;
  AlienAI spawn;
  SpawnQueue(AlienAI ai,int t){
    spawn=ai;
    time=t;
  }
  void run(){
    time--;
    if(time==0){
      bots.add(spawn.getPlane());
      spawn.activate();
    }
  }
  boolean isAlive(){
    return time>0;
  }
}
class Director{
  ArrayList<SpawnQueue> queue;
  int spawnDelay;
  ArrayList<AlienAI> flyers;//bots that are free to fly on their own
  ArrayList<ShieldAI> shields;
  ArrayList<SwarmerAI> swarm;
  ArrayList<BlockAI> blocks;
  ArrayList<SniperAI> snipers;
  AlienAI commander;
  float rot;
  int waveKills;
  int currentWave;
  Director(){
    queue=new ArrayList<SpawnQueue>();
    spawnDelay=80;
    flyers=new ArrayList<AlienAI>();
    shields=new ArrayList<ShieldAI>();
    swarm=new ArrayList<SwarmerAI>();
    blocks=new ArrayList<BlockAI>();
    snipers=new ArrayList<SniperAI>();
    
    currentWave=1;
    spawnWave(currentWave);
    
    //Alien leaderAdd=new FlagShip(new Vector(1000+random(-2000,2000),random(-500,500)));
    //AlienAI ai=new AlienAI(leaderAdd);
    //commander=ai;
    //bots.add(leaderAdd);
    //for(int i=0;i<30;i++){
    //  spawnShield();
    //}
  }
  Vector getSpawnPos(){
    Vector spawnCenter=p1.getPos();
    float x=spawnCenter.x;
    float y=spawnCenter.y;
    float yMin=max(y-2000,-1500);
    float yMax=min(y+2000,waterline);
    y=random(yMin,yMax);
    y=max(min(y,waterline),-1500);
    x+=random(-2000,2000);
    return new Vector(x,y);
  }
  int getWave(){
    return currentWave;
  }
  void spawnWave(int wave){
    int payout=0;
    //for(int i=2;i<wave;i++){
    //  payout+=(i-1)*50;
    //}
    //payout/=2;
    payout+=(wave-1)*25;
    player.pay(payout);
    
    setCaption("WAVE "+wave,120);
    
    waveKills=0;
    
    //if there is no commander at a high wave summon a commander wave
    if(wave>=10&&commander==null){
      waveKills+=waveCommander(wave);
    }else{
      //summon primary wave
      int primeWave=(int)random(0,4);
      switch(primeWave){
        case 0:
          waveKills+=waveGunner(wave);
          break;
        case 1:
          waveKills+=waveSwarm(wave);
          break;
        case 2:
          waveKills+=waveGeneral(wave);
          break;
        case 3:
          waveKills+=waveSniper(wave);
          break;
        default:
          break;
      }
    }
    //summon smaller support secondary wave (general, swarm or support)
    if(wave>2){
      int supportWave=(int)random(0,3);
      switch(supportWave){
        case 0:
          waveKills+=waveSupport(wave-2);
          break;
        case 1:
          waveKills+=waveSwarm(wave-2);
          break;
        case 2:
          waveKills+=waveGeneral(wave-2);
          break;
        default:
          break;
      }
    }
    //must kill all ships up to _15_, if there are more than that then kill _80%_ of them
    waveKills=max((int)(waveKills*0.8),min(waveKills,15));
    //spawnArcher();
    //spawnArcher();
    //spawnShield();
  }
  //summons general units
  //like: gunner, heavy gunner, dart
  int waveGeneral(int wave){
    int count=0;
    int spawnNum;
    
    spawnNum=(int)max(random(0,wave/2),2);
    count+=spawnNum;
    for(int i=0;i<spawnNum;i++){
      spawnGunner();
    }
    
    spawnNum=(int)random(0,wave/4);
    count+=spawnNum;
    for(int i=0;i<spawnNum;i++){
      spawnHeavyGunner();
    }
    
    spawnNum=(int)random(wave/2,wave);
    count+=spawnNum;
    for(int i=0;i<spawnNum;i++){
      spawnDart();
    }
    return count;
  }
  //summons gunner units
  //like: shotgun, heavy gunner, archer
  int waveGunner(int wave){
    int count=0;
    int spawnNum;
    
    spawnNum=(int)max(random(wave/4,wave/2),5);
    count+=spawnNum;
    for(int i=0;i<spawnNum;i++){
      spawnGunner();
    }
    
    spawnNum=(int)random(0,wave/4);
    count+=spawnNum;
    for(int i=0;i<spawnNum;i++){
      spawnHeavyGunner();
    }
    
    if(random(0,1)<0.5){
      spawnNum=(int)max(random(0,wave/2),2);
      count+=spawnNum;
      for(int i=0;i<spawnNum;i++){
        spawnShotGunner();
      }
    }else{
      spawnNum=(int)max(random(0,wave/2),2);
      count+=spawnNum;
      for(int i=0;i<spawnNum;i++){
        spawnArcher();
      }
    }
    return count;
  }
  //summons sniper related units
  //like: archer, shield
  int waveSniper(int wave){
    int count=0;
    int spawnNum;
    
    spawnNum=(int)max(random(wave/2,wave),1);
    count+=spawnNum;
    for(int i=0;i<spawnNum;i++){
      spawnArcher();
    }
    if(shields.size()<30){
      spawnNum=(int)random(0,wave);
      //count+=spawnNum;
      for(int i=0;i<spawnNum;i++){
        spawnShield();
      }
    }
    return count;
  }
  //summons support units
  //like: bug, mine, shield
  int waveSupport(int wave){
    int count=0;
    int spawnNum;
    
    spawnNum=(int)max(random(wave/2,wave*2),4);
    count+=spawnNum;
    for(int i=0;i<spawnNum;i++){
      spawnBug();
    }
    spawnNum=(int)random(wave/2,wave*2);
    count+=spawnNum;
    for(int i=0;i<spawnNum;i++){
      spawnMine();
    }
    spawnNum=(int)random(0,wave*0.75);
    //count+=spawnNum;
    for(int i=0;i<spawnNum;i++){
      spawnShield();
    }
    return count;
  }
  //summons swarmers
  //like: swarmer
  int waveSwarm(int wave){
    int count=0;
    int spawnNum;
    
    spawnNum=(int)max(random(wave*2,wave*4),8);
    count+=spawnNum;
    for(int i=0;i<spawnNum;i++){
      spawnSwarmer();
    }
    return count;
  }
  //summons flag ship and units to defend it
  //like: flagship, shield, archer, bug
  int waveCommander(int wave){
    int count=0;
    int spawnNum;
    
    Alien leaderAdd=new FlagShip(getSpawnPos());
    AlienAI ai=new AlienAI(leaderAdd);
    commander=ai;
    bots.add(leaderAdd);
    
    if(shields.size()<30){
      spawnNum=(int)random(wave/2,wave);
      //count+=spawnNum;
      for(int i=0;i<spawnNum;i++){
        spawnShield();
      }
    }
    spawnNum=(int)random(0,wave*0.75);
    count+=spawnNum;
    for(int i=0;i<spawnNum;i++){
      spawnArcher();
    }
    spawnNum=(int)random(wave,wave*2);
    count+=spawnNum;
    for(int i=0;i<spawnNum;i++){
      spawnBug();
    }
    return count;
  }
  void spawnShield(){
    Alien toAdd=new Shield(getSpawnPos(),random(0,TWO_PI));
    ShieldAI ai=new ShieldAI(toAdd);
    shields.add(ai);
    queueSpawn(ai,spawnDelay,200);
  }
  void spawnMine(){
    Alien toAdd=new Mine(getSpawnPos(),random(0,TWO_PI));
    StalkerAI ai=new StalkerAI(toAdd,100);
    flyers.add(ai);
    queueSpawn(ai,spawnDelay,100);
  }
  void spawnBug(){
    Alien toAdd=new Bug(getSpawnPos(),random(0,TWO_PI));
    BlockAI ai=new BlockAI(toAdd);
    blocks.add(ai);
    queueSpawn(ai,spawnDelay,100);
  }
  void spawnShotGunner(){
    Alien toAdd=new ShotGunner(getSpawnPos(),random(0,TWO_PI));
    StalkerAI ai=new StalkerAI(toAdd,400);
    flyers.add(ai);
    queueSpawn(ai,spawnDelay,180);
  }
  void spawnGunner(){
    Alien toAdd=new Gunner(getSpawnPos(),random(0,TWO_PI));
    AlienAI ai=new AlienAI(toAdd);
    flyers.add(ai);
    queueSpawn(ai,spawnDelay,150);
  }
  void spawnHeavyGunner(){
    Alien toAdd=new HeavyGunner(getSpawnPos(),random(0,TWO_PI));
    AlienAI ai=new AlienAI(toAdd);
    flyers.add(ai);
    queueSpawn(ai,spawnDelay,170);
  }
  void spawnDart(){
    Alien toAdd=new Dart(getSpawnPos(),random(0,TWO_PI));
    AlienAI ai=new AlienAI(toAdd);
    flyers.add(ai);
    queueSpawn(ai,spawnDelay,120);
  }
  void spawnArcher(){
    Alien toAdd=new Archer(getSpawnPos(),random(0,TWO_PI));
    SniperAI ai=new SniperAI(toAdd);
    //ai.setCover(shields.get((int)random(0,shields.size())));
    snipers.add(ai);
    queueSpawn(ai,spawnDelay,200);
  }
  void spawnSwarmer(){
    Alien toAdd=new Swarmer(getSpawnPos(),random(0,TWO_PI));
    SwarmerAI ai=new SwarmerAI(toAdd);
    swarm.add(ai);
    queueSpawn(ai,spawnDelay,100);
  }
  void queueSpawn(AlienAI toSpawn,int spawnTime,int size){
    particles.add(new SpawnWarning(toSpawn.getPlane().getPos(),new Vector(0,0),spawnTime,size));
    queue.add(new SpawnQueue(toSpawn,spawnTime));
  }
  void run(Plane target,ArrayList<Bullet> playerBts,ArrayList<Bullet> alienBts){
    //spawn wave
    if(waveKills<=0){
      currentWave++;
      spawnWave(currentWave);
    }
    
    //spawn queued
    for(int i=queue.size()-1;i>=0;i--){
      queue.get(i).run();
      if(!queue.get(i).isAlive()){
        queue.remove(i);
      }
    }
    
    for(int i=flyers.size()-1;i>=0;i--){
      if(!flyers.get(i).isAlive()){
        flyers.remove(i);
        waveKills--;
      }
    }
    for(int i=shields.size()-1;i>=0;i--){
      if(!shields.get(i).isAlive()){
        shields.remove(i);
        waveKills--;
      }
    }
    for(int i=swarm.size()-1;i>=0;i--){
      if(!swarm.get(i).isAlive()){
        swarm.remove(i);
        waveKills--;
      }
    }
    for(int i=blocks.size()-1;i>=0;i--){
      if(!blocks.get(i).isAlive()){
        blocks.remove(i);
        waveKills--;
      }
    }
    for(int i=snipers.size()-1;i>=0;i--){
      if(!snipers.get(i).isAlive()){
        snipers.remove(i);
        waveKills--;
      }
    }
    
    //general behaviour
    repel();
    for(int i=0;i<flyers.size();i++){
      if(flyers.get(i).isActive())
        flyers.get(i).run(target,playerBts,alienBts);
    }
    //try to form chains with swarm
    if(swarm.size()>1){
      int tryJoin=(int)random(0,swarm.size());
      int tryJoin2=(int)random(0,swarm.size());
      SwarmerAI tarJoin=swarm.get(tryJoin);
      SwarmerAI tarJoin2=swarm.get(tryJoin2);
      if(tryJoin!=tryJoin2&&tarJoin.isLeader()&&tarJoin.isActive()&&tarJoin2.isActive()){
        SwarmerAI follow=swarm.get(tryJoin2);
        while(follow!=null&&!follow.isLeader()){
          follow=follow.getFollow();
        }
        if(follow!=tarJoin&&follow!=null){
          SwarmerAI end=tarJoin2;
          while(end!=null&&!end.isEnd()){
            end=end.getFollower();
          }
          if(end!=null){
            tarJoin.setFollow(end);
          }
        }
      }
    }
    
    //leaderless behaviour
    if(commander==null){
      for(int i=0;i<shields.size();i++){
        if(shields.get(i).isActive())
          shields.get(i).run(target,playerBts,alienBts);
      }
      for(int i=0;i<swarm.size();i++){
        if(swarm.get(i).isActive())
          swarm.get(i).run(target,playerBts,alienBts);
      }
      for(int i=0;i<blocks.size();i++){
        if(blocks.get(i).isActive())
          blocks.get(i).run(target,playerBts,alienBts);
      }
      for(int i=0;i<snipers.size();i++){
        if(snipers.get(i).isActive())
          snipers.get(i).run(target,playerBts,alienBts);
      }
    
      //try to guard ships
      if(blocks.size()>1){
        int tryBlock=(int)random(0,blocks.size());
        if(blocks.get(tryBlock).isActive()&&!blocks.get(tryBlock).isDefending()){
          if(shields.size()>0){
            blocks.get(tryBlock).setDefend(shields.get((int)random(0,shields.size())));
          }
        }
      }
      //try to hide behind shields
      if(snipers.size()>0){
        int trySnipe=(int)random(0,snipers.size());
        if(snipers.get(trySnipe).isActive()&&!snipers.get(trySnipe).hasCover()){
          if(shields.size()>0){
            snipers.get(trySnipe).setCover(shields.get((int)random(0,shields.size())));
          }
        }
      }
    }else{
      if(!commander.isAlive()){
        commander=null;
      }else{
        rot+=0.001;
        commander.run(target,playerBts,alienBts);
        
        Vector cmdPos=commander.getPlane().getPos();
        float radius=shields.size()*150/TWO_PI;
        radius=max(radius,500);
        int sNum=shields.size();
        //leader behaviour
        for(int i=0;i<shields.size();i++){
          if(shields.get(i).isActive()){
            float tarAng=i*TWO_PI/sNum+rot;
            Vector moveTo=new Vector(tarAng,radius,true);
            moveTo.addVec(cmdPos);
            shields.get(i).command(moveTo,tarAng+PI);
          }
        }
        for(int i=0;i<swarm.size();i++){
          if(swarm.get(i).isActive())
            swarm.get(i).command(target,alienBts,commander,radius,radius+2500);
        }
        for(int i=0;i<blocks.size();i++){
          if(blocks.get(i).isActive())
            blocks.get(i).command(playerBts,commander,radius);
        }
        int snpNum=snipers.size();
        for(int i=0;i<snipers.size();i++){
          if(snipers.get(i).isActive()){
            float tarAng=i*TWO_PI/snpNum+rot;
            Vector moveTo=new Vector(tarAng,radius-200,true);
            moveTo.addVec(cmdPos);
            snipers.get(i).command(target,alienBts,moveTo);
          }
        }
      }
    }
  }
  void repel(){
    float repelDist=50;
    float repelForce=1;
    for(int i=0;i<flyers.size();i++){
      for(int j=i+1;j<flyers.size();j++){
        Vector posDiff=flyers.get(i).getPlane().getPos();
        posDiff.subVec(flyers.get(j).getPlane().getPos());
        float dist=posDiff.getMag();
        if(dist<repelDist){
          Vector push=new Vector(posDiff);
          push.nrmVec((repelDist-dist)/repelDist*repelForce);
          flyers.get(i).getPlane().velo.addVec(push);
          flyers.get(j).getPlane().velo.subVec(push);
        }
      }
    }
    for(int i=0;i<blocks.size();i++){
      for(int j=i+1;j<blocks.size();j++){
        Vector posDiff=blocks.get(i).getPlane().getPos();
        posDiff.subVec(blocks.get(j).getPlane().getPos());
        float dist=posDiff.getMag();
        if(dist<repelDist){
          Vector push=new Vector(posDiff);
          push.nrmVec((repelDist-dist)/repelDist*repelForce);
          blocks.get(i).getPlane().velo.addVec(push);
          blocks.get(j).getPlane().velo.subVec(push);
        }
      }
    }
    repelDist=80;
    repelForce=1;
    for(int i=0;i<snipers.size();i++){
      for(int j=i+1;j<snipers.size();j++){
        Vector posDiff=snipers.get(i).getPlane().getPos();
        posDiff.subVec(snipers.get(j).getPlane().getPos());
        float dist=posDiff.getMag();
        if(dist<repelDist){
          Vector push=new Vector(posDiff);
          push.nrmVec((repelDist-dist)/repelDist*repelForce);
          snipers.get(i).getPlane().velo.addVec(push);
          snipers.get(j).getPlane().velo.subVec(push);
        }
      }
    }
  }
}
class AlienAI{
  Alien alien;
  boolean active;
  AlienAI(Alien a){
    alien=a;
    active=false;
  }
  void run(Plane target,ArrayList<Bullet> playerBts,ArrayList<Bullet> alienBts){
    Vector movePos=alien.getPos();
    movePos.subVec(target.getPos());
    movePos.nrmVec(200);
    movePos.addVec(target.getPos());
    alien.move(movePos);
    alien.face(target.getPos());
    alien.shoot(alienBts);
  }
  void activate(){
    active=true;
  }
  boolean isAlive(){
    return alien.isAlive();
  }
  boolean isActive(){
    return active;
  }
  Alien getPlane(){
    return alien; 
  }
}
class ShieldAI extends AlienAI{
  ShieldAI(Alien a){
    super(a);
  }
  @Override
  void run(Plane target,ArrayList<Bullet> playerBts,ArrayList<Bullet> alienBts){
    alien.face(target.getPos());
  }
  void command(Vector target,float tarAng){
    alien.move(target);
    alien.face(tarAng);
  }
}
class BlockAI extends AlienAI{
  AlienAI defend;
  float bulletTime;
  BlockAI(Alien a){
    super(a);
    defend=null;
    bulletTime=0;
  }
  void setDefend(AlienAI toDef){
    defend=toDef;
  }
  boolean isDefending(){
    return defend!=null;
  }
  @Override
  void run(Plane target,ArrayList<Bullet> playerBts,ArrayList<Bullet> alienBts){
    for(int i=0;i<playerBts.size();i++){
      Vector btPos=playerBts.get(i).getPos();
      if(btPos.getMag(alien.getPos())<300){
        Vector movePos=btPos;
        alien.move(movePos);
        bulletTime=100;
        return;
      }
    }
    
    if(bulletTime<=0){
      if(defend!=null){
        if(defend.isAlive()){
          Vector defPos=defend.getPlane().getPos();
          if(defPos.getMag(alien.getPos())>200){
            float defAng=defPos.getAng(alien.getPos());
            defAng+=0.002;
            Vector movePos=new Vector(defAng,150,true);
            movePos.addVec(defPos);
            alien.move(movePos);
          }else{
            float defAng=defPos.getAng(alien.getPos());
            float defMag=defPos.getMag(alien.getPos());
            defAng+=0.002;
            Vector movePos=new Vector(defAng,defMag,true);
            movePos.addVec(defPos);
            alien.move(movePos);
          }
        }else{
          defend=null;
        }
      }
    }else{
      bulletTime--;
    }
  }
  void command(ArrayList<Bullet> playerBts,AlienAI commander,float radius){
    Vector cmdPos=commander.getPlane().getPos();
    for(int i=0;i<playerBts.size();i++){
      Vector btPos=playerBts.get(i).getPos();
      if(btPos.getMag(alien.getPos())<300){
        if(btPos.getMag(cmdPos)<radius){
          Vector movePos=btPos;
          alien.move(movePos);
          bulletTime=100;
          return;
        }
      }
    }
    
    if(bulletTime<=0){
      if(cmdPos.getMag(alien.getPos())>radius-100){
        float defAng=cmdPos.getAng(alien.getPos());
        defAng-=0.0005;
        Vector movePos=new Vector(defAng,radius-150,true);
        movePos.addVec(cmdPos);
        alien.move(movePos);
      }else{
        float defAng=cmdPos.getAng(alien.getPos());
        float defMag=cmdPos.getMag(alien.getPos());
        defAng-=0.0005;
        Vector movePos=new Vector(defAng,defMag,true);
        movePos.addVec(cmdPos);
        alien.move(movePos);
      }
    }else{
      bulletTime--;
    }
  }
}
class StalkerAI extends AlienAI{
  float range;
  StalkerAI(Alien a,float r){
    super(a);
    range=r;
  }
  @Override
  void run(Plane target,ArrayList<Bullet> playerBts,ArrayList<Bullet> alienBts){
    Vector movePos=alien.getPos();
    movePos.subVec(target.getPos());
    if(movePos.getMag()<range){
      alien.shoot(alienBts);
    }
    movePos.nrmVec(range);
    movePos.addVec(target.getPos());
    alien.move(movePos);
    alien.face(target.getPos());
  }
}
class SniperAI extends AlienAI{
  AlienAI cover;
  SniperAI(Alien a){
    super(a);
    cover=null;
  }
  void setCover(AlienAI toCov){
    cover=toCov;
  }
  boolean hasCover(){
    return cover!=null;
  }
  @Override
  void run(Plane target,ArrayList<Bullet> playerBts,ArrayList<Bullet> alienBts){
    if(cover!=null&&!cover.isAlive()){
      cover=null;
    }
    if(cover!=null){
      Vector covPos=cover.getPlane().getPos();
      float covAng=covPos.getAng(target.getPos())+PI;
      Vector movePos=new Vector(covAng,100,true);
      movePos.addVec(covPos);
      alien.move(movePos);
    }else{
      alien.move(target.getPos());
    }
    alien.face(target.getPos());
    alien.shoot(alienBts);
  }
  void command(Plane target,ArrayList<Bullet> alienBts,Vector tarPos){
    alien.move(tarPos);
    alien.face(target.getPos());
    alien.shoot(alienBts);
  }
}
class SwarmerAI extends AlienAI{
  SwarmerAI follow;
  SwarmerAI follower;
  SwarmerAI(Alien a){
    super(a);
    follow=null;
    follower=null;
  }
  void setFollower(SwarmerAI toFol){
    follower=toFol;
  }
  SwarmerAI getFollower(){
    if(follower!=null&&!follower.isAlive()){
      follower=null;
    }
    return follower;
  }
  void setFollow(SwarmerAI toFol){
    follow=toFol;
    follow.setFollower(this);
  }
  SwarmerAI getFollow(){
    if(follow!=null&&!follow.isAlive()){
      follow=null;
    }
    return follow;
  }
  boolean isLeader(){
    return follow==null;
  }
  boolean isEnd(){
    return follower==null;
  }
  @Override
  void run(Plane target,ArrayList<Bullet> playerBts,ArrayList<Bullet> alienBts){
    if(follow!=null&&!follow.isAlive()){
      follow=null;
    }
    if(follower!=null&&!follower.isAlive()){
      follower=null;
    }
    if(follow!=null){
      Vector folPos=follow.getPlane().getPos();
      Vector alnPos=alien.getPos();
      
      Vector movePos=new Vector(folPos);
      movePos.subVec(alnPos);
      float dist=movePos.getMag();
      movePos.sclVec(1/20f);
      movePos.addVec(alnPos);
      
      alien.move(movePos);
      alien.face(folPos);
      alien.shoot(alienBts);
    }else{
      Vector movePos=new Vector(alien.getAngle(),5,true);
      movePos.addVec(alien.getPos());
      
      alien.move(movePos);
      alien.face(target.getPos());
      alien.shoot(alienBts);
    }
  }
  void command(Plane target,ArrayList<Bullet> alienBts,AlienAI commander,float radius,float attackRadius){
    Vector cmdPos=commander.getPlane().getPos();
    if(follow!=null&&!follow.isAlive()){
      follow=null;
    }
    if(follower!=null&&!follower.isAlive()){
      follower=null;
    }
    if(follow!=null){
      Vector folPos=follow.getPlane().getPos();
      Vector alnPos=alien.getPos();
      
      Vector movePos=new Vector(folPos);
      movePos.subVec(alnPos);
      float dist=movePos.getMag();
      if(target.getPos().getMag(cmdPos)<attackRadius||alnPos.getMag(cmdPos)>radius){
        movePos.sclVec(1/20f);
      }else{
        movePos.sclVec(1/80f);
      }
      movePos.addVec(alnPos);
      
      alien.move(movePos);
      alien.face(folPos);
      alien.shoot(alienBts);
    }else{
      Vector alnPos=alien.getPos();
      if(target.getPos().getMag(cmdPos)<attackRadius){
        Vector movePos=new Vector(alien.getAngle(),5,true);
        movePos.addVec(alien.getPos());
        alien.move(movePos);
        alien.face(target.getPos());
      }else{
        if(alnPos.getMag(cmdPos)>radius){
          Vector movePos=new Vector(alien.getAngle(),5,true);
          movePos.addVec(alien.getPos());
          alien.move(movePos);
        }else{
          Vector movePos=new Vector(alien.getAngle(),1,true);
          movePos.addVec(alien.getPos());
          alien.move(movePos);
        }
        alien.face(cmdPos);
      }
      alien.shoot(alienBts);
    }
  }
}
