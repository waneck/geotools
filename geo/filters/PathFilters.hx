package geo.filters;
import geo.*;
import geo.units.*;

@:dce class PathFilters
{
	public static function kalman(secsBetweenFixes:Seconds):LocationTime->LocationTime
	{
		var k:KalmanFilter = null,
				last:LocationTime = null;
		return function(r) {
			var lst = last;
			last = r;
			if (lst == null || r.time.getTime() - last.time.getTime() > secsBetweenFixes.float() * 60)
			{
				k = new KalmanFilter(secsBetweenFixes.float());
				return r;
			} else {
				k.update(r, r.time.getTime() - last.time.getTime());
				var calc = k.calculatedPosition;
				return new LocationTime(calc.lat,calc.lon,r.time);
			}
		};
	}
}
