package flxanimate.animate;

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
    @:deprecated()
    public var labels(default, null):Map<String, FlxLabel>;
    
    public var layers(get, null):Array<String>;
    
    public var curFrame:Int;
    
    var _tick:Float;
    
    @:allow(flxanimate.animate.FlxAnim)
    function new(name:String, timeline:FlxTimeline)
    {
        layers = [];
        curFrame = 0;
        this.timeline = timeline;
        this.name = name;
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
    public function removeAllCallbacksFrom(label:String, ?layer:EitherType<Int, String>)
    {
        var label = getFrameLabel(label, layer);
        if (label == null)
        {
            return false;
        }
        label.removeCallbacks();
        return true;
    }
    public function getNextToFrameLabel(label:String, ?layer:EitherType<Int, String>)
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
    public function getFrameLabel(name:String, ?layer:EitherType<Int, String>)
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

    function get_length()
    {
        return timeline.totalFrames;
    }
    function get_layers()
    {
        return timeline.getListNames();
    }
    public static function prepareMatrix(d:Dynamic, e:Dynamic) {return new FlxMatrix();}
}