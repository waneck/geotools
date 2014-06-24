package geo;

@:dce @:forward abstract PathWay(Path<Location>) from Path<Location> to Path<Location>
{
	@:extern inline public function new(path)
	{
		this = path;
	}

	@:arrayAccess @:extern inline public function byIndex(idx:Int):Location
	{
		return this.get(idx);
	}


}
