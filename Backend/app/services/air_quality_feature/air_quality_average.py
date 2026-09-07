from typing import List, Optional


def calculate_rolling_average(
    values: List[Optional[float]],
    window: int,
) -> List[Optional[float]]:
    """
    Calculate a rolling average over the specified number of hours.

    The result at index i is calculated only when a complete
    window of valid values is available.

    Example:
        window=8
        index 0-6 -> None
        index 7    -> average of values 0-7
    """

    averages: List[Optional[float]] = []

    for i in range(len(values)):

        if i + 1 < window:
            averages.append(None)
            continue

        window_values = values[i - window + 1:i + 1]

        if any(value is None for value in window_values):
            averages.append(None)
            continue

        valid_window_values = [value for value in window_values if value is not None]
        average = sum(valid_window_values) / window

        averages.append(average)

    return averages