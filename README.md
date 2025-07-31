# MutualInformation

Elixir module that calculates Mutual Information between two datasets. This implementation will handle both discrete and continuous data by using histogram-based probability estimation.

Mutual Information (MI) measures the amount of information obtained about one random variable through observing another random variable.

MI(X,Y) = ∑∑ p(x,y) * log2(p(x,y) / (p(x) * p(y)))

where:
- p(x,y) is the joint probability distribution
- p(x) and p(y) are the marginal probability distributions


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `mutual_information` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mutual_information, "~> 0.1.0"}
  ]
end
```

## Main Functions

* `compute/3` - Calculates mutual information between two datasets
* `normalized/3` - Returns normalized mutual information (0-1 scale)
* `entropy/2` - Calculates entropy of a single dataset

## Key Features

* Handles both discrete and continuous data - Automatically detects if data is discrete (integers) or continuous and applies appropriate binning
* Configurable options - You can specify the number of bins for continuous data and the logarithm base
* Normalized MI - Provides normalized Mutual Information for easier interpretation

## Usage Examples

```elixir
# For discrete data
x = [1, 2, 3, 4, 5, 1, 2, 3, 4, 5]
y = [1, 2, 3, 4, 5, 1, 2, 3, 4, 5]
MutualInformation.compute(x, y)

# For continuous data with custom bins
x = [1.2, 2.3, 3.4, 4.5, 5.6]
y = [2.1, 3.2, 4.3, 5.4, 6.5]
MutualInformation.compute(x, y, bins: 5)

# Normalized mutual information
MutualInformation.normalized(x, y)

# Calculate entropy
MutualInformation.entropy(x)
```
