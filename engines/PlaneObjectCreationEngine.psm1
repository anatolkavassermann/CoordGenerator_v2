function CreatePlane {
    param (
        [parameter(Mandatory=$true)] [hashtable] $PlanePatternConfiguration,
        [GEO_classes.World] $World,
        [System.Random] $rnd
    )
    [System.String]$ID = GenerateID
	$CoordsAndAngle = GenerateCoordsAndAngle -World $World -rnd $rnd
    [Plane]$PlaneObject = [Plane]::new(        
		$World,        
		$PlanePatternConfiguration["PatternName"],		
		($PlanePatternConfiguration["PatternName"] + "-" + $ID),		
		$PlanePatternConfiguration["RefreshRate"],		
		$CoordsAndAngle["Coords"],
		$PlanePatternConfiguration["MinSpeed"],		
		$PlanePatternConfiguration["MaxSpeed"],		
		$PlanePatternConfiguration["SpeedAdjust"],		
		$PlanePatternConfiguration["SpeedDecrease"],		
		$PlanePatternConfiguration["MinHeight"],		
		$PlanePatternConfiguration["MaxHeight"],		
		$PlanePatternConfiguration["MaxUpDownAngle"],        
		$PlanePatternConfiguration["MaxRotateAngle"],        
        $CoordsAndAngle["Angle"],
        $rnd 
	)
    return $PlaneObject
}
function GenerateID ()
{
	[System.Text.StringBuilder]$sb = [System.Text.StringBuilder]::new(16)
	[System.Random]$rand = [System.Random]::new()
	for ($i = 0; $i -lt 16; $i++)
	{
		$l = [System.Text.Encoding]::ASCII.GetString([System.Convert]::ToByte($rand.Next(48, 57)))
		$sb.Append($l) | Out-Null
	}
	return $sb.ToString();
}
function GenerateCoordsAndAngle {
    param (
        [GEO_classes.World]$World,
        [System.Random]$rnd
    )
	$LatitudeOrLongtitude = $rnd.Next(0, 10)
	switch ($LatitudeOrLongtitude % 2) {
        0 {
            Generator -Half "0" -World $World -rnd $rnd
            break;
        }
        default {
            Generator -Half "1" -World $World -rnd $rnd
            break;
        }
    }
}
function Generator {
    param (
        [System.Random]$rnd,
        [System.String]$Half, 
        [GEO_classes.World]$World
    )
    #[System.Random]$rnd = [System.Random]::new()
    switch ($Half)
	{
		"0"
		{
			[hashtable]$Data = @{}
            $Data.Add("WorldTopLeftCornerCoords", $World.WorldTopLeftCornerCoords['longtitude'])
            $Data.Add("WorldTopRightCornerCoords", $World.WorldTopRightCornerCoords['longtitude'])
			switch ($Data['WorldTopRightCornerCoords'] -ge $Data['WorldTopLeftCornerCoords'])
			{
                $true
				{
					$longtitude = $rnd.Next($Data['WorldTopLeftCornerCoords']*1000000,($Data['WorldTopRightCornerCoords']*1000000+1))
                    $longtitude = $longtitude / 1000000
                    break;
				}
                $false
				{
                    $LeftOrRight = $rnd.Next(0,10)
                    switch ($LeftOrRight % 2 -eq 0) {
                        $true {
                            $longtitude = $rnd.Next($Data['WorldTopLeftCornerCoords']*1000000,180000001)
                            $longtitude = $longtitude / 1000000
                        }
                        $false {
                            $longtitude = $rnd.Next([System.Math]::Abs($Data['WorldTopRightCornerCoords']*1000000),180000001)
                            $longtitude = $longtitude / 1000000
                            $longtitude = $longtitude * (-1)
                        }
                    }
                    break;
				}
            }
            $UpOrDown = $rnd.Next(0, 10)
            switch ($UpOrDown % 2) {
                0 {
                    $Angle = $rnd.Next(90, 271)
                    $latitude = $World.WorldTopLeftCornerCoords['latitude']
                    break;
                }
                default {
                    $Angle = [System.Random]::new().Next(-90, 91)
                    switch ($Angle -lt 0)
                    {
                        $true
                        {
                            $Angle = 360 + ($Angle)
                        }
                    }
                    $latitude = $World.WorldBottomLeftCornerCoords['latitude']
                    break;
                }
            }
			[hashtable] $Coords = @{}
			$Coords.Add("latitude", $latitude)
			$Coords.Add("longtitude", $longtitude)
			$AngleAndCoords = @{ }
			$AngleAndCoords.Add("Coords", $Coords)  
			$AngleAndCoords.Add("Angle", $Angle)
			$AngleAndCoords.Add("Half", $Half)
            return $AngleAndCoords
            break;
		}
		
		"1"
		{
            [hashtable]$Data = @{}
            $Data.Add("WorldTopLeftCornerCoords", $World.WorldTopLeftCornerCoords['latitude'])
            $Data.Add("WorldBottomLeftCornerCoords", $World.WorldBottomLeftCornerCoords['latitude'])
			switch ([System.Math]::Abs($Data['WorldTopLeftCornerCoords'] - $Data['WorldBottomLeftCornerCoords']) -eq 180) {
                $true {
                    $UpOrDown = $rnd.Next(0,10)
                    switch ($Data['WorldTopLeftCornerCoords'] -lt 0) {
                        $true {
                            switch ($UpOrDown % 2 -eq 0) {
                                $true {
                                    $latitude = $rnd.Next([System.Math]::Abs($Data['WorldTopLeftCornerCoords']*1000000),90000001)
                                    $latitude = $latitude / 1000000
                                    $latitude = $latitude * (-1)
                                    break;
                                }
                                $false {
                                    $latitude = $rnd.Next([System.Math]::Abs($Data['WorldBottomLeftCornerCoordss']*1000000),90000001)
                                    $latitude = $latitude / 1000000
                                    $latitude = $latitude * (-1)
                                    break;
                                }
                            }
                            break;
                        }
                        $false {
                            switch ($UpOrDown % 2 -eq 0) {
                                $true {
                                    $latitude = $rnd.Next([System.Math]::Abs($Data['WorldTopLeftCornerCoords']*1000000),90000001)
                                    $latitude = $latitude / 1000000
                                }
                                $false {
                                    $latitude = $rnd.Next([System.Math]::Abs($Data['WorldBottomLeftCornerCoordss']*1000000),90000001)
                                    $latitude = $latitude / 1000000
                                }
                            }
                        }
                    }
                    break;
                }
                $false {
                    switch ($Data['WorldBottomLeftCornerCoords'] -lt 0) {
                        $true {
                            $latitude = $rnd.Next($Data['WorldTopLeftCornerCoords']*1000000,($Data['WorldBottomLeftCornerCoordss']*1000000+1))
                            $latitude = $latitude / 1000000
                            break;
                        }
                        $false {
                            $latitude = $rnd.Next($Data['WorldBottomLeftCornerCoords']*1000000,($Data['WorldTopLeftCornerCoords']*1000000+1))
                            $latitude = $latitude / 1000000
                            break;
                        }
                    }    
                    break;
                }
            }
            $LeftOrRight = $rnd.Next(0,10)
            switch ($LeftOrRight % 2) {
                0 {
                    $Angle = [System.Random]::new().Next(0, 181)
                    $longtitude = $World.WorldTopLeftCornerCoords['longtitude']
                    break;
                }
                default {
                    $Angle = [System.Random]::new().Next(180, 361)
                    $longtitude = $World.WorldTopRightCornerCoords['longtitude']
                    break;
                }
            }
			[hashtable] $Coords = @{}
			$Coords.Add("latitude", $latitude)
			$Coords.Add("longtitude", $longtitude)
			$AngleAndCoords = @{ }
			$AngleAndCoords.Add("Coords", $Coords)  
			$AngleAndCoords.Add("Angle", $Angle)
			$AngleAndCoords.Add("Half", $Half)
			return $AngleAndCoords
		}	
	}
}