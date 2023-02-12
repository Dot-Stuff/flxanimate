package flxanimate.animate;


import flxanimate.data.AnimationData.LayerType;
import flixel.math.FlxMath;
import haxe.extern.EitherType;
import flxanimate.data.AnimationData.Frame;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flxanimate.data.AnimationData.Layers;


class FlxLayer implements IFlxDestroyable
{
    @:allow(flxanimate.animate.FlxTimeline)
    var _parent(default, set):FlxTimeline;
    
    public var name(default, null):String;
    
    @:allow(flxanimate.animate.FlxKeyFrame)
    var _labels:Map<String, FlxKeyFrame>;
    
    public var type:LayerType;
    var _keyframes(default, null):Array<FlxKeyFrame>;


    public var visible:Bool;


    public var length(get, null):Int;


    public function new(?name:String, ?keyframes:Array<FlxKeyFrame>)
    {
        this.name = name;
        type = Normal;
        _keyframes = (keyframes != null) ? keyframes : [];
        visible = true;
        _labels = [];
    }


    public function hide()
    {
        visible = false;
    }
    public function show()
    {
        visible = true;
    }
    public function destroy()
    {
    }
    public function get(frame:EitherType<String, Int>)
    {
        var index = 0;
        if ((frame is String))
        {
            if (!_labels.exists(frame)) return null;
            
            return _labels.get(frame);
        }
        else
        {
            index = frame;
            if (index > length) return null;
        }


        for (keyframe in _keyframes)
        {
            if (keyframe.index + keyframe.duration > index)
                return keyframe;
        }
        return null;
    }
    
    public function add(keyFrame:FlxKeyFrame)
    {
        if (keyFrame == null) return null;
        var index = keyFrame.index;
        if (keyFrame.name != null)
            _labels.set(keyFrame.name, keyFrame);


        var keyframe = get(cast FlxMath.bound(index, 0, length - 1));
        if (length == 0)
        {
            keyframe = new FlxKeyFrame(0, 1);
            _keyframes.push(keyframe);
        }
        var difference:Int = cast Math.abs(index - keyframe.index);


        if (index == keyframe.index)
        {
            keyFrame.duration += keyframe.duration - 1;


            _keyframes.insert(_keyframes.indexOf(keyframe), keyFrame);
            _keyframes.remove(keyframe);
            keyframe.destroy();
        }
        else
        {
            var dur = keyframe.duration;
            keyframe.duration += difference - dur;
            keyFrame.duration += cast FlxMath.bound(dur - difference - 1, 0);
            _keyframes.insert(_keyframes.indexOf(keyframe) + 1, keyFrame);
        }


        keyFrame._parent = this;
        return keyFrame;
    }
    public function remove(frame:EitherType<Int, FlxKeyFrame>)
    {
        if ((frame is FlxKeyFrame))
        {
            _keyframes.remove(frame);
            return frame;
        }
        var index:Int = frame;
        if (length > index)
        {
            var keyframe = get(index);
            (keyframe.duration > 1) ? keyframe.duration-- : _keyframes.remove(keyframe);
            return keyframe;
        }
        return null;
    }
    public function rename(name:String = "")
    {
        if (["", null].indexOf(name) != -1 && ["", null].indexOf(this.name) != -1)
        {
            name = 'Layer ${(_parent != null) ? _parent.getList().length : 1}';
        }
        if (_parent != null && _parent.get(name) != null)
        {
            name += " copy";
        }
        if (["", null].indexOf(name) == -1)
            this.name = name;
    }
    function set__parent(par:FlxTimeline)
    {
        _parent = par;
        rename();
        return par;
    }
    function get_length()
    {
        var keyframe = _keyframes[_keyframes.length - 1];
        return (keyframe != null) ? keyframe.index + keyframe.duration : 0;
    }
    public static function fromJSON(layer:Layers)
    {
        if (layer == null) return null;
        var frames = [];
        var l = new FlxLayer(layer.LN);
        if (layer.LT != null || layer.Clpb != null)
        {
            l.type = (layer.LT != null) ? Clipper : Clipped(layer.Clpb); 
        }
        if (layer.FR != null)
        {
            for (frame in layer.FR)
            {
                l.add(FlxKeyFrame.fromJSON(frame));
            }
        }


        return l;
    }
}