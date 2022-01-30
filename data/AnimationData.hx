package flixelatlas.data;

@:noCompletion

class AnimationData 
{
    @:noCompletion
    public static function parseLoopType(str:String):LoopType 
    {
        switch (str)
        {
            case "LP", "loop": return LOOP;
            case "PO": return PLAY_ONCE;
            case "SF": return SINGLE_FRAME;
            default: return null;
        }
    }   
    @:noCompletion
    public static function parseSymbolType(str:String):SymbolType
    {
        switch(str)
        {
            case "G", "graphic": return GRAPHIC;
            case "MC": return MOVIE_CLIP;
            case "B": return BUTTON;
            default: return null;
        }
    }
    @:noCompletion
    public static function parseDurationFrames(frame:Array<Frame>):Array<Frame>
    {
        var frames:Array<Frame> = [];
        for (frame in frame)
        {
            for (i in 0...frame.DU)
            {
                frames.push(frame);
            }
        }
        return frames;
    }
}

typedef Parsed = {
    var AN:Animation;
    var SD:SymbolDictionary;
    var MD:AtlasMetaData;
}

typedef Animation = {
    var SN:String;
    var N:String;
    var TL:Timeline;
    var STI:SettingTimeInstance;
}
typedef SettingTimeInstance = {
    var SI:SymbolInstance;
}
typedef SymbolDictionary = {
    var S:Array<Animation>;
}

typedef Timeline = {
    var L:Array<Layer>;
}

typedef Layer = {
    var LN:String;
    var FR:Array<Frame>;
}

typedef Frame = {
    var I:Int;
    var DU:Int;
    var E:Array<Element>;
}

typedef Element = {
    var SI:SymbolInstance;
    var ASI:AtlasSymbolInstance;
}

typedef SymbolInstance = {
    var SN:String;
    var ST:String;

    var FF:Int;
    var LP:String;
    var TRP:TransformationPoint;
    var M3D:Array<Float>;
}

enum LoopType {
    LOOP;
    PLAY_ONCE;
    SINGLE_FRAME;   
}

enum SymbolType {
    GRAPHIC;
    MOVIE_CLIP;
    BUTTON;
}

typedef AtlasSymbolInstance = {
    var N:String;
    var M3D:Array<Float>;
}

typedef TransformationPoint = {
    var x:Float;
    var y:Float;
}

typedef AtlasMetaData = 
{
    var FRT:Float;
}
