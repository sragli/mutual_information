defmodule MutualInformation do
  @moduledoc """
  A module for calculating mutual information between two datasets.

  Mutual Information (MI) measures the amount of information obtained about one
  random variable through observing another random variable.

  MI(X,Y) = ∑∑ p(x,y) * log2(p(x,y) / (p(x) * p(y)))

  Where:
  - p(x,y) is the joint probability distribution
  - p(x) and p(y) are the marginal probability distributions
  """

  @doc """
  Calculates mutual information between two datasets.

  ## Parameters
  - `dataset_x`: List of values for variable X
  - `dataset_y`: List of values for variable Y
  - `opts`: Keyword list of options
    - `:bins` - Number of bins for continuous data (default: 10)
    - `:base` - Logarithm base for calculation (default: 2)

  ## Examples

      iex> x = [1, 2, 3, 4, 5, 1, 2, 3, 4, 5]
      iex> y = [1, 2, 3, 4, 5, 1, 2, 3, 4, 5]
      iex> MutualInformation.compute(x, y)
      2.321928094887362

      iex> x = [1, 1, 2, 2, 3, 3]
      iex> y = [1, 2, 1, 2, 1, 2]
      iex> MutualInformation.compute(x, y)
      0.0
  """
  def compute(dataset_x, dataset_y, opts \\ []) do
    bins = Keyword.get(opts, :bins, 10)
    base = Keyword.get(opts, :base, 2)

    if length(dataset_x) != length(dataset_y) do
      raise ArgumentError, "Datasets must have the same length"
    end

    if length(dataset_x) == 0 do
      raise ArgumentError, "Datasets cannot be empty"
    end

    # Discretize data if needed
    x_discrete = discretize(dataset_x, bins)
    y_discrete = discretize(dataset_y, bins)

    # Calculate probability distributions
    joint_prob = joint_probability(x_discrete, y_discrete)
    marginal_x = marginal_probability(x_discrete)
    marginal_y = marginal_probability(y_discrete)

    # Calculate mutual information
    compute_mi(joint_prob, marginal_x, marginal_y, base)
  end

  @doc """
  Calculates normalized mutual information (0 to 1 scale).

  Normalized MI = MI(X,Y) / min(H(X), H(Y))
  Where H(X) and H(Y) are the entropies of X and Y.
  """
  def normalized(dataset_x, dataset_y, opts \\ []) do
    mi = compute(dataset_x, dataset_y, opts)

    h_x = entropy(dataset_x, opts)
    h_y = entropy(dataset_y, opts)

    min_entropy = min(h_x, h_y)

    if min_entropy == 0 do
      0.0
    else
      mi / min_entropy
    end
  end

  @doc """
  Calculates entropy of a dataset.

  H(X) = -∑ p(x) * log(p(x))
  """
  def entropy(dataset, opts \\ []) do
    bins = Keyword.get(opts, :bins, 10)
    base = Keyword.get(opts, :base, 2)

    dataset
    |> discretize(bins)
    |> marginal_probability()
    |> Enum.reduce(0, fn {_value, prob}, acc ->
      if prob > 0 do
        acc - prob * :math.log(prob) / :math.log(base)
      else
        acc
      end
    end)
  end

  defp discretize(data, bins) when is_list(data) do
    # Check if data is already discrete (integers only)
    if Enum.all?(data, &is_integer/1) do
      data
    else
      # Continuous data - create bins
      {min_val, max_val} = Enum.min_max(data)

      if min_val == max_val do
        # All values are the same
        Enum.map(data, fn _ -> 0 end)
      else
        bin_width = (max_val - min_val) / bins

        Enum.map(data, fn value ->
          bin = trunc((value - min_val) / bin_width)
          # Ensure the maximum value falls into the last bin
          min(bin, bins - 1)
        end)
      end
    end
  end

  defp joint_probability(x_data, y_data) do
    total_count = length(x_data)

    x_data
    |> Enum.zip(y_data)
    |> Enum.frequencies()
    |> Enum.map(fn {key, count} -> {key, count / total_count} end)
    |> Enum.into(%{})
  end

  defp marginal_probability(data) do
    total_count = length(data)

    data
    |> Enum.frequencies()
    |> Enum.map(fn {key, count} -> {key, count / total_count} end)
    |> Enum.into(%{})
  end

  defp compute_mi(joint_prob, marginal_x, marginal_y, base) do
    Enum.reduce(joint_prob, 0, fn {{x, y}, p_xy}, acc ->
      p_x = Map.get(marginal_x, x, 0)
      p_y = Map.get(marginal_y, y, 0)

      if p_xy > 0 and p_x > 0 and p_y > 0 do
        mi_term = p_xy * (:math.log(p_xy / (p_x * p_y)) / :math.log(base))
        acc + mi_term
      else
        acc
      end
    end)
  end
end
