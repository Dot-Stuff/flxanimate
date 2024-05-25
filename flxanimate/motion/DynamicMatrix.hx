package flxanimate.motion;

import openfl.Vector;

/**
 * The DynamicMatrix class calculates and stores a matrix based on given values.
 * This class supports the ColorMatrixFilter and can be extended by the ColorMatrix class.
 * @see [flxanimate.motion.AdjustColor]
 * @see [openfl.filters.ColorMatrixFilter](https://api.openfl.org/openfl/filters/ColorMatrixFilter.html)
 */
class DynamicMatrix
{
	/**
	 * Specifies that a matrix is prepended for concatenation.
	 */
	public static var MATRIX_ORDER_PREPEND(default, null):Int = 0;
	/**
	 * Specifies that a matrix is appended for concatenation.
	 */
	public static var MATRIX_ORDER_APPEND(default, null):Int = 1;

	var m_width:Int;
	var m_height:Int;
	var m_matrix:Vector<Vector<Float>>;

	/**
	 * Constructs a matrix with the given number of rows and columns.
	 * @param width Number of columns.
	 * @param height Number of rows.
	 */
	public function new(width:Int, height:Int)
	{
		create(width, height);
	}
	function create(width:Int, height:Int)
	{
		if (width <= 0 || height <= 0) return;
		m_width = width;
		m_height = height;
		m_matrix = new Vector(height, true);
		for (i in 0...height)
		{
			m_matrix[i] = new Vector(width, true);
			for (j in 0...width)
			{
				m_matrix[i][j] = 0;
			}
		}
	}

	/**
	 * Returns the number of columns in the current matrix.
	 * @return The number of columns.
	 * @see #getHeight
	 */
	public function getWidth()
	{
		return m_width;
	}
	/**
	 * Returns the number of rows in the current matrix.
	 * @return The number of rows.
	 */
	public function getHeight()
	{
		return m_height;
	}
	public function getValue(row:Int, col:Int)
	{
		var value:Float = 0;

		value = m_matrix[row][col];

		return value;
	}
	/**
	 * Sets the value at a specified zero-based row and column in the current matrix.
	 * @param row The row containing the value you want to set.
	 * @param col The column containing the value you want to set.
	 * @param value The number to insert into the matrix.
	 */
	public function setValue(row:Int, col:Int, value:Float)
	{
		if (row >= 0 && row < m_height && col >= 0 && col <= m_width)
			m_matrix[row][col] = value;
	}
	/**
	 * Sets the current matrix to an identity matrix.
	 * @see [openfl.geom.Matrix#identity](https://api.openfl.org/openfl/geom/Matrix.html#identity)
	 */
	public function loadIdentity()
	{
		if (m_matrix != null)
		{
			for (i in 0...m_height)
			{
				for (j in 0...m_width)
				{
					m_matrix[i][j] = (i == j) ? 1 : 0;
				}
			}
		}
	}
	/**
	 * Sets all values in the current matrix to zero.
	 */
	public function loadZeros()
	{
		if (m_matrix != null)
			multiplyNumber(0);
	}
	/**
	 * Multiplies the current matrix with a specified matrix; and either
	 * appends or prepends the specified matrix. Use the `DynamicMatrix.multiply()` method to
	 * append
	 * @param inMatrix The matrix to add to the current matrix.
	 * @param order Specifies whether to append or prepend the matrix from the
	 * `inMatrix` parameter; either `MATRIX_ORDER_APPEND` or `MATRIX_ORDER_PREPEND`.
	 * @return  A Boolean value indicating whether the multiplication succeeded (`true`) or
	 * failed (`false`). The value is `false` if either the current matrix or
	 * specified matrix (the `inMatrix` parameter) is null, or if the order is to append and the
	 * current matrix's width is not the same as the supplied matrix's height; or if the order is to prepend
	 * and the current matrix's height is not equal to the supplied matrix's width.
	 * @see `DynamicMatrix.MATRIX_ORDER_PREPEND`
	 * @see `DynamicMatrix.MATRIX_ORDER_APPEND`
	 */
	public function multiply(inMatrix:DynamicMatrix, order:Int = 0)
	{
		if (m_matrix == null || inMatrix == null)
			return false;

		var inHeight = inMatrix.getHeight();
		var inWidth = inMatrix.getWidth();

		var width = (order == MATRIX_ORDER_APPEND) ? inWidth : inMatrix.getWidth();
		var height = (order == MATRIX_ORDER_APPEND) ? inHeight : m_height;

		if (width != height)
			return false;

		var result = new DynamicMatrix(width, height);
		for (i in 0...height)
		{
			for (j in 0...width)
			{
				var total:Float = 0;
				var k = 0, m = 0;
				while (k < Math.max(m_height, inHeight) && m < Math.max(m_width, inWidth))
				{
					total += inMatrix.getValue(k, j) * m_matrix[i][m];
					k++;
					m++;
				}
				result.setValue(i, j, total);
			}
		}

		m_matrix = null;

		create(width, height);

		for (i in 0...inHeight)
		{
			for (j in 0...m_width)
			{
				m_matrix[i][j] = result.getValue(i, j);
			}
		}
		return true;
	}

	/**
	 * Multiplies a number with each item in the matrix and stores the results in
	 * the current matrix.
	 * @param value A number to multiply by each item in the matrix.
	 * @return A Boolean value indicating whether the multiplication succeeded (`true`)
	 * or failed (`false`).
	 */
	public function multiplyNumber(value:Float)
	{
		if (m_matrix == null)
			return false;

		for (i in 0...m_height)
		{
			for (j in 0...m_width)
			{
				m_matrix[i][j] *= value;
			}
		}

		return true;
	}
	/**
	 * Adds the current matrix with a specified matrix. The
	 * current matrix becomes the result of the addition (in other
	 * words the `DynamicMatrix.add()` method does
	 * not create a new matrix to contain the result).
	 * @param inMatrix The matrix to add to the current matrix.
	 * @return A Boolean value indicating whether the addition succeeded (`true`)
	 * or failed (`false`). If the dimensions of the matrices are not
	 * the same, `DynamicMatrix.add()` returns `false`.
	 */
	public function add(inMatrix:DynamicMatrix)
	{
		if (m_matrix == null || inMatrix == null)
			return false;

		var inHeight = inMatrix.getHeight();
		var inWidth = inMatrix.getWidth();
		if (m_width != inWidth || inHeight != m_height)
			return false;

		for (i in 0...m_height)
		{
			for (j in 0...m_width)
			{
				m_matrix[i][j] += inMatrix.getValue(i, j);
			}
		}

		return true;
	}
}