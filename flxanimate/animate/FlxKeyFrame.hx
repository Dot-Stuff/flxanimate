package flxanimate.animate;

import openfl.utils.Function;
import haxe.extern.EitherType;
import flixel.FlxG;
import flixel.math.FlxMath;
import openfl.geom.ColorTransform;
import flxanimate.data.AnimationData;
import flxanimate.animate.FlxLayer;

class FlxKeyFrame
{
    public var name(default, null):Null<String>;
    @:allow(flxanimate.animate.FlxSymbol)
    @:allow(flxanimate.FlxAnimate)
    var callbacks(default, null):Array<Function>;
    @:allow(flxanimate.animate.FlxLayer)
    var _parent:FlxLayer;
    public var index(default, set):Int;
    public var duration(default, set):Int;
    public var colorEffect:ColorEffect;
    @:allow(flxanimate.FlxAnimate)
    var _elements(default, null):Array<FlxElement>;
    @:allow(flxanimate.FlxAnimate)
    var _colorEffect(get, null):ColorTransform;

    public function new(index:Int, ?duration:Int = 1, ?elements:Array<FlxElement>, ?colorEffect:ColorEffect, ?name:String)
    {
        this.index = index;
        this.duration = duration;
        
        this.name = name;
        _elements = (elements == null) ? [] : elements;
        this.colorEffect = colorEffect;
        callbacks = [];
    }
    
    function set_duration(duration:Int)
    {
        var difference:Int = cast this.duration - FlxMath.bound(duration, 1);
        this.duration = cast FlxMath.bound(duration, 1);
        if (_parent != null)
        {
            var frame = _parent.get(index + duration);
            if (frame != null)
                frame.index -= difference;
        }
        return duration;
    }
    public function add(element:EitherType<FlxElement, Function>)
    {   
        if ((element is FlxElement))
        {
            var element:FlxElement = element;
            if (element == null)
            {
                FlxG.log.error("this element is null!");
                return null;
            }
            element._parent = this;
            _elements.push(element);
        }
        else
        {
            if (element == null)
            {
                FlxG.log.error("this callback is null!");
                return null;
            }
            callbacks.push(element);
        }

        return element;
    }
    public function get(element:Int)
    {
        return _elements[element];
    }
    public function getList()
    {
        return _elements;
    }
    public function remove(element:EitherType<FlxElement, Function>)
    {
        if (element == null) return null;

        if ((element is FlxElement))
        {
            if (element == null || !_elements.remove(element))
            {
                FlxG.log.error("this element doesn't exist!");
                return null;
            }
        }
        else
        {
            if (element == null || !callbacks.remove(element))
            {
                FlxG.log.error("this callback doesn't exist!");
                return null;
            }
        }
        return element;
    }
    public function fireCallbacks()
    {
        for (callback in callbacks)
        {
            callback();
        }
    }
    public function removeCallbacks()
    {
        callbacks = [];
    }
    public function clone()
    {
        var keyframe = new FlxKeyFrame(duration, _elements, colorEffect, name);
        keyframe.callbacks = callbacks;
        return keyframe;
    }

    public function destroy() {}

    public function toString()
    {
        return '{index: $index, duration: $duration}';
    }
    function get__colorEffect()
    {
        return AnimationData.parseColorEffect(colorEffect);
    }
    function set_index(i:Int)
    {
        index = i;
        if (_parent != null)
        {
            _parent.remove(this);
            _parent.add(this);
        }
        return index;
    }
    public static function fromJSON(frame:Frame)
    {
        if (frame == null) return null;
        var elements:Array<FlxElement> = [];
        if (frame.E != null)
        {
            for (element in frame.E)
            {
                elements.push(FlxElement.fromJSON(element));
            }
        }

        return new FlxKeyFrame(frame.I, frame.DU, elements, AnimationData.fromColorJson(frame.C), frame.N);
    }
}
