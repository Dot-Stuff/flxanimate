package flxanimate.motion.easing;

import flxanimate.data.AnimationData.TransformationPoint;
import flixel.math.FlxPoint;

class BezierEase 
{
    public static var LINEAR(get, never):BezierEase;

    public var anchor1(default, set):FlxPoint;

    public var anchor2(default, set):FlxPoint;


    public var points:Array<KeyPoint>;

    public function new(anchor1:FlxPoint, anchor2:FlxPoint)
    {
        points = [];
        
        this.anchor1 = anchor1;
        this.anchor2 = anchor2;
    }


    public function addPoint(percent:Float)
    {
        
    }


    public static function lerp(a:Float, b:Float, r:Float)
    {
        return (1 - r) * a + r * b;
    }

    function set_anchor1(val:FlxPoint)
    {
        if (val == null)
        {
            if (anchor1 == null)
                anchor1 = FlxPoint.get(0.3333, 0.3333);
            return anchor1;
        }
        return anchor1 = val;
    }
    function set_anchor2(val:FlxPoint)
    {
        if (val == null)
        {
            if (anchor2 == null)
                anchor2 = FlxPoint.get(0.6667, 0.6667);
            return anchor2;
        }
        return anchor2 = val;
    }


    public static function fromValue(ease:Float):BezierEase
    {
        var lin = BezierEase.LINEAR;

        if (ease == 0)
            return lin;

        var e = ease * 0.01;
        

        if (ease > 0)
        {
            lin.anchor1.y = lerp(lin.anchor1.y, 0.6667, e);
            lin.anchor2.y = lerp(lin.anchor2.y, 1, e);
        }
        else
        {
            lin.anchor1.y = lerp(lin.anchor1.y, 0, e);
            lin.anchor2.y = lerp(lin.anchor2.y, 0.3333, e);
        }

        return lin;

    }


    public function compute(percent:Float)
    {
        if (points.length == 0)
        {
            var value = bezier(FlxPoint.weak(), anchor1, anchor2, FlxPoint.weak(1, 1), percent);
            return value.y;
        }

        return 0;
    }

    function bezier(p0:FlxPoint, p1:FlxPoint, p2:FlxPoint, p3:FlxPoint, t:Float)
    {
        if (t < 0)
            t = 0;
        if (t > 1)
            t = 1;
        var z = (1 - t);
        return (z * z * z) * p0 + 
                3 * t * (z * z) * p1 + 
                3 * (t * t) * z * p2 + 
                (t * t * t) * p3;
    }

    static function get_LINEAR()
    {
        return new BezierEase(null, null);
    }

    public static function fromJSON(points:Array<TransformationPoint>):BezierEase
    {
        var points = points.copy();

        if ((points[0].x + points[0].y) != 0 || (points[points.length - 1].x + points[points.length - 1].y) != 2)
        {
            return null;
        }

        points.pop();
        points.shift();

        var p0 = new FlxPoint(points[0].x, points[0].y);
        var p1 = new FlxPoint(points[points.length - 1].x, points[points.length - 1].y);

        var ease = new BezierEase(p0, p1);
        
        
        return ease;
    }
}