package flxanimate.motion.easing;

class KeyPoint 
{
    var _parent:BezierEase = null;
    public var x:Float;
    public var y:Float;


    public function new(x:Float = 0, y:Float = 0)
    {
        this.x = x;
        this.y = y;
    }
}