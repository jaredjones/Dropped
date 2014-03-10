<?php
	$opcode = htmlspecialchars((isset($_GET['o']) ? $_GET['o'] : null));
	if (!ctype_digit($opcode))
    exit();
    
    
    try {
        # MySQL with PDO_MYSQL
        $host = "127.0.0.1";
        $dbname = "REMOVED";
        $dbuser = "REMOVED";
        $dbpass = "REMOVED";
        $DBH = new PDO("mysql:host=$host;dbname=$dbname", $dbuser, $dbpass);
    }
    catch(PDOException $e) {
        exit();
        #    echo $e->getMessage();
    }
	switch($opcode)
	{
            //REQUEST DEVICEID
		case 0:
			$randguid = 0;
			//$guidpass = htmlspecialchars((isset($_GET['pass']) ? $_GET['pass'] : exit()));
			$data = json_decode(file_get_contents('php://input'));
			$guidpass = $data->{'pass'};
            
			if (empty($guidpass))
				exit();
			for ($i = 0; $i < 5; $i++)
			{
				$randguid = sprintf('%04X%04X-%04X-%04X-%04X-%04X%04X%04X', mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(16384, 20479), mt_rand(32768, 49151), mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(0, 65535));
                
				$STH = $DBH->prepare("SELECT devid FROM users WHERE devid=? LIMIT 1");
				$STH->execute(array($randguid));
				if ($STH->rowCount() == 0)
					break;
				if ($i == 4)//We couldn't generate a unique after 5 turns? Uh Exit...
					exit();
			}
			$STH = $DBH->prepare("INSERT INTO users (devid,pass) VALUES (?,?)");
			$STH->execute(array($randguid, $guidpass));
            
			$the_json['deviceID'] = $randguid;
			header('Content-type:application/json');
			echo json_encode($the_json);
			exit();
            
            break;
            
            //REQUEST ALIAS FOR FOR DEVICE ID
		case 1:
			//$deviceid = htmlspecialchars((isset($_GET['devid']) ? $_GET['devid'] : exit()));
			$data = json_decode(file_get_contents('php://input'));
            $deviceid = $data->{'deviceID'};
			if (empty($deviceid))
				exit();
            
			$STH = $DBH->prepare("SELECT alias FROM users WHERE devid=? LIMIT 1");
			$STH->execute(array($deviceid));
			$result = $STH->fetch();
			$alias = $result["alias"];
            
			$the_json['alias'] = $alias;
			echo json_encode($the_json);
			exit();
            break;
            
            //REQUEST ALIAS FOR USERID
		case 2:
			//$userID = htmlspecialchars((isset($_GET['userID']) ? $_GET['userID'] : exit()));
			$data = json_decode(file_get_contents('php://input'));
            $userID = $data->{'userID'};
            
            if (empty($userID))
                exit();
            
            $STH = $DBH->prepare("SELECT alias FROM users WHERE fbid=? LIMIT 1");
            $STH->execute(array($userID));
            $result = $STH->fetch();
            $alias = $result["alias"];
            
            $the_json['alias'] = $alias;
            echo json_encode($the_json);
            exit();
            break;
            
            //Set Alias for deviceID and Pass
            //Returns new alias if success, else nothing shows up
		case 3:
			#$guidpass = htmlspecialchars((isset($_GET['pass']) ? $_GET['pass'] : exit()));
			#$deviceID = htmlspecialchars((isset($_GET['deviceID']) ? $_GET['deviceID'] : exit()));
			#$alias = htmlspecialchars((isset($_GET['alias']) ? $_GET['alias'] : exit()));
            
			$data = json_decode(file_get_contents('php://input'));
            $guidpass = $data->{'pass'};
			$deviceID = $data->{'deviceID'};
			$alias = $data->{'alias'};
			if (empty($alias) || empty($deviceID) || empty($alias))
				exit();
            
			$STH = $DBH->prepare("SELECT * FROM users WHERE devid=? AND pass=? LIMIT 1");
            $STH->execute(array($deviceID, $guidpass));
            
			if ($STH->rowCount() == 0)
				exit();
			$result = $STH->fetch();
			$sqlID = $result["id"];
			$STH = $DBH->prepare("UPDATE users SET alias=? WHERE id=?");
			$STH->execute(array($alias, $sqlID));
            
			$the_json['alias'] = $alias;
            echo json_encode($the_json);
            break;
            
            //Set Alias for FBID and Pass//UPDATES ALL DEVIDs ASSOCIATED WITH
		case 4:
			#$guidpass = htmlspecialchars((isset($_GET['pass']) ? $_GET['pass'] : exit()));
			#$fbID = htmlspecialchars((isset($_GET['userID']) ? $_GET['userID'] : exit()));
            #$alias = htmlspecialchars((isset($_GET['alias']) ? $_GET['alias'] : exit()));
            
			$data = json_decode(file_get_contents('php://input'));
            $guidpass = $data->{'pass'};
			$fbID = $data->{'userID'};
			$alias = $data->{'alias'};
			if (empty($alias) || empty($fbID) || empty($alias))
                exit();
            
			$STH = $DBH->prepare("SELECT * FROM users WHERE fbid=? AND pass=? LIMIT 1");
            $STH->execute(array($fbID, $guidpass));
            
            if ($STH->rowCount() == 0)
                exit();
            
			$STH = $DBH->prepare("UPDATE users SET alias=? WHERE fbid=?");
            $STH->execute(array($alias, $fbID));
            
			$the_json['alias'] = $alias;
            echo json_encode($the_json);
            break;
            
            //Request Match (NEEDS USERID AND FRIENDID SUPPORT ONCE FB IS IMPLEMENTED)
		case 5:
			#$guidpass = htmlspecialchars((isset($_GET['pass']) ? $_GET['pass'] : exit()));
            #$deviceID = htmlspecialchars((isset($_GET['deviceID']) ? $_GET['deviceID'] : exit()));
            
			$data = json_decode(file_get_contents('php://input'));
            $guidpass = $data->{'pass'};
			$deviceID = $data->{'deviceID'};
            
			if (empty($guidpass) || empty($deviceID))
				exit();
            
			$STH = $DBH->prepare("SELECT * FROM users WHERE devid=? AND pass=? LIMIT 1");
            $STH->execute(array($deviceID, $guidpass));
            
            if ($STH->rowCount() == 0)
                exit();
            
			$result = $STH->fetch();
			$sqlID = $result["id"];
            
			$STH = $DBH->prepare("SELECT @tmpID := id FROM matchlist WHERE seconduser IS NULL AND active=1 AND firstuser!=? ORDER BY time ASC LIMIT 1 FOR UPDATE; UPDATE matchlist SET seconduser=? WHERE id=@tmpID; SELECT @tmpID;");
			$STH->execute(array($sqlID, $sqlID));
			$result = $STH->fetch();
			$tmpVar = $result[0];
			if (!empty($tmpVar))
			{
				$the_json['matchID'] = $tmpVar;
				echo json_encode($the_json);
				//PLAYER NEEDS TO GET A PUSH NOTIFICATION HERE INFORMING THEM THAT SOMEONE JOINED THE MATCH!!!!!!
				exit();
			}
            
			$STH = $DBH->prepare("INSERT INTO matchlist (firstuser) VALUES(?)");
			$STH->execute(array($sqlID));
			$matchID = $DBH->lastInsertId();
            
			$the_json['matchID'] = $matchID;
			echo json_encode($the_json);
			exit();
            
			//$STH = $DBH->prepare("SELECT * FROM matchlist WHERE ");
            break;
            
            //Is a Pair Valid? Receives a deviceID and Pass, it will return validPair:1 if valid else validPair:0
		case 6:
			$data = json_decode(file_get_contents('php://input'));
            $guidpass = $data->{'pass'};
			$deviceID = $data->{'deviceID'};
            
			if (empty($guidpass) || empty($deviceID))
				exit();
            
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
            
		default:
            exit();
	}
    
    ?>