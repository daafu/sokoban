util_part_progress :: (t: float, min: float, max: float) -> float {
    if t < min return 0;
    if t > max return 1;

    return (t - min) / (max - min);
}
