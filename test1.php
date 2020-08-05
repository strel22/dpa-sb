start... version: 6

<?php 

//echo getenv('DATABASE_URL') ;

$schema = "dpasf";
$database = "ddg30magmsqno";
//$host = "ec2-3-248-4-172.eu-west-1.compute.amazonaws.com";
$host = "localhost";
$port = 5432;
$user = "";
$pass = "";

//user=lamb password=bar
//$db_conn = pg_connect("host=$host port=$port dbname=$database user=$user password=$pass");
//$db_conn = pg_connect("host=$host port=$port schema=$schema dbname=$database");
$db_conn = pg_connect(getenv('DATABASE_URL'));
if (!$db_conn) {
  echo "Невозможно соединиться с postgres базой $database\n";
  exit;
}

$qu = pg_query($db_conn, "SELECT Name FROM Account");

//echo $qu;

while ($data = pg_fetch_object($qu)) {
  echo $data->Name . "<br />";
}

pg_free_result($qu);
pg_close($db_conn);

?>

<br>
end...
