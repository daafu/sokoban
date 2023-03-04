#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "Math";


EaseFunc :: enum u8 {
    LINEAR;
    SINE_IN;
    SINE_OUT;
    SINE_IN_OUT;
    QUAD_IN;
    QUAD_OUT;
    QUAD_IN_OUT;
    CUBIC_IN;
    CUBIC_OUT;
    CUBIC_IN_OUT;
    QUARTIC_IN;
    QUARTIC_OUT;
    QUARTIC_IN_OUT;
    QUANTIC_IN;
    QUANTIC_OUT;
    QUANTIC_IN_OUT;
    EXPO_IN;
    EXPO_OUT;
    EXPO_IN_OUT;
    CIRC_IN;
    CIRC_OUT;
    CIRC_IN_OUT;
    BACK_IN;
    BACK_OUT;
    BACK_IN_OUT;
    ELASTIC_IN;
    ELASTIC_OUT;
    ELASTIC_IN_OUT;
    BOUNCE_IN;
    BOUNCE_OUT;
    BOUNCE_IN_OUT;
}

ease_interp :: (func : EaseFunc, start: u8, end: u8, t: float) -> u8
{
    t = value(func, t);
    return cast (u8)clamp(round_to_uint(start + ((end - start) * t)), 0, U8_MAX);
}

ease_interp :: (func : EaseFunc, start: s8, end: s8, t: float) -> s8
{
    t = value(func, t);
    return cast (s8)clamp(round_to_int(start + ((end - start) * t)), S8_MIN, S8_MAX);
}

ease_interp :: (func : EaseFunc, start: s16, end: s16, t: float) -> s16
{
    t = value(func, t);
    return cast (s16)clamp(round_to_int(start + ((end - start) * t)), S16_MIN, S16_MAX);
}

ease_interp :: (func : EaseFunc, start: u16, end: u16, t: float) -> u16
{
    t = value(func, t);
    return cast (u16)clamp(round_to_uint(start + ((end - start) * t)), 0, U16_MAX);
}

ease_interp :: (func : EaseFunc, start: s32, end: s32, t: float) -> s32
{
    t = value(func, t);
    return clamp(cast(s16) round_to_int(start + ((end - start) * t)), S16_MIN, S16_MAX);
}

ease_interp :: (func : EaseFunc, start: u32, end: u32, t: float) -> u32
{
    t = value(func, t);
    return clamp(cast(u32) round_to_uint(start + ((end - start) * t)), 0, U32_MAX);
}

ease_interp :: (func : EaseFunc, start: s64, end: s64, t: float) -> s64
{
    t = value(func, t);
    return clamp(round_to_int(start + ((end - start) * t)), S64_MIN, S64_MAX);
}

ease_interp :: (func : EaseFunc, start: u64, end: u64, t: float) -> u64
{
    t = value(func, t);
    return clamp(round_to_uint(start + ((end - start) * t)), 0, U32_MAX);
}

ease_interp :: (func : EaseFunc, start: float, end: float, t: float) -> float
{
    t = value(func, t);
    return start + ((end - start) * t);
}

ease_interp :: (func : EaseFunc, start: float64, end: float64, t: float) -> float64
{
    t = value(func, t);
    return start + ((end - start) * t);
}

ease_interp :: (func : EaseFunc, start: Vector2i, end: Vector2i, t: float) -> Vector2i
{
    t = value(func, t);
    return Vector2i.{
        clamp(cast(s32) round_to_int(start.x + ((end.x - start.x) * t)), S32_MIN, S32_MAX),
        clamp(cast(s32) round_to_int(start.y + ((end.y - start.y) * t)), S32_MIN, S32_MAX)};
}

ease_interp :: (func : EaseFunc, start: Vector2, end: Vector2, t: float) -> Vector2
{
    t = value(func, t);
    return Vector2.{start.x + ((end.x - start.x) * t), start.y + ((end.y - start.y) * t)};
}

#scope_file

HALF_PI :: (PI / 2.0);


linear :: (t: float) -> float {
    return t;
}

sine_in :: (t: float) -> float {
    return sin((t - 1) * HALF_PI) + 1;
}

sine_out :: (t: float) -> float {
    return sin(t * HALF_PI);
}

sine_in_out :: (t: float) -> float {
    return 0.5 * (1 - cos(t * PI));
}

quad_in :: (t: float) -> float {
    return t * t;
}

quad_out :: (t: float) -> float {
    return -(t * (t - 2));
}

quad_in_out :: (t: float) -> float {
    if t < 0.5 {
        return 2 * t * t;
    }
    else {
        return (-2 * t * t) + (4 * t) - 1;
    }
}

cubic_in :: (t: float) -> float {
    return t * t * t;
}

cubic_out :: (t: float) -> float {
    f : float = t - 1;
    return (f * f * f) + 1;
}

cubic_in_out :: (t: float) -> float {
    if t < 0.5 {
        return 4 * t * t * t;
    }
    else {
        f : float = (2 * t) - 2;
        return (0.5 * f * f * f) + 1;
    }
}

quartic_in :: (t: float) -> float {
    return t * t * t * t;
}

quartic_out :: (t: float) -> float {
    f : float = t - 1;
    return (f * f * f * (1 - t)) + 1;
}

quartic_in_out :: (t: float) -> float {
    if t < 0.5 {
        return 8 * t * t * t * t;
    }
    else {
        f : float = t - 1;
        return (-8 * f * f * f * f) + 1;
    }
}

quantic_in :: (t: float) -> float {
    return t * t * t * t * t;
}

quantic_out :: (t: float) -> float {
    f : float = t - 1;
    return (f * f * f * f * f) + 1;
}

quantic_in_out :: (t: float) -> float {
    if t < 0.5 {
        return 16 * t * t * t * t * t;
    }
    else {
        f : float = (2 * t) - 2;
        return (0.5 * f * f * f * f * f) + 1;
    }
}

expo_in :: (t: float) -> float {
    return ifx t == 0.0 then t else pow(2, 10 * (t - 1));
}

expo_out :: (t: float) -> float {
    return ifx t == 1.0 then t else 1 - pow(2, -10 * t);
}

expo_in_out :: (t: float) -> float {
    if t == 0.0 || t == 1.0 {
        return t;
    }

    if t < 0.5 {
        return 0.5 * pow(2, (20 * t) - 10);
    }
    else {
        return (-0.5 * pow(2, (-20 * t) + 10)) + 1;
    }
}

circ_in :: (t: float) -> float {
    return 1 - sqrt(1 - (t * t));
}

circ_out :: (t: float) -> float {
    return sqrt((2 - t) * t);
}

circ_in_out :: (t: float) -> float {
    if t < 0.5 {
        return 0.5 * (1 - sqrt(1 - (4 * (t * t))));
    }
    else {
        return 0.5 * (sqrt(-((2 * t) - 3) * ((2 * t) - 1)) + 1);
    }
}

back_in :: (t: float) -> float {
    return (t * t * t) - (t * sin(t * PI));
}

back_out :: (t: float) -> float {
    f : float = 1 - t;
    return 1 - ((f * f * f) - (f * sin(f * PI)));
}

back_in_out :: (t: float) -> float {
    if t < 0.5 {
        f : float = 2 * t;
        return 0.5 * ((f * f * f) - (f * sin(f * PI)));
    }
    else {
        f : float = 1 - ((2 * t) - 1);
        return (0.5 * (1 - ((f * f * f) - (f * sin(f * PI))))) + 0.5;
    }
}

elastic_in :: (t: float) -> float {
    return sin(13 * HALF_PI * t) * pow(2, 10 * (t - 1));
}

elastic_out :: (t: float) -> float {
    return (sin(-13 * HALF_PI * (t + 1)) * pow(2, -10 * t)) + 1;
}

elastic_in_out :: (t: float) -> float {
    if t < 0.5 {
        return 0.5 * sin(13 * HALF_PI * (2 * t)) * pow(2, 10 * ((2 * t) - 1));
    }
    else {
        return 0.5 * ((sin(-13 * HALF_PI * (((2 * t) - 1) + 1)) * pow(2, -10 * ((2 * t) - 1))) + 2);
    }
}

bounce_in :: (t: float) -> float {
    return 1 - bounce_out(1 - t);
}

bounce_out :: (t: float) -> float {
    if t < 4 / 11.0 {
        return (121 * t * t) / 16.0;
    }
    else if t < 8 / 11.0 {
        return (363 / 40.0 * t * t) - (99 / 10.0 * t) + (17 / 5.0);
    }
    else if t < 9 / 10.0 {
        return (4356 / 361.0 * t * t) - (35442 / 1805.0 * t) + (16061 / 1805.0);
    }
    else {
        return (54 / 5.0 * t * t) - (513 / 25.0 * t) + (268 / 25.0);
    }
}

bounce_in_out :: (t: float) -> float {
    if t < 0.5 {
        return 0.5 * bounce_in(t * 2);
    }
    else {
        return (0.5 * bounce_out((t * 2) - 1)) + 0.5;
    }
}

value :: (func: EaseFunc, t: float) -> float {
    if func == {
        case .LINEAR; return linear(t);
        case .SINE_IN; return sine_in(t);
        case .SINE_OUT; return sine_out(t);
        case .SINE_IN_OUT; return sine_in_out(t);
        case .QUAD_IN; return quad_in(t);
        case .QUAD_OUT; return quad_out(t);
        case .QUAD_IN_OUT; return quad_in_out(t);
        case .CUBIC_IN; return cubic_in(t);
        case .CUBIC_OUT; return cubic_out(t);
        case .CUBIC_IN_OUT; return cubic_in_out(t);
        case .QUARTIC_IN; return quartic_in(t);
        case .QUARTIC_OUT; return quartic_out(t);
        case .QUARTIC_IN_OUT; return quartic_in_out(t);
        case .QUANTIC_IN; return quantic_in(t);
        case .QUANTIC_OUT; return quantic_out(t);
        case .QUANTIC_IN_OUT; return quantic_in_out(t);
        case .EXPO_IN; return expo_in(t);
        case .EXPO_OUT; return expo_out(t);
        case .EXPO_IN_OUT; return expo_in_out(t);
        case .CIRC_IN; return circ_in(t);
        case .CIRC_OUT; return circ_out(t);
        case .CIRC_IN_OUT; return circ_in_out(t);
        case .BACK_IN; return back_in(t);
        case .BACK_OUT; return back_out(t);
        case .BACK_IN_OUT; return back_in_out(t);
        case .ELASTIC_IN; return elastic_in(t);
        case .ELASTIC_OUT; return elastic_out(t);
        case .ELASTIC_IN_OUT; return elastic_in_out(t);
        case .BOUNCE_IN; return bounce_in(t);
        case .BOUNCE_OUT; return bounce_out(t);
        case .BOUNCE_IN_OUT; return bounce_in_out(t);
        case; return t;
    }
}

round_to_int :: (f: float) -> int {
    if f < 0.0 {
        return cast (int)(f - 0.5);
    } else {
        return cast (int)(f + 0.5);
    }    
}

round_to_uint :: (f: float) -> u64 {
    return cast (u64)(f + 0.5);
}
