<?php
        define("VERSION_NUMBER", 2);
        define("DISABLE_UPDATES", 1);

        if (DISABLE_UPDATES)
                exit();

        $id = htmlspecialchars($_GET['i']);     
        if (!ctype_digit($id))
                exit();
        
        if (VERSION_NUMBER == $id)
        {
                exit();
        }

        $finishedsql = "";

        for ($i = $id + 1; $i <= VERSION_NUMBER; $i++)
        {
                $filename = 'sql/droppedsqlupdate_'.$i.'.sql';
                if (file_exists($filename))
                {
                        $handle = fopen($filename, 'r') or die();
                        $data = fread($handle, filesize($filename));
                        $finishedsql .= $data;
                }
        }
        $finishedsql .= "UPDATE settings SET version=".VERSION_NUMBER.";"; 
        echo $finishedsql;
?>