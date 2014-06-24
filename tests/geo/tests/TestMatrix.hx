package geo.tests;
import geo.math.Matrix;
import utest.Assert;

class TestMatrix
{

	public function new()
	{

	}

	function testCopy()
	{
		var foo = new Matrix(3, 3);
		var bar = new Matrix(3, 3);

		foo.set(1, 1, 1337);
		bar.copyFrom(foo);
		Assert.equals(1337, bar.get(1, 1));
	}

	function testInverse()
	{
		var foo = new Matrix(4, 4,
		haxe.ds.Vector.fromArrayCopy([
			1.0, 2.0, 3.0, 4.0,
			4.0, 1.0, 7.0, 9.0,
			0.0, 0.0, -4.0, -4.0,
			2.3, 3.4, 3.1, 0.0
		]));
		var copy = new Matrix(4, 4);
		copy.copyFrom(foo);

		var bar = new Matrix(4, 4);
		var identity = new Matrix(4, 4);
		identity.identity();

		/* foo should be invertible */
		Assert.isTrue(foo.destructiveInvertMatrix(bar));

		/* The process should leave foo as an identity */
		Assert.isTrue(foo.equals(identity, 0.0001));

		/* bar should be foo's inverse in either direction of multiplication */
		Matrix.multiply(copy, bar, foo);
		Assert.isTrue(foo.equals(identity, 0.0001));
		Matrix.multiply(bar, copy, foo);
		Assert.isTrue(foo.equals(identity, 0.0001));
	}

}
