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

void processSQL(){
  msql.query( "SELECT * FROM data WHERE processed = 0 order by id LIMIT 1");
  while (msql.next())
   {
    int id = msql.getInt("id"); 
    int carId= msql.getInt("carId"); 
    float x = msql.getFloat("x"); 
    float y = msql.getFloat("y"); 
    float speed = msql.getFloat("speed"); 
    int time =  msql.getInt("time"); 
    cars.addData(carId, x, y, speed, time);
    println("Processing... " + id);
    msql.execute( "UPDATE data SET processed = 1 WHERE id ="+ str(id));
    break;
  }

}
