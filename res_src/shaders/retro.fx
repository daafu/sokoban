//-----------------------------------------------------------------------------
// bowl_curve.fx
//
// Microsoft XNA Community Game Platform
// Copyright (C) Microsoft Corporation. All rights reserved.
//-----------------------------------------------------------------------------

#include "macros.fxh"


DECLARE_TEXTURE(Texture, 0);


BEGIN_CONSTANTS

    // .x = unmodified time, loops around every 12 hours
    // .y = sin(time)
    // .y = cos(time)
    // .z = time delta
    float4 Time;

    // Size of screen
    float2 ScreenSize;

    // Size of the render target which is the same as ScreenSize if render target is the back buffer
    float2 RenderTargetSize;

    // Pixel size of the main sampler texture
    float2 TextureSize;

MATRIX_CONSTANTS

    float4x4 MatrixTransform    _vs(c0) _cb(c0);

END_CONSTANTS

void SpriteVertexShader(inout float4 color    : COLOR0,
                        inout float2 spriteUV : TEXCOORD0,
                        inout float2 spritesheetUV0 : TEXCOORD1,
                        inout float2 spritesheetUV1 : TEXCOORD2,
                        inout float4 position : SV_Position)
{
    position = mul(position, MatrixTransform);
}

// Map UV from sprite to spritesheet
float2 MapUV(float2 spriteUV, float2 spritesheetUV0, float2 spritesheetUV1) {
    float2 outUV;

    outUV.x = ((spritesheetUV1.x - spritesheetUV0.x) * frac(spriteUV.x)) + spritesheetUV0.x;
    outUV.y = ((spritesheetUV1.y - spritesheetUV0.y) * frac(spriteUV.y)) + spritesheetUV0.y;

    return outUV;
}

// Map UV from sprite to spritesheet
float2 MapUVNoWrap(float2 spriteUV, float2 spritesheetUV0, float2 spritesheetUV1) {
    float2 outUV;

    outUV.x = ((spritesheetUV1.x - spritesheetUV0.x) * spriteUV.x) + spritesheetUV0.x;
    outUV.y = ((spritesheetUV1.y - spritesheetUV0.y) * spriteUV.y) + spritesheetUV0.y;

    return outUV;
}

float4 SpritePixelShader(float4 iterated_color : COLOR0,
                         float2 spriteUV : TEXCOORD0,
                         float2 spritesheetUV0 : TEXCOORD1,
                         float2 spritesheetUV1 : TEXCOORD2) : SV_Target0 {

    float2 uv = spriteUV;

    float sampleFactor = 1.0f / ((ScreenSize.x / TextureSize.x) * 2.5f);
    float chromaticAberration = (ScreenSize.x / 1500000.0) / (ScreenSize.x / 1280.0);
    chromaticAberration = chromaticAberration * 0.5;

    /* Wrap UV */
    float warp_amount = 0.15;
    float2 delta = uv - 0.5;
    float delta2 = dot(delta.xy, delta.xy);
    float delta4 = delta2 * delta2;
    float delta_offset = delta4 * warp_amount;

    uv = uv + delta * delta_offset;

    /* Here we sample neighbouring pixels to get some pixel smoothing when display size
    doesn't divide evenly into the native window resolution. */
    float2 pixelSize = float2(1.0 / TextureSize.x, 1.0 / TextureSize.y);
    pixelSize *= sampleFactor;

    float4 leftColor;
    leftColor.r = SAMPLE_TEXTURE(Texture, float2(uv.x - pixelSize.x, uv.y) + chromaticAberration).r;
    leftColor.ga = SAMPLE_TEXTURE(Texture, float2(uv.x - pixelSize.x, uv.y)).ga;
    leftColor.b = SAMPLE_TEXTURE(Texture, float2(uv.x - pixelSize.x, uv.y) - chromaticAberration).b;

    float4 rightColor;
    rightColor.r = SAMPLE_TEXTURE(Texture, float2(uv.x + pixelSize.x, uv.y) + chromaticAberration).r;
    rightColor.ga = SAMPLE_TEXTURE(Texture, float2(uv.x + pixelSize.x, uv.y)).ga;
    rightColor.b = SAMPLE_TEXTURE(Texture, float2(uv.x + pixelSize.x, uv.y) - chromaticAberration).b;

    float4 topColor;
    topColor.r = SAMPLE_TEXTURE(Texture, float2(uv.x, uv.y + pixelSize.y) + chromaticAberration).r;
    topColor.ga = SAMPLE_TEXTURE(Texture, float2(uv.x, uv.y + pixelSize.y)).ga;
    topColor.b = SAMPLE_TEXTURE(Texture, float2(uv.x, uv.y + pixelSize.y) - chromaticAberration).b;

    float4 bottomColor;
    bottomColor.r = SAMPLE_TEXTURE(Texture, float2(uv.x, uv.y - pixelSize.y) + chromaticAberration).r;
    bottomColor.ga = SAMPLE_TEXTURE(Texture, float2(uv.x, uv.y - pixelSize.y)).ga;
    bottomColor.b = SAMPLE_TEXTURE(Texture, float2(uv.x, uv.y - pixelSize.y) - chromaticAberration).b;

    float4 texelColor = (leftColor + rightColor + topColor + bottomColor) / 4.0;

    float4 color = texelColor * iterated_color;

    // Saturate
    float saturation = 0.15;
    float4 scaledColor = color * float4(0.3, 0.59, 0.11, 1);
    float luminance = scaledColor.r + scaledColor.g + scaledColor.b;
    float4 desatColor = float4(luminance, luminance, luminance, 1);
    color = lerp(color, desatColor, -saturation);

    // Scanline
    float pixelLuminance = (color.r * 0.6) + (color.g * 0.3) + (color.b * 0.1) * 0.75;
    float scanWave = (sin((uv.y * TextureSize.y * 2.0) * 3.14159265) + 1.0) / 2.0;
    scanWave = (scanWave * scanWave);

    float scanlineIntensity = 0.5;
    float scanFade = 1.0 - ((scanWave)*scanlineIntensity * (1.0 - pixelLuminance));

    color *= scanFade;

    return color;
}


technique SpriteBatch
{
    pass
    {
        VertexShader = compile vs_3_0 SpriteVertexShader();
        PixelShader  = compile ps_3_0 SpritePixelShader();
    }
}
