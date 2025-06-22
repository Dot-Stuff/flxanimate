package flxanimate;

import haxe.Constraints.Function;
import haxe.io.Bytes;
import openfl.display.BitmapData;

import openfl.utils.Assets as OpenFLAssets;
import openfl.utils.AssetType as OpenFLAssetType;

import flixel.FlxG;
#if (flixel >= "5.9.0")
import flixel.system.frontEnds.AssetFrontEnd;
#end
using StringTools;

/**
 * Wrapper for assets to allow HaxeFlixel 5.9.0+ and HaxeFlixel 5.8.0- compatibility
 */
class AssetWrapper {
    public static dynamic function exists(path:String):Bool {
        #if (flixel >= "5.9.0")
        return FlxG.assets.exists(path);
        #else
        return OpenFLAssets.exists(path);
        #end
    }

    public static dynamic function getText(path:String):String {
        #if (flixel >= "5.9.0")
        return FlxG.assets.getText(path);
        #else
        return OpenFLAssets.getText(path);
        #end
    }

    public static dynamic function getBytes(path:String):Bytes {
        #if (flixel >= "5.9.0")
        return FlxG.assets.getBytes(path);
        #else
        return OpenFLAssets.getBytes(path);
        #end
    }

    public static dynamic function getBitmapData(path:String):BitmapData {
        #if (flixel >= "5.9.0")
        return FlxG.assets.getBitmapData(path);
        #else
        return OpenFLAssets.getBitmapData(path);
        #end
    }

    public static dynamic function list(?type:AssetType, ?library:String):Array<String> {
        #if (flixel >= "5.9.0")
        if(library != null && library.length != 0) {
            var lib = OpenFLAssets.getLibrary(library);
            if(lib != null)
                return lib.list(cast type.toOpenFlType());
            else
                FlxG.log.error('Could not find asset library: ${library}, falling back to FlxG.assets');
        }
        return FlxG.assets.list(type);
        #else
        if(library != null && library.length != 0) {
            var lib = OpenFLAssets.getLibrary(library);
            if(lib != null)
                return lib.list(cast type);
            else
                FlxG.log.error('Could not find asset library: ${library}, listing for all libraries instead');
        }
        return OpenFLAssets.list(type);
        #end
    }
}

typedef AssetType = #if (flixel >= "5.9.0") FlxAssetType #else OpenFLAssetType #end;