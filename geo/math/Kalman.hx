package geo.math;

/**
 * Refer to http://en.wikipedia.org/wiki/Kalman_filter for
   mathematical details. The naming scheme is that variables get names
   that make sense, and are commented with their analog in
   the Wikipedia mathematical notation.
   This Kalman filter implementation does not support controlled
   input.
   (Like knowing which way the steering wheel in a car is turned and
   using that to inform the model.)
   Vectors are handled as n-by-1 matrices.
   TODO: comment on the dimension of the matrices

 * @author Kevin Lacker
 * @author waneck
 */

class Kalman
{
	/* k */
	var timeStep:Int;

	/* These parameters define the size of the matrices. */
	public var state_dimension(default, null):Int;
	public var observation_dimension(default, null):Int;

	/* This group of matrices must be specified by the user. */
	/* F_k */
	public var state_transition:Matrix;
	/* H_k */
	public var observation_model:Matrix;
	/* Q_k */
	public var process_noise_covariance:Matrix;
	/* R_k */
	public var observation_noise_covariance:Matrix;

	/* The observation is modified by the user before every time step. */
	/* z_k */
	public var observation:Matrix;

	/* This group of matrices are updated every time step by the filter. */
	/* x-hat_k|k-1 */
	var predicted_state:Matrix;
	/* P_k|k-1 */
	var predicted_estimate_covariance:Matrix;
	/* y-tilde_k */
	var innovation:Matrix;
	/* S_k */
	var innovation_covariance:Matrix;
	/* S_k^-1 */
	var inverse_innovation_covariance:Matrix;
	/* K_k */
	var optimal_gain:Matrix;
	/* x-hat_k|k */
	public var state_estimate:Matrix;
	/* P_k|k */
	public var estimate_covariance:Matrix;

	/* This group is used for meaningless intermediate calculations */
	var vertical_scratch:Matrix;
	var small_square_scratch:Matrix;
	var big_square_scratch:Matrix;

	static inline function alloc_matrix(x, y)
	{
		return new Matrix(x, y);
	}

	public function new(state_dimension,observation_dimension)
	{
		this.state_dimension = state_dimension;
		this.observation_dimension = observation_dimension;

		timeStep = 0;
		state_transition = new Matrix(state_dimension, state_dimension);
		this.observation_model = alloc_matrix(observation_dimension, state_dimension);
		this.process_noise_covariance = alloc_matrix(state_dimension, state_dimension);
		this.observation_noise_covariance = alloc_matrix(observation_dimension, observation_dimension);

		this.observation = alloc_matrix(observation_dimension, 1);

		this.predicted_state = alloc_matrix(state_dimension, 1);
		this.predicted_estimate_covariance = alloc_matrix(state_dimension, state_dimension);
		this.innovation = alloc_matrix(observation_dimension, 1);
		this.innovation_covariance = alloc_matrix(observation_dimension, observation_dimension);
		this.inverse_innovation_covariance = alloc_matrix(observation_dimension, observation_dimension);
		this.optimal_gain = alloc_matrix(state_dimension, observation_dimension);
		this.state_estimate = alloc_matrix(state_dimension, 1);
		this.estimate_covariance = alloc_matrix(state_dimension, state_dimension);

		this.vertical_scratch = alloc_matrix(state_dimension, observation_dimension);
		this.small_square_scratch = alloc_matrix(observation_dimension, observation_dimension);
		this.big_square_scratch = alloc_matrix(state_dimension, state_dimension);
	}

	/* Runs one timestep of prediction + estimation.

	   Before each time step of running this, set f.observation to be the
	   next time step's observation.

	   Before the first step, define the model by setting:
	   f.state_transition
	   f.observation_model
	   f.process_noise_covariance
	   f.observation_noise_covariance

	   It is also advisable to initialize with reasonable guesses for
	   f.state_estimate
	   f.estimate_covariance
	*/
	public function update():Void
	{
		predict();
		estimate();
	}

	/* Just the prediction phase of update. */
	function predict():Void
	{
		timeStep++;

		/* Predict the state */
		Matrix.multiply(state_transition, state_estimate, predicted_state);

		/* Predict the state estimate covariance */
		Matrix.multiply(state_transition, estimate_covariance, big_square_scratch);
		Matrix.multiplyByTranspose(big_square_scratch, state_transition, predicted_estimate_covariance);
		Matrix.add(predicted_estimate_covariance, process_noise_covariance, predicted_estimate_covariance);
	}

	/* Just the estimation phase of update. */
	function estimate():Void
	{
		/* Calculate innovation */
		Matrix.multiply(observation_model, predicted_state, innovation);
		Matrix.subtract(observation, innovation, innovation);

		/* Calculate innovation covariance */
		Matrix.multiplyByTranspose(predicted_estimate_covariance, observation_model, vertical_scratch);
		Matrix.multiply(observation_model, vertical_scratch, innovation_covariance);
		Matrix.add(innovation_covariance, observation_noise_covariance, innovation_covariance);

		/* Invert the innovation covariance.
		Note: this destroys the innovation covariance.
		TODO: handle inversion failure intelligently. */
		innovation_covariance.destructiveInvertMatrix(inverse_innovation_covariance);

		/* Calculate the optimal Kalman gain.
		 Note we still have a useful partial product in vertical scratch
		 from the innovation covariance. */
		Matrix.multiply(vertical_scratch, inverse_innovation_covariance, optimal_gain);

		/* Estimate the state */
		Matrix.multiply(optimal_gain, innovation, state_estimate);
		Matrix.add(state_estimate, predicted_state, state_estimate);

		/* Estimate the state covariance */
		Matrix.multiply(optimal_gain, observation_model, big_square_scratch);
		big_square_scratch.subtractFromIdentity();
		Matrix.multiply(big_square_scratch, predicted_estimate_covariance, estimate_covariance);
	}
}
