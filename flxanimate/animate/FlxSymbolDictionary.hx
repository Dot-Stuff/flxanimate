package flxanimate.animate;

import flixel.FlxG;
import haxe.extern.EitherType;
import haxe.io.Path;

class FlxSymbolDictionary
{
	var _parent:FlxAnim;

	var _mcFrame:Map<String, Int> = [];

	var _symbols:Map<String, FlxSymbol> = [];

	public var length(default, null):Int;

	public function new()
	{
		_symbols = [];
	}


	public function getLibrary(library:String)
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

	public function existsSymbol(symbol:String)
	{
		return _symbols.exists(symbol);
	}

	public function getSymbol(symbol:String)
	{
		return _symbols.get(symbol);
	}

	public function addSymbol(symbol:FlxSymbol, ?overrideSymbol:Bool = false)
	{
		if (_symbols.exists(symbol.name) && !overrideSymbol)
		{
			symbol.name += " Copy";
		}

			_symbols.set(symbol.name, symbol);

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

		bool = _symbols.remove((Std.isOfType(symbol, FlxSymbol)) ? symbol.name : symbol);

		if (bool)
			length--;

		return bool;
	}
}