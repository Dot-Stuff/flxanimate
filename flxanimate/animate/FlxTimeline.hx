package flxanimate.animate;
import haxe.extern.EitherType;
import flxanimate.data.AnimationData.SymbolData;
import flixel.FlxG;
import flxanimate.data.AnimationData.Timeline;


class FlxTimeline
{
    
    @:allow(flxanimate.FlxAnimate)
    var _layers:Array<FlxLayer>;

    public var length(get, null):Int;
    public var totalFrames(get, null):Int;
    public function new(?layers:Array<FlxLayer>)
    {
        _layers = (layers != null) ? layers : [];
    }
    public function getListNames()
    {
        return [for (layer in _layers) layer.name];
    }
    public function getList()
    {
        return _layers;
    }
    public function get(name:EitherType<String, Int>)
    {
        if ((name is Int)) return _layers[name];

        for (layer in _layers)
        {
            if (layer.name == name) return layer;
        }

        return null;
    }
    public function hide(name:EitherType<String, Int>)
    {
        var layer = get(name);
        var name:String = (name is String) ? name : layer.name;
        if (layer == null)
        {
            FlxG.log.error('There\'s no layer called "$name"!');
            return;
        }
        if (!layer.visible)
        { 
            FlxG.log.error('The layer called "$name" is already hidden!');
            return;
        }
        layer.hide();
    }

    public function show(name:EitherType<String, Int>)
    {
        var layer = get(name);
        
        var name:String = (name is String) ? name : layer.name;
        if (layer == null) 
        {
            FlxG.log.error('There\'s no layer called "$name"!');
            return;
        }
        if (layer.visible)
        { 
            FlxG.log.error('The layer called "$name" is not hidden!');
            return;
        }

        layer.show();
    }

    public function add(?position:Int = 0, ?name:EitherType<String, FlxLayer>)
    {
        var layer:FlxLayer = null;
        if ((name is String) || name == null)
        {
            layer = new FlxLayer(name);
        }
        else
        {
            layer = name;
        }
        layer._parent = this;
        _layers.insert(position, layer);
        return layer;
    }

    public function remove(name:EitherType<String, FlxLayer>)
    {
        var layer:FlxLayer = null;
        if ((name is String) || name == null)
        {
            layer = get(name);
            if (layer == null)
            {
                FlxG.log.error('There\'s no layer called "$name"!');
            }
        }
        else if (_layers.indexOf(name) != -1)
        {
           layer = name;
        }
        if (layer == null)
        {
            FlxG.log.error('There\'s no layer called "$name"!');
        }
        layer._parent = null;
        _layers.remove(layer);
        return layer;
    }

    function get_length()
    {
        return _layers.length;
    }
    function get_totalFrames()
    {
        var _length = 0;
        for (layer in _layers)
        {
            var length = layer.length;
            if (_length < length)
                _length = length;
        }
        return _length;
    }

    public static function fromJSON(timeline:Timeline)
    {
        if (timeline == null || timeline.L == null) return null;
        var layers = [];
        for (layer in timeline.L)
        {
            layers.push(FlxLayer.fromJSON(layer));
        }

        return new FlxTimeline(layers);
    }
}