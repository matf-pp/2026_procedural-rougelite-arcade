extern vec2 direction;
extern vec2 resolution;

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 screen) {
    vec2 off1 = vec2(1.3846153846) * direction / resolution;
    vec2 off2 = vec2(3.2307692308) * direction / resolution;

    vec4 result = vec4(0.0);
    result += Texel(tex, uv)        * 0.2270270270;
    result += Texel(tex, uv + off1) * 0.3162162162;
    result += Texel(tex, uv - off1) * 0.3162162162;
    result += Texel(tex, uv + off2) * 0.0702702703;
    result += Texel(tex, uv - off2) * 0.0702702703;

    return result * color;
}
