ipmo ".\engines\CoordsCalculation.psm1"  -ErrorAction Stop
function CalculateWorldsCoords {
    param (
        [parameter(Mandatory=$true)] [hashtable] $WorldConfiguration
    )
    [hashtable]$WorldTopLeftCornerCoords = $WorldConfiguration['WorldLeftCornerCoords']
    [System.Double]$WorldSide = $WorldConfiguration['WorldSide']
    [System.Double]$Angle = 180
    [hashtable]$WorldsBottomLeftCornerCoords = CalculateCoords -InitCoords $WorldTopLeftCornerCoords -InitAngle $Angle -DistanceToGo $WorldSide
    [System.Double]$Angle = 90
    [hashtable]$WorldsTopRightCornerCoords = CalculateCoords -InitCoords $WorldTopLeftCornerCoords -InitAngle $Angle -DistanceToGo $WorldSide
    [GEO_classes.World]$World = [GEO_classes.World]::new($WorldTopLeftCornerCoords, $WorldsBottomLeftCornerCoords, $WorldsTopRightCornerCoords)
    return $World
}