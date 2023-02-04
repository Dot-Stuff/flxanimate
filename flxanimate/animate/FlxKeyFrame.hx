package flxanimate.animate;

import openfl.display.Sprite;
import openfl.filters.BitmapFilter;
import openfl.utils.Function;
import haxe.extern.EitherType;
import flixel.FlxG;
import flixel.math.FlxMath;
import openfl.geom.ColorTransform;
import flxanimate.data.AnimationData;
import flxanimate.animate.FlxLayer;

class FlxKeyFrame
{
    public var name(default, set):Null<String>;
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

    @:allow(flxanimate.FlxAnimate)
    var _sprite:Sprite;

    public var filters:Array<BitmapFilter>;

    public function new(index:Int, ?duration:Int = 1, ?elements:Array<FlxElement> = null, ?colorEffect:ColorEffect = None, ?name:String = null)
    {
        this.index = index;
        this.duration = duration;
        
        this.name = name;
        _elements = (elements == null) ? [] : elements;
        this.colorEffect = colorEffect;
        _sprite = new Sprite();
        _sprite.filters = filters;
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
        if (element is FlxElement)
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

        if (element is FlxElement)
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

    public function destroy() 
    {
        name = null;
        index = 0;
        duration = 0;
        callbacks = null;
        _parent = null;
        colorEffect = null;
        for (element in _elements)
        {
            element.destroy();
        }
        _sprite = null;
    }

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
    function set_name(name:String)
    {
        if (_parent != null)
        {
            _parent._labels.remove(this.name);
            _parent._labels.set(name, this);
        }
        return this.name = name;
    }
    public static function fromJSON(frame:Frame)
    {
        if (frame == null) return null;

        var keyframe = new FlxKeyFrame(frame.I, frame.DU, frame.N);
        keyframe.colorEffect = AnimationData.fromColorJson(frame.C);

        if (frame.E != null)
        {
            for (element in frame.E)
            {
                keyframe.add(FlxElement.fromJSON(element));
            }
        }
        keyframe.filters = AnimationData.fromFilterJson(frame.F);

        return keyframe;
    }
}