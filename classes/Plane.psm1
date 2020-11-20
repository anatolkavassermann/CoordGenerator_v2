class Plane : GEO_classes.TestPlane {
    Plane (    
        [GEO_classes.World] $_World,
        [string] $_PatternName,
        [string] $_PlaneID,
        [double] $_RefreshRate,
        [Hashtable] $_Coords,
        [double] $_MinSpeed,
        [double] $_MaxSpeed,
        [double] $_SpeedAdjust,
        [double] $_SpeedDecrease,
        [double] $_MinHeight,
        [double] $_MaxHeight,
        [double] $_MaxUpDownAngle,
        [double] $_MaxRotateAngle,
        [double] $_CurrentAngle,
        [System.Random] $_rnd
        ) 
    : base (
        [GEO_classes.World] $_World,
        [string] $_PatternName,
        [string] $_PlaneID,
        [double] $_RefreshRate,
        [Hashtable] $_Coords,
        [double] $_MinSpeed,
        [double] $_MaxSpeed,
        [double] $_SpeedAdjust,
        [double] $_SpeedDecrease,
        [double] $_MinHeight,
        [double] $_MaxHeight,
        [double] $_MaxUpDownAngle,
        [double] $_MaxRotateAngle,
        [double] $_CurrentAngle,
        [System.Random] $_rnd
    ) {
        $this.CanFly = $true;
    }
    [hashtable] CalculateTempCoords ([System.Double]$DistanceToGo) {
        [hashtable]$_TempCoords = $this.Coords
        $_TempCoords = CalculateCoords -InitCoords $_TempCoords -InitAngle $this.CurrentAngle -DistanceToGo $DistanceToGo
        return $_TempCoords
    }
    [void] Move() {
        [System.Double]$DistanceGone = ($this.CurrentSpeed / 3600000) * $this.RefreshRate
        $DistanceGone = $DistanceGone * [System.Math]::Cos($this.CurrentUpDownAngle)
        [System.Double]$HeightGone = $DistanceGone * [System.Math]::Tan($this.CurrentUpDownAngle)
        $this.CurrentHeight += $HeightGone
        switch (($this.CurrentHeight -gt $this.MaxHeight) -or ($this.CurrentHeight -lt $this.MinHeight)) {
            $true {
                $this.CanFly = $false
                return
            }
		}
		[hashtable]$TempCoords = @{}
		$TempCoords = $this.CalculateTempCoords($DistanceGone)
		# Провека выхода за широту
        switch ([System.Math]::Abs($this.World.WorldTopLeftCornerCoords['longtitude'] - $this.World.WorldBottomLeftCornerCoords['longtitude']) -eq 180) {
            $true {
                switch ($this.World.WorldTopLeftCornerCoords['latitude'] -lt 0) {
                    $true {
                        switch (($TempCoords['latitude'] -gt $this.World.WorldTopLeftCornerCoords['latitude']) -or ($TempCoords['latitude'] -gt $this.World.WorldBottomLeftCornerCoords['latitude']))
						{
							$true
							{
								$this.CanFly = $false
								return;
							}
						}
                    }
                    $false {
                        switch (($TempCoords['latitude'] -lt $this.World.WorldTopLeftCornerCoords['latitude']) -or ($TempCoords['latitude'] -lt $this.World.WorldBottomLeftCornerCoords['latitude']))
						{
							$true
							{
								$this.CanFly = $false
								return;
							}
						}
                    }
                }
            }
            $false {
                switch (($TempCoords['latitude'] -gt $this.World.WorldTopLeftCornerCoords['latitude']) -or ($TempCoords['latitude'] -lt $this.World.WorldBottomLeftCornerCoords['latitude'])){
                    $true {
                        $this.CanFly = $false
                        return
                     }
                }
            }
        }
        # Проверка выхода за долготу
        switch (($TempCoords['longtitude'] -lt $this.World.WorldTopLeftCornerCoords['longtitude']) -or ($TempCoords['longtitude'] -gt $this.World.WorldTopRightCornerCoords['longtitude']))
		{
			$true
			{
				$this.CanFly = $false
				return;
			}
        }
        
        $this.Coords = $TempCoords
        return
    }
    [void] MakeStep () {
        switch ($this.CanFly) {
            $true {
                [System.Int16]$Command = $this.rnd.Next(0, 7)
                switch ($Command)
			    {
				    0
				    {
			    		$this.RotateLeft()
			    		$this.Move()
			    	}
                    1
				    {
				    	$this.RotateRight()
				    	$this.Move()
				    }
    				2
	    			{
		    			$this.IncreaseSpeed()
			    		$this.Move()
				    }
    				3
	    			{
		    			$this.DecreaseSpeed()
			    		$this.Move()
				    }
    				4
	    			{
		    			$this.NoseUp()
			    		$this.Move()
				    }
    				5
    				{
	    				$this.NoseDown()
		    			$this.Move()
			    	}
				    default
    				{
	    				$this.Move()
		    		}
			    }
            }
        }
    }
}