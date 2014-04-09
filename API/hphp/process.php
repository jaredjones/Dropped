<?php
	$opcode = htmlspecialchars((isset($_GET['o']) ? $_GET['o'] : null));
	if (!ctype_digit($opcode))
		exit(); 
    
	try
	{
		# MySQL with PDO_MYSQL
		$host = "REMOVED";
		$dbname = "REMOVED";
		$dbuser = "REMOVED";
		$dbpass = "REMOVED";
		$DBH = new PDO("mysql:host=$host;dbname=$dbname", $dbuser, $dbpass);
	}
	catch(PDOException $e) {
		exit();
		#echo $e->getMessage();
	}

	header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
	header("Cache-Control: post-check=0, pre-check=0", false);
	header("Pragma: no-cache");
	header('Content-type:application/json');
/*
	$url = "http://localhost/dropped/push/push.php";
                                $a = array(
                                        //"uID"=>
                                        "uAPN"=>"868f3e34967913e1d9b27a99d0fca71207a7594e12faaf824232280ba634ee69");
                                
                                        curl_request_async($url,$a,"POST");
*/
	switch($opcode)
	{
		//REQUEST DEVICEID
		case 0:
			$emptyManually = "{\"deviceID\":\"null\"}";
			$randguid = 0;
			//$guidpass = htmlspecialchars((isset($_GET['pass']) ? $_GET['pass'] : exit()));
			$data = json_decode(file_get_contents('php://input'));
			$guidpass = $data->{'pass'};
            
			if (empty($guidpass))
				exit($emptyManually);
			for ($i = 0; $i < 5; $i++)
			{
				$randguid = sprintf('%04X%04X-%04X-%04X-%04X-%04X%04X%04X', mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(16384, 20479), mt_rand(32768, 49151), mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(0, 65535));
                
				$STH = $DBH->prepare("SELECT devid FROM users WHERE devid=? LIMIT 1");
				$STH->execute(array($randguid));
				if ($STH->rowCount() == 0)
					break;
				if ($i == 4)//We couldn't generate a unique after 5 turns? Uh Exit...
					exit($emptyManually);
			}
			$STH = $DBH->prepare("INSERT INTO users (devid,pass) VALUES (?,?)");
			$STH->execute(array($randguid, $guidpass));
            
			$the_json['deviceID'] = $randguid;
			echo json_encode($the_json);
			exit();
            
		break;
            
		//Is a Pair Valid? Receives a deviceID and Pass, it will return validPair:1 if valid else validPair:0
		case 1:
			$emptyManually = "{\"validPair\",\"null\"}";			

			$data = json_decode(file_get_contents('php://input'));
			$guidpass = $data->{'pass'};
			$deviceID = $data->{'deviceID'};
            
			if (empty($guidpass) || empty($deviceID))
				exit($emptyManually);
            
			$STH = $DBH->prepare("SELECT * FROM users WHERE devid=? AND pass=? LIMIT 1");
			$STH->execute(array($deviceID, $guidpass));
            
			if ($STH->rowCount() > 0)
			{
				$the_json['validPair'] = 1;
				echo json_encode($the_json);
				exit();
			}
			$the_json['validPair'] = 0;
			echo json_encode($the_json);
			exit();
		break;

		//REQUEST ALIAS FOR FOR DEVICE ID or USERID. If UserID is filled, ignore deviceID
		case 2:
			$emptyManually = "{\"alias\":\"null\"}";
			//$deviceid = htmlspecialchars((isset($_GET['devid']) ? $_GET['devid'] : exit()));
			$data = json_decode(file_get_contents('php://input'));
			$deviceid = $data->{'deviceID'};
			$userID = $data->{'userID'};
			if (empty($deviceid) && empty($userID))
				exit($emptyManually);
            
			if (!empty($userID))
			{		
				$STH = $DBH->prepare("SELECT alias FROM users WHERE fbid=? LIMIT 1");
				$STH->execute(array($userID));
				$result = $STH->fetch();
				$alias = $result["alias"];
            
				$the_json['alias'] = $alias;
				echo json_encode($the_json);
				exit();
			}

			$STH = $DBH->prepare("SELECT alias FROM users WHERE devid=? LIMIT 1");
			$STH->execute(array($deviceid));
			$result = $STH->fetch();
			$alias = $result["alias"];
            
			$the_json['alias'] = $alias;
			echo json_encode($the_json);
			exit();
		break; 
            
		//Set Alias for deviceID and Pass if userID is empty, else Update UserID devices only
		//Returns new alias if success, else null alias shows up
		case 3:
			#$guidpass = htmlspecialchars((isset($_GET['pass']) ? $_GET['pass'] : exit()));
			#$deviceID = htmlspecialchars((isset($_GET['deviceID']) ? $_GET['deviceID'] : exit()));
			#$alias = htmlspecialchars((isset($_GET['alias']) ? $_GET['alias'] : exit()));
			$emptyManually = "{\"alias\":\"null\"}";           
 
			$data = json_decode(file_get_contents('php://input'));
			$guidpass = $data->{'pass'};
			$deviceID = $data->{'deviceID'};
			$fbID = $data->{'userID'};
			$alias = $data->{'alias'};


			if (!empty(fbID))
			{	
				if (empty($alias) || empty($fbID) || empty($alias))
                			exit($emptyManually);
            
				$STH = $DBH->prepare("SELECT * FROM users WHERE fbid=? AND pass=? LIMIT 1");
				$STH->execute(array($fbID, $guidpass));
            
				if ($STH->rowCount() == 0)
					exit($emptyManually);
            
				$STH = $DBH->prepare("UPDATE users SET alias=? WHERE fbid=?");
				$STH->execute(array($alias, $fbID));
            
				$the_json['alias'] = $alias;
				echo json_encode($the_json);
				exit();
			}



			if (empty($alias) || empty($deviceID) || empty($alias))
				exit($emptyManually);
            
			$STH = $DBH->prepare("SELECT * FROM users WHERE devid=? AND pass=? LIMIT 1");
			$STH->execute(array($deviceID, $guidpass));
            
			if ($STH->rowCount() == 0)
				exit($emptyManually);
			$result = $STH->fetch();
			$sqlID = $result["id"];
			$STH = $DBH->prepare("UPDATE users SET alias=? WHERE id=?");
			$STH->execute(array($alias, $sqlID));
            
			$the_json['alias'] = $alias;
			echo json_encode($the_json);
		break;
           	
		//Set APNS Token sends deviceID, pass and APNSToken (if Exists)
		case 4:
		    	$emptyManually = "{}";

		    	$data = json_decode(file_get_contents('php://input'));
		    	$deviceID = $data->{'deviceID'};
		    	$guidpass = $data->{'pass'};
		    	$apnstoken = $data->{'APNSToken'};

		    	if (empty(deviceID) || empty(guidpass))
				exit($emptyManually);

		    	$STH = $DBH->prepare("SELECT apns FROM users WHERE devid=? AND pass=? LIMIT 1");
		    	$STH->execute(array($deviceID, $guidpass));

		    	if ($STH->rowCount() == 0)
				exit($emptyManually);

		    	$result = $STH->fetch();
		    	$dbAPNToken = $result[0];

		    	if (empty($apnstoken))
		    	{
				$STH = $DBH->prepare("UPDATE users SET apns=? WHERE devid=? AND pass=?");
				$STH->execute(array(0, $deviceID, $guidpass));
				exit($emptyManually);
		    	}

		    	if ($apnstoken == $dbAPNToken)
				exit($emptyManually);

		    	$STH = $DBH->prepare("UPDATE users SET apns=? WHERE devid=? AND pass=?");
		    	$STH->execute(array($apnstoken, $deviceID, $guidpass));

		     	exit($emptyManually);
		break;

		//Get matchIDs for userID if specified, else get matchIDs for userID
		case 11:
			$emptyManually = "{\"matchIDs\":\"[null]\"}";
			
			$data = json_decode(file_get_contents('php://input'));
			$deviceID = $data->{'deviceID'};
			$userID = $data->{'userID'};

			if (!empty($userID))
			{
				$STH = $DBH->prepare("SELECT id FROM users WHERE fbid=?");
				$STH->execute(array($userID));
				if ($STH->rowCount() == 0)
					exit($emptyManually);

				$matchIDArray = array();
				
				for ($i = 0; $i < $STH->rowCount(); $i++)
				{
					$result = $STH->fetch(PDO::FETCH_ASSOC);
					$myID = $result['id'];
						
					if (empty($myID))
						exit($emptyManually);

					$STH2 = $DBH->prepare("SELECT id FROM matchlist WHERE firstuser=? OR seconduser=? AND firstuser!=seconduser");
					$STH2->execute(array($myID, $myID));
			
					for ($j = 0; $j < $STH2->rowCount(); $j++)
					{
						$result2 = $STH2->fetch(PDO::FETCH_ASSOC);
						array_push($matchIDArray, $result2['id']);
					}
				}
				$the_json['matchIDs'] = $matchIDArray;
				exit(json_encode($the_json));
				//exit($matchIDArray[0]);	
			}

			if (empty($deviceID))
				exit($emptyManually);	
			
			$STH = $DBH->prepare("SELECT id FROM users WHERE devid=? LIMIT 1");
			$STH->execute(array($deviceID));
			$result = $STH->fetch();
			$myID = $result["id"];
			if (empty($myID))
				exit($emptyManually);

			$STH = $DBH->prepare("SELECT id FROM matchlist WHERE firstuser=? OR seconduser=? AND firstuser!=seconduser");
			$STH->execute(array($myID, $myID));
			
			$idArray = array();
			for ($i = 0; $i < $STH->rowCount(); $i++)
			{
				$result = $STH->fetch(PDO::FETCH_ASSOC);
				$idArray[$i] = $result['id'];
				
			}
			
			$the_json['matchIDs'] = $idArray;
			exit(json_encode($the_json));

		break;
 
		//Request Match (NEEDS USERID AND FRIENDID SUPPORT ONCE FB IS IMPLEMENTED)
		case 12:
			#$guidpass = htmlspecialchars((isset($_GET['pass']) ? $_GET['pass'] : exit()));
			#$deviceID = htmlspecialchars((isset($_GET['deviceID']) ? $_GET['deviceID'] : exit()));
            		
			$emptyManually = "{\"matchID\":\"null\", \"localPlayerTurn\":\"null\"}";

			$data = json_decode(file_get_contents('php://input'));
			$guidpass = $data->{'pass'};
			$deviceID = $data->{'deviceID'};
            
			if (empty($guidpass) || empty($deviceID))
				exit($emptyManually);
            
			$STH = $DBH->prepare("SELECT * FROM users WHERE devid=? AND pass=? LIMIT 1");
			$STH->execute(array($deviceID, $guidpass));
            
			if ($STH->rowCount() == 0)
				exit($emptyManually);
            
			$result = $STH->fetch();
			$sqlID = $result["id"];

			//DELETE THIS
		//	shell_exec("wget -q --spider http://localhost/dropped/push/push.php?uID=".$sqlID);
	
			$STH = $DBH->prepare("SELECT @tmpID := id FROM matchlist WHERE seconduser IS NULL AND data IS NOT NULL AND active=1 AND firstuser!=? ORDER BY start_time ASC LIMIT 1 FOR UPDATE; UPDATE matchlist SET seconduser=? WHERE id=@tmpID; SELECT @tmpID;");
			$STH->execute(array($sqlID, $sqlID));
			$result = $STH->fetch();
			$tmpVar = $result[0];
			if (!empty($tmpVar))
			{
				$the_json['matchID'] = $tmpVar;
				$the_json['localPlayerTurn'] = 1;
				echo json_encode($the_json);
				//PLAYER NEEDS TO GET A PUSH NOTIFICATION HERE INFORMING THEM THAT SOMEONE JOINED THE MATCH!!!!!!
				exit();
			}
            
			$STH = $DBH->prepare("INSERT INTO matchlist (firstuser) VALUES(?)");
			$STH->execute(array($sqlID));
			$matchID = $DBH->lastInsertId();
            
			$the_json['matchID'] = $matchID;
			$the_json['localPlayerTurn'] = 0;
			echo json_encode($the_json);
			exit();
            
			//$STH = $DBH->prepare("SELECT * FROM matchlist WHERE ");
		break;
            
		//Receives a MatchID and DeviceID then it returns matchData, localPlayerTurn, remotePlayerAlias, and matchStatus
                case 13:
			$emptyManually = "{\"matchData\":\"null\", \"localPlayerTurn\":\"null\", \"remotePlayerAlias\":\"null\", \"matchStatus\":\"null\"}";

			$data = json_decode(file_get_contents('php://input'));
			$matchID = $data->{'matchID'};
			$deviceID = $data->{'deviceID'};

			if (empty($matchID) || empty($deviceID))
				exit($emptyManually);

			$STH = $DBH->prepare("SELECT firstuser, seconduser, turn, data, active FROM matchlist WHERE id = ? LIMIT 1");
			$STH->execute(array($matchID));
			
			if ($STH->rowCount() == 0)
				exit($emptyManually);

			$result = $STH->fetch();
			$firstUser = $result[0];
			$secondUser = $result[1];
			$turn = $result[2];
			$dataBlob = $result[3];
			$matchStatus = $result[4];

			$STH = $DBH->prepare("SELECT id FROM users WHERE devid=? LIMIT 1");
			$STH->execute(array($deviceID));			
			if ($STH->rowCount() == 0)
				exit($emptyManually);
			
			$result = $STH->fetch();
			$myID = $result[0];

			
			if ($myID != $firstUser && $myID != $secondUser)
				exit($emptyManually);

			//$localPlayerTurn = 0; //Assume opponents turn
			if ($myID == $firstUser)
			{
				$opponent = $secondUser;
				$localPlayerTurn = 0;
				/*if ($turn == 0)
					$localPlayerTurn = 1;*/
			}
			else
			{
				$opponent = $firstUser;
				$localPlayerTurn = 1;
				/*if ($turn == 1)
					$localPlayerTurn = 1;*/
			}


			$STH = $DBH->prepare("SELECT alias FROM users WHERE id=?");
			$STH->execute(array($opponent));
			$result = $STH->fetch();
			$opponentAlias = $result[0];

			$the_json['matchData'] = $dataBlob;
			$the_json['localPlayerTurn'] = $localPlayerTurn;
			$the_json['remotePlayerAlias'] = $opponentAlias;
			$the_json['matchStatus'] = $matchStatus;
			$the_json['matchID'] = $matchID;

			echo json_encode($the_json);
			exit();
		break;
		
		//Receives A Submitted Turn Request of matchID, deviceID, userID, pass, advanceTurn, and matchData
		case 14:
			$emptyManually = "{\"matchStatus\":\"null\"}";			

			$data = json_decode(file_get_contents('php://input'));
                        $matchID = $data->{'matchID'};
                        $deviceID = $data->{'deviceID'};
			$guidpass = $data->{'pass'};
			$advanceTurn = $data->{'advanceTurn'};
			$matchData = $data->{'matchData'};
			
			if (!is_numeric($matchID) || !is_numeric($advanceTurn) || empty($deviceID) || empty($guidpass) || empty($matchData))
				exit($emptyManually);
	
			$STH = $DBH->prepare("SELECT * FROM users WHERE devid=? AND pass=? LIMIT 1");
			$STH->execute(array($deviceID, $guidpass));
            
			if ($STH->rowCount() == 0)
				exit($emptyManually);

			$result = $STH->fetch();
			$sqlID = $result["id"];
		
			
			$STH = $DBH->prepare("SELECT firstuser, seconduser, turn, active FROM matchlist WHERE (firstuser=? OR seconduser=?) AND id=? LIMIT 1");
			$STH->execute(array($sqlID, $sqlID, $matchID));
			
			if ($STH->rowCount() == 0)
				exit($emptyManually);

			$result = $STH->fetch();
			$firstUser = $result[0];
			$secondUser = $result[1];
			$turnCount = $result[2];
			$active = $result[3];	

			if ($active == 0)
			{
				$the_json['matchStatus'] = $active;
				exit(json_encode($the_json));
			}

			if ($turnCount >= 10)
				exit($emptyManually);
			if ($turnCount % 2 == 0 && $sqlID == $secondUser)
				exit($emptyManually);
			if ($turnCount % 2 == 1 && $sqlID == $firstUser)
				exit($emptyManually);	

			if ($advanceTurn == 0)
			{
				$STH = $DBH->prepare("UPDATE matchlist SET data=? WHERE id=?");
				$STH->execute(array($matchData, $matchID));
				$the_json['matchStatus'] = $active;
				exit(json_encode($the_json));
			}
			
			++$turnCount;
			
			if ($turnCount >= 10)	
				$STH = $DBH->prepare("UPDATE matchlist SET turn=?, data=?, active=0 WHERE id=?");
			else
				$STH = $DBH->prepare("UPDATE matchlist SET turn=?, data=? WHERE id=?");
			$STH->execute(array($turnCount, $matchData, $matchID));

			if ($turnCount >= 10)
				$active = 0;

			$the_json['matchStatus'] = $active;
			exit(json_encode($the_json));				
		break;

		default:
		exit();
	}

function curl_request_async($url, $params, $type='POST')
{
	foreach ($params as $key => &$val)
	{
		if (is_array($val)) $val = implode(',', $val);
	  	$post_params[] = $key.'='.urlencode($val);
	}
	$post_string = implode('&', $post_params);

	$parts=parse_url($url);

	$fp = fsockopen($parts['host'],
	    isset($parts['port'])?$parts['port']:80,
	    $errno, $errstr, 0.2);
	
	stream_set_timeout($fp, 0.2);

	// Data goes in the path for a GET request
	if('GET' == $type) $parts['path'] .= '?'.$post_string;

	$out = "$type ".$parts['path']." HTTP/1.1\r\n";
	$out.= "Host: ".$parts['host']."\r\n";
	$out.= "Content-Type: application/x-www-form-urlencoded\r\n";
	$out.= "Content-Length: ".strlen($post_string)."\r\n";
	$out.= "Connection: Close\r\n\r\n";
	// Data goes in the request body for a POST request
	if ('POST' == $type && isset($post_string)) $out.= $post_string;

		fwrite($fp, $out);
		fclose($fp);
	}

?>
