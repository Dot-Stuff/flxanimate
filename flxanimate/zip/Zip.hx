package flxanimate.zip;

import haxe.zip.Reader;
import haxe.zip.Entry;
#if lime
import lime._internal.format.Deflate;
#end

class Zip
{
    var i:haxe.io.Input;

    public function new(i)
    {
        this.i = i;
    }

    function readZipDate()
    {
       var thing = new Reader(i);
       @:privateAccess
       return thing.readZipDate();
    }

    function readExtraFields(length)
    {
        var thing = new Reader(i);
       @:privateAccess
       return thing.readExtraFields(length);
    }

    public function readEntryHeader():Entry
    {
        var thing = new Reader(i);
       @:privateAccess
       return thing.readEntryHeader();
    }

    public function read():List<Entry>
    {
        var thing = new Reader(i);
       return thing.read();
    }

    public static function readZip(i:haxe.io.Input)
    {
        var r = new Reader(i);
        return r.read();
    }
    public static function unzip(f:List<Entry>):List<Entry>
    {
        for (list in f)
        {
            if (list.compressed)
            {
                #if !lime
                var s = haxe.io.Bytes.alloc(list.fileSize);
                var c = new haxe.zip.Uncompress(-15);
                var r = c.execute(list.data, 0, s, 0);
                c.close();
                if (!r.done || r.read != list.data.length || r.write != list.fileSize)
                    throw "Invalid compressed data for " + list.fileName;
                list.data = s;
                #else
                    list.data = Deflate.decompress(list.data);
                #end
                list.compressed = false;
                list.dataSize = list.fileSize;
            }
        }
        return f;
    }
}
