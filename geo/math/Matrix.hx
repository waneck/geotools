package geo.math;
import haxe.ds.Vector;

class Matrix
{
	public var rows(default, null):Int;
	public var cols(default, null):Int;

	public var data(default, null):Vector<Float>;

	public function new(rows, cols, ?data:Vector<Float>)
	{
		this.rows = rows;
		this.cols = cols;
		if (data == null)
		{
			var d = this.data = new Vector(cols*rows);
#if (neko || flash)
			for (i in 0...(cols*rows))
				d[i] = 0;
#end
		} else {
			if (data.length != cols * rows) throw "assert";
			this.data = data;
		}
	}

	/**
	 * Turn into an identity matrix
	 */
	public function identity():Void
	{
		if (cols != rows) throw "assert";

		var d = data, cols = cols;
		for (i in 0...cols)
			for (j in 0...rows)
				if (i == j)
					d[i + j * cols] = 1;
				else
					d[i + j * cols] = 0;
	}

	/**
	 * Copies the values from a source Matrix
	 * @param	m	source matrix
	 */
	public function copyFrom(m:Matrix):Void
	{
		if (cols != m.cols || rows != m.cols) throw "assert";

		var data = data, mdata = m.data;
		for (i in 0...(rows * cols))
		{
			data[i] = mdata[i];
		}
	}

	public function toString():String
	{
		var ret = new StringBuf();
		for (i in 0...rows)
		{
			ret.add("\n");
			for (j in 0...cols)
			{
				if (j > 0)
					ret.add(" ");
				var v = StringTools.rpad(data[j + i * cols] + "", " ", 14).substr(0,14);
				ret.add(v);
			}


		}

		return ret.toString();
	}

	/**
	 * Adds the value of a and b to the 'result' matrix
	 * @param	a
	 * @param	b
	 * @param	result
	 */
	public static function add(a:Matrix, b:Matrix, result:Matrix):Void
	{
		if (a.rows != b.rows || a.rows != result.rows || a.cols != b.cols || a.cols != result.cols) throw "assert";

		var ad = a.data, bd = b.data, rd = result.data, rows = a.rows, cols = a.cols;
		for (i in 0...(rows * cols))
		{
			rd[i] = ad[i] + bd[i];
		}
	}

	/**
	 * Subtracts the value of a and b to he 'result' matrix
	 * @param	a
	 * @param	b
	 * @param	result
	 */
	public static function subtract(a:Matrix, b:Matrix, result:Matrix):Void
	{
		if (a.rows != b.rows || a.rows != result.rows || a.cols != b.cols || a.cols != result.cols) throw "assert";

		var ad = a.data, bd = b.data, rd = result.data, rows = a.rows, cols = a.cols;
		for (i in 0...(rows * cols))
		{
			rd[i] = ad[i] - bd[i];
		}
	}

	/**
	 * Multiplies a with b, and stores the result in 'result'
	 * @param	a
	 * @param	b
	 * @param	result
	 */
	public static function multiply(a:Matrix, b:Matrix, result:Matrix):Void
	{
		if (a.cols != b.rows || a.rows != result.rows || b.cols != result.cols) throw "assert";

		var rc = a.rows, ad = a.data, bd = b.data, cd = result.data;
		for (i in 0...result.rows)
			for (j in 0...result.cols)
			{
				cd[j + i * result.cols] = 0;
				for (k in 0...a.cols)
				{
					cd[j + i * result.cols] += ad[k + i * a.cols] * bd[j + k * b.cols];
				}
			}
	}

	/**
	 * This is multiplying a by b-tranpose so it is like multiply_matrix
	 * but references to b reverse rows and cols
	 * @param	a
	 * @param	b
	 * @param	result
	 */
	public static function multiplyByTranspose(a:Matrix, b:Matrix, result:Matrix):Void
	{
		if (a.cols != b.cols || a.rows != result.rows || b.rows != result.cols) throw "assert";

		var rc = a.rows, ad = a.data, bd = b.data, cd = result.data;
		for (i in 0...result.rows)
			for (j in 0...result.cols)
			{
				cd[j + i * result.cols] = 0;
				for (k in 0...a.cols)
				{
					cd[j + i * result.cols] += ad[k + i * a.cols] * bd[k + j * b.cols];
				}
			}
	}

	/**
	 * Transposes current matrix to destination
	 * @param	destination
	 */
	public function transposeTo(destination:Matrix):Void
	{
		if (rows != destination.cols || cols != destination.rows) throw "assert";

		var dd = destination.data, d = data, rows = rows, cols = cols;
		for (i in 0...rows)
			for (j in 0...cols)
				dd[i + j * rows] = d[j + i * cols];
	}

	public function equals(to:Matrix, tolerance:Float=0.00001):Bool
	{
		if (rows != to.rows || cols != to.cols) throw "assert";

		var ad = data, bd = to.data, cols = cols;
		for (i in 0...rows)
			for (j in 0...cols)
				if (Math.abs(ad[j + i * cols] - bd[j + i * cols]) > tolerance)
					return false;

		return true;
	}

	/**
	 * Scalar multiplication
	 * @param	scalar
	 */
	public function scale(scalar:Float):Void
	{
		if (scalar == 0) throw "assert";

		var data = data, cols = cols;
		for (i in 0...rows)
			for (j in 0...cols)
				data[j + i * cols] *= scalar;
	}

	/**
	 * Swap rows
	 * @param	r1
	 * @param	r2
	 */
	public function swapRows(r1:Int, r2:Int):Void
	{
		if (r1 == r2 || r1 > rows || r2 > rows) throw "assert";
		var tmp = [], data = data, cols = cols;
		for ( i in 0...cols )
			tmp.push(data[i + r1 * cols]);

		for ( i in 0...cols )
			data[i + r1 * cols] = data[i + r2 * cols];
		for ( i in 0...cols )
			data[i + r2 * cols] = tmp[i];
	}

	public function scaleRow(row:Int, scalar:Float):Void
	{
		if (scalar == 0) throw "assert";
		var data = data, rd = row * cols;
		for (i in 0...cols)
		{
			data[i + rd] *= scalar;
		}
	}

	/**
	 * Add scalar * row r2 to row r1
	 * @param	r1
	 * @param	r2
	 * @param	scalar
	 */
	public function shearRow(r1:Int, r2:Int, scalar:Float):Void
	{
		if (r1 == r2) throw "assert";

		var data = data, cols = cols;
		for (i in 0...cols)
		{
			data[i + r1 * cols] += scalar * data[i + r2 * cols];
		}
	}

	/**
	 * Uses Gauss-Jordan elimination.
	 *
	 *  The elimination procedure works by applying elementary row
	 *  operations to our input matrix until the input matrix is reduced to
	 *  the identity matrix.
	 *  Simultaneously, we apply the same elementary row operations to a
	 *  separate identity matrix to produce the inverse matrix.
	 *  If this makes no sense, read wikipedia on Gauss-Jordan elimination.
	 *
	 *  This is not the fastest way to invert matrices, so this is quite
	 *  possibly the bottleneck.
	 *
	 * @param	output
	 */
	public function destructiveInvertMatrix(output:Matrix):Bool
	{
		if (rows != cols || rows != output.cols || rows != output.rows)
			throw "assert";

		output.identity();

		var idata = data, rows = rows, cols = cols;
		/* Convert input to the identity matrix via elementary row operations.
		The ith pass through this loop turns the element at i,i to a 1
		and turns all other elements in column i to a 0. */
		for (i in 0...rows)
		{
			if (idata[i + i * cols] == 0)
			{
				/* We must swap rows to get a nonzero diagonal element. */
				var r = i + 1;
				while (r < rows)
				{
					if (idata[i + r * cols] != 0)
						break;
					r++;
				}

				if (r == rows)
				{
					/* Every remaining element in this column is zero, so this
					matrix cannot be inverted. */
					return false;
				}

				this.swapRows(i, r);
				output.swapRows(i, r);
			}

			/* Scale this row to ensure a 1 along the diagonal.
			We might need to worry about overflow from a huge scalar here. */
			var scalar = 1 / data[i + i * cols];
			scaleRow(i, scalar);
			output.scaleRow(i, scalar);

			/* Zero out the other elements in this column. */
			for (j in 0...rows)
			{
				if (i == j)
					continue;
				var shearNeeded = -data[i + j * cols];
				shearRow(j, i, shearNeeded);
				output.shearRow(j, i, shearNeeded);
			}
		}

		return true;
  }

	/**
	 * Subtracts this matrix from identity
	 */
	public function subtractFromIdentity():Void
	{
		if (rows != cols) throw "assert";
		var data = data, cols = cols;
		for (i in 0...rows)
			for (j in 0...cols)
			{
				if (i == j)
					data[j + i * cols] = 1 - data[j + i * cols];
				else
					data[j + i * cols] = -data[j + i * cols];
			}
	}

	/**
	 * Gets a value from matrix
	 * @param	row
	 * @param	col
	 * @return
	 */
	public inline function get(row:Int, col:Int):Float
	{
		return data[col + row * cols];
	}

	/**
	 * Sets a value to matrix
	 * @param	row
	 * @param	col
	 * @param	val
	 * @return
	 */
	public inline function set(row:Int, col:Int, val:Float):Float
	{
		return data[col + row * cols] = val;
	}
}
