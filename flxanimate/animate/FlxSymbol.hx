package flxanimate.animate;

import openfl.events.Event;
import openfl.events.EventType;
import openfl.display.Sprite;
import openfl.utils.Function;
import haxe.extern.EitherType;
import flixel.math.FlxMatrix;
import flixel.FlxG;
import flxanimate.data.AnimationData;

class FlxSymbol
{
    public var timeline(default, null):FlxTimeline;

    public var length(get, null):Int;

    public var name(default, null):String;
    @:noCompletion
    @:deprecated("")
    public var labels(default, null):Map<String, FlxLabel>;
    
    public var layers(get, null):Array<String>;
    
    public var curFrame(get, set):Int;
    
    @:allow(flxanimate.animate.FlxAnim)
    var _curFrame:Int;

    @:allow(flxanimate.FlxAnimate)
    var _shootCallback:Bool;

    var _tick:Float;
    
    @:allow(flxanimate.animate.FlxAnim)
    function new(name:String, timeline:FlxTimeline)
    {
        layers = [];
        curFrame = 0;
        this.timeline = timeline;
        this.name = name;
    }
    @:access(flxanimate.FlxAnimate)
    function toSprite()
    {
        var sprite = new Sprite();
        var list = timeline.getList();
        for (layer in list)
        {
            var spr = new Sprite();
            spr.name = layer.name;
            sprite.addChildAt(spr, 0);
        }
        return sprite;
    }
    public function hideLayer(layer:String)
    {
        timeline.hide(layer);
    }
    public function showLayer(layer:String)
    {
        timeline.show(layer);
    }
    public function addCallbackTo(label:String, callback:Function, ?layer:EitherType<Int, String>)
    {
        var label = getFrameLabel(label, layer);
        if (label == null)
        {
            return false;
        }
        
        if (label.callbacks.indexOf(callback) != -1)
        {
            FlxG.log.error("this callback already exists!");
            return false;
        }
        label.callbacks.push(callback);
        return true;
    }
    public function getCallbackFrom(label:String, callback:EitherType<Function, Int>, ?layer:EitherType<Int, String>)
    {
        var label = getFrameLabel(name, layer);
        if (label == null)
        {
            return null;
        }
        var c:Function = label.callbacks[(callback is Int) ? callback : label.callbacks.indexOf(callback)];
        return c;
    }
    public function removeCallbackFrom(label:String, callback:EitherType<Function, Int>, ?layer:EitherType<Int, String>)
    {
        var label = getFrameLabel(name, layer);
        if (label == null)
        {
            return false;
        }
        var callback = (callback is Int) ? label.callbacks[callback] : callback;
        if (label.callbacks.indexOf(callback) == -1)
        {
            FlxG.log.error("this callback doesn't exist!");
        }
        label.callbacks.remove(callback);
        return true;
    }
    public function removeAllCallbacksFrom(label:String, ?layer:EitherType<Int, String> = null)
    {
        var label = getFrameLabel(label, layer);
        if (label == null)
        {
            return false;
        }
        label.removeCallbacks();
        return true;
    }
    public function getNextToFrameLabel(label:String, ?layer:EitherType<Int, String> = null)
    {
        if (layer == null) layer = 0;
        var label = getFrameLabel(label, layer);
        if (label == null) return null;

        var layer = timeline.get(layer);
        @:privateAccess
        var j = layer._keyframes.indexOf(label);
        @:privateAccess
        while (j++ < layer._keyframes.length)
        {
            @:privateAccess
            if ([null, label.name].indexOf(layer._keyframes[j].name) == -1)
                return layer._keyframes[j];
        }

        return null;
    }
    public function getFrameLabel(name:String, ?layer:EitherType<Int, String> = null)
    {
        var frame:FlxKeyFrame = null;
        var layers = (layer == null) ? timeline.getList() : [timeline.get(layer)];
        
        for (layer in layers)
        {
            if (layer == null) continue;
            
            var fr = layer.get(name);
            if (fr != null)
            {
                frame = fr;
                break;
            } 
        }

        if (frame == null)
        {
            FlxG.log.error('The frame label "$name" does not exist! maybe you misspelled it?');
        }

        return frame;
    }
    public function frameControl(frame:Int, loopType:LoopType)
    {
        if (frame < 0)
		{
			if ([loop, "loop"].indexOf(loopType) != -1)
				frame += (length > 0) ? length - 1 : frame;
			else
			{
				frame = 0;
			}
			
		}
		else if (frame > length - 1)
		{
			if ([loop, "loop"].indexOf(loopType) != -1)
			{
				frame -= (length > 0) ? length - 1 : frame;
			}
			else
			{
				frame = length - 1;
			}
		}

        return frame;
    }

    public function update(framerate:Float, reversed:Bool)
    {
        // _tick += FlxG.elapsed;
        // var delay = 1 / framerate;

        // while (_tick > delay)
        // {
        //     curFrame++;
        //     _tick -= delay;
        // }
    }
    /**
     * Gets an element through a specific index from a frame.
     * @param index The element index.
     * @param frame The keyframe the element is located. If set to `null`, it will take `curFrame` as a reference.
     * @return an `FlxElement` instance.
     */
    public function getElement(index:Int, ?frame:Int = null)
    {
        if (frame == null)
            frame = curFrame;
        for (layer in timeline.getList())
        {
            var keyframe = layer.get(frame);

            if (keyframe == null) continue;

            var elements = keyframe.getList();

            if (index > elements.length - 1)
            {
                index -= elements.length - 1;
                continue;
            }

            return elements[index];
        }
        return null;
    }
    public function getFrameLabels(?layer:EitherType<Int, String> = null)
    {
        var array = [];
        var labels = [];
        if (layer == null)
        {
            for (layer in timeline.getList())
            {
                @:privateAccess
                for (label in layer._labels.iterator())
                {
                    labels.push(label);
                }
            }
        }
        else
        {
            @:privateAccess
            for (label in timeline.get(layer)._labels.iterator())
            {
                labels.push(label);
            }
        }
        labels.sort((a, b) -> a.index - b.index);
        for (label in labels)
        {
            array.push(label.name);
        }
        
        return array;
    }
    /**
     * Gets an element with a name
     * @param name this can be either the name of the symbol or the instance.
     * @param frame The keyframe the element is located. If set to `null`, it will take `curFrame` as a reference.
     * @param layer Which layer it should take as a reference. if set to `null`, it'll take every layer available.
     * @return an `FlxElement` instance.
     */
    public function getElementByName(name:String, ?frame:Int = null, ?layer:EitherType<Int, String> = null)
    {
        if (frame == null)
            frame = curFrame;

        if (layer != null)
        {
            var keyframe = timeline.get(layer).get(frame);

            if (keyframe == null) return null;

            for (element in keyframe.getList())
            {
                if (element.symbol == null)
                    continue;

                var instance = (element.symbol.instance == "") ? element.symbol.name : element.symbol.instance;

                if (instance == name) 
                    return element;
                else
                    continue;
            }
        }
        else
        {
            for (layer in timeline.getList())
            {
                var keyframe = layer.get(frame);

                if (keyframe == null) continue;

                for (element in keyframe.getList())
                {
                    if (element.symbol == null)
                        continue;

                    var instance = (element.symbol.instance == "") ? element.symbol.name : element.symbol.instance;

                    if (instance == name)
                        return element;
                    else
                        continue;
                }
            }
        }
        return null;
    }
    public function getElementIndex(element:FlxElement, ?frame:Int = null)
    {
        if (frame == null)
            frame = curFrame;

        var list:Int = 0;
        for (layer in timeline.getList())
        {
            var keyframe = layer.get(frame);
            
            if (keyframe == null) continue;

            for (e in keyframe.getList())
            {
                if (element == e)
                    return list;

                list++;
            }
        }
        return -1;
    }
    public function swapElements(oldElement:FlxElement, newElement:FlxElement, ?frame:Int = null)
    {
        if (frame == null)
            frame = curFrame;

        var index = getElementIndex(oldElement);

        if (index == -1)
        {
            FlxG.log.error("oldElement doesnt exist in this symbol!");
            return;
        }
        var oldElement = getElement(index);
        oldElement = newElement;
    }

    function get_length()
    {
        return timeline.totalFrames;
    }
    function get_layers()
    {
        return timeline.getListNames();
    }
    function get_curFrame()
    {
        return _curFrame;
    }
    function set_curFrame(value:Int)
    {
        _curFrame = value;
        _shootCallback = false;

        return value;
    }

    public static function prepareMatrix(d:Dynamic, e:Dynamic) {return new FlxMatrix();}
}