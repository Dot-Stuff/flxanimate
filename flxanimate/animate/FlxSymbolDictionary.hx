package flxanimate.animate;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.graphics.frames.FlxFramesCollection;
import flxanimate.data.AnimationData.AnimAtlas;
import haxe.extern.EitherType;
import haxe.io.Path;

class FlxSymbolDictionary implements IFlxDestroyable
{
	@:allow(flxanimate.animate.FlxAnim)
	var _parent:FlxAnim = null;

	//var _mcFrame:Map<String, Int> = [];

	var _symbols:Map<String, FlxSymbol> = [];
	var _tmpSymbols:Map<String, FlxSymbol> = [];

	public var length(default, null):Int;

	public var frames:FlxFramesCollection;

	public function new(?parent:FlxAnim)
	{
		_symbols = [];
		frames = null;
		_parent = parent;
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
		return _tmpSymbols.exists(symbol) || _symbols.exists(symbol);
	}

	public function getSymbol(symbol:String):Null<FlxSymbol>
	{
		return _tmpSymbols.exists(symbol) ? _tmpSymbols.get(symbol) : _symbols.get(symbol);
	}

	public function getLibrarySymbol(symbol:String):Null<FlxSymbol> {
		return _symbols.get(symbol);
	}

	public function addSymbol(symbol:FlxSymbol, ?isTempSymbol:Bool = false)
	{
		var name = haxe.io.Path.withoutDirectory(symbol.name);
		var loc = haxe.io.Path.directory(symbol.name);

		symbol.location = loc;
		symbol.name = name;

		if (loc != "")
			loc += "/";

		(isTempSymbol ? _tmpSymbols : _symbols).set(loc + symbol.name, symbol);

		length++;
	}

	public function addLibrary(library:Map<String, FlxSymbol>, ?isTempSymbol:Bool = false)
	{
		for (symbol in library)
		{
			addSymbol(symbol, isTempSymbol);
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
		var id = (Std.isOfType(symbol, FlxSymbol)) ? cast (symbol, FlxSymbol).name : symbol;
		var bool = (_tmpSymbols.exists(id) ? _tmpSymbols.remove(id) : _symbols.remove(id));

		if (bool)
			length--;

		return bool;
	}

	public function getList() {
		return _symbols;
	}

	public function getTmpList() {
		return _tmpSymbols;
	}

	public function getFullList() {
		var _map = _symbols.copy();
		for (key => symbol in _tmpSymbols)
			_map.set(key, symbol);
		return _map;
	}

	public function destroy()
	{
		for (symbol in _symbols.iterator())
			symbol.destroy();

		for (symbol in _tmpSymbols.iterator())
			symbol.destroy();

		_symbols.clear();
		_symbols = null;

		_tmpSymbols.clear();
		_tmpSymbols = null;
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