start...
<?php 

$database = "ddg30magmsqno";
$host = "ec2-3-248-4-172.eu-west-1.compute.amazonaws.com";
$port = 5432;

$db_conn = pg_connect("host=$host port=$port dbname=$database");
if (!$db_conn) {
  echo "Невозможно соединиться с postgres базой $database\n";
  exit;
}

$qu = pg_query($db_conn, "SELECT * FROM Account");

while ($data = pg_fetch_object($qu)) {
  echo $data->Id . "<br />";
}

pg_free_result($qu);
pg_close($db_conn);

?>

<br>
end...
