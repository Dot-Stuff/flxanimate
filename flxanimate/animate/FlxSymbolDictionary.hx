package flxanimate.animate;

import flixel.FlxG;
import haxe.extern.EitherType;
import haxe.io.Path;

class FlxSymbolDictionary
{
    public var name:String;

    var _folders:Map<String, FlxSymbolDictionary>;
    
    var _symbols:Map<String, FlxSymbol>;
    
    public var libraryLength(default, null):Int;

    public var symbolLength(default, null):Int;

    public var totalLength(get, null):Int;
    public function new(?name:String = "")
    {
        this.name = name;
        _folders = [];
        _symbols = [];   
    }

    
    public function getLibrary(library:EitherType<String, Int>)
    {
        if (Std.isOfType(library, String))
        {
            var path = Path.directory(Path.addTrailingSlash(library));
            var prevMap = _folders;
            for (path in path.split("/"))
            {
                prevMap = prevMap[path]._folders;

                if (prevMap == null)
                    FlxG.log.error('Path $library doesn\'t exist! Check the path');
            }
            return prevMap[Path.withoutDirectory(path)];
        }
        else
        {
            var library:Int = library;
            if (library < 0 || library >= libraryLength)
                return null;

            var i = 0;
            for (value in _folders.iterator())
            {
                if (i == library)
                    return value;

                i++;
            }
        }
        

        return null;
    }

    public function existsLibrary(library:String)
    {
        if (library == null) return false;

        var path = Path.directory(Path.addTrailingSlash(library));

        if (path == Path.addTrailingSlash(library))
            return _folders.exists(library);
        else
        {
            var folder = _folders;
            var folders = path.split("/");
            for (library in folders)
            {
                var newFolder = folder[library];
                if (newFolder == null)
                    return false;
                folder = newFolder._folders;
            }

            return folder.exists(folders[folders.length - 1]);
        }

        return false;
    }

    public function existsSymbol(symbol:String)
    {
        var path = Path.directory(symbol);
        
        if (path == "")
            return _symbols.exists(symbol);
        else
        {
            var folder = this;
            var folders = path.split("/");
            for (library in folders)
            {
                folder = folder._folders[library];
            }

            return folder._symbols.exists(folders[folders.length - 1]);
        }

        return false;
    }

    public function getSymbol(symbol:EitherType<String, Int>)
    {
        if (Std.isOfType(symbol, String))
        {
            var path = Path.directory(symbol);
            trace(path);
            return (path == "") ? _symbols[symbol] : getLibrary(path)._symbols.get(Path.withoutDirectory(symbol));
        }
        else
        {
            var symbol:Int = symbol;
            if (symbol < 0 || symbol >= symbolLength)
                return null;

            var i = 0;
            for (value in _symbols.iterator())
            {
                if (i == symbol)
                    return value;

                i++;
            }
        }

        return null;
    }

    public function addSymbol(symbol:FlxSymbol)
    {
        if (_symbols.exists(symbol.name))
        {
            return false;
        }
        else
            _symbols.set(symbol.name, symbol);

        symbolLength++;
        
        return true;
    }

    public function addLibrary(library:FlxSymbolDictionary)
    {
        if (_folders.exists(library.name))
        {
            return false;
        }
        else
            _folders.set(library.name, library);

        libraryLength++;
        return true;
    }

    public function indexOf(value:EitherType<FlxSymbolDictionary, FlxSymbol>)
    {
        var map:Map<String, EitherType<FlxSymbolDictionary, FlxSymbol>>  = (Std.isOfType(value, FlxSymbolDictionary)) ? _folders : _symbols;

        var i = 0;

        for (v in map.iterator())
        {
            if (v == value)
            
                return i;
            i++;
        }

        return -1;
    }
    public function removeLibrary(library:EitherType<FlxSymbolDictionary, String>)
    {
        var bool:Bool = false;

        if (Std.isOfType(library, FlxSymbolDictionary))
            bool = _folders.remove(library);
        else
        {
            var lib = getLibrary(library);
            
            if (lib == null)
                return false;

            bool = lib._folders.remove(library);
        }

        if (bool)
            libraryLength--;

        return bool;
    }
    public function removeSymbol(symbol:EitherType<FlxSymbol, String>)
    {
        var bool:Bool = false;

        if (Std.isOfType(symbol, FlxSymbol))
            bool = _symbols.remove(symbol);
        else
        {
            var path = haxe.io.Path.directory(symbol);
            var library = (path != "") ? getLibrary(path) : this;

            if (library == null)
                return false;

            bool = library._symbols.remove(symbol);
        }

        if (bool)
            symbolLength--;

        return bool;
    }

    function get_totalLength()
    {
        return libraryLength + symbolLength;
    }
    public function getSymbolList()
    {
        return [for (symbol in _symbols.keys()) symbol];
    }
    public function getLibraryList()
    {
        return [for (library in _folders.keys()) library];
    }
}