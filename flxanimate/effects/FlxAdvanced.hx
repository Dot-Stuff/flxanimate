package flxanimate.effects;

import openfl.geom.ColorTransform;

class FlxAdvanced extends FlxColorEffect 
{
    public var colorTransform(get, set):ColorTransform;
    
    public function new(colorTransform:ColorTransform)
    {
        super();
        this.colorTransform = colorTransform;
    }
    
    function get_colorTransform()
    {
        return c_Transform;
    }
    function set_colorTransform(value:ColorTransform)
    {
        return c_Transform = value;
    }
}