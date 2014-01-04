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
