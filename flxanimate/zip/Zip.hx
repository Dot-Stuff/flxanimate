package flxanimate.zip;

import haxe.zip.Reader;
import haxe.zip.Entry;
import lime._internal.format.Deflate;

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
    // I'm trying to make like a custom zip thing so that it's easy to make in every framework, cos it's "Haxe-made", but hl is another story cos well...
    // It needs an hdll, tbs, the fmt.hdll, but idk where to download that, neither include in a project, so I'm gonna try to unzip shit without that
    public static function unzip(f:List<Entry>):List<Entry>
    {
        for (list in f)
        {
            if (list.compressed)
            {
                #if !hl
                var s = haxe.io.Bytes.alloc(list.fileSize);
                var c = new haxe.zip.Uncompress(-15);
                var r = c.execute(list.data, 0, s, 0);
                c.close();
                if (!r.done || r.read != list.data.length || r.write != list.fileSize)
                    throw "Invalid compressed data for " + list.fileName;
                list.data = s;
                #else
                trace("NO HASHLINK FULL SUPPORT!!!!!!");
                list.data = Deflate.decompress(list.data);
                #end
                list.compressed = false;
                list.dataSize = list.fileSize;
            }
        }
        return f;
    }
}
