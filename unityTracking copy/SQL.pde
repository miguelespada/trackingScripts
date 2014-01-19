import de.bezier.data.sql.*;

import java.sql.Timestamp;

class sqlData {
  int id;
  int carId;
  float x, y;
  float speed;
  int  time;
  String status;
  sqlData() {
  }
}

class SQL {
  MySQL msql;
  MySQL remote;
  SQL(MySQL msql, MySQL remote) { 
    this.msql = msql; 
    this.remote = remote;
    msql.connect();
    remote.connect();
  }
  void insertTrack(String s, boolean full) {
    if (full)
      msql.query("INSERT INTO tracks VALUES (" + s  + ")");  
    else
      msql.query("INSERT INTO tracks (CarId, TramoId, realIndex, avgSpeed, trackTime, trackDistance, remainingDistance) VALUES (" + s  + ")");
  }
  void remove() {
    String iDate = getInitTime(tramos.getFocusName());
    String eDate = getEndTime(tramos.getFocusName());
    msql.query("DELETE FROM tracks WHERE 1");
    String q = "UPDATE data SET processed = 0 WHERE timeStamp > '" + iDate+ "' " + " and  timeStamp < '" + eDate+ "'" ;
   
    remote.query(q);
    
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
     while (msql.next ()){
       return msql.getInt("n");
     }
     return 0;

   }
     /*  while (msql.next ())
    {
         String root = msql.getString("prueba");
         String tramoName = str(msql.getInt("id"));
         String utm =  root + "/" + tramoName + "/" + tramoName + "_utm.txt";
         int start =  msql.getInt("start");
         int end = -abs( msql.getInt("end"));
         Tramo t = new Tramo(tramoName, utm, start, end);
         tramos.add(t);
         
     }*/
   
  void process() {
    remote.query( "SELECT * FROM data WHERE processed = 0");
    ArrayList<sqlData> data = new ArrayList<sqlData>();
    while (remote.next ())
    {
      sqlData s = new sqlData();
      s.id = remote.getInt("id"); 
      s.carId= remote.getInt("carId"); 
      s.x = remote.getFloat("x"); 
      s.y = remote.getFloat("y"); 
      s.speed = remote.getFloat("speed"); 
      try{
        s.time = int(remote.getString("time").substring(6, 10));
        s.status =  remote.getString("status");
        data.add(s);
        print(s.id);
      }catch(Exception e){print(e);}
    }

    for (sqlData s: data) {
      cars.addData(s.carId, s.x, s.y, s.speed, s.time, s.status);
    }
    remote.execute( "UPDATE data SET processed = 1");
  }
  

  
  void updateTramoStartEnd(String id, int start, int end){
      msql.execute( "UPDATE tramos SET start = " + str(start) + " WHERE id ="+ id);
      msql.execute( "UPDATE tramos SET end = " + str(end) + " WHERE id ="+ id);
  }
 
  
  String getInitTime(String name){
     try{
       msql.query( "SELECT initTime FROM tramos WHERE id = "+ name);
     while (msql.next ())
      {
        return msql.getString("initTime");
      }
     }
     catch(Exception e){
       setInit(name);
     }
    return "";
  
  }
   String getEndTime(String name){
     try{
     msql.query( "SELECT endTime FROM tramos WHERE id = "+ name);
     while (msql.next ())
      {
        return msql.getString("endTime");
      }
     }
      catch(Exception e){
       setEnd(name);
     }
     return "";
  }
  
  void setInit(String name){
	 java.util.Date date= new java.util.Date();
	 Timestamp d = new Timestamp(date.getTime());
         msql.execute( "UPDATE tramos SET initTime = '" + d.toString() + "' WHERE id ="+ name);
  }
  void setEnd(String name){
	 java.util.Date date= new java.util.Date();
	 Timestamp d = new Timestamp(date.getTime());
         msql.execute( "UPDATE tramos SET endTime = '" + d.toString() + "' WHERE id ="+ name);
  }
}






