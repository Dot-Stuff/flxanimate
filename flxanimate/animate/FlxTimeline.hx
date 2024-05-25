package flxanimate.animate;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import haxe.extern.EitherType;
import flxanimate.data.AnimationData.SymbolData;
import flixel.FlxG;
import flxanimate.data.AnimationData.Timeline;

class FlxTimeline implements IFlxDestroyable
{
	@:allow(flxanimate.animate.FlxSymbol)
	var _parent:FlxSymbol;

	@:allow(flxanimate.FlxAnimate)
	var _layers:Array<FlxLayer>;
	/**
	 * The total of layers the timeline has.
	 */
	public var length(get, null):Int;
	/**
	 * The total length of frames that the timeline has.
	 */
	public var totalFrames(get, null):Int;
	/**
	 * @param layers the amount of layers the timeline is set.
	 */
	public function new(?layers:Array<FlxLayer>)
	{
		_layers = (layers != null) ? layers : [];
		for (layer in _layers)
			layer._parent = this;
	}
	/**
	 * Gets a list layers' names that the timeline has.
	 *
	 * **WARNING**: Do not confuse `getListNames()` with `getList`!
	 * @return an `Array` of `String`
	 */
	public function getListNames()
	{
		return [for (layer in _layers) layer.name];
	}
	/**
	 * Gets a list of layers that the timeline has.
	 *
	 * **WARNING**: Do not confuse `getListNames()` with `getList`!
	 * @return an `Array` of `FlxLayer`
	 */
	public function getList()
	{
		return _layers;
	}
	/**
	 * Gets a layer.
	 *
	 * **WARNING**: it can return `null`!
	 * @param name Either the name of the layer or the position of it.
	 * @return Either a `FlxLayer` instance or `null`.
	 */
	public function get(name:EitherType<String, Int>)
	{
		if (name is Int) return _layers[name];

		for (layer in _layers)
		{
			if (layer.name == name) return layer;
		}

		return null;
	}
	/**
	 * Gets and sets the layer visibility to `false`.
	 * @param name The layer in question. Can be either a `String` or an `Int`.
	 */
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
	/**
	 * Gets and sets the layer visibility to `true`.
	 * @param name The layer in question. Can be either a `String` or an `Int`.
	 */
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
	/**
	 * Inserts a new layer from a position,
	 * @param position if it's ignored, it'll be set to `0`.
	 * @param name The layer you want to add. it can be either a `String` or a `FlxLayer`.
	 */
	public function add(?position:Int = 0, name:EitherType<String, FlxLayer>)
	{
		var layer:FlxLayer = null;
		if (name is String || name == null)
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
	/**
	 * Removes a layer from the list.
	 * @param name The layer in question. Can be either a `String` or a `FlxLayer`.
	 */
	public function remove(name:EitherType<String, FlxLayer>)
	{
		var layer:FlxLayer = null;
		if (name is String || name == null)
		{
			layer = get(name);
		}
		else if (_layers.indexOf(name) != -1)
		{
		   layer = name;
		}
		if (layer == null)
		{
			FlxG.log.error('There\'s no layer called "$name"!');
			return null;
		}
		layer._parent = null;
		_layers.remove(layer);
		return layer;
	}

	public function updateRender(elapsed:Float, curFrame:Int, dictionary:Map<String, FlxSymbol>, ?swfRender:Bool = false)
	{
		for (layer in _layers)
		{
			layer.updateRender(elapsed, curFrame, dictionary, swfRender);
		}
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
	public function destroy()
	{
		for (layer in _layers)
		{
			layer.destroy();
		}
		_layers = null;
	}
	/**
	 * Creates a `FlxTimeline` instance from the Animation file.
	 * @param timeline The animation file's timeline.
	 * @return a new `FlxTimeline` instance.
	 */
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