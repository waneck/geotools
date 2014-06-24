package geo.filters;
import geo.math.Kalman;
import geo.math.Matrix;
import geo.Location;
import geo.units.*;

class KalmanFilter
{
	static inline var EARTH_RADIUS_IN_M = 6371000;

	/**
	 * The original position, as observed by the device
	 */
	public var observedPosition(get_observedPosition, null):Location;

	/**
	 * The calculated - filtered - position, smoothed by the filter.
	 */
	public var calculatedPosition(get_calculatedPosition, null):Location;

	/**
	 * The Calculated Velocity, in m/s
	 */
	public var calculatedVelocity(get_calculatedVelocity, null):Float;

	public var noise(default, null):Float;

	private var f:Kalman;

	public var deltaLat(default, null):Float;
	public var deltaLon(default, null):Float;

	public function new(noise:Float)
	{
		this.noise = noise;
		/* The state model has four dimensions:
		 x, y, x', y'
		 Each time step we can only observe position, not velocity, so the
		 observation vector has only two dimensions.
		*/
		var f = this.f = new Kalman(4, 2);

		/* Assuming the axes are rectilinear does not work well at the
		 poles, but it has the bonus that we don't need to convert between
		 lat/long and more rectangular coordinates. The slight inaccuracy
		 of our physics model is not too important.
		*/
		var v2p = 0.001;
		f.state_transition.identity();
		setSecondsPerTimestep(1.0);

		/* We observe (x, y) in each time step */
		f.observation_model = new Matrix(2, 4,
		haxe.ds.Vector.fromArrayCopy([
			1.0, 0.0, 0.0, 0.0,
			0.0, 1.0, 0.0, 0.0
		]));

		/* Noise in the world. */
		var pos = 0.000001;
		f.process_noise_covariance = new Matrix(4, 4,
		haxe.ds.Vector.fromArrayCopy([
			pos, 0.0, 0.0, 0.0,
			0.0, pos, 0.0, 0.0,
			0.0, 0.0, 1.0, 0.0,
			0.0, 0.0, 0.0, 1.0
		]));

		/* Noise in our observation */
		f.observation_noise_covariance = new Matrix(2, 2,
		haxe.ds.Vector.fromArrayCopy([
			pos * noise, 0.0,
			0.0, pos * noise
		]));

		/* The start position is totally unknown, so give a high variance */
		f.state_estimate = new Matrix(4, 1, haxe.ds.Vector.fromArrayCopy([0.0, 0.0, 0.0, 0.0]));
		f.estimate_covariance.identity();
		var trillion = 1000.0 * 1000.0 * 1000.0 * 1000.0;
		f.estimate_covariance.scale(trillion);
	}

	private function setSecondsPerTimestep(seconds_per_timestep:Float)
	{
		/* unit_scaler accounts for the relation between position and
		 * velocity units */
		var unit_scaler = 0.001;
		f.state_transition.set(0,2, unit_scaler * seconds_per_timestep);
		f.state_transition.set(1,3, unit_scaler * seconds_per_timestep);
	}

	/* INTERFACE gps.filter.Filter */

	private function get_observedPosition():Location
	{
		return observedPosition;
	}

	private function get_calculatedPosition():Location
	{
		return calculatedPosition;
	}

	private function get_calculatedVelocity():Float
	{
		return calculateVelocity();
	}

	public function update(p:Location, secondsSinceLastUpdate:Seconds):Void
	{
		this.observedPosition = p;
		this.setSecondsPerTimestep(secondsSinceLastUpdate.float());
		//f.observation = new Matrix(2, 1, [ p.lat * 1000.0, p.lon * 1000.0 ]);
		f.observation.set(0, 0, p.lat * 1000);
		f.observation.set(1, 0, p.lon * 1000);

		f.update();
		this.calculatedPosition = new Location(f.state_estimate.get(0, 0) / 1000.0, f.state_estimate.get(1, 0) / 1000.0);
		this.deltaLat = f.state_estimate.get(2, 0) / (1000.0 * 1000.0);
		this.deltaLon = f.state_estimate.get(3, 0) / (1000.0 * 1000.0);
	}

	private function calculateVelocity()
	{
		/* First, let's calculate a unit-independent measurement - the radii
		 of the earth traveled in each second. (Presumably this will be
		 a very small number.) */

		/* Convert to radians */
		var to_radians = Math.PI / 180.0;
		var lat = calculatedPosition.lat * to_radians, lon = calculatedPosition.lon * to_radians;
		var delta_lat = deltaLat * to_radians, delta_lon = deltaLon * to_radians;
		/* Haversine formula */
		var lat1 = lat - delta_lat;
		var sin_half_dlat = Math.sin(delta_lat / 2.0);
		var sin_half_dlon = Math.sin(delta_lon / 2.0);
		var a = sin_half_dlat * sin_half_dlat + Math.cos(lat1) * Math.cos(lat) * sin_half_dlon * sin_half_dlon;
		var radians_per_second = 2 * Math.atan2(1000.0 * Math.sqrt(a), 1000.0 * Math.sqrt(1.0 - a));

		/* Convert units */
		var meters_per_second = radians_per_second * EARTH_RADIUS_IN_M;
		return meters_per_second;
	}

	/**
	 * Extract a bearing from a velocity2d Kalman filter.
	 * 0 = north, 90 = east, 180 = south, 270 = west
	 * @return	the bearing value
	 */
	/* See
	   http://www.movable-type.co.uk/scripts/latlong.html
	   for formulas */
	public function bearing():Float
	{
		var lat = calculatedPosition.lat, lon = calculatedPosition.lon, delta_lat = deltaLat, delta_lon = deltaLon;

		/* Convert to radians */
		var to_radians = Math.PI / 180.0;
		lat *= to_radians;
		lon *= to_radians;
		delta_lat *= to_radians;
		delta_lon *= to_radians;

		/* Do math */
		var lat1 = lat - delta_lat;
		var y = Math.sin(delta_lon) * Math.cos(lat);
		var x = Math.cos(lat1) * Math.sin(lat) - Math.sin(lat1) * Math.cos(lat) * Math.cos(delta_lon);
		var bearing = Math.atan2(y, x);

		/* Convert to degrees */
		bearing = bearing / to_radians;
		while (bearing >= 360.0) bearing -= 360;
		while (bearing < 0.0) bearing += 360.0;

		return bearing;
	}
}
