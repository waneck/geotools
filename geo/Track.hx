package geo;
import haxe.ds.Vector;

@:forward(iterator)
abstract Track<Position : Loc>(TrackImpl<Position>)
{
	@:extern inline public function new(data)
	{
		this = impl;
	}
}

class TrackImpl<Position : Loc>
{
	public function iterator():TrackIterator<Position>
	{
		return new
	}
}

class TrackIterator<Position : Loc>
{
	var impl:TrackImpl<Position>;
	var idx:Int;

	public function new(trackImpl)
	{
		this.impl = trackImpl;
	}

	public function hasNext():Bool;
	public function next():Position;
}
