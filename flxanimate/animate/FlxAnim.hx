package flxanimate.animate;

import flxanimate.geom.FlxMatrix3D;
import flixel.math.FlxMath;
import haxe.extern.EitherType;
import flxanimate.animate.SymbolParameters;
import flixel.util.FlxStringUtil;
import openfl.geom.ColorTransform;
import flixel.util.FlxSignal;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxDestroyUtil;
import flixel.FlxG;
import flixel.math.FlxMatrix;
import flxanimate.data.AnimationData;
#if FLX_SOUND_SYSTEM
#if (flixel >= "5.3.0")
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end
#end
using StringTools;

typedef SymbolStuff = {var instance:FlxElement; var frameRate:Float;};
typedef ClickStuff = {
	?OnClick:Void->Void,
	?OnRelease:Void->Void
}
typedef ButtonSettings = {
	?Callbacks:ClickStuff,
	#if FLX_SOUND_SYSTEM
	?Sound:FlxSound
	#end
}
@:access(flxanimate.FlxAnimate)
class FlxAnim implements IFlxDestroyable
{
	/**
	 * The amount of frames that are in the current symbol.
	 */
	public var length(get, never):Int;

	/**
	 * The Instance the texture atlas was exported when it was on stage.
	 */
	public var stageInstance:FlxElement;

	/**
	 * The current instance the animation is playing.
	 */
	public var curInstance:FlxElement;

	/**
	 * Metadata. shortcut to display the name of the document and the default framerate.
	 */
	public var metadata:FlxMetaData;

	/**
	 * The current symbol the instance is taking as a reference.
	 */
	public var curSymbol(get, never):FlxSymbol;

	/**
	 * Whether the animation has finished or not.
	 */
	public var finished(get, never):Bool;
	/**
	 * a reverse option where the animation plays backwards or not.
	 */
	public var reversed(get, set):Bool;

	/**
	 * A map containing all `FlxSymbol` instances, whether prefabricated or not.
	 */
	public var symbolDictionary:Map<String, FlxSymbol>;

	public var library:FlxSymbolDictionary = null;

	/**
		Checks whether MovieClips should move or not.
	**/
	public var swfRender:Bool = false;

	var buttonMap:Map<String, ButtonSettings> = new Map();
	/**
	 * When ever the animation is playing.
	 */
	public var isPlaying(default, null):Bool;

	/**
	 * A signal dispatched when the animation's over,
	 * when the current frame is equal to the current symbol's length.
	 */
	public var onComplete:FlxSignal = new FlxSignal();

	/**
	 * A signal dispatched when the animation advances one frame.
	 * @param frame The current frame number.
	 */
	public var onFrame:FlxTypedSignal<Int->Void> = new FlxTypedSignal();

	/**
	 * The framerate of the current animation.
	 */
	public var framerate(default, set):Float;


	/**
	 * Internal, used for each skip between frames.
	 */
	var frameDelay:Float;

	/**
	 * The frame the animation is currently.
	 */
	public var curFrame(get, set):Int;


	var animsMap:Map<String, SymbolStuff> = new Map();

	/**
	 *  The looping method of `curSymbol`.
	 *
	 * _Made public since `4.0.0`_
	 */
	public var loopType(get, set):Loop;

	/**
	 * How fast or slow the symbols are going to go.
	 * Default value is `1.0`
	 * @since `4.0.0`
	 */
	public var timeScale:Float = 1.0;

	/**
	 	The type of the current symbol.
	 	This can be of three types:

	 	- `MovieClip`
	 	- `Graphic`
		- `Button`

	 */
	public var symbolType(get, set):SymbolT;


	var _parent:FlxAnimate;


	var _tick:Float;

	/**
	 * Creates a new `FlxAnim` instance.
	 * @param parent The `FlxAnimate` instance it's gonna control.
	 * @param coolParsed The Animation file.
	 */
	public function new(parent:FlxAnimate, ?coolParsed:AnimAtlas)
	{
		_tick = 0;
		_parent = parent;
		isPlaying = false;
		if (coolParsed != null) _loadAtlas(coolParsed);
	}
	@:allow(flxanimate.FlxAnimate)
	function _loadAtlas(animationFile:AnimAtlas)
	{
		symbolDictionary = [];
		library = new FlxSymbolDictionary();
		library._parent = this;
		stageInstance = null;

		if (animationFile == null) return;

		var bta = animationFile.MD.V != null;

		if (!bta)
			library.fromJSON(animationFile);
		else
			library.fromJSONEx(animationFile);

		symbolDictionary = library.getList();
		
		library.frames = _parent.frames;

		stageInstance = (animationFile.AN.STI != null) ? ((!bta) ? FlxElement.fromJSON(cast animationFile.AN.STI) : FlxElement.fromJSONEx(cast animationFile.AN.STI)) : new FlxElement(new SymbolParameters(animationFile.AN.SN));


		curInstance = stageInstance;


		curFrame = stageInstance.symbol.firstFrame;

		_parent.origin.copyFrom(stageInstance.symbol.transformationPoint);
		metadata = new FlxMetaData(animationFile.AN.N, animationFile.MD.FRT);
		framerate = metadata.frameRate;
		if (bta)
			metadata.version = animationFile.MD.V;
	}

	@:allow(flxanimate.FlxAnimate)
	function _loadExAtlas(path:String)
	{
		symbolDictionary = [];
		library = new FlxSymbolDictionary();
		library._parent = this;
		stageInstance = null;

		var animationFile:AnimAtlas = haxe.Json.parse(AssetWrapper.getText(path + "/Animation.json"));

		var md:MetaData = haxe.Json.parse(AssetWrapper.getText(path + "/metadata.json"));
		

		var colon = path.indexOf(":");
		var l = "";
		var po = path.substring(colon + 1);

		
		

		var symbols:Array<String> = [];

		if (colon == -1)
		{
			symbols = AssetWrapper.list().filter(function (s)
				{
					if (StringTools.contains(s, "testing"))
						trace(s);
					return StringTools.startsWith(s, path + "/LIBRARY") && haxe.io.Path.extension(s) == "json";
				});
		}
		else
		{
			l = path.substring(0, colon);
			symbols = openfl.Assets.getLibrary(l).list("TEXT").filter(function (s)
				{
					return StringTools.startsWith(s, po + "/LIBRARY") && haxe.io.Path.extension(s) == "json";
				});

			l += ":";
		}




		for (symbol in symbols)
		{
			var json = haxe.Json.parse(l.contains(":") ? openfl.Assets.getText(l + symbol) : AssetWrapper.getText(l + symbol));

			library.addSymbol(new FlxSymbol(haxe.io.Path.withoutExtension(symbol.substring(po.length + 9)), FlxTimeline.fromJSONEx(json)));
		}
		symbolDictionary = library.getList();
		library.frames = _parent.frames;
		
		
		metadata = new FlxMetaData(animationFile.AN.N, md.FRT);
		metadata.version = md.V;

		framerate = metadata.frameRate;

		library.fromJSONEx(animationFile);
		stageInstance = (animationFile.AN.STI != null) ? (FlxElement.fromJSONEx(cast animationFile.AN.STI)) : new FlxElement(new SymbolParameters(animationFile.AN.SN));
		curInstance = stageInstance;

		curFrame = stageInstance.symbol.firstFrame;
		_parent.origin.copyFrom(stageInstance.symbol.transformationPoint);

	}
	/**
	 * Plays an animation.
	 * @param Name The name of an animation or an `FlxSymbol`
	 * @param Force Whether it should Force a reset to the animation before playing.
	 * @param Reverse If the animation will go on reverse or not.
	 * @param Frame To which frame it will begin.
	 */
	public function play(?Name:String = "", ?Force:Bool = false, ?Reverse:Bool = false, ?Frame:Int = 0)
	{
		pause();

		Force = (Force || finished);

		if (Name != "")
		{
			if (!animsMap.exists(Name))
			{
				if (Name == metadata.name)
					curInstance = stageInstance;
				else if (symbolDictionary.exists(Name))
				{
					curInstance.symbol.reset();
					curInstance.symbol.name = Name;
				}
				else
					FlxG.log.error('There\'s no animation called $Name!');
			}
			else
			{
				var curThing = animsMap.get(Name);

				framerate = (curThing.frameRate == 0) ? metadata.frameRate : curThing.frameRate;

				Force = (Force || curInstance != curThing.instance);

				curInstance = curThing.instance;
			}
		}


		if (Force)
			curFrame = (Reverse) ? Frame - length : Frame;

		reversed = Reverse;



		resume();

		curSymbol.fireCallbacks();
	}

	public function playElement(element:FlxElement, ?Force:Bool = false, ?Reverse:Bool = false, ?Frame:Int = 0)
	{
		if (finished || curInstance != element)
			Force = true;

		if (curInstance == element && !Force) return;

		pause();

		if (element != null)
			curInstance = element;
		else
		{
			curInstance = stageInstance;
		}

		if (Force)
			curFrame = (!Reverse) ? Frame : length - 1 - Frame;

		resume();
	}

	/**
	 * Pauses the current animation.
	 */
	public function pause()
	{
		isPlaying = false;
	}

	/**
	 * stops the current animation.
	 */
	public function stop()
	{
		pause();
		curFrame = 0;
	}

	public function finish()
	{
		stop();

		if (!reversed)
			curFrame = length - 1;
	}

	/**
	 * Resumes the current animation.
	 */
	public function resume()
	{
		isPlaying = true;
	}

	function setSymbols(Anim:AnimAtlas)
	{

		symbolDictionary.set(Anim.AN.SN, new FlxSymbol(haxe.io.Path.withoutDirectory(Anim.AN.SN), FlxTimeline.fromJSON(Anim.AN.TL)));

		if (Anim.SD != null)
		{
			for (symbol in Anim.SD.S)
			{
				symbolDictionary.set(symbol.SN, new FlxSymbol(haxe.io.Path.withoutDirectory(symbol.SN), FlxTimeline.fromJSON(symbol.TL)));
			}
		}
	}

	function setSymbolsEx(Anim:AnimAtlas)
	{
		symbolDictionary.set(Anim.AN.SN, new FlxSymbol(haxe.io.Path.withoutDirectory(Anim.AN.SN), FlxTimeline.fromJSONEx(Anim.AN.TL)));

		if (Anim.SD != null)
		{
			for (symbol in Anim.SD.S)
			{
				symbolDictionary.set(symbol.SN, new FlxSymbol(haxe.io.Path.withoutDirectory(symbol.SN), FlxTimeline.fromJSONEx(symbol.TL)));
			}
		}
	}

	public function update(elapsed:Float)
	{
		if (curInstance != null)
			curInstance.updateRender(elapsed * timeScale #if (flixel >= "5.5.0") * FlxG.animationTimeScale #end, curFrame, symbolDictionary, swfRender);
		if (frameDelay == 0 || !isPlaying || finished) return;

		_tick += elapsed * timeScale #if (flixel >= "5.5.0") * FlxG.animationTimeScale #end;


		while (_tick > frameDelay)
		{
			(reversed) ? curFrame-- : curFrame++;
			curSymbol.fireCallbacks();
			onFrame.dispatch(curFrame);

			_tick -= frameDelay;
		}


		if (loopType != SingleFrame && curFrame == (reversed ? 0 : length - 1))
		{
			if (loopType == PlayOnce)
				pause();

			onComplete.dispatch();
		}
	}
	function get_finished()
	{
		return (loopType == PlayOnce) && (reversed && curFrame == 0 || !reversed && curFrame >= length - 1);
	}
	function get_curFrame()
	{
		return (curSymbol != null) ? curSymbol.curFrame : 0;
	}
	function set_curFrame(Value:Int)
	{
		if (curSymbol == null)
			return 0;

		curSymbol.curFrame = switch (loopType)
		{
			case Loop: (Value < 0) ? curSymbol.length - 1 : Value % curSymbol.length;
			case PlayOnce: cast FlxMath.bound(Value, 0, curSymbol.length - 1);
			case _: Value;
		}

		if (symbolType == MovieClip && !swfRender)
			curSymbol.curFrame = 0;


		return curSymbol.curFrame;
	}
	/**
	 * Creates an animation using an already made symbol from a texture atlas
	 * @param Name The name of the animation
	 * @param SymbolName the name of the symbol you're looking. if you have two symbols beginning by the same name, use `\` at the end to differ one symbol from another
	 * @param X the *x* axis of the animation.
	 * @param Y  the *y* axis of the animation.
	 * @param FrameRate the framerate of the animation.
	 */
	public function addBySymbol(Name:String, SymbolName:String, FrameRate:Float = 0, Looped:Bool = true, X:Float = 0, Y:Float = 0)
	{
		if (symbolDictionary == null)
		{
			return;
		}
		var params = new FlxElement(new SymbolParameters((Looped) ? Loop : PlayOnce), new FlxMatrix(1,0,0,1,X,Y));
		for (name in symbolDictionary.keys())
		{
			if (startsWith(name, SymbolName))
			{
				params.symbol.name = name;
				break;
			}
		}
		if (params.symbol.name != null)
			animsMap.set(Name, {instance: params, frameRate: FrameRate});
		else
			FlxG.log.error('No symbol was found with the name $SymbolName!');
	}
	function startsWith(reference:String, string:String):Bool
	{
		if (StringTools.endsWith(string, "\\"))
			return reference == string.substring(0, string.length - 1)
		else
			return StringTools.startsWith(reference, string);
	}
	/**
	 * Creates an animation using the indices, looking as a reference the main animation of the texture atlas.
	 * @param Name The name of the animation you're creating
	 * @param Indices The indices you're gonna be using for the animation, like `[0,1,2]`.
	 * @param FrameRate the framerate of the animation.
	 */
	public function addByAnimIndices(Name:String, Indices:Array<Int>, FrameRate:Float = 0)
	{
		addBySymbolIndices(Name, stageInstance.symbol.name, Indices, FrameRate, stageInstance.symbol.loop == Loop, 0,0);
	}

	/**
	 * Creates an animation based on a frame label's starting frame and duration.0
	 * @param Name The name of the animation to add.
	 * @param FrameLabel The frame label to use as the starting frame.
	 * @param FrameRate The framerate of the animation to use.
	 * @param Looped Whether the animation should loop or not.
	 * @param X A x offset to apply to the animation.
	 * @param Y A y offset to apply to the animation.
	 */
	public function addByFrameLabel(Name:String, FrameLabel:String, FrameRate:Float = 0, Looped:Bool = true, X:Float = 0, Y:Float = 0) {
		var keyFrame = getFrameLabel(FrameLabel);
		addBySymbolIndices(Name, stageInstance.symbol.name, keyFrame.getFrameIndices(), FrameRate, Looped, X, Y);
	}

	public function addBySymbolIndices(Name:String, SymbolName:String, Indices:Array<Int>, FrameRate:Float = 0, Looped:Bool = true, X:Float = 0, Y:Float = 0)
	{
		if (symbolDictionary == null)
		{
			return;
		}
		if (!symbolDictionary.exists(SymbolName))
		{
			FlxG.log.error('$SymbolName does not exist as a symbol! maybe you misspelled it?');
			return;
		}
		var params = new FlxElement(new SymbolParameters((Looped) ? Loop : PlayOnce), new FlxMatrix(1,0,0,1,X,Y));
		var timeline = new FlxTimeline();
		timeline.add("Layer 1");

		for (index in 0...Indices.length)
		{
			var i = Indices[index];
			var keyframe = new FlxKeyFrame(index);


			var params = new SymbolParameters(SymbolName, params.symbol.loop);
			params.firstFrame = i;
			keyframe.add(new FlxElement(params));
			timeline.get(0).add(keyframe);
		}
		var symbol = new FlxSymbol(Name, timeline);
		params.symbol.name = symbol.name;

		symbolDictionary.set(symbol.name, symbol);


		animsMap.set(Name, {instance: params, frameRate: FrameRate});
	}


	function set_framerate(value:Float):Float
	{
		frameDelay = 1 / value;
		return framerate = value;
	}
	/**
	 * This adds a new animation by adding a custom timeline, obviously taking as a reference the timeline syntax!
	 * **WARNING**: I, *CheemsAndFriends*, do **NOT** recommend this unless you're using an extern json file to do this!
	 * if you wanna make a custom symbol to play around and is separated from the texture atlas, go ahead! but if you wanna just make a new symbol,
	 * just do it in Flash directly
	 * @param Name The name of the new Symbol.
	 * @param Timeline The timeline which will have the symbol.
	 * @param FrameRate The framerate it'll go, by default is 30.
	 */
	public function addByCustomTimeline(Name:String, Timeline:FlxTimeline, FrameRate:Float = 0, Looped:Bool = true):Void
	{
		symbolDictionary.set(Name, new FlxSymbol(haxe.io.Path.withoutDirectory(Name), Timeline));
		var params = new FlxElement(new SymbolParameters((Looped) ? Loop : PlayOnce));
		animsMap.set(Name, {instance: params, frameRate: FrameRate});
	}

	public function get_length():Int
	{
		return (curSymbol != null) ? curSymbol.length : 0;
	}

	public function getFrameLabel(name:String, ?layer:EitherType<Int, String>):FlxKeyFrame
	{
		return curSymbol.getFrameLabel(name, layer);
	}

	public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("symbolDictionary", symbolDictionary),
			LabelValuePair.weak("framerate", framerate)
		]);
	}
	/**
	 * Redirects the frame into a frame with a frame label of that type.
	 * @param name the name of the label.
	 */
	public function goToFrameLabel(name:String, ?layer:EitherType<Int, String>):Void
	{
		pause();

		var label = getFrameLabel(name, layer);


		if (label != null)
			curFrame = label.index;

		resume();
	}
	/**
	 * Checks the next frame label name you're looking for.
	 * **WARNING: DO NOT** confuse with `anim.curSymbol.getNextToFrameLabel`!!
	 * @param name the name of the frame label.
	 * @return A `String`. WARNING: it can be `null`
	 */
	public function getNextToFrameLabel(name:String):Null<String>
	{
		return curSymbol.getNextToFrameLabel(name).name;
	}
	/**
	 * Links a callback into a label.
	 * @param label the name of the label.
	 * @param callback the callback you're going to add
	 */
	public function addCallbackTo(label:String, callback:()->Void):Bool
	{
		return curSymbol.addCallbackTo(label, callback);
	}

	public function removeCallbackFrom(label:String, callback:()->Void):Bool
	{
		return curSymbol.removeCallbackFrom(label, callback);
	}

	public function removeAllCallbacksFrom(label:String):Bool
	{
		return curSymbol.removeAllCallbacksFrom(label);
	}

	public function getFrameLabels(?layer:EitherType<Int, String>):Array<FlxKeyFrame>
	{
		return curSymbol.getFrameLabels(layer);
	}

	function get_loopType():Loop
	{
		return curInstance.symbol.loop;
	}

	function set_loopType(type:Loop):Loop
	{
		return curInstance.symbol.loop = type;
	}
	function get_symbolType():SymbolT
	{
		return curInstance.symbol.type;
	}
	function set_symbolType(type:SymbolT):SymbolT
	{
		return curInstance.symbol.type = type;
	}
	function get_reversed():Bool
	{
		return curInstance.symbol.reverse;
	}
	function set_reversed(value:Bool):Bool
	{
		if (curInstance != null)
			return curInstance.symbol.reverse = value;
		else
			return value;
	}

	public function getByName(name:String):SymbolStuff
	{
		return animsMap.get(name);
	}
	inline public function existsByName(name:String)
	{
		return animsMap.exists(name);
	}


	public function getByInstance(instance:String, ?frame:Int = null, ?layer:EitherType<String, Int>)
	{
		if (frame == null) frame = curFrame;


		var symbol:FlxSymbol = null;

		var layers = (layer == null) ? curSymbol.timeline.getList() : [curSymbol.timeline.get(layer)];

		for (layer in layers)
		{
			if (layer == null) continue;
			var elements = layer.get(frame);

			if (elements == null) continue;

			for (element in elements.getList())
			{
				if (element.symbol == null) continue;
				if (element.symbol.instance != "" && element.symbol.instance == instance)
				{
					return symbolDictionary.get(element.symbol.name);
				}
			}
		}

		FlxG.log.error("This instance doesn't exist! Have you checked if the layer exists or the instance isn't misspelled?");
		return null;
	}


	function get_curSymbol()
	{
		return (symbolDictionary != null) ? symbolDictionary.get(curInstance.symbol.name) : null;
	}

	public function destroy()
	{
		isPlaying = false;
		curFrame = 0;
		framerate = 0;
		_tick = 0;
		buttonMap = null;
		animsMap = null;
		curInstance = FlxDestroyUtil.destroy(curInstance);
		stageInstance = FlxDestroyUtil.destroy(stageInstance);
		metadata = FlxDestroyUtil.destroy(metadata);
		swfRender = false;
		_parent = null;
		for (symbol in symbolDictionary.iterator())
		{
			symbol.destroy();
		}
		symbolDictionary = null;
	}
}
/**
 * This class shows what framerate the animation was initially set.
 * (Remind myself to include more than this, like more metadata to stuff lmao)
 */
class FlxMetaData implements IFlxDestroyable
{
	public var name:String;
	/**
	 * The frame rate the animation was exported in the texture atlas in the beginning.
	 */
	public var frameRate:Float;

	public var showHiddenLayers:Bool;

	public var skipFilters:Bool;

	/**
	 * The version the Texture Atlas has been exported. 
	 * 
	 * (used in BTA, if it's been exported with the default one, it will set to `"Generic Adobe Animate TA"`)
	 */
	public var version:String;

	public function new(name:String, frameRate:Float)
	{
		this.name = name;
		this.frameRate = frameRate;
		showHiddenLayers = true;
		skipFilters = false;
		version = "Generic Adobe Animate TA";
	}
	public function destroy()
	{
		name = null;
		frameRate = 0;
	}
}
