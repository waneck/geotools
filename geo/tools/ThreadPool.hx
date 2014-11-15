package geo.tools;
#if java
import java.vm.*;
#elseif neko
import neko.vm.*;
#elseif cs
import cs.vm.*;
#elseif cpp
import cpp.vm.*;
#else
#error unsupported
#end

class ThreadPool
{
	var pool:Array<Thread>;
	var deque:Deque<Void->Void>;

	public function new(size)
	{
		this.deque = new Deque();
		this.pool = [ for (i in 0...size) Thread.create(loop) ];
	}

	private function loop()
	{
		var d = deque;
		while(true)
		{
			var val = d.pop(true);
			if (val == null)
				return;
			val();
		}
	}

	public function add(work:Void->Void)
	{
		if (work != null)
			deque.add(work);
		else
			throw "work == null";
	}

	public function push(work:Void->Void)
	{
		if (work != null)
			deque.push(work);
		else
			throw "work == null";
	}

	public function close()
	{
		for (i in 0...pool.length)
			deque.add(null);
	}

	public function partitionWork<T>(array:Array<T>, fn:Array<T>->Void)
	{
		if (fn == null) throw "fn == null";
		var arrlen = array.length,
				deque = deque;
		var total = arrlen;
		var each = Std.int(total / pool.length);
		while (total > 0)
		{
			var len = total < each ? total : each;
			if (len == 0) len = 1;
			var arr = [ for (i in (arrlen - total)...(arrlen - total + len)) array[i] ];
			deque.add(function() fn(arr));
			total -= len;
		}
	}

	public function partitionMap<A,B>(array:Array<A>, fn:A->B):Array<B>
	{
		var curd = new Deque();
		if (fn == null) throw "fn == null";
		var arrlen = array.length,
				deque = deque;
		var total = arrlen;
		var each = Std.int(total / pool.length);
		var num = 0;
		while (total > 0)
		{
			var len = total < each ? total : each;
			if (len == 0) len = 1;
			var arr = [ for (i in (arrlen - total)...(arrlen - total + len)) array[i] ];
			deque.add(function() {
				var a2 = [ for (a in arr) fn(a) ];
				curd.add(a2);
			});
			total -= len;
			num++;
		}
		var ret = [];
		for (i in 0...num)
		{
			ret = ret.concat(curd.pop(true));
		}
		return ret;
	}

	public function closeImmediate()
	{
		for (i in 0...pool.length)
			deque.push(null);
	}
}
