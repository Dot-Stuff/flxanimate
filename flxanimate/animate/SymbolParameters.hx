package flxanimate.animate;

import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import openfl.geom.ColorTransform;
import flxanimate.data.AnimationData;

class SymbolParameters
{
    public var instance:String;
    
    public var type(default, set):SymbolT;
    
    public var loop(default, set):Loop;

    public var reverse:Bool;
    
    public var firstFrame:Int;

    public var name:String;

    public var colorEffect:ColorEffect;

    @:allow(flxanimate.FlxAnimate)
    @:allow(flxanimate.animate.FlxAnim)
    var _colorEffect(get, null):ColorTransform;
    
    public var transformationPoint:FlxPoint;


    public function new(?name = null, ?instance:String = "", ?type:SymbolT = Graphic, ?loop:Loop = Loop)
    {
        this.name = name;
        this.instance = instance;
        this.type = type;
        this.loop = loop;
        firstFrame = 0;
        transformationPoint = FlxPoint.get();
        colorEffect = None;
    }

    public function destroy()
    {
        instance = null;
        type = null;
        reverse = false;
        firstFrame = 0;
        name = null;
        colorEffect = null;
        transformationPoint = FlxDestroyUtil.put(transformationPoint);
    }

    function set_type(type:SymbolT)
    {
        this.type = type;
        loop = (type == null) ? null : Loop;

        return type;
    }

    function set_loop(loop:Loop)
    {
        if (type == null) return this.loop = null;
        this.loop = switch (type)
        {
            case MovieClip: Loop;
            case Button: SingleFrame;
            default: loop;
        }

        return loop;
    }

    function get__colorEffect()
    {
        return AnimationData.parseColorEffect(colorEffect);
    }
}