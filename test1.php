start... version: 12
<br>

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
  echo "Can't connect to DB!!! $database\n";
  exit;
}

$qu = pg_query($db_conn, "SELECT id, sfid, name, phone FROM ".$schema.".account");

//echo $qu;

while ($data = pg_fetch_object($qu)) {
  echo $data->id ." | ". $data->sfid ." | ". $data->name ." | ". $data->phone . "<br />";
}

// update !

echo "<hr>updating<hr>";

$data_for_update = array('phone'=>'+31644941133');
$conditions_for_update = array('sfid'=>'0015E000010U8e2QAC');
$res = pg_update($db_conn, $schema.".account", $data_for_update, $conditions_for_update);
  if ($res) {
      echo "Data is updated: $res\n";
  } else {
      echo "User must have sent wrong inputs\n";
  }


pg_free_result($qu);
pg_close($db_conn);

?>

<br>
end...
