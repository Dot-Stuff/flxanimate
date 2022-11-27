// Thought things could change, but the only thing changing is my self-esteem.
// Why am I still alive? am I even being useful?
// Who cares? I am just me, smiling and laughing with people as long as they don't notice my dissappearing, who would care?
// I am judged, with a bat swinging around my head. Fortunately, I have brain damage because of it.
// Who cares? I am just vibing, just "sad" one day and then happy again.
// Who cares? I just gonna go through the window and fly away.
// Why am I even holding myself from it? am I in love?
// She doesn't even care about me, does she?
// I don't wanna even know, since dead people don't have to think anymore, am I right?
// Who cares? Just a few stabs, a rope or falling could end my suffering.
// All those looks, all those insults, my mere presence would benefit if it disappeared.
// But I am stupid to still be alive, working for a project that nobody cares.
// But I am stupid to think I would be relevant to anyone, Even though they tell me I am not.
// But I somehow try to believe as hard as I can to her, am I in love?
// Everywhere is grey, what happened to me?
// Am I broken? Can I reverse it?
// Or am I just unfixable?
// Who cares? I am just a stranger, with bad behaviour to many people and someone to be mocked at.
// I wish to go back where I could be careless, back when I almost died.
// Maybe I should've died there.

package flxanimate.animate;

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
    

    var _keyframes(default, null):Array<FlxKeyFrame>;

    public var visible:Bool;

    public var length(get, null):Int;

    public function new(?name:String, ?keyframes:Array<FlxKeyFrame>)
    {
        this.name = name;
        _keyframes = (keyframes != null) ? keyframes : [];
        visible = true;
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
        if (frame is Int)
        {
            index = frame;
            if (index > length) return null;
        }

        for (keyframe in _keyframes)
        {
            if (keyframe.index + keyframe.duration > index || frame is String && keyframe.name == frame)
                return keyframe;
        }
        return null;
    }
    
    public function add(keyFrame:FlxKeyFrame)
    {
        if (keyFrame == null) return null;
        var index = keyFrame.index;

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
        if (frame is FlxKeyFrame)
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