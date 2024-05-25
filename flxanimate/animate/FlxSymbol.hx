package flxanimate.animate;

import flixel.util.FlxDestroyUtil;
import flxanimate.display.FlxAnimateFilterRenderer;
import openfl.filters.BitmapFilter;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.EventType;
import openfl.display.Sprite;
import openfl.utils.Function;
import haxe.extern.EitherType;
import flixel.math.FlxMatrix;
import flixel.FlxG;
import flxanimate.data.AnimationData;

class FlxSymbol implements IFlxDestroyable
{
	@:allow(flxanimate.animate.FlxElement)
	var filterPool:Map<Array<BitmapFilter>, BitmapData> = [];

	var _sprite:Sprite;
	@:allow(flxanimate.FlxAnimate)
	var _checking:Bool = false;
	@:allow(flxanimate.FlxAnimate)
	var activeCount:Int = 0;

	var _sprites:Array<Sprite> = [];

	public var timeline(default, null):FlxTimeline;
	/**
	 * The amount of frames the symbol has.
	 */
	public var length(get, null):Int;
	/**
	 * The name of the symbol.
	 */
	public var name(default, null):String;
	@:noCompletion
	@:deprecated("")
	public var labels(default, null):Map<String, FlxLabel>;

	/**
	 * The callback that's called for every `fireCallbacks()`.
	 */
	public var onCallback:()->Void;

	/**
	 * The amount of layers structured in names.
	 */
	public var layers(get, null):Array<String>;

	/**
	 * The current frame.
	 */
	public var curFrame(get, set):Int;

	@:allow(flxanimate.animate.FlxAnim)
	var _curFrame:Int;

	var _tick:Float;

	@:allow(flxanimate.animate.FlxAnim)
	function new(name:String, timeline:FlxTimeline)
	{
		layers = [];
		curFrame = 0;
		this.timeline = timeline;
		timeline._parent = this;

		this.name = name;

		activeCount = 0;
	}
	/**
	 * Hides a layer from the timeline.
	 * @param layer The name of the layer.
	 */
	public function hideLayer(layer:String)
	{
		timeline.hide(layer);
	}
	/**
	 * Shows a layer from the timeline.
	 * @param layer The name of the layer.
	 */
	public function showLayer(layer:String)
	{
		timeline.show(layer);
	}
	/**
	 * Adds a callback to a specific frame label.
	 * @param label
	 * @param callback
	 * @param layer
	 */
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
	/**
	 * Removes a callback from a certain label. can be extracted from a certain layer.
	 * @param label The label in question.
	 * @param callback The callback. Can be the actual function or an `Int` referring to its index.
	 * @param layer The layer in question.
	 */
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
	public function destroy()
	{
		name = "";

		timeline.destroy();
	}
	public function getNextToFrameLabel(label:String, ?layer:EitherType<Int, String> = null)
	@:privateAccess {
		if (layer == null) layer = 0;
		var label = getFrameLabel(label, layer);
		if (label == null) return null;

		var layer = timeline.get(layer);
		var j = layer._keyframes.indexOf(label);
		while (j++ < layer._keyframes.length)
		{
			var name = layer._keyframes[j].name;
			//if ([null, label.name].indexOf(layer._keyframes[j].name) == -1)
			if (name != null && name != label.name)
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

	public function updateRender(elapsed:Float, curFrame:Int, dictionary:Map<String, FlxSymbol>, ?swfRender:Bool = false)
	{
		timeline.updateRender(elapsed, curFrame, dictionary, swfRender);
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
	/**
	 * Gets a list of frames that have a label of any kind.
	 * @param layer A specific layer to get the list. if set to `null`, it'll get a list from every layer.
	 */
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
			array.push(label);
		}

		return array;
	}
	public function getFrameLabelNames(?layer:EitherType<Int, String> = null)
	{
		var labels = getFrameLabels(layer);
		var array = [];
		for (label in labels)
		{
			array.push(label.name);
		}

		return array;
	}
	/**
	 * Gets a symbol element via the symbol's name or the instance's name inside a frame.
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

				if (element.symbol.name == name || element.symbol.instance == name)
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

					if (element.symbol.name == name || element.symbol.instance == name)
						return element;
					else
						continue;
				}
			}
		}
		return null;
	}
	/**
	 * Gets the element's position inside a frame.
	 * @param element The element in question.
	 * @param frame The keyframe the element is located. If set to `null`, it will take `curFrame` as a reference.
	 */
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
	/**
	 * Swaps an element with another one.
	 * @param oldElement The element you wanna replace
	 * @param newElement The new element that's gonna replace the old one
	 * @param frame The keyframe the element is located. If set to `null`, it will take `curFrame` as a reference.
	 */
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
	public function fireCallbacks(?frame:Int)
	{
		if (frame == null)
			frame = _curFrame;

		for (layer in timeline.getList())
		{
			for (label in layer._labels.iterator())
			{
				if (label.index != frame)
					continue;

				label.fireCallbacks();
			}
		}
		if (onCallback != null)
			onCallback();
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
		return _curFrame = value;
	}
}