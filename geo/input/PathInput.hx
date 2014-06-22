package geo.input;
import geo.*;

interface PathInput<Pos : Location>
{
	function stream( onData:Pos->Void, onEndPath:Void->Void, onError:Dynamic->Void ):Void;
}
