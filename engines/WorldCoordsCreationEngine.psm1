function CalculateWorldsCoords {
    param (
        [parameter(Mandatory=$true)] [hashtable] $WorldConfiguration
    )
    [hashtable]$WorldTopLeftCornerCoords = $WorldConfiguration['WorldLeftCornerCoords']
    [System.Double]$WorldSide = $WorldConfiguration['WorldSide']
    [System.Double]$Angle = 180
    [hashtable]$WorldsBottomLeftCornerCoords = [GEO_classes.Sphere]::CalculateCoords($WorldTopLeftCornerCoords, $Angle, $WorldSide)#CalculateCoords -InitCoords $WorldTopLeftCornerCoords -InitAngle $Angle -DistanceToGo $WorldSide
    [System.Double]$Angle = 90
    [hashtable]$WorldsTopRightCornerCoords = [GEO_classes.Sphere]::CalculateCoords($WorldTopLeftCornerCoords, $Angle, $WorldSide)#CalculateCoords -InitCoords $WorldTopLeftCornerCoords -InitAngle $Angle -DistanceToGo $WorldSide
    [GEO_classes.World]$World = [GEO_classes.World]::new($WorldTopLeftCornerCoords, $WorldsBottomLeftCornerCoords, $WorldsTopRightCornerCoords)
    return $World
}