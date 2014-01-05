import de.bezier.data.sql.*;

MySQL msql;
void setupMySQL()
{
    String user     = "miguel";
    String pass     = "miguel";
    String database = "unity";
    msql = new MySQL( this, "localhost:8889", database, user, pass );
    msql.connect();
}

void insertMySQL(String s){
   msql.query("INSERT INTO tracks VALUES (" + s  + ")");   
}
void insertMySQL2(String s){
   msql.query("INSERT INTO tracks (CarId, TramoId, realIndex, avgSpeed, trackTime, trackDistance, remainingDistance) VALUES (" + s  + ")");   
}

void removeMySQL(){
   msql.query("DELETE FROM tracks WHERE 1");   
}
void clearMySQL(){
   msql.query("UPDATE data SET processed = 0 WHERE processed = 1");   
}

class sqlData{
  int id;
  int carId;
  float x, y;
  float speed;
  int time;
  sqlData(){
  }
}

void processSQL(){
  msql.query( "SELECT * FROM data WHERE processed = 0 order by id");
  ArrayList<sqlData> data = new ArrayList<sqlData>();
  while (msql.next())
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
  for(sqlData s: data){
    println("Processing... " + s.id);
    cars.addData(s.carId, s.x, s.y, s.speed, s.time);
    msql.execute( "UPDATE data SET processed = 1 WHERE id ="+ str(s.id));
  }
}
