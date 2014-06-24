package geo.tests;
import geo.filters.KalmanFilter;
import geo.math.Kalman;
import geo.math.Matrix;
import geo.Location;
import utest.Assert;

class TestKalman
{

	public function new()
	{

	}

	function testCalculateKmh()
	{
		var k = new KalmanFilter(1);
		untyped k.calculatedPosition = new Location(39.315842, -120.167107);
		untyped k.deltaLat = -0.000031;
		untyped k.deltaLon = 0.000003;

		Assert.floatEquals(3.46, k.calculatedVelocity, 0.01);
	}

	/* Test the example of a train moving along a 1-d track */
	function testTrain()
	{
		var f = new Kalman(2, 1);
		/* The train state is a 2d vector containing position and velocity.
		 * Velocity is measured in position units per timestep units. */
		f.state_transition = new Matrix(2, 2,
		haxe.ds.Vector.fromArrayCopy([
			1.0, 1.0,
			0.0, 1.0
		]));

		/* We only observe position */
		f.observation_model = new Matrix(1, 2, haxe.ds.Vector.fromArrayCopy([ 1.0, 0.0 ]));

		/* The covariance matrices are blind guesses */
		f.process_noise_covariance.identity();
		f.observation_noise_covariance.identity();

		/* Our knowledge of the start position is incorrect and unconfident */
		var deviation = 1000.0;
		f.state_estimate.set(0,0, 10 * deviation);
		f.estimate_covariance.identity();
		f.estimate_covariance.scale(deviation * deviation);

		/* Test with time steps of the position gradually increasing */
		for (i in 0...10)
		{
			f.observation.set(0, 0, i);
			f.update();
		}

		/* Our prediction should be close to (10, 1) */
		trace("estimated position: " + f.state_estimate.get(0, 0));
		trace("estimated velocity: " + f.state_estimate.get(1, 0));

		Assert.equals(Math.round(f.state_estimate.get(1, 0)), 1);
	}

	function testBearingNorth()
	{
		var f = new KalmanFilter(1);
		for (i in 0...100)
		{
			f.update(new Location(i * 0.0001, 0.0), 1.0);
		}
		var bearing = f.bearing();

		Assert.isTrue( Math.abs(bearing) < 0.01 );

		/* Velocity should be 0.0001 x units per timestep */
		Assert.isTrue( Math.abs(f.deltaLat - 0.0001) < 0.00001 );
		Assert.isTrue( Math.abs(f.deltaLon) < 0.00001 );
	}

	function testBearingEast()
	{
		var f = new KalmanFilter(1);
		for (i in 0...100)
		{
			f.update(new Location(0, i * 0.0001), 1);
		}

		var bearing = f.bearing();
		Assert.isTrue( Math.abs(bearing - 90) < 0.01 );

		/*
			At this rate, it takes 10,000 timesteps to travel one longitude
			unit, and thus 3,600,000 timesteps to travel the circumference of
			the earth. Let's say one timestep is a second, so it takes
 			3,600,000 seconds, which is 60,000 minutes, which is 1,000
 			hours. Since the earth is about 40008 km around, this means we
 			are traveling at about 40 km per hour.
		*/
		var ms = f.calculatedVelocity;
		var kmh = ms * 3.6;
		Assert.isTrue( Math.abs(kmh - 40) < 2 );
	}

	function testBearingSouth()
	{
		var f = new KalmanFilter(1);
		for (i in 0...100)
		{
			f.update(new Location(i * -0.0001, 0), 1);
		}

		var bearing = f.bearing();

		Assert.isTrue( Math.abs(bearing - 180) < 0.01 );
	}

	function testBearingWest()
	{
		var f = new KalmanFilter(1);
		for (i in 0...100)
		{
			f.update(new Location(0, i * -0.0001), 1);
		}

		var bearing = f.bearing();
		Assert.isTrue( Math.abs(bearing - 270) < 0.01 );
	}
}
