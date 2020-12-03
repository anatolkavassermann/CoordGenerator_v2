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
    public class Plane
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
        public Plane(
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
            this.MinSpeed = Math.Abs(_MinSpeed);
            this.MaxSpeed = Math.Abs(_MaxSpeed);
            this.SpeedAdjust = _SpeedAdjust;
            this.SpeedDecrease = _SpeedDecrease;
            this.MinHeight = Math.Abs(_MinHeight);
            this.MaxHeight = Math.Abs(_MaxHeight);
            this.MaxUpDownAngle = Math.Abs(_MaxUpDownAngle);
            this.MaxRotateAngle = Math.Abs(_MaxRotateAngle);
            this.CurrentAngle = _CurrentAngle;
            this.CurrentSpeed = this.rnd.Next((int)this.MinSpeed, (int)this.MaxSpeed);
            this.CurrentHeight = this.rnd.Next((int)this.MinHeight, (int)this.MaxHeight);
            this.CurrentRotationAngle = this.rnd.Next(0, (int)this.MaxRotateAngle);
            if (this.rnd.Next(0, 10) % 2 == 0)
            {
                this.CurrentRotationAngle *= (-1);
            }
            this.CurrentUpDownAngle = this.rnd.Next(0, (int)this.MaxUpDownAngle);
            if (this.rnd.Next(0, 10) % 2 == 0)
            {
                this.CurrentUpDownAngle *= (-1);
            }
            this.CanFly = true;
        }
        private void IncreaseSpeed()
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
        private void DecreaseSpeed()
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
        private void CheckIfAngleIsGreaterThan360Degrees()
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
        private void RotateLeft()
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
        private void RotateRight()
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
        private void NoseUp()
        {
            if (this.CurrentUpDownAngle + 1 < this.MaxUpDownAngle)
            {
                this.CurrentUpDownAngle += 1;
            }
        }
        private void NoseDown()
        {
            if (this.CurrentUpDownAngle - 1 > this.MaxUpDownAngle * -1)
            {
                this.CurrentUpDownAngle -= 1;
            }
        }
        private Hashtable CalculateTempCoords(double DistanceToGo)
        {
            Hashtable _TempCoords = this.Coords;
            _TempCoords = Sphere.CalculateCoords(_TempCoords, this.CurrentAngle, DistanceToGo);
            return _TempCoords;
        }
        private void Move()
        {
            double DistanceGone = (this.CurrentSpeed / 3600000) * this.RefreshRate;
            DistanceGone = DistanceGone * Math.Cos(this.CurrentUpDownAngle);
            double HeightGone = DistanceGone * Math.Tan(this.CurrentUpDownAngle);
            this.CurrentHeight += HeightGone;
            switch ((this.CurrentHeight > this.MaxHeight) || (this.CurrentHeight < this.MinHeight))
            {
                case true:
                    {
                        this.CanFly = false;
                        return;
                    }
            }
            Hashtable TempCoords = new Hashtable();
            TempCoords = CalculateTempCoords(DistanceGone);
            switch (Math.Abs((double)this.World.WorldTopLeftCornerCoords["longtitude"] - (double)this.World.WorldBottomLeftCornerCoords["longtitude"]) == 180)
            {
                case true:
                    {
                        switch ((double)this.World.WorldTopLeftCornerCoords["latitude"] < 0)
                        {
                            case true: {
                                switch (((double)TempCoords["latitude"] > (double)this.World.WorldTopLeftCornerCoords["latitude"]) || ((double)TempCoords["latitude"] > (double)this.World.WorldBottomLeftCornerCoords["latitude"]))
                                {
                                    case true:
                                    {
                                        this.CanFly = false;
                                        return;
                                    }
                                }
                                break;
                            }
                            case false: {
                                    switch (((double)TempCoords["latitude"] < (double)this.World.WorldTopLeftCornerCoords["latitude"]) || ((double)TempCoords["latitude"] < (double)this.World.WorldBottomLeftCornerCoords["latitude"]))
                                    {
                                        case true:
                                            {
                                                this.CanFly = false;
                                                return;
                                            }
                                    }
                                    break;
                            }
                        }
                        break;
                    }
                case false:
                    {
                        switch (((double)TempCoords["latitude"] > (double)this.World.WorldTopLeftCornerCoords["latitude"]) || ((double)TempCoords["latitude"] < (double)this.World.WorldBottomLeftCornerCoords["latitude"]))
                        {
                            case true:
                                {
                                    this.CanFly = false;
                                    return;
                                }
                        }
                        break;
                    }
            }
            switch (((double)TempCoords["longtitude"] < (double)this.World.WorldTopLeftCornerCoords["longtitude"]) || ((double)TempCoords["longtitude"] > (double)this.World.WorldTopRightCornerCoords["longtitude"]))
            {
                case true:
                    {
                        this.CanFly = false;
                        return;
                    }
            }
            this.Coords = TempCoords;
            return;
        }
        public void MakeStep()
        {
            switch (this.CanFly)
            {
                case true:
                    {
                        byte Command = (byte)this.rnd.Next(0, 7);
                        switch (Command)
                        {
                            case 0:
                                {
                                    this.RotateLeft();
                                    this.Move();
                                    break;
                                }
                            case 1:
                                {
                                    this.RotateRight();
                                    this.Move();
                                    break;
                                }
                            case 2:
                                {
                                    this.IncreaseSpeed();
                                    this.Move();
                                    break;
                                }
                            case 3:
                                {
                                    this.DecreaseSpeed();
                                    this.Move();
                                    break;
                                }
                            case 4:
                                {
                                    this.NoseUp();
                                    this.Move();
                                    break;
                                }
                            case 5:
                                {
                                    this.NoseDown();
                                    this.Move();
                                    break;
                                }
                            default:
                                {
                                    this.Move();
                                    break;
                                }
                        }
                        break;
                    }
            }
            return;
        }
    }
    public class Sphere
    {
        static public double A_E = 6371.0;
        static public double[] SphereToCart(double lat, double lon)
        {
            double x = Math.Cos(lat) * Math.Cos(lon);
            double y = Math.Cos(lat) * Math.Sin(lon);
            double z = Math.Sin(lat);
            return (new double[3] { x, y, z });
        }
        static public double[] CartToSphere(double x, double y, double z)
        {
            double lat = Math.Atan2(z, Math.Sqrt(x * x + y * y));
            double lon = Math.Atan2(y, x);
            return (new double[2] { lat, lon });
        }
        static public double[] Rotate(double x, double y, double a)
        {
            double c = Math.Cos(a);
            double s = Math.Sin(a);
            double u = x * c + y * s;
            double v = -x * s + y * c;
            return (new double[2] { u, v });
        }
        static public double[] Inverse(double lat1, double lon1, double lat2, double lon2)
        {
            double[] t = SphereToCart(lat2, lon2);
            double x = t[0];
            double y = t[1];
            double z = t[2];
            t = Rotate(x, y, lon1);
            x = t[0];
            y = t[1];
            t = Rotate(z, x, Math.PI / 2 - lat1);
            z = t[0];
            x = t[1];
            t = CartToSphere(x, y, z);
            double lat = t[0];
            double lon = t[1];
            double dist = Math.PI / 2 - lat;
            double azi = Math.PI - lon;
            return (new double[2] { dist, azi });
        }
        static public double[] Direct(double lat1, double lon1, double dist, double azi)
        {
            double[] t = SphereToCart(Math.PI / 2 - dist, Math.PI - azi);
            double x = t[0];
            double y = t[1];
            double z = t[2];
            t = Rotate(z, x, lat1 - Math.PI / 2);
            z = t[0];
            x = t[1];
            t = Rotate(x, y, -lon1);
            x = t[0];
            y = t[1];
            t = CartToSphere(x, y, z);
            double lat2 = t[0];
            double lon2 = t[1];
            return (new double[2] { lat2, lon2 });
        }
        static public double Radians(double x)
        {
            return (x / 57.29577951308232);
        }
        static public double Degrees(double x)
        {
            return (x * 57.29577951308232);
        }
        static public Hashtable CalculateCoords (Hashtable Point1, double azi, double dist)
        {
            double lat1 = (double)Point1["latitude"];
            double lon1 = (double)Point1["longtitude"];
            lat1 = Radians(lat1);
            lon1 = Radians(lon1);
            double azi1 = Radians(azi);
            double dist1 = dist / A_E;
            double[] t = Direct(lat1, lon1, dist1, azi1);
            double lat2 = t[0];
            double lon2 = t[1];
            t = Inverse(lat2, lon2, lat1, lon1);
            dist1 = t[0];
            azi1 = t[1];
            lat2 = Degrees(lat2);
            lon2 = Degrees(lon2);
            Hashtable Point2 = new Hashtable();
            Point2.Add("latitude", Math.Round(lat2, 6));
            Point2.Add("longtitude", Math.Round(lon2, 6));
            return Point2;
        }
    }
}