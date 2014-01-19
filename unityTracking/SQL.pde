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
    msql.query( "SELECT * FROM cars ORDER BY carId");
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
   msql.query( "SELECT count(*) as n FROM tramos ");
   while (msql.next()){
     return msql.getInt("n");
   }
   return 0;
 }
 Tramo loadTramo(int focus){
    msql.query( "SELECT * FROM tramos");
    int i = 0;
    while (msql.next ())
    {  
         if(i < focus) {
           i += 1;
           continue;
         }
         String prueba = msql.getString("prueba");
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
    String iDate =  (new Timestamp(tramos.getInitTime())).toString();
    String eDate =  (new Timestamp(tramos.getEndTime())).toString();
    msql.query("DELETE FROM tracks WHERE tramoId = " + str(tramos.tramo.id));
    String q = "UPDATE data SET processed = 0 WHERE timeStamp > '" + iDate+ "' " + " and  timeStamp < '" + eDate+ "'" ;
    println(q);
    remote.query(q);
  }
  
  void removeDiferido() {
    String iDate =  rt.getPrevElapsed();
    String eDate =  rt.getElapsed();
    rt.setPrevElapsed(eDate);
    msql.query("DELETE FROM tracks WHERE tramoId = " + str(tramos.tramo.id));
    String q = "UPDATE data SET processed = 0 WHERE timeStamp > '" + iDate+ "' " + " and  timeStamp < '" + eDate+ "'" ;
    println(q);
    remote.query(q);
  }
  
  void process() {
    if(rt.running)
      removeDiferido();
    
    remote.query( "SELECT count(*) as n FROM data WHERE processed = 0");
    
    while (remote.next ()){
      int total = remote.getInt("n");
      println("Processing... " + total + " rows");
      break;
    }
    
    remote.query( "SELECT * FROM data WHERE processed = 0");
    ArrayList<sqlData> data = new ArrayList<sqlData>();
    while (remote.next ())
    {
      sqlData s = new sqlData();
      s.carId= remote.getInt("carId"); 
      s.x = remote.getFloat("x"); 
      s.y = remote.getFloat("y"); 
      s.speed = remote.getFloat("speed"); 
      try{
        s.time = int(remote.getString("time").substring(6, 10));
      }catch(Exception e){print(e);}
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
      msql.query("INSERT INTO tracks (CarId, TramoId, realIndex, avgSpeed, trackTime, trackDistance, remainingDistance) VALUES (" + s  + ")");
  }
}






