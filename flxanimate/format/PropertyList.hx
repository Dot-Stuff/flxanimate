package flxanimate.format;
#if haxe4
import haxe.xml.Access;
#else
import haxe.xml.Fast as Access;
#end


/**
 * The Apple's propietary XML parser
 *
 * @author noonat
 */
class PropertyList
{
	static var _dateRegex:EReg = ~/(\d{4}-\d{2}-\d{2})(?:T(\d{2}:\d{2}:\d{2})Z)?/;

	/**
	 * Parse an Apple property list XML file into a dynamic object. If
	 * the property list is empty, an empty object will be returned.
	 * @param text Text contents of the property list file.
	 */
	static public function parse(text:String):Dynamic
	{
		var fast = new Access(Xml.parse(text).firstElement());
		return fast.hasNode.dict ? parseDict(fast.node.dict) : {};
	}

	static function parseDate(text:String):Date
	{
		if (!_dateRegex.match(text))
		{
			throw 'Invalid date "' + text + '" (only yyyy-mm-dd and yyyy-mm-ddThh:mm:ssZ supported)';
		}
		text = _dateRegex.matched(1);
		if (_dateRegex.matched(2) != null)
		{
			text += ' ' + _dateRegex.matched(2);
		}
		return Date.fromString(text);
	}

	static function parseDict(node:Access):Dynamic
	{
		var key:String = null;
		var result:Dynamic = {};
		for (childNode in node.elements)
		{
			if (childNode.name == 'key')
			{
				key = childNode.innerData;
			}
			else if (key != null)
			{
				Reflect.setField(result, key, parseValue(childNode));
			}
		}
		return result;
	}

	static function parseValue(node:Access):Dynamic
	{
		var value:Dynamic = null;
		switch (node.name)
		{
			case 'array':
				value = new Array<Dynamic>();
				for (childNode in node.elements)
				{
					value.push(parseValue(childNode));
				}

			case 'dict':
				value = parseDict(node);

			case 'date':
				value = parseDate(node.innerData);

			case 'string':
				var thing:Dynamic = node.innerData;
				if (thing.charAt(0) == "{")
				{
					thing = StringTools.replace(thing, "{", "");
					thing = StringTools.replace(thing, "}", "");
					thing = thing.split(",");
				}
				value = thing;
			case 'data':
				value = node.innerData;

			case 'true':
				value = true;

			case 'false':
				value = false;

			case 'real':
				value = Std.parseFloat(node.innerData);

			case 'integer':
				value = Std.parseInt(node.innerData);
		}
		return value;
	}
}