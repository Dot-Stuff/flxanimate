package flxanimate.motion;

/**
 * The AdjustColor class defines various color properties, such as brightness, contrast, hue, and saturation, to support the ColorMatrixFilter class.
 * You can apply the AdjustColor filter to any display object,
 * and also generate a flat array representing all four color properties to use with the ColorMatrixFilter class.
 *
 * @see [openfl.filters.ColorMatrixFilter](https://api.openfl.org/openfl/filters/ColorMatrixFilter.html)
 */
class AdjustColor
{
	private static var s_arrayOfDeltaIndex = [
		0,    0.01, 0.02, 0.04, 0.05, 0.06, 0.07, 0.08, 0.1,  0.11,
		0.12, 0.14, 0.15, 0.16, 0.17, 0.18, 0.20, 0.21, 0.22, 0.24,
		0.25, 0.27, 0.28, 0.30, 0.32, 0.34, 0.36, 0.38, 0.40, 0.42,
		0.44, 0.46, 0.48, 0.5,  0.53, 0.56, 0.59, 0.62, 0.65, 0.68,
		0.71, 0.74, 0.77, 0.80, 0.83, 0.86, 0.89, 0.92, 0.95, 0.98,
		1.0,  1.06, 1.12, 1.18, 1.24, 1.30, 1.36, 1.42, 1.48, 1.54,
		1.60, 1.66, 1.72, 1.78, 1.84, 1.90, 1.96, 2.0,  2.12, 2.25,
		2.37, 2.50, 2.62, 2.75, 2.87, 3.0,  3.2,  3.4,  3.6,  3.8,
		4.0,  4.3,  4.7,  4.9,  5.0,  5.5,  6.0,  6.5,  6.8,  7.0,
		7.3,  7.5,  7.8,  8.0,  8.4,  8.7,  9.0,  9.4,  9.6,  9.8,
		10.0];


	private var m_brightnessMatrix:ColorMatrix;
	private var m_contrastMatrix:ColorMatrix;
	private var m_saturationMatrix:ColorMatrix;
	private var m_hueMatrix:ColorMatrix;
	private var m_finalMatrix:ColorMatrix;

	/**
	 * Sets the brightness of the AdjustColor filter. The range of valid values is `-100` to `100`.
	 */
	public var brightness(null, set):Float;

	/**
	 * Sets the contrast of the AdjustColor filter. The range of valid values is `-100` to `100`.
	 */
	public var contrast(null, set):Float;

	/**
	 * Sets the saturation of the AdjustColor filter. The range of valid values is `-100` to `100`.
	 */
	public var saturation(null, set):Float;

	/**
	 * Sets the hue of the AdjustColor filter. The range of valid values is `-180` to `180`.
	 */
	public var hue(null, set):Float;

	/**
	 * The AdjustColor class defines various color properties to support the ColorMatrixFilter.
	 *
	 * @see [openfl.filters.ColorMatrixFilter](https://api.openfl.org/openfl/filters/ColorMatrixFilter.html)
	 */
	public function new() {}

	function set_brightness(value:Float)
	{
		if (m_brightnessMatrix == null)
			m_brightnessMatrix = new ColorMatrix();

		m_brightnessMatrix.setBrightnessMatrix(value * 2);

		return value;
	}

	function set_contrast(value:Float)
	{
		// denormalized contrast value
		var deNormVal:Float = value;

		deNormVal = ((value > 0) ? s_arrayOfDeltaIndex[Std.int(value)] : value / 100) * 127 + 127;

		if(m_contrastMatrix == null)
			m_contrastMatrix = new ColorMatrix();

		m_contrastMatrix.setContrastMatrix(deNormVal);

		return value;
	}

	function set_saturation(value:Float)
	{
		// denormalized saturation value
		var deNormVal:Float = value;

		if (value > 0)
			deNormVal = 1.0 + (3 * value / 100); // max value is 4
		else
			deNormVal = value / 100 + 1;

		if(m_saturationMatrix == null)
		{
			m_saturationMatrix = new ColorMatrix();
		}
		m_saturationMatrix.setSaturationMatrix(deNormVal);

		return value;
	}

	function set_hue(value:Float)
	{
		// hue value does not need to be denormalized

		if(m_hueMatrix == null)
		{
			m_hueMatrix = new ColorMatrix();
		}

		if(value != 0)
			m_hueMatrix.setHueMatrix(value * Math.PI / 180.0);

		return value;
	}
	/**
	 * Verifies if all four AdjustColor properties are set.
	 * @return A Bool value that is `true` if all four AdjustColor properties have been set, `false` otherwise.
	 */
	public function allValuesAreSet()
	{
		return m_brightnessMatrix != null && m_contrastMatrix != null && m_saturationMatrix != null && m_hueMatrix != null;//[m_brightnessMatrix, m_contrastMatrix, m_saturationMatrix, m_hueMatrix].indexOf(null) == -1;
	}
	/**
	 * Returns the flat array of values for all four properties.
	 * @return An array of 20 numerical values representing all four AdjustColor properties
	 * to use with the `openfl.filters.ColorMatrixFilter` class.
	 * @see [openfl.filters.ColorMatrixFilter](https://api.openfl.org/openfl/filters/ColorMatrixFilter.html)
	 */
	public function calculateFinalFlatArray()
	{
		if(calculateFinalMatrix())
		{
			return m_finalMatrix.getFlatArray();
		}

		return null;
	}

	function calculateFinalMatrix()
	{
		if(!allValuesAreSet())
			return false;

		if (m_finalMatrix == null)
			m_finalMatrix = new ColorMatrix();
		else
			m_finalMatrix.loadIdentity();

		m_finalMatrix.multiply(m_brightnessMatrix);
		m_finalMatrix.multiply(m_contrastMatrix);
		m_finalMatrix.multiply(m_saturationMatrix);
		m_finalMatrix.multiply(m_hueMatrix);

		return true;
	}
}