import de.bezier.data.sql.*;

class sqlData {
  int carId;
  float x, y;
  float speed;
  int  time;
  String status;
  sqlData() {}
}

class SQL {
  MySQL msql;
  MySQL remote;
  
  SQL(MySQL msql, MySQL remote) { 
    this.msql = msql; 
    this.remote = remote;
    msql.connect();
    println("Connected to local DB");
    remote.connect();
    println("Connected to remote DB");
  }
  void loadCars() {
    msql.query( "SELECT * FROM cars  WHERE active = 1 ORDER BY carId");
    while (msql.next ())
    {
        int id = msql.getInt("carId");
         String name = msql.getString("name");
         String theColor = msql.getString("color");;
         Car c = new Car(id, name);
         c.setColor(theColor);
         cars.add(c);
    }
   
   }
 int loadTramos() {
   msql.query( "SELECT count(*) as n FROM tramos WHERE rally = '" + rally + "'");
   while (msql.next()){
     return msql.getInt("n");
   }
   return 0;
 }
 Tramo loadTramo(int focus){
  
    
    String q = "SELECT * FROM tramos WHERE rally = '" + rally + "'";
    msql.query( q);
    int i = 0;
    while (msql.next ())
    {  
         if(i < focus) {
           i += 1;
           continue;
         }
         String prueba = msql.getString("rally");
         int id = msql.getInt("id");
         String fileName =  prueba + "/" + str(id) + "/" + str(id) + "_utm.txt";
         int start =  msql.getInt("start");
         int end = -abs(msql.getInt("end"));
         String initTime = msql.getString("initTime");
         String endTime = msql.getString("endTime");
         return new Tramo(prueba, id, fileName, start, end, initTime, endTime);
     }
     return null;
 }
  void updateTramoStartEnd(int id, int start, int end){
      msql.execute( "UPDATE tramos SET start = " + str(start) + " WHERE id ="+ str(id));
      msql.execute( "UPDATE tramos SET end = " + str(end) + " WHERE id ="+ str(id));
  }
  
  
  void setInit(int id, String timeStamp){
         msql.execute( "UPDATE tramos SET initTime = '" + timeStamp + "' WHERE id = "+ str(id));
  }
  void setEnd(int id, String timeStamp){
         msql.execute( "UPDATE tramos SET endTime = '" + timeStamp + "' WHERE id = "+ str(id));
  }
  
  void remove() {
   
    String iDate =  tramos.initDate();
    String eDate =  tramos.endDate();
    
    msql.query("DELETE FROM tracks WHERE tramoId = " + str(tramos.tramo.id) + " and rally = '" + rally + "'");
    String q = "UPDATE data SET processed = 0 WHERE timeStamp > '" + iDate+ "' " + " and  timeStamp < '" + eDate+ "'" ;
    println(q);
    remote.query(q);
  }
   void markAsProcessed() {
   
    String iDate =  tramos.initDate();
    String eDate =  tramos.endDate();
    String q = "UPDATE data SET processed = 1 WHERE timeStamp > '" + iDate+ "' " + " and  timeStamp < '" + eDate+ "'" ;
    println(q);
    remote.query(q);
  }
  void removeTracks(){
    String q = "DELETE FROM tracks WHERE tramoId = " + str(tramos.tramo.id) + " and rally = '" + rally + "'";
     msql.query(q);
     println(q);

  }
  
  void updateDiferido() {
    String iDate =  rt.getPrevElapsed();
    String eDate =  rt.getElapsed();
    rt.setPrevElapsed(eDate);
    String q = "UPDATE data SET processed = 0 WHERE timeStamp > '" + iDate+ "' " + " and  timeStamp < '" + eDate+ "'" ;
    
     println(q);
    remote.query(q);
  }
  
  void process() {
    if(rt.running) updateDiferido();
    
    String iDate =  tramos.initDate();
    String eDate =  tramos.endDate();
    remote.query( "SELECT count(*) as n FROM data WHERE processed = 0 and timeStamp > '" 
                + iDate+ "' " + " and  timeStamp < '" + eDate+ "'" );
    
    while (remote.next ()){
      int total = remote.getInt("n");
      println("Processing... " + total + " rows");
      break;
    }
    String q = "SELECT * FROM data WHERE processed = 0 and timeStamp > '" 
                    + iDate+ "' " + " and  timeStamp < '" + eDate+ "'";
    println(q);
    remote.query(q);
    ArrayList<sqlData> data = new ArrayList<sqlData>();
    while (remote.next ())
    {
      sqlData s = new sqlData();
      s.carId= remote.getInt("carId"); 
      s.x = remote.getFloat("x"); 
      s.y = remote.getFloat("y"); 
      s.speed = remote.getFloat("speed"); 
      try{
        s.time = int(remote.getString("time").substring(5, 10));
      }catch(Exception e){
        s.time = int(remote.getString("time"));
        print(e);
        continue;
      }
      s.status =  remote.getString("status");
      data.add(s);
    }

    for (sqlData s: data) 
      cars.addData(s.carId, s.x, s.y, s.speed, s.time, s.status);
    
    remote.execute( "UPDATE data SET processed = 1");
    
  }
  
  void insertTrack(String s, boolean full) {
    if (full)
      msql.query("INSERT INTO tracks VALUES (" + s  + ")");  
    else
      msql.query("INSERT INTO tracks (CarId, TramoId, rally, realIndex, avgSpeed, trackTime, trackDistance, remainingDistance) VALUES (" + s  + ")");
  }
  void insertResult(int carId, int tramoId, float time){
    String q = "DELETE FROM results WHERE tramoId = " + str(tramoId) + " and carId = " + str(carId) + " and rally = " +  "'" +  rally +  "'";
    msql.query(q);
    String s = str(carId) + "," + str(tramoId) + ",'" + rally + "'," + str(time) + ",'" + int(time)/60 + ":" + int(time)%60 + "'"; 
    q = "INSERT INTO results (CarId, TramoId, rally, time, timeString) VALUES (" + s + ")";
    msql.query(q);

  }
}






