package flxanimate.animate;

import flixel.FlxG;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxRect;
import flixel.graphics.FlxGraphic;
import openfl.geom.Rectangle;
import flixel.FlxObject;
import flxanimate.display.FlxAnimateFilterRenderer;
import flixel.math.FlxMatrix;
import flixel.graphics.frames.FlxFrame;
import flixel.FlxCamera;
import openfl.display.BitmapData;
import flxanimate.data.AnimationData.LayerType;
import flixel.math.FlxMath;
import haxe.extern.EitherType;
import flxanimate.data.AnimationData.Frame;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flxanimate.data.AnimationData.Layers;
import flxanimate.interfaces.IFilterable;
import flxanimate.motion.easing.*;

class FlxLayer extends FlxObject implements IFilterable
{
	@:allow(flxanimate.FlxAnimate)
	var _filterCamera:FlxCamera;

	/**
	 *
	 *
	 * @since `4.0.0`
	 */
	public var onFrameUpdate:(prevFrame:FlxKeyFrame, curFrame:FlxKeyFrame)->Void;

	var _mcMap:Map<String, Int>;
	@:allow(flxanimate.FlxAnimate)
	var _filterFrame:FlxFrame;
	@:allow(flxanimate.FlxAnimate)
	var _bmp1:BitmapData;
	@:allow(flxanimate.FlxAnimate)
	var _bmp2:BitmapData;

	@:allow(flxanimate.FlxAnimate)
	var _filterMatrix:FlxMatrix;

	@:allow(flxanimate.FlxAnimate)
	var _renderable:Bool = true;

	@:allow(flxanimate.animate.FlxTimeline)
	var _parent(default, set):FlxTimeline;

	public var name(default, null):String;

	@:allow(flxanimate.animate.FlxKeyFrame)
	@:allow(flxanimate.animate.FlxSymbol)
	var _labels:Map<String, FlxKeyFrame>;

	public var type(default, set):LayerType;

	@:allow(flxanimate.animate.FlxKeyFrame)
	var _keyframes(default, null):Array<FlxKeyFrame>;

	@:allow(flxanimate.FlxAnimate)
	var _correctClip:Bool = false;

	@:allow(flxanimate.FlxAnimate)
	var _clipper:FlxLayer = null;

	public var length(get, null):Int;

	@:allow(flxanimate.FlxAnimate)
	var _currFrame:FlxKeyFrame;

	public function new(?name:String, ?keyframes:Array<FlxKeyFrame>)
	{
		super();
		this.name = name;
		type = Normal;
		_keyframes = (keyframes != null) ? keyframes : [];
		visible = true;
		_labels = [];
		_mcMap = [];
		_filterMatrix = new FlxMatrix();
	}

	public function hide()
	{
		visible = false;
	}
	public function show()
	{
		visible = true;
	}
	override public function destroy()
	{
		super.destroy();
		if (_filterFrame != null)
		{
			FlxG.bitmap.remove(_filterFrame.parent);
		}
		_filterFrame = FlxDestroyUtil.destroy(_filterFrame);
		_filterCamera = FlxDestroyUtil.destroy(_filterCamera);
		_filterMatrix = null;
		FlxG.bitmap.remove(FlxG.bitmap.get(FlxG.bitmap.findKeyForBitmap(_bmp1)));
		_bmp1 = FlxDestroyUtil.dispose(_bmp1);
		FlxG.bitmap.remove(FlxG.bitmap.get(FlxG.bitmap.findKeyForBitmap(_bmp2)));
		_bmp2 = FlxDestroyUtil.dispose(_bmp2);

		for (keyframe in _keyframes)
		{
			keyframe.destroy();
		}
		_keyframes = null;
	}

	public function updateRender(elapsed:Float, curFrame:Int, dictionary:Map<String, FlxSymbol>, ?swfRender:Bool = false)
	{
		update(elapsed);
		var _prevFrame = _currFrame;
		_setCurFrame(curFrame);
		if (_clipper == null && type.getName() == "Clipped")
		{
			if (_parent != null)
			{
				var l = _parent.get(type.getParameters()[0]);
				if (l != null)
				{
					l._correctClip = true;

					_clipper = l;
				}
			}
		}
		else if (_clipper != null)
		{
			if (_clipper._currFrame._renderDirty)
			{
				_currFrame._renderDirty = true;
			}
		}

		if (_currFrame != null)
		{
			if (_correctClip)
				_currFrame._cacheAsBitmap = true;
			if (_prevFrame != _currFrame)
			{
				_currFrame._renderDirty = true;
				_prevFrame = _currFrame;
			}
			_currFrame.updateRender(elapsed, curFrame, dictionary);
		}


	}
	public function get(frame:EitherType<String, Int>)
	{
		return _get(frame, false);
	}
	@:allow(flxanimate.FlxAnimate)
	function _get(frame:EitherType<String, Int>, _animateRendering:Bool = true)
	{
		if (_animateRendering && type.getName() == "Clipped")
		{
			var layers = _parent.getList();
			var layer = layers[layers.indexOf(this) - 1];
			if (_parent != null && layer != null && layer.type.getName() == "Clipper")
			{
				layer._renderable = false;
			}
		}
		var index = 0;
		if ((frame is String))
		{
			if (!_labels.exists(frame)) return null;

			var label = _labels.get(frame);

			return label;
		}
		else
		{
			index = frame;
			if (index < 0 || index == Math.NaN)
				index = 0;
			if (index > length) return null;
		}

		for (keyframe in _keyframes)
		{
			if (keyframe.index + keyframe.duration > index)
			{
				return keyframe;
			}
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
		_correctClip = false;
		//if (["", null].indexOf(name) != -1 && ["", null].indexOf(this.name) != -1)
		if (name != "" && name != null && this.name != "" && this.name != null)
		{
			name = 'Layer ${(_parent != null) ? _parent.getList().length : 1}';
		}
		if (_parent != null && _parent.get(name) != null)
		{
			name += " copy";
		}
		//if (["", null].indexOf(name) == -1)
		if (name != "" && name != null)
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
	function set_type(value:LayerType)
	{
		if (type != null && type.getName() == "Clipped")
		{
			var layers = _parent.getList();
			var layer = layers[layers.indexOf(this) - 1];
			if (_parent != null && layer != null && layer.type.getName() == "Clipper")
			{
				layer._renderable = true;
			}
		}
		return type = value;
	}
	@:allow(flxanimate.FlxAnimate)
	function _setCurFrame(frame:Int)
	{

		if (length == 0 || frame > length)
		{
			_currFrame = null;
			return;
		}

		if (_currFrame != null)
		{
			if (frame >= _currFrame.index && frame < _currFrame.duration) return;

			var i = _keyframes.indexOf(_currFrame);

			var prevFrame = _currFrame;

			if (frame >= _currFrame.index + _currFrame.duration)
			{
				var keyframe = _keyframes[i];
				while (frame >= keyframe.index + keyframe.duration)
				{
					keyframe = _keyframes[i++];
					if (keyframe == null)
						break;
				}

				_currFrame = keyframe;
			}
			else if (frame < _currFrame.index)
			{
				var keyframe = _keyframes[i];
				while (frame < keyframe.index)
				{
					keyframe = _keyframes[i--];
					if (keyframe == null)
						break;
				}

				_currFrame = keyframe;
			}
			if (onFrameUpdate != null)
				onFrameUpdate(prevFrame, _currFrame);
		}
		else
			_currFrame = get(frame);
	}

	@:allow(flxanimate.FlxAnimate)
	function updateBitmaps(rect:Rectangle)
	{
		if (_filterFrame == null || (rect.width > _filterFrame.parent.bitmap.width || rect.height > _filterFrame.parent.bitmap.height))
		{
			var wid = (_filterFrame == null || rect.width > _filterFrame.parent.width) ? rect.width * 1.25 : _filterFrame.parent.width;
			var hei = (_filterFrame == null || rect.height > _filterFrame.parent.height) ? rect.height * 1.25 : _filterFrame.parent.height;
			if (_filterFrame != null)
			{
				_filterFrame.parent.destroy();
				FlxG.bitmap.remove(FlxG.bitmap.get(FlxG.bitmap.findKeyForBitmap(_bmp1)));
				FlxG.bitmap.remove(FlxG.bitmap.get(FlxG.bitmap.findKeyForBitmap(_bmp2)));
			}
			else
			{
				@:privateAccess
				_filterFrame = new FlxFrame(null);
			}
			_filterFrame.parent = FlxG.bitmap.add(new BitmapData(Math.ceil(wid), Math.ceil(hei),0), true);
			_bmp1 = new BitmapData(Math.ceil(wid), Math.ceil(hei), 0);
			FlxGraphic.fromBitmapData(_bmp1, true);
			_bmp2 = new BitmapData(Math.ceil(wid), Math.ceil(hei), 0);
			FlxGraphic.fromBitmapData(_bmp2, true);
			_filterFrame.frame = new FlxRect(0, 0, wid, hei);
			_filterFrame.sourceSize.set(rect.width, rect.height);
			@:privateAccess
			_filterFrame.cacheFrameMatrix();
		}
		else
		{
			_bmp1.fillRect(_bmp1.rect, 0);
			_filterFrame.parent.bitmap.fillRect(_filterFrame.parent.bitmap.rect, 0);
			_bmp2.fillRect(_bmp2.rect, 0);
		}

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