package flxanimate.animate;

import flixel.graphics.frames.FlxFramesCollection;
import flxanimate.data.AnimationData.AnimAtlas;
import haxe.extern.EitherType;
import haxe.io.Path;

class FlxSymbolDictionary
{
	@:allow(flxanimate.animate.FlxAnim)
	var _parent:FlxAnim = null;

	var _mcFrame:Map<String, Int> = [];

	var _symbols:Map<String, FlxSymbol> = [];

	public var length(default, null):Int;

	public var frames:FlxFramesCollection;

	public function new()
	{
		_symbols = [];
		frames = null;
	}


	public function getLibrary(library:String):Map<String, FlxSymbol>
	{
		var path = Path.directory(Path.addTrailingSlash(library));

		var libraries:Map<String, FlxSymbol> = [];
		for (instance in _symbols.keys())
		{
			if (path == instance)
				libraries.set(path, _symbols.get(path));
		}

		return libraries;
	}

	public function existsSymbol(symbol:String):Bool
	{
		return _symbols.exists(symbol);
	}

	public function getSymbol(symbol:String):Null<FlxSymbol>
	{
		return _symbols.get(symbol);
	}

	public function addSymbol(symbol:FlxSymbol, ?overrideSymbol:Bool = false)
	{
		if (_symbols.exists(symbol.name) && !overrideSymbol)
		{
			symbol.name += " Copy";
		}


		var name = haxe.io.Path.withoutDirectory(symbol.name);
		var loc = haxe.io.Path.directory(symbol.name);

		symbol.location = loc;
		symbol.name = name;

		if (loc != "")
			loc += "/";

		_symbols.set(loc + symbol.name, symbol);

		length++;
	}

	public function addLibrary(library:Map<String, FlxSymbol>, ?overrideSymbol:Bool = false)
	{
		for (symbol in library)
		{
			addSymbol(symbol, overrideSymbol);
		}
	}

	public function removeLibrary(library:String)
	{
		var bool:Bool = false;

		var library = getLibrary(library);

		for (symbol in library)
		{
			if (removeSymbol(symbol))
				bool = true;
		}

		return bool;
	}
	public function removeSymbol(symbol:EitherType<FlxSymbol, String>)
	{
		var bool:Bool = false;

		bool = _symbols.remove((Std.isOfType(symbol, FlxSymbol)) ? cast (symbol, FlxSymbol).name : symbol);

		if (bool)
			length--;

		return bool;
	}

	public function getList()
	{
		return _symbols;
	}

	public function fromJSON(animation:AnimAtlas)
	{
		
		addSymbol(new FlxSymbol(animation.AN.SN, FlxTimeline.fromJSON(animation.AN.TL)));

		if (animation.SD != null)
		{
			for (symbol in animation.SD.S)
			{
				addSymbol(new FlxSymbol(symbol.SN, FlxTimeline.fromJSON(symbol.TL)));
			}
		}
	}

	public function fromJSONEx(animation:AnimAtlas)
	{
		trace(animation.AN.SN);
		addSymbol(new FlxSymbol(animation.AN.SN, FlxTimeline.fromJSONEx(animation.AN.TL)));

		if (animation.SD != null)
		{
			for (symbol in animation.SD.S)
			{
				addSymbol(new FlxSymbol(symbol.SN, FlxTimeline.fromJSONEx(symbol.TL)));
			}
		}
	}
}