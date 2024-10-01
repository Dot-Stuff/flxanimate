package flxanimate.data;

class MacroAnimationData
{
	public static macro function getFieldBool(abstracto:ExprOf<Dynamic>, things:Array<String>):ExprOf<Dynamic>
	{
		#if macro
		if(things.length == 0)
			return macro null;
		// this != null ? this.N ?? this.name : null;
		var field = things.shift();
		var nullCoalesce = macro obj.$field;
		for (thing in things)
		{
			nullCoalesce = macro $nullCoalesce ?? obj.$thing;
		}

		return macro {
			var obj:Dynamic = $abstracto;
			var res:Dynamic = obj != null ? $nullCoalesce : null;
			res;
		};
		#end
	}
}