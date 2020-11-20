using System;
using System.Collections;

namespace GEO_classes
{
    abstract public class MyObj
    {
        public Double FormattedData;
        public String InputData;
        public String ParameterName;
        public String PatternName;
        public string ErrorMessage;
        public String SectionName;
        public Boolean DataIsCorrect;
        public virtual void TryConvert()
        {
            bool Success = Double.TryParse(this.InputData, out this.FormattedData);
            switch (Success)
            {
                case false:
                    {
                        this.ErrorMessage = "Couldn`t covert to double! Check config file!";
                        this.DataIsCorrect = false;
                        break;
                    }
                case true:
                    {
                        this.DataIsCorrect = true;
                        break;
                    }
            }
        }
    }
    public class Angle : MyObj
    {
        public Angle(
            String _InputData,
            String _ParameterName,
            String _PatternName,
            String _SectionName
            )
        {
            this.InputData = _InputData;
            this.ParameterName = _ParameterName;
            this.PatternName = _PatternName;
            this.SectionName = _SectionName;
            this.FormattedData = 0;
            this.TryConvert();
        }

        public Angle(
            String _InputData,
            String _ParameterName,
            String _SectionName
            )
        {
            this.InputData = _InputData;
            this.ParameterName = _ParameterName;
            this.SectionName = _SectionName;
            this.FormattedData = 0;
            this.TryConvert();
        }
    }
    public class Height : MyObj
    {
        public Height(
            String _InputData,
            String _ParameterName,
            String _PatternName,
            String _SectionName
            )
        {
            this.InputData = _InputData;
            this.ParameterName = _ParameterName;
            this.PatternName = _PatternName;
            this.SectionName = _SectionName;
            this.FormattedData = 0;
            this.TryConvert();
        }

        public Height(
            String _InputData,
            String _ParameterName,
            String _SectionName
            )
        {
            this.InputData = _InputData;
            this.ParameterName = _ParameterName;
            this.SectionName = _SectionName;
            this.FormattedData = 0;
            this.TryConvert();
        }
    }
    public class Speed : MyObj
    {
        public Speed(
            String _InputData,
            String _ParameterName,
            String _PatternName,
            String _SectionName
            )
        {
            this.InputData = _InputData;
            this.ParameterName = _ParameterName;
            this.PatternName = _PatternName;
            this.SectionName = _SectionName;
            this.FormattedData = 0;
            this.TryConvert();
        }

        public Speed(
           String _InputData,
           String _ParameterName,
           String _SectionName
           )
        {
            this.InputData = _InputData;
            this.ParameterName = _ParameterName;
            this.SectionName = _SectionName;
            this.FormattedData = 0;
            this.TryConvert();
        }
    }
    public class Distance : MyObj
    {
        public Distance(
            String _InputData,
            String _ParameterName,
            String _PatternName,
            String _SectionName
            )
        {
            this.InputData = _InputData;
            this.ParameterName = _ParameterName;
            this.PatternName = _PatternName;
            this.SectionName = _SectionName;
            this.FormattedData = 0;
            this.TryConvert();
        }

        public Distance(
            String _InputData,
            String _ParameterName,
            String _SectionName
            )
        {
            this.InputData = _InputData;
            this.ParameterName = _ParameterName;
            this.SectionName = _SectionName;
            this.FormattedData = 0;
            this.TryConvert();
        }
    }
    public class Point : MyObj
    {
        public new Hashtable FormattedData;
        public Point(
            String _InputData,
            String _ParameterName,
            String _PatternName,
            String _SectionName
            )
        {
            this.InputData = _InputData;
            this.ParameterName = _ParameterName;
            this.PatternName = _PatternName;
            this.SectionName = _SectionName;
            this.FormattedData = new Hashtable();
            this.TryConvert();
        }

        public Point(
            String _InputData,
            String _ParameterName,
            String _SectionName
            )
        {
            this.InputData = _InputData;
            this.ParameterName = _ParameterName;
            this.SectionName = _SectionName;
            this.FormattedData = new Hashtable();
            this.TryConvert();
        }

        public override void TryConvert()
        {
            String[] Coords = this.InputData.Split('|');
            switch (Coords.Length)
            {
                case 2:
                    {
                        for (int i = 0; i < Coords.Length; i++)
                        {
                            double CoordD = 0;
                            bool Success = Double.TryParse(Coords[i], out CoordD);
                            switch (Success)
                            {
                                case true:
                                    {
                                        switch (i)
                                        {
                                            case 1:
                                                {
                                                    if ((Math.Abs(CoordD) > 90) == true)
                                                    {
                                                        this.ErrorMessage = "Longtitude range: -90 .. 90. Check config file!";
                                                        this.DataIsCorrect = false;
                                                    }
                                                    else if ((Math.Abs(CoordD) > 90) == false)
                                                    {
                                                        this.DataIsCorrect = true;
                                                        this.FormattedData.Add("longtitude", CoordD);
                                                    }
                                                    break;
                                                }
                                            case 0:
                                                {
                                                    if (((CoordD > 360) || (CoordD < 0)) == true)
                                                    {
                                                        this.ErrorMessage = "Latitude range: 0 .. 360. Check config file!";
                                                        this.DataIsCorrect = false;
                                                    }
                                                    else if (((CoordD > 360) || (CoordD < 0)) == false)
                                                    {
                                                        this.DataIsCorrect = true;
                                                        this.FormattedData.Add("latitude", CoordD);
                                                    }
                                                    break;
                                                }
                                        }
                                        break;
                                    }
                                case false:
                                    {
                                        this.ErrorMessage = "Couldn`t covert to double! Check config file!";
                                        this.DataIsCorrect = false;
                                        break;
                                    }
                            }
                        }
                        break;
                    }
                default:
                    {
                        this.ErrorMessage = "Not enough params specified! Check config file!";
                        this.DataIsCorrect = false;
                        break;
                    }
            }
        }
    }
    public class World
    {
        public Hashtable WorldTopLeftCornerCoords;
        public Hashtable WorldBottomLeftCornerCoords;
        public Hashtable WorldTopRightCornerCoords;

        public World(
            Hashtable _WorldTopLeftCornerCoords,
            Hashtable _WorldBottomLeftCornerCoords,
            Hashtable _WorldTopRightCornerCoords
            )
        {
            this.WorldBottomLeftCornerCoords = _WorldBottomLeftCornerCoords;
            this.WorldTopLeftCornerCoords = _WorldTopLeftCornerCoords;
            this.WorldTopRightCornerCoords = _WorldTopRightCornerCoords;
        }
    }
    public class TestPlane
    {
        public World World;
        public bool CanFly;
        public string PatternName;
        public string PlaneID;
        public double RefreshRate;
        public Hashtable Coords;
        public double MinSpeed;
        public double MaxSpeed;
        public double CurrentSpeed;
        public double SpeedAdjust;
        public double SpeedDecrease;
        public double MinHeight;
        public double MaxHeight;
        public double CurrentHeight;
        public double MaxUpDownAngle;
        public double CurrentUpDownAngle;
        public double MaxRotateAngle;
        public double CurrentAngle;
        public double CurrentRotationAngle;
        public Random rnd;
        public TestPlane(
                World _World,
                string _PatternName,
                string _PlaneID,
                double _RefreshRate,
                Hashtable _Coords,
                double _MinSpeed,
                double _MaxSpeed,
                double _SpeedAdjust,
                double _SpeedDecrease,
                double _MinHeight,
                double _MaxHeight,
                double _MaxUpDownAngle,
                double _MaxRotateAngle,
                double _CurrentAngle,
                Random _rnd
            )
        {
            this.rnd = _rnd;
            this.World = _World;
            this.PatternName = _PatternName;
            this.PlaneID = _PlaneID;
            this.RefreshRate = _RefreshRate;
            this.Coords = _Coords;
            this.MinSpeed = _MinSpeed;
            this.MaxSpeed = _MaxSpeed;
            this.SpeedAdjust = _SpeedAdjust;
            this.SpeedDecrease = _SpeedDecrease;
            this.MinHeight = _MinHeight;
            this.MaxHeight = _MaxHeight;
            this.MaxUpDownAngle = _MaxUpDownAngle;
            this.MaxRotateAngle = _MaxRotateAngle;
            this.CurrentAngle = _CurrentAngle;
            this.CurrentSpeed = this.rnd.Next((int)this.MinSpeed, (int)this.MaxSpeed);
            this.CurrentHeight = this.rnd.Next((int)this.MinHeight, (int)this.MaxHeight);
            this.CurrentRotationAngle = this.rnd.Next(0, (int)this.MaxRotateAngle);
            if (this.rnd.Next(0,10)%2 == 0)
            {
                this.CurrentRotationAngle *= (-1);
            }
            this.CurrentUpDownAngle = this.rnd.Next(0, (int)this.MaxUpDownAngle);
            if (this.rnd.Next(0, 10) % 2 == 0)
            {
                this.MaxUpDownAngle *= (-1);
            }
            this.CanFly = true;
        }
        public void IncreaseSpeed()
        {
            if ((this.CurrentSpeed < this.MaxSpeed) && (this.MaxSpeed - this.CurrentSpeed) >= this.SpeedAdjust)
            {
                this.CurrentSpeed += this.SpeedAdjust;
            }
            else if ((this.CurrentSpeed < this.MaxSpeed) && (this.MaxSpeed - this.CurrentSpeed) < this.SpeedAdjust)
            {
                this.CurrentSpeed = this.MaxSpeed;
            }
        }
        public void DecreaseSpeed()
        {
            if ((this.CurrentSpeed > this.MinSpeed) && (this.CurrentSpeed - this.MinSpeed) >= this.SpeedAdjust)
            {
                this.CurrentSpeed -= this.SpeedDecrease;
            }
            else if ((this.CurrentSpeed > this.MinSpeed) && (this.CurrentSpeed - this.MinSpeed) < this.SpeedAdjust)
            {
                this.CurrentSpeed = this.MinSpeed;
            }
        }
        public void CheckIfAngleIsGreaterThan360Degrees()
        {
            if (this.CurrentAngle >= 360)
            {
                this.CurrentAngle -= 360;
            }
            else if (this.CurrentAngle < 0)
            {
                this.CurrentAngle += 360;
            }
        }
        public void RotateLeft()
        {
            if (this.CurrentRotationAngle + 1 < this.MaxRotateAngle)
            {
                this.CurrentRotationAngle++;
            }
            this.CurrentAngle += this.CurrentRotationAngle;
            if (this.CurrentRotationAngle == 0)
            {
                this.CurrentRotationAngle += 1;
            }
            this.CheckIfAngleIsGreaterThan360Degrees();
        }
        public void RotateRight()
        {
            if (this.CurrentRotationAngle - 1 > (this.MaxRotateAngle) * -1)
            {
                this.CurrentRotationAngle--;
            }
            this.CurrentAngle += this.CurrentRotationAngle;
            if (this.CurrentRotationAngle == 0)
            {
                this.CurrentRotationAngle -= 1;
            }
            this.CheckIfAngleIsGreaterThan360Degrees();
        }
        public void NoseUp()
        {
            if (this.CurrentUpDownAngle + 1 < this.MaxUpDownAngle)
            {
                this.CurrentUpDownAngle += 1;
            }
        }
        public void NoseDown()
        {
            if (this.CurrentUpDownAngle - 1 > this.MaxUpDownAngle * -1)
            {
                this.CurrentUpDownAngle -= 1;
            }
        }
    }
}