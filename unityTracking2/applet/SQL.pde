import de.bezier.data.sql.*;

class sqlData {
  int id;
  int carId;
  float x, y;
  float speed;
  int time;
  sqlData() {
  }
}


class SQL {
  MySQL msql;
  SQL(MySQL msql) { 
    this.msql = msql; 
    msql.connect();
  }
  void insertTrack(String s, boolean full) {
    if (full)
      msql.query("INSERT INTO tracks VALUES (" + s  + ")");  
    else
      msql.query("INSERT INTO tracks (CarId, TramoId, realIndex, avgSpeed, trackTime, trackDistance, remainingDistance) VALUES (" + s  + ")");
  }
  void remove() {
    msql.query("DELETE FROM tracks WHERE 1");
    msql.query("UPDATE data SET processed = 0 WHERE processed = 1");
  }
  
  void process() {
    msql.query( "SELECT * FROM data WHERE processed = 0 order by id");
    ArrayList<sqlData> data = new ArrayList<sqlData>();
    while (msql.next ())
    {
      sqlData s = new sqlData();
      s.id = msql.getInt("id"); 
      s.carId= msql.getInt("carId"); 
      s.x = msql.getFloat("x"); 
      s.y = msql.getFloat("y"); 
      s.speed = msql.getFloat("speed"); 
      s.time =  msql.getInt("time"); 
      data.add(s);
    }
    for (sqlData s: data) {
      println("Processing... " + s.id);
      cars.addData(s.carId, s.x, s.y, s.speed, s.time);
      msql.execute( "UPDATE data SET processed = 1 WHERE id ="+ str(s.id));
    }
  }
  void updateLeader(int id){
      msql.execute("UPDATE leader SET carId ="+ str(id) + " WHERE 1") ;
  }
  int getLeader(){
      msql.query( "SELECT carId FROM leader");
       while (msql.next ())
      {
        return msql.getInt("carId");
      }
      return 0;
  }
  
  void updateEnabled(int id, boolean v){
    if(v)
      msql.execute( "UPDATE cars SET enabled = 1 WHERE carId ="+ str(id));
    else
      msql.execute( "UPDATE cars SET enabled = 0 WHERE carId ="+ str(id));
  }
  boolean isEnabled(int id){
     msql.query( "SELECT enabled FROM cars WHERE carId ="+ str(id));
     while (msql.next ())
      {
        return msql.getInt("enabled") == 1;
      }
      msql.query( "INSERT INTO cars (CarId) VALUES (" + str(id)  + ")");
      return true;
  }
}






