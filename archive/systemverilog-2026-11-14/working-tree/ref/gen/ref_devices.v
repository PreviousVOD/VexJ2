module ref_devices__uartlite_1_eee99cc82b436e2be5204cecddaa56d739e34653
  (input  rst,
   input  clk,
   input  a_dc,
   input  [7:0] a_d,
   input  a_en,
   input  a_we,
   input  rx,
   output [7:0] y_d,
   output y_ack,
   output y_int,
   output tx);
  wire [10:0] n2556_o;
  wire [7:0] n2558_o;
  wire n2559_o;
  wire n2560_o;
  wire [99:0] this_c;
  reg [99:0] this_r;
  wire [13:0] rxfw;
  wire [12:0] txfw;
  wire [4:0] n2578_o;
  wire [31:0] n2579_o;
  wire [4:0] n2581_o;
  wire [31:0] n2582_o;
  wire n2583_o;
  wire n2585_o;
  wire n2586_o;
  wire n2587_o;
  wire n2590_o;
  wire [3:0] n2593_o;
  wire [31:0] n2594_o;
  wire [3:0] n2596_o;
  wire [31:0] n2597_o;
  wire n2598_o;
  wire n2600_o;
  wire n2601_o;
  wire n2602_o;
  wire n2605_o;
  wire [97:0] n2610_o;
  wire [99:0] n2611_o;
  wire n2612_o;
  wire [99:0] n2613_o;
  wire [3:0] n2615_o;
  wire [31:0] n2616_o;
  wire n2618_o;
  wire [99:0] n2619_o;
  wire [1:0] n2621_o;
  wire n2624_o;
  wire [87:0] n2626_o;
  wire [8:0] n2627_o;
  wire [99:0] n2628_o;
  wire [3:0] n2630_o;
  wire [35:0] n2635_o;
  wire [43:0] n2636_o;
  wire [8:0] n2637_o;
  wire [99:0] n2638_o;
  wire [3:0] n2640_o;
  wire [31:0] n2641_o;
  wire n2643_o;
  wire [35:0] n2645_o;
  wire [43:0] n2646_o;
  wire [8:0] n2647_o;
  wire [99:0] n2648_o;
  wire [3:0] n2650_o;
  wire [31:0] n2651_o;
  wire [31:0] n2653_o;
  wire [3:0] n2654_o;
  wire [3:0] n2655_o;
  wire [35:0] n2657_o;
  wire [6:0] n2658_o;
  wire [9:0] n2659_o;
  wire [21:0] n2660_o;
  wire [8:0] n2661_o;
  wire [99:0] n2662_o;
  wire [3:0] n2664_o;
  wire [31:0] n2665_o;
  wire [35:0] n2666_o;
  wire [6:0] n2667_o;
  wire [9:0] n2668_o;
  wire [21:0] n2669_o;
  wire [8:0] n2670_o;
  wire [99:0] n2671_o;
  wire [3:0] n2673_o;
  wire [31:0] n2674_o;
  wire n2675_o;
  wire [35:0] n2676_o;
  wire [6:0] n2677_o;
  wire [9:0] n2678_o;
  wire [21:0] n2679_o;
  wire [8:0] n2680_o;
  wire [99:0] n2681_o;
  wire n2682_o;
  wire n2683_o;
  wire n2685_o;
  wire n2687_o;
  wire [99:0] n2688_o;
  wire n2689_o;
  wire [87:0] n2690_o;
  wire [8:0] n2691_o;
  wire [99:0] n2692_o;
  wire [6:0] n2693_o;
  wire [7:0] n2695_o;
  wire n2697_o;
  wire n2700_o;
  wire [3:0] n2701_o;
  wire [7:0] n2702_o;
  reg [7:0] n2704_o;
  wire n2705_o;
  reg n2707_o;
  wire [3:0] n2708_o;
  reg [3:0] n2710_o;
  reg n2712_o;
  reg n2714_o;
  wire [35:0] n2715_o;
  wire [6:0] n2716_o;
  wire [9:0] n2717_o;
  wire [21:0] n2718_o;
  wire [8:0] n2719_o;
  wire [99:0] n2720_o;
  wire [1:0] n2722_o;
  wire [35:0] n2723_o;
  wire [6:0] n2724_o;
  wire [9:0] n2725_o;
  wire [21:0] n2726_o;
  wire [8:0] n2727_o;
  wire [99:0] n2728_o;
  wire [3:0] n2730_o;
  wire [31:0] n2731_o;
  wire [35:0] n2732_o;
  wire [6:0] n2733_o;
  wire [9:0] n2734_o;
  wire [21:0] n2735_o;
  wire [8:0] n2736_o;
  wire [99:0] n2737_o;
  wire [3:0] n2739_o;
  wire [31:0] n2740_o;
  wire n2741_o;
  wire [35:0] n2742_o;
  wire [6:0] n2743_o;
  wire [9:0] n2744_o;
  wire [21:0] n2745_o;
  wire [8:0] n2746_o;
  wire [99:0] n2747_o;
  wire n2749_o;
  wire n2750_o;
  wire [1:0] n2753_o;
  wire [1:0] n2754_o;
  wire [3:0] n2755_o;
  wire [3:0] n2756_o;
  wire n2758_o;
  wire n2763_o;
  wire [35:0] n2764_o;
  wire [6:0] n2765_o;
  wire [9:0] n2766_o;
  wire [21:0] n2767_o;
  wire [8:0] n2768_o;
  wire [99:0] n2769_o;
  wire [2:0] n2771_o;
  wire [31:0] n2772_o;
  wire n2774_o;
  wire [35:0] n2776_o;
  wire [6:0] n2777_o;
  wire [9:0] n2778_o;
  wire [21:0] n2779_o;
  wire [8:0] n2780_o;
  wire [99:0] n2781_o;
  wire [2:0] n2783_o;
  wire [31:0] n2784_o;
  wire [31:0] n2786_o;
  wire [2:0] n2787_o;
  wire [1:0] n2788_o;
  wire [1:0] n2789_o;
  wire [2:0] n2790_o;
  wire [2:0] n2791_o;
  wire n2794_o;
  wire [35:0] n2795_o;
  wire [6:0] n2796_o;
  wire [9:0] n2797_o;
  wire [21:0] n2798_o;
  wire [8:0] n2799_o;
  wire [99:0] n2800_o;
  wire [3:0] n2802_o;
  wire [31:0] n2803_o;
  wire [35:0] n2804_o;
  wire [6:0] n2805_o;
  wire [9:0] n2806_o;
  wire [21:0] n2807_o;
  wire [8:0] n2808_o;
  wire [99:0] n2809_o;
  wire [3:0] n2811_o;
  wire [31:0] n2812_o;
  wire n2813_o;
  wire [35:0] n2814_o;
  wire [6:0] n2815_o;
  wire [9:0] n2816_o;
  wire [21:0] n2817_o;
  wire [8:0] n2818_o;
  wire [99:0] n2819_o;
  wire n2821_o;
  wire n2822_o;
  wire [1:0] n2826_o;
  wire [3:0] n2827_o;
  wire [3:0] n2828_o;
  wire n2830_o;
  wire [3:0] n2831_o;
  reg [1:0] n2833_o;
  wire [2:0] n2834_o;
  reg [2:0] n2836_o;
  reg [3:0] n2838_o;
  wire [99:0] n2839_o;
  wire [3:0] n2841_o;
  wire [31:0] n2842_o;
  wire [31:0] n2844_o;
  wire [3:0] n2845_o;
  wire [17:0] n2846_o;
  wire [12:0] n2847_o;
  wire [12:0] n2848_o;
  wire [12:0] n2849_o;
  wire [3:0] n2850_o;
  wire [3:0] n2851_o;
  wire n2852_o;
  wire n2853_o;
  wire n2854_o;
  wire [3:0] n2855_o;
  wire [3:0] n2856_o;
  wire n2857_o;
  wire n2858_o;
  wire n2859_o;
  wire [33:0] n2860_o;
  wire [9:0] n2861_o;
  wire [21:0] n2862_o;
  wire [8:0] n2863_o;
  wire [99:0] n2864_o;
  wire [3:0] n2866_o;
  wire [31:0] n2867_o;
  wire n2869_o;
  wire [33:0] n2870_o;
  wire [9:0] n2871_o;
  wire [21:0] n2872_o;
  wire [8:0] n2873_o;
  wire [99:0] n2874_o;
  wire [3:0] n2876_o;
  wire [31:0] n2877_o;
  wire n2879_o;
  wire n2880_o;
  wire [33:0] n2881_o;
  wire [9:0] n2882_o;
  wire [21:0] n2883_o;
  wire [8:0] n2884_o;
  wire [99:0] n2885_o;
  wire [3:0] n2887_o;
  wire [31:0] n2888_o;
  wire n2890_o;
  wire n2891_o;
  wire [33:0] n2892_o;
  wire [9:0] n2893_o;
  wire [21:0] n2894_o;
  wire [8:0] n2895_o;
  wire [99:0] n2896_o;
  wire n2897_o;
  wire [33:0] n2898_o;
  wire [9:0] n2899_o;
  wire [21:0] n2900_o;
  wire [8:0] n2901_o;
  wire [99:0] n2902_o;
  wire [1:0] n2904_o;
  wire [31:0] n2905_o;
  wire [31:0] n2907_o;
  wire [1:0] n2908_o;
  wire [1:0] n2909_o;
  wire [1:0] n2910_o;
  wire [21:0] n2911_o;
  wire [9:0] n2912_o;
  wire [9:0] n2913_o;
  wire [21:0] n2914_o;
  wire [8:0] n2915_o;
  wire [99:0] n2916_o;
  wire [3:0] n2918_o;
  wire [31:0] n2919_o;
  wire [31:0] n2921_o;
  wire [3:0] n2922_o;
  wire [33:0] n2923_o;
  wire [9:0] n2924_o;
  wire [21:0] n2925_o;
  wire [8:0] n2926_o;
  wire [99:0] n2927_o;
  wire [3:0] n2929_o;
  wire [31:0] n2930_o;
  wire n2932_o;
  wire [33:0] n2933_o;
  wire [9:0] n2934_o;
  wire [21:0] n2935_o;
  wire [8:0] n2936_o;
  wire [99:0] n2937_o;
  wire [1:0] n2939_o;
  wire n2941_o;
  wire n2942_o;
  wire [10:0] n2945_o;
  wire [16:0] n2946_o;
  wire [9:0] n2947_o;
  wire [21:0] n2948_o;
  wire [8:0] n2949_o;
  wire [99:0] n2950_o;
  wire [1:0] n2952_o;
  wire [31:0] n2953_o;
  wire n2955_o;
  wire [10:0] n2956_o;
  wire [16:0] n2957_o;
  wire [9:0] n2958_o;
  wire [21:0] n2959_o;
  wire [8:0] n2960_o;
  wire [99:0] n2961_o;
  wire n2963_o;
  wire [10:0] n2965_o;
  wire [16:0] n2966_o;
  wire [9:0] n2967_o;
  wire [21:0] n2968_o;
  wire [8:0] n2969_o;
  wire [99:0] n2970_o;
  wire [4:0] n2972_o;
  wire [31:0] n2973_o;
  wire [10:0] n2974_o;
  wire [16:0] n2975_o;
  wire [9:0] n2976_o;
  wire [21:0] n2977_o;
  wire [8:0] n2978_o;
  wire [99:0] n2979_o;
  wire [4:0] n2981_o;
  wire [31:0] n2982_o;
  wire n2983_o;
  wire [10:0] n2984_o;
  wire [16:0] n2985_o;
  wire [9:0] n2986_o;
  wire [21:0] n2987_o;
  wire [8:0] n2988_o;
  wire [99:0] n2989_o;
  wire n2990_o;
  wire n2991_o;
  wire n2993_o;
  wire [10:0] n2994_o;
  wire [16:0] n2995_o;
  wire [9:0] n2996_o;
  wire [21:0] n2997_o;
  wire [8:0] n2998_o;
  wire [99:0] n2999_o;
  wire [7:0] n3001_o;
  wire [10:0] n3002_o;
  wire [16:0] n3003_o;
  wire [9:0] n3004_o;
  wire [21:0] n3005_o;
  wire [8:0] n3006_o;
  wire [99:0] n3007_o;
  wire [4:0] n3009_o;
  wire [10:0] n3011_o;
  wire [16:0] n3012_o;
  wire [9:0] n3013_o;
  wire [21:0] n3014_o;
  wire [8:0] n3015_o;
  wire [99:0] n3016_o;
  wire [4:0] n3018_o;
  wire [31:0] n3019_o;
  wire n3021_o;
  wire [10:0] n3023_o;
  wire [16:0] n3024_o;
  wire [9:0] n3025_o;
  wire [21:0] n3026_o;
  wire [8:0] n3027_o;
  wire [99:0] n3028_o;
  wire [4:0] n3030_o;
  wire [31:0] n3031_o;
  wire [31:0] n3033_o;
  wire [4:0] n3034_o;
  wire [4:0] n3035_o;
  wire [10:0] n3036_o;
  wire [6:0] n3037_o;
  wire [4:0] n3038_o;
  wire [9:0] n3039_o;
  wire [21:0] n3040_o;
  wire [8:0] n3041_o;
  wire [99:0] n3042_o;
  wire [4:0] n3044_o;
  wire [31:0] n3045_o;
  wire [10:0] n3046_o;
  wire [6:0] n3047_o;
  wire [4:0] n3048_o;
  wire [9:0] n3049_o;
  wire [21:0] n3050_o;
  wire [8:0] n3051_o;
  wire [99:0] n3052_o;
  wire [4:0] n3054_o;
  wire [31:0] n3055_o;
  wire n3056_o;
  wire n3058_o;
  wire n3059_o;
  wire n3060_o;
  wire n3061_o;
  wire n3062_o;
  wire n3063_o;
  wire [4:0] n3064_o;
  wire [4:0] n3065_o;
  wire n3066_o;
  wire [13:0] n3067_o;
  wire [13:0] n3069_o;
  wire [1:0] n3071_o;
  wire [1:0] n3072_o;
  wire [1:0] n3073_o;
  wire n3074_o;
  wire n3075_o;
  wire [4:0] n3076_o;
  wire [4:0] n3077_o;
  wire n3078_o;
  wire [13:0] n3080_o;
  wire [33:0] n3081_o;
  wire [9:0] n3082_o;
  wire [21:0] n3083_o;
  wire [8:0] n3084_o;
  wire [99:0] n3085_o;
  wire [3:0] n3087_o;
  wire [31:0] n3088_o;
  wire n3090_o;
  wire [33:0] n3091_o;
  wire [9:0] n3092_o;
  wire [21:0] n3093_o;
  wire [8:0] n3094_o;
  wire [99:0] n3095_o;
  wire [1:0] n3097_o;
  wire n3099_o;
  wire [33:0] n3100_o;
  wire [9:0] n3101_o;
  wire [21:0] n3102_o;
  wire [8:0] n3103_o;
  wire [99:0] n3104_o;
  wire [1:0] n3106_o;
  wire [31:0] n3107_o;
  wire n3109_o;
  wire [33:0] n3110_o;
  wire [9:0] n3111_o;
  wire [21:0] n3112_o;
  wire [8:0] n3113_o;
  wire [99:0] n3114_o;
  wire [6:0] n3115_o;
  wire [7:0] n3117_o;
  wire [33:0] n3118_o;
  wire [9:0] n3119_o;
  wire [21:0] n3120_o;
  wire [8:0] n3121_o;
  wire [99:0] n3122_o;
  wire [6:0] n3123_o;
  wire [7:0] n3125_o;
  wire [7:0] n3126_o;
  wire [7:0] n3127_o;
  wire [7:0] n3128_o;
  wire [1:0] n3129_o;
  wire [23:0] n3130_o;
  wire [9:0] n3131_o;
  wire [21:0] n3132_o;
  wire [8:0] n3133_o;
  wire [99:0] n3134_o;
  wire [1:0] n3136_o;
  wire [1:0] n3137_o;
  wire [23:0] n3138_o;
  wire [9:0] n3139_o;
  wire [21:0] n3140_o;
  wire [8:0] n3141_o;
  wire [99:0] n3142_o;
  wire n3143_o;
  wire n3144_o;
  wire [1:0] n3147_o;
  wire [1:0] n3148_o;
  wire [3:0] n3149_o;
  wire [3:0] n3150_o;
  wire n3152_o;
  wire [1:0] n3153_o;
  wire [23:0] n3154_o;
  wire [9:0] n3155_o;
  wire [21:0] n3156_o;
  wire [8:0] n3157_o;
  wire [99:0] n3158_o;
  wire [1:0] n3160_o;
  wire [31:0] n3161_o;
  wire n3163_o;
  wire [6:0] n3168_o;
  wire [1:0] n3169_o;
  wire [6:0] n3170_o;
  wire [6:0] n3171_o;
  wire n3173_o;
  wire [1:0] n3175_o;
  wire [2:0] n3176_o;
  wire [16:0] n3177_o;
  wire [9:0] n3178_o;
  wire [21:0] n3179_o;
  wire [8:0] n3180_o;
  wire [99:0] n3181_o;
  wire [2:0] n3183_o;
  wire [31:0] n3184_o;
  wire n3186_o;
  wire [1:0] n3188_o;
  wire [2:0] n3189_o;
  wire [16:0] n3190_o;
  wire [9:0] n3191_o;
  wire [21:0] n3192_o;
  wire [8:0] n3193_o;
  wire [99:0] n3194_o;
  wire [2:0] n3196_o;
  wire [31:0] n3197_o;
  wire [31:0] n3199_o;
  wire [2:0] n3200_o;
  wire [1:0] n3201_o;
  wire [1:0] n3202_o;
  wire [2:0] n3203_o;
  wire [2:0] n3204_o;
  wire n3206_o;
  wire [2:0] n3207_o;
  wire [1:0] n3208_o;
  reg [1:0] n3209_o;
  wire [2:0] n3210_o;
  wire [2:0] n3211_o;
  reg [2:0] n3212_o;
  wire [3:0] n3213_o;
  wire [3:0] n3214_o;
  reg [3:0] n3215_o;
  wire [33:0] n3217_o;
  wire [9:0] n3218_o;
  wire [21:0] n3219_o;
  wire [8:0] n3220_o;
  wire [99:0] n3221_o;
  wire [3:0] n3223_o;
  wire [31:0] n3224_o;
  wire [31:0] n3226_o;
  wire [3:0] n3227_o;
  wire [16:0] n3228_o;
  wire [12:0] n3229_o;
  wire [12:0] n3230_o;
  wire [12:0] n3231_o;
  wire [3:0] n3232_o;
  wire [3:0] n3233_o;
  wire [1:0] n3234_o;
  wire [1:0] n3235_o;
  wire [16:0] n3236_o;
  wire [6:0] n3237_o;
  wire [1:0] n3238_o;
  wire [1:0] n3239_o;
  wire [10:0] n3240_o;
  wire [10:0] n3241_o;
  wire [10:0] n3242_o;
  wire [3:0] n3243_o;
  wire [3:0] n3244_o;
  wire [3:0] n3245_o;
  wire [2:0] n3246_o;
  wire [2:0] n3247_o;
  wire [2:0] n3248_o;
  wire [1:0] n3249_o;
  wire [1:0] n3250_o;
  wire n3252_o;
  wire n3253_o;
  wire [13:0] n3255_o;
  wire [19:0] n3256_o;
  wire [6:0] n3257_o;
  wire [12:0] n3258_o;
  wire [12:0] n3259_o;
  wire [12:0] n3260_o;
  wire [3:0] n3261_o;
  wire [3:0] n3262_o;
  wire [2:0] n3263_o;
  wire [2:0] n3264_o;
  wire [2:0] n3265_o;
  wire [1:0] n3266_o;
  wire [1:0] n3267_o;
  wire [4:0] n3268_o;
  wire [4:0] n3269_o;
  wire [4:0] n3270_o;
  wire n3271_o;
  wire [13:0] n3273_o;
  wire [19:0] n3276_o;
  wire [6:0] n3277_o;
  wire [17:0] n3278_o;
  wire [7:0] n3279_o;
  wire [19:0] n3280_o;
  wire [19:0] n3281_o;
  wire [6:0] n3282_o;
  wire [6:0] n3283_o;
  wire [17:0] n3284_o;
  wire [17:0] n3285_o;
  wire [3:0] n3286_o;
  wire [3:0] n3287_o;
  wire [7:0] n3288_o;
  wire [7:0] n3289_o;
  wire n3290_o;
  wire n3291_o;
  wire n3292_o;
  wire [1:0] n3295_o;
  wire [4:0] n3297_o;
  wire [9:0] n3299_o;
  wire [12:0] n3301_o;
  wire [8:0] n3302_o;
  wire n3303_o;
  wire [13:0] n3305_o;
  wire [99:0] n3307_o;
  wire [11:0] n3308_o;
  wire [12:0] n3310_o;
  wire [12:0] n3312_o;
  wire [99:0] n3313_o;
  wire n3314_o;
  wire n3315_o;
  wire n3316_o;
  wire n3317_o;
  wire n3318_o;
  wire n3319_o;
  wire n3320_o;
  wire n3321_o;
  wire n3323_o;
  wire [99:0] n3324_o;
  wire [4:0] n3326_o;
  wire [31:0] n3327_o;
  wire [99:0] n3328_o;
  wire [4:0] n3330_o;
  wire [31:0] n3331_o;
  wire n3332_o;
  wire [99:0] n3333_o;
  wire n3335_o;
  wire n3336_o;
  wire [99:0] n3337_o;
  wire [4:0] n3339_o;
  wire n3344_o;
  wire [99:0] n3345_o;
  wire [4:0] n3347_o;
  wire [31:0] n3348_o;
  wire n3350_o;
  wire n3352_o;
  wire [99:0] n3353_o;
  wire [4:0] n3355_o;
  wire [31:0] n3356_o;
  wire [31:0] n3358_o;
  wire [4:0] n3359_o;
  wire [4:0] n3360_o;
  wire n3362_o;
  wire n3363_o;
  wire [4:0] n3364_o;
  wire [7:0] n3365_o;
  wire [7:0] n3366_o;
  wire [99:0] n3367_o;
  wire n3369_o;
  wire [1:0] n3371_o;
  wire [99:0] n3372_o;
  wire n3374_o;
  wire [2:0] n3375_o;
  wire [99:0] n3376_o;
  wire n3377_o;
  wire [3:0] n3378_o;
  wire [99:0] n3379_o;
  wire n3381_o;
  wire [4:0] n3382_o;
  wire [5:0] n3383_o;
  wire [99:0] n3384_o;
  wire n3386_o;
  wire [6:0] n3387_o;
  wire n3388_o;
  wire [7:0] n3389_o;
  wire [1:0] n3392_o;
  wire n3394_o;
  wire [1:0] n3395_o;
  wire [1:0] n3396_o;
  wire n3397_o;
  wire [7:0] n3398_o;
  wire [2:0] n3400_o;
  wire [8:0] n3401_o;
  wire [2:0] n3402_o;
  wire [2:0] n3403_o;
  wire n3404_o;
  wire [7:0] n3405_o;
  wire [8:0] n3406_o;
  wire [8:0] n3407_o;
  wire [16:0] n3408_o;
  wire n3409_o;
  wire [99:0] n3410_o;
  wire n3411_o;
  wire n3412_o;
  wire n3413_o;
  wire n3414_o;
  wire n3415_o;
  wire n3416_o;
  wire n3417_o;
  wire n3419_o;
  wire [99:0] n3420_o;
  wire n3422_o;
  wire [7:0] n3424_o;
  wire [99:0] n3425_o;
  wire [3:0] n3427_o;
  wire [99:0] n3429_o;
  wire [3:0] n3431_o;
  wire [31:0] n3432_o;
  wire n3434_o;
  wire [99:0] n3436_o;
  wire [3:0] n3438_o;
  wire [31:0] n3439_o;
  wire [31:0] n3441_o;
  wire [3:0] n3442_o;
  wire [3:0] n3443_o;
  wire [5:0] n3444_o;
  wire [99:0] n3445_o;
  wire [3:0] n3447_o;
  wire [31:0] n3448_o;
  wire [5:0] n3449_o;
  wire [99:0] n3450_o;
  wire [3:0] n3452_o;
  wire [31:0] n3453_o;
  wire n3454_o;
  wire n3456_o;
  wire n3457_o;
  wire n3458_o;
  wire n3459_o;
  wire n3460_o;
  wire n3461_o;
  wire [3:0] n3462_o;
  wire [3:0] n3463_o;
  wire [12:0] n3464_o;
  wire [12:0] n3466_o;
  wire n3467_o;
  wire [7:0] n3471_o;
  wire n3472_o;
  wire n3473_o;
  wire [3:0] n3474_o;
  wire [7:0] n3475_o;
  wire [7:0] n3476_o;
  wire n3477_o;
  wire [9:0] n3481_o;
  wire n3482_o;
  wire n3483_o;
  wire [4:0] n3484_o;
  wire [9:0] n3485_o;
  wire [9:0] n3486_o;
  wire n3487_o;
  wire [1:0] n3488_o;
  wire n3489_o;
  wire n3490_o;
  wire [4:0] n3491_o;
  wire [9:0] n3492_o;
  wire [9:0] n3493_o;
  wire n3494_o;
  wire n3495_o;
  wire n3496_o;
  wire n3497_o;
  wire n3498_o;
  wire [3:0] n3499_o;
  wire [3:0] n3500_o;
  wire [3:0] n3501_o;
  wire [3:0] n3502_o;
  wire n3503_o;
  wire [12:0] n3505_o;
  wire [1:0] n3507_o;
  wire [7:0] n3508_o;
  wire n3509_o;
  wire n3510_o;
  wire [4:0] n3511_o;
  wire [9:0] n3512_o;
  wire [9:0] n3513_o;
  wire n3514_o;
  wire n3515_o;
  wire [1:0] n3516_o;
  wire [1:0] n3517_o;
  wire [3:0] n3518_o;
  wire [7:0] n3519_o;
  wire [7:0] n3520_o;
  wire n3521_o;
  wire n3522_o;
  wire n3523_o;
  wire [1:0] n3524_o;
  wire [1:0] n3525_o;
  wire [16:0] n3526_o;
  wire [4:0] n3528_o;
  wire [7:0] n3529_o;
  wire [12:0] n3531_o;
  wire n3533_o;
  wire [99:0] n3534_o;
  wire n3535_o;
  wire [1:0] n3536_o;
  wire [99:0] n3537_o;
  wire n3550_o;
  wire [3:0] n3551_o;
  wire [7:0] n3555_o;
  wire n3558_o;
  wire [4:0] n3559_o;
  wire [7:0] n3563_o;
  wire [9:0] n3569_o;
  wire n3570_o;
  reg [99:0] n3571_q;
  wire [7:0] n3576_data; // mem_rd
  wire [7:0] n3578_data; // mem_rd
  assign y_d = n2558_o; //(module output)
  assign y_ack = n2559_o; //(module output)
  assign y_int = n2560_o; //(module output)
  assign tx = n3570_o; //(module output)
  assign n2556_o = {a_we, a_en, a_d, a_dc};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/ref_devices__aic_edgedet.vhd:21:17  */
  assign n2558_o = n3569_o[7:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/ref_devices__aic_edgedet.vhd:21:17  */
  assign n2559_o = n3569_o[8]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/ref_devices__aic_edgedet.vhd:21:17  */
  assign n2560_o = n3569_o[9]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:21:8  */
  assign this_c = n3537_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:22:8  */
  always @*
    this_r = n3571_q; // (isignal)
  initial
    this_r = 100'b0000000000010100000000000000000000000000000000000111100000000000000000000000000000011110000000000000;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:24:8  */
  assign rxfw = n3305_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:26:8  */
  assign txfw = n3531_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:45:19  */
  assign n2578_o = this_r[28:24]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:45:22  */
  assign n2579_o = {27'b0, n2578_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:45:33  */
  assign n2581_o = this_r[33:29]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:45:22  */
  assign n2582_o = {27'b0, n2581_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:45:22  */
  assign n2583_o = n2579_o == n2582_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:45:48  */
  assign n2585_o = this_r[17]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:45:53  */
  assign n2586_o = ~n2585_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:45:36  */
  assign n2587_o = n2586_o & n2583_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:45:7  */
  assign n2590_o = n2587_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:46:19  */
  assign n2593_o = this_r[61:58]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:46:22  */
  assign n2594_o = {28'b0, n2593_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:46:33  */
  assign n2596_o = this_r[65:62]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:46:22  */
  assign n2597_o = {28'b0, n2596_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:46:22  */
  assign n2598_o = n2594_o == n2597_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:46:48  */
  assign n2600_o = this_r[51]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:46:53  */
  assign n2601_o = ~n2600_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:46:36  */
  assign n2602_o = n2601_o & n2598_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:46:7  */
  assign n2605_o = n2602_o ? 1'b1 : 1'b0;
  assign n2610_o = this_r[97:0]; // extract
  assign n2611_o = {1'b0, 1'b0, n2610_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:52:18  */
  assign n2612_o = n2611_o[78]; // extract
  assign n2613_o = {1'b0, 1'b0, n2610_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:54:21  */
  assign n2615_o = n2613_o[50:47]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:54:25  */
  assign n2616_o = {28'b0, n2615_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:54:25  */
  assign n2618_o = n2616_o == 32'b00000000000000000000000000001111;
  assign n2619_o = {1'b0, 1'b0, n2610_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:56:26  */
  assign n2621_o = n2619_o[35:34]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:57:13  */
  assign n2624_o = n2621_o == 2'b00;
  assign n2626_o = this_r[87:0]; // extract
  assign n2627_o = this_r[97:89]; // extract
  assign n2628_o = {1'b0, 1'b0, n2627_o, 1'b0, n2626_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:60:43  */
  assign n2630_o = n2628_o[65:62]; // extract
  assign n2635_o = this_r[35:0]; // extract
  assign n2636_o = this_r[87:44]; // extract
  assign n2637_o = this_r[97:89]; // extract
  assign n2638_o = {1'b0, 1'b0, n2637_o, 1'b0, n2636_o, n3576_data, n2635_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:61:28  */
  assign n2640_o = n2638_o[65:62]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:61:31  */
  assign n2641_o = {28'b0, n2640_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:61:31  */
  assign n2643_o = n2641_o == 32'b00000000000000000000000000001111;
  assign n2645_o = this_r[35:0]; // extract
  assign n2646_o = this_r[87:44]; // extract
  assign n2647_o = this_r[97:89]; // extract
  assign n2648_o = {1'b0, 1'b0, n2647_o, 1'b0, n2646_o, n3576_data, n2645_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:64:43  */
  assign n2650_o = n2648_o[65:62]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:64:46  */
  assign n2651_o = {28'b0, n2650_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:64:46  */
  assign n2653_o = n2651_o + 32'b00000000000000000000000000000001;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:64:19  */
  assign n2654_o = n2653_o[3:0];  // trunc
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:61:16  */
  assign n2655_o = n2643_o ? 4'b0000 : n2654_o;
  assign n2657_o = this_r[35:0]; // extract
  assign n2658_o = this_r[50:44]; // extract
  assign n2659_o = this_r[61:52]; // extract
  assign n2660_o = this_r[87:66]; // extract
  assign n2661_o = this_r[97:89]; // extract
  assign n2662_o = {1'b0, 1'b0, n2661_o, 1'b0, n2660_o, n2655_o, n2659_o, 1'b0, n2658_o, n3576_data, n2657_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:67:28  */
  assign n2664_o = n2662_o[61:58]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:67:31  */
  assign n2665_o = {28'b0, n2664_o};  //  uext
  assign n2666_o = this_r[35:0]; // extract
  assign n2667_o = this_r[50:44]; // extract
  assign n2668_o = this_r[61:52]; // extract
  assign n2669_o = this_r[87:66]; // extract
  assign n2670_o = this_r[97:89]; // extract
  assign n2671_o = {1'b0, 1'b0, n2670_o, 1'b0, n2669_o, n2655_o, n2668_o, 1'b0, n2667_o, n3576_data, n2666_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:67:42  */
  assign n2673_o = n2671_o[65:62]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:67:31  */
  assign n2674_o = {28'b0, n2673_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:67:31  */
  assign n2675_o = n2665_o == n2674_o;
  assign n2676_o = this_r[35:0]; // extract
  assign n2677_o = this_r[50:44]; // extract
  assign n2678_o = this_r[61:52]; // extract
  assign n2679_o = this_r[87:66]; // extract
  assign n2680_o = this_r[97:89]; // extract
  assign n2681_o = {1'b0, 1'b0, n2680_o, 1'b0, n2679_o, n2655_o, n2678_o, 1'b0, n2677_o, n3576_data, n2676_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:67:54  */
  assign n2682_o = n2681_o[87]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:67:45  */
  assign n2683_o = n2682_o & n2675_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:67:16  */
  assign n2685_o = n2683_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:58:13  */
  assign n2687_o = n2621_o == 2'b01;
  assign n2688_o = {1'b0, 1'b0, n2610_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:69:38  */
  assign n2689_o = n2688_o[36]; // extract
  assign n2690_o = this_r[87:0]; // extract
  assign n2691_o = this_r[97:89]; // extract
  assign n2692_o = {1'b0, 1'b0, n2691_o, n2689_o, n2690_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:70:46  */
  assign n2693_o = n2692_o[43:37]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:70:34  */
  assign n2695_o = {1'b0, n2693_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:68:13  */
  assign n2697_o = n2621_o == 2'b10;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:71:13  */
  assign n2700_o = n2621_o == 2'b11;
  assign n2701_o = {n2700_o, n2697_o, n2687_o, n2624_o};
  assign n2702_o = this_r[43:36]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:56:13  */
  always @*
    case (n2701_o)
      4'b1000: n2704_o = n2702_o;
      4'b0100: n2704_o = n2695_o;
      4'b0010: n2704_o = n3576_data;
      4'b0001: n2704_o = n2702_o;
      default: n2704_o = 8'bX;
    endcase
  assign n2705_o = this_r[51]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:56:13  */
  always @*
    case (n2701_o)
      4'b1000: n2707_o = n2705_o;
      4'b0100: n2707_o = n2705_o;
      4'b0010: n2707_o = 1'b0;
      4'b0001: n2707_o = n2705_o;
      default: n2707_o = 1'bX;
    endcase
  assign n2708_o = this_r[65:62]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:56:13  */
  always @*
    case (n2701_o)
      4'b1000: n2710_o = n2708_o;
      4'b0100: n2710_o = n2708_o;
      4'b0010: n2710_o = n2655_o;
      4'b0001: n2710_o = n2708_o;
      default: n2710_o = 4'bX;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:56:13  */
  always @*
    case (n2701_o)
      4'b1000: n2712_o = 1'b1;
      4'b0100: n2712_o = n2689_o;
      4'b0010: n2712_o = 1'b0;
      4'b0001: n2712_o = 1'b1;
      default: n2712_o = 1'bX;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:56:13  */
  always @*
    case (n2701_o)
      4'b1000: n2714_o = 1'b0;
      4'b0100: n2714_o = 1'b0;
      4'b0010: n2714_o = n2685_o;
      4'b0001: n2714_o = 1'b0;
      default: n2714_o = 1'bX;
    endcase
  assign n2715_o = this_r[35:0]; // extract
  assign n2716_o = this_r[50:44]; // extract
  assign n2717_o = this_r[61:52]; // extract
  assign n2718_o = this_r[87:66]; // extract
  assign n2719_o = this_r[97:89]; // extract
  assign n2720_o = {n2714_o, 1'b0, n2719_o, n2712_o, n2718_o, n2710_o, n2717_o, n2707_o, n2716_o, n2704_o, n2715_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:75:26  */
  assign n2722_o = n2720_o[35:34]; // extract
  assign n2723_o = this_r[35:0]; // extract
  assign n2724_o = this_r[50:44]; // extract
  assign n2725_o = this_r[61:52]; // extract
  assign n2726_o = this_r[87:66]; // extract
  assign n2727_o = this_r[97:89]; // extract
  assign n2728_o = {n2714_o, 1'b0, n2727_o, n2712_o, n2726_o, n2710_o, n2725_o, n2707_o, n2724_o, n2704_o, n2723_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:77:28  */
  assign n2730_o = n2728_o[61:58]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:77:31  */
  assign n2731_o = {28'b0, n2730_o};  //  uext
  assign n2732_o = this_r[35:0]; // extract
  assign n2733_o = this_r[50:44]; // extract
  assign n2734_o = this_r[61:52]; // extract
  assign n2735_o = this_r[87:66]; // extract
  assign n2736_o = this_r[97:89]; // extract
  assign n2737_o = {n2714_o, 1'b0, n2736_o, n2712_o, n2735_o, n2710_o, n2734_o, n2707_o, n2733_o, n2704_o, n2732_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:77:43  */
  assign n2739_o = n2737_o[65:62]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:77:31  */
  assign n2740_o = {28'b0, n2739_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:77:31  */
  assign n2741_o = n2731_o != n2740_o;
  assign n2742_o = this_r[35:0]; // extract
  assign n2743_o = this_r[50:44]; // extract
  assign n2744_o = this_r[61:52]; // extract
  assign n2745_o = this_r[87:66]; // extract
  assign n2746_o = this_r[97:89]; // extract
  assign n2747_o = {n2714_o, 1'b0, n2746_o, n2712_o, n2745_o, n2710_o, n2744_o, n2707_o, n2743_o, n2704_o, n2742_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:77:57  */
  assign n2749_o = n2747_o[51]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:77:46  */
  assign n2750_o = n2741_o | n2749_o;
  assign n2753_o = this_r[35:34]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:77:16  */
  assign n2754_o = n2750_o ? 2'b01 : n2753_o;
  assign n2755_o = this_r[50:47]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:77:16  */
  assign n2756_o = n2750_o ? 4'b0000 : n2755_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:76:13  */
  assign n2758_o = n2722_o == 2'b00;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:81:13  */
  assign n2763_o = n2722_o == 2'b01;
  assign n2764_o = this_r[35:0]; // extract
  assign n2765_o = this_r[50:44]; // extract
  assign n2766_o = this_r[61:52]; // extract
  assign n2767_o = this_r[87:66]; // extract
  assign n2768_o = this_r[97:89]; // extract
  assign n2769_o = {n2714_o, 1'b0, n2768_o, n2712_o, n2767_o, n2710_o, n2766_o, n2707_o, n2765_o, n2704_o, n2764_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:86:27  */
  assign n2771_o = n2769_o[46:44]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:86:29  */
  assign n2772_o = {29'b0, n2771_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:86:29  */
  assign n2774_o = n2772_o == 32'b00000000000000000000000000000111;
  assign n2776_o = this_r[35:0]; // extract
  assign n2777_o = this_r[50:44]; // extract
  assign n2778_o = this_r[61:52]; // extract
  assign n2779_o = this_r[87:66]; // extract
  assign n2780_o = this_r[97:89]; // extract
  assign n2781_o = {n2714_o, 1'b0, n2780_o, n2712_o, n2779_o, n2710_o, n2778_o, n2707_o, n2777_o, n2704_o, n2776_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:89:40  */
  assign n2783_o = n2781_o[46:44]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:89:42  */
  assign n2784_o = {29'b0, n2783_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:89:42  */
  assign n2786_o = n2784_o + 32'b00000000000000000000000000000001;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:89:19  */
  assign n2787_o = n2786_o[2:0];  // trunc
  assign n2788_o = this_r[35:34]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:86:16  */
  assign n2789_o = n2774_o ? 2'b11 : n2788_o;
  assign n2790_o = this_r[46:44]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:86:16  */
  assign n2791_o = n2774_o ? n2790_o : n2787_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:85:13  */
  assign n2794_o = n2722_o == 2'b10;
  assign n2795_o = this_r[35:0]; // extract
  assign n2796_o = this_r[50:44]; // extract
  assign n2797_o = this_r[61:52]; // extract
  assign n2798_o = this_r[87:66]; // extract
  assign n2799_o = this_r[97:89]; // extract
  assign n2800_o = {n2714_o, 1'b0, n2799_o, n2712_o, n2798_o, n2710_o, n2797_o, n2707_o, n2796_o, n2704_o, n2795_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:93:28  */
  assign n2802_o = n2800_o[61:58]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:93:31  */
  assign n2803_o = {28'b0, n2802_o};  //  uext
  assign n2804_o = this_r[35:0]; // extract
  assign n2805_o = this_r[50:44]; // extract
  assign n2806_o = this_r[61:52]; // extract
  assign n2807_o = this_r[87:66]; // extract
  assign n2808_o = this_r[97:89]; // extract
  assign n2809_o = {n2714_o, 1'b0, n2808_o, n2712_o, n2807_o, n2710_o, n2806_o, n2707_o, n2805_o, n2704_o, n2804_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:93:43  */
  assign n2811_o = n2809_o[65:62]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:93:31  */
  assign n2812_o = {28'b0, n2811_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:93:31  */
  assign n2813_o = n2803_o != n2812_o;
  assign n2814_o = this_r[35:0]; // extract
  assign n2815_o = this_r[50:44]; // extract
  assign n2816_o = this_r[61:52]; // extract
  assign n2817_o = this_r[87:66]; // extract
  assign n2818_o = this_r[97:89]; // extract
  assign n2819_o = {n2714_o, 1'b0, n2818_o, n2712_o, n2817_o, n2710_o, n2816_o, n2707_o, n2815_o, n2704_o, n2814_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:93:57  */
  assign n2821_o = n2819_o[51]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:93:46  */
  assign n2822_o = n2813_o | n2821_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:93:16  */
  assign n2826_o = n2822_o ? 2'b01 : 2'b00;
  assign n2827_o = this_r[50:47]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:93:16  */
  assign n2828_o = n2822_o ? 4'b0000 : n2827_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:92:13  */
  assign n2830_o = n2722_o == 2'b11;
  assign n2831_o = {n2830_o, n2794_o, n2763_o, n2758_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:75:13  */
  always @*
    case (n2831_o)
      4'b1000: n2833_o = n2826_o;
      4'b0100: n2833_o = n2789_o;
      4'b0010: n2833_o = 2'b10;
      4'b0001: n2833_o = n2754_o;
      default: n2833_o = 2'bX;
    endcase
  assign n2834_o = this_r[46:44]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:75:13  */
  always @*
    case (n2831_o)
      4'b1000: n2836_o = n2834_o;
      4'b0100: n2836_o = n2791_o;
      4'b0010: n2836_o = 3'b000;
      4'b0001: n2836_o = n2834_o;
      default: n2836_o = 3'bX;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:75:13  */
  always @*
    case (n2831_o)
      4'b1000: n2838_o = n2828_o;
      4'b0100: n2838_o = 4'b0000;
      4'b0010: n2838_o = 4'b0000;
      4'b0001: n2838_o = n2756_o;
      default: n2838_o = 4'bX;
    endcase
  assign n2839_o = {1'b0, 1'b0, n2610_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:101:36  */
  assign n2841_o = n2839_o[50:47]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:101:40  */
  assign n2842_o = {28'b0, n2841_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:101:40  */
  assign n2844_o = n2842_o + 32'b00000000000000000000000000000001;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:101:13  */
  assign n2845_o = n2844_o[3:0];  // trunc
  assign n2846_o = {n2707_o, n2838_o, n2836_o, n2704_o, n2833_o};
  assign n2847_o = n2846_o[12:0]; // extract
  assign n2848_o = this_r[46:34]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:54:10  */
  assign n2849_o = n2618_o ? n2847_o : n2848_o;
  assign n2850_o = n2846_o[16:13]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:54:10  */
  assign n2851_o = n2618_o ? n2850_o : n2845_o;
  assign n2852_o = n2846_o[17]; // extract
  assign n2853_o = this_r[51]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:54:10  */
  assign n2854_o = n2618_o ? n2852_o : n2853_o;
  assign n2855_o = this_r[65:62]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:54:10  */
  assign n2856_o = n2618_o ? n2710_o : n2855_o;
  assign n2857_o = this_r[88]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:54:10  */
  assign n2858_o = n2618_o ? n2712_o : n2857_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:54:10  */
  assign n2859_o = n2618_o ? n2714_o : 1'b0;
  assign n2860_o = this_r[33:0]; // extract
  assign n2861_o = this_r[61:52]; // extract
  assign n2862_o = this_r[87:66]; // extract
  assign n2863_o = this_r[97:89]; // extract
  assign n2864_o = {n2859_o, 1'b0, n2863_o, n2858_o, n2862_o, n2856_o, n2861_o, n2854_o, n2851_o, n2849_o, n2860_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:104:21  */
  assign n2866_o = n2864_o[16:13]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:104:25  */
  assign n2867_o = {28'b0, n2866_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:104:25  */
  assign n2869_o = n2867_o == 32'b00000000000000000000000000000111;
  assign n2870_o = this_r[33:0]; // extract
  assign n2871_o = this_r[61:52]; // extract
  assign n2872_o = this_r[87:66]; // extract
  assign n2873_o = this_r[97:89]; // extract
  assign n2874_o = {n2859_o, 1'b0, n2873_o, n2858_o, n2872_o, n2856_o, n2871_o, n2854_o, n2851_o, n2849_o, n2870_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:104:40  */
  assign n2876_o = n2874_o[16:13]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:104:44  */
  assign n2877_o = {28'b0, n2876_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:104:44  */
  assign n2879_o = n2877_o == 32'b00000000000000000000000000001000;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:104:29  */
  assign n2880_o = n2869_o | n2879_o;
  assign n2881_o = this_r[33:0]; // extract
  assign n2882_o = this_r[61:52]; // extract
  assign n2883_o = this_r[87:66]; // extract
  assign n2884_o = this_r[97:89]; // extract
  assign n2885_o = {n2859_o, 1'b0, n2884_o, n2858_o, n2883_o, n2856_o, n2882_o, n2854_o, n2851_o, n2849_o, n2881_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:104:59  */
  assign n2887_o = n2885_o[16:13]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:104:63  */
  assign n2888_o = {28'b0, n2887_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:104:63  */
  assign n2890_o = n2888_o == 32'b00000000000000000000000000001001;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:104:48  */
  assign n2891_o = n2880_o | n2890_o;
  assign n2892_o = this_r[33:0]; // extract
  assign n2893_o = this_r[61:52]; // extract
  assign n2894_o = this_r[87:66]; // extract
  assign n2895_o = this_r[97:89]; // extract
  assign n2896_o = {n2859_o, 1'b0, n2895_o, n2858_o, n2894_o, n2856_o, n2893_o, n2854_o, n2851_o, n2849_o, n2892_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:106:25  */
  assign n2897_o = n2896_o[21]; // extract
  assign n2898_o = this_r[33:0]; // extract
  assign n2899_o = this_r[61:52]; // extract
  assign n2900_o = this_r[87:66]; // extract
  assign n2901_o = this_r[97:89]; // extract
  assign n2902_o = {n2859_o, 1'b0, n2901_o, n2858_o, n2900_o, n2856_o, n2899_o, n2854_o, n2851_o, n2849_o, n2898_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:106:61  */
  assign n2904_o = n2902_o[23:22]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:106:63  */
  assign n2905_o = {30'b0, n2904_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:106:63  */
  assign n2907_o = n2905_o + 32'b00000000000000000000000000000001;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:106:40  */
  assign n2908_o = n2907_o[1:0];  // trunc
  assign n2909_o = this_r[23:22]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:106:13  */
  assign n2910_o = n2897_o ? n2908_o : n2909_o;
  assign n2911_o = this_r[21:0]; // extract
  assign n2912_o = this_r[33:24]; // extract
  assign n2913_o = this_r[61:52]; // extract
  assign n2914_o = this_r[87:66]; // extract
  assign n2915_o = this_r[97:89]; // extract
  assign n2916_o = {n2859_o, 1'b0, n2915_o, n2858_o, n2914_o, n2856_o, n2913_o, n2854_o, n2851_o, n2849_o, n2912_o, n2910_o, n2911_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:107:36  */
  assign n2918_o = n2916_o[16:13]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:107:40  */
  assign n2919_o = {28'b0, n2918_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:107:40  */
  assign n2921_o = n2919_o + 32'b00000000000000000000000000000001;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:107:13  */
  assign n2922_o = n2921_o[3:0];  // trunc
  assign n2923_o = this_r[33:0]; // extract
  assign n2924_o = this_r[61:52]; // extract
  assign n2925_o = this_r[87:66]; // extract
  assign n2926_o = this_r[97:89]; // extract
  assign n2927_o = {n2859_o, 1'b0, n2926_o, n2858_o, n2925_o, n2856_o, n2924_o, n2854_o, n2851_o, n2849_o, n2923_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:108:24  */
  assign n2929_o = n2927_o[16:13]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:108:28  */
  assign n2930_o = {28'b0, n2929_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:108:28  */
  assign n2932_o = n2930_o == 32'b00000000000000000000000000001010;
  assign n2933_o = this_r[33:0]; // extract
  assign n2934_o = this_r[61:52]; // extract
  assign n2935_o = this_r[87:66]; // extract
  assign n2936_o = this_r[97:89]; // extract
  assign n2937_o = {n2859_o, 1'b0, n2936_o, n2858_o, n2935_o, n2856_o, n2934_o, n2854_o, n2851_o, n2849_o, n2933_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:108:45  */
  assign n2939_o = n2937_o[1:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:108:47  */
  assign n2941_o = n2939_o == 2'b11;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:108:33  */
  assign n2942_o = n2941_o & n2932_o;
  assign n2945_o = this_r[12:2]; // extract
  assign n2946_o = this_r[33:17]; // extract
  assign n2947_o = this_r[61:52]; // extract
  assign n2948_o = this_r[87:66]; // extract
  assign n2949_o = this_r[97:89]; // extract
  assign n2950_o = {n2859_o, 1'b0, n2949_o, n2858_o, n2948_o, n2856_o, n2947_o, n2854_o, n2851_o, n2849_o, n2946_o, 4'b1111, n2945_o, 2'b00};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:112:24  */
  assign n2952_o = n2950_o[23:22]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:112:26  */
  assign n2953_o = {30'b0, n2952_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:112:26  */
  assign n2955_o = $signed(n2953_o) > $signed(32'b00000000000000000000000000000001);
  assign n2956_o = this_r[12:2]; // extract
  assign n2957_o = this_r[33:17]; // extract
  assign n2958_o = this_r[61:52]; // extract
  assign n2959_o = this_r[87:66]; // extract
  assign n2960_o = this_r[97:89]; // extract
  assign n2961_o = {n2859_o, 1'b0, n2960_o, n2858_o, n2959_o, n2856_o, n2958_o, n2854_o, n2851_o, n2849_o, n2957_o, 4'b1111, n2956_o, 2'b00};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:113:27  */
  assign n2963_o = n2961_o[17]; // extract
  assign n2965_o = this_r[12:2]; // extract
  assign n2966_o = this_r[33:17]; // extract
  assign n2967_o = this_r[61:52]; // extract
  assign n2968_o = this_r[87:66]; // extract
  assign n2969_o = this_r[97:89]; // extract
  assign n2970_o = {n2859_o, 1'b0, n2969_o, n2858_o, n2968_o, n2856_o, n2967_o, n2854_o, n2851_o, n2849_o, n2966_o, 4'b1111, n2965_o, 2'b00};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:118:34  */
  assign n2972_o = n2970_o[28:24]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:118:37  */
  assign n2973_o = {27'b0, n2972_o};  //  uext
  assign n2974_o = this_r[12:2]; // extract
  assign n2975_o = this_r[33:17]; // extract
  assign n2976_o = this_r[61:52]; // extract
  assign n2977_o = this_r[87:66]; // extract
  assign n2978_o = this_r[97:89]; // extract
  assign n2979_o = {n2859_o, 1'b0, n2978_o, n2858_o, n2977_o, n2856_o, n2976_o, n2854_o, n2851_o, n2849_o, n2975_o, 4'b1111, n2974_o, 2'b00};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:118:48  */
  assign n2981_o = n2979_o[33:29]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:118:37  */
  assign n2982_o = {27'b0, n2981_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:118:37  */
  assign n2983_o = n2973_o == n2982_o;
  assign n2984_o = this_r[12:2]; // extract
  assign n2985_o = this_r[33:17]; // extract
  assign n2986_o = this_r[61:52]; // extract
  assign n2987_o = this_r[87:66]; // extract
  assign n2988_o = this_r[97:89]; // extract
  assign n2989_o = {n2859_o, 1'b0, n2988_o, n2858_o, n2987_o, n2856_o, n2986_o, n2854_o, n2851_o, n2849_o, n2985_o, 4'b1111, n2984_o, 2'b00};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:118:60  */
  assign n2990_o = n2989_o[87]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:118:51  */
  assign n2991_o = n2990_o & n2983_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:118:22  */
  assign n2993_o = n2991_o ? 1'b1 : n2859_o;
  assign n2994_o = this_r[12:2]; // extract
  assign n2995_o = this_r[33:17]; // extract
  assign n2996_o = this_r[61:52]; // extract
  assign n2997_o = this_r[87:66]; // extract
  assign n2998_o = this_r[97:89]; // extract
  assign n2999_o = {n2993_o, 1'b0, n2998_o, n2858_o, n2997_o, n2856_o, n2996_o, n2854_o, n2851_o, n2849_o, n2995_o, 4'b1111, n2994_o, 2'b00};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:125:36  */
  assign n3001_o = n2999_o[9:2]; // extract
  assign n3002_o = this_r[12:2]; // extract
  assign n3003_o = this_r[33:17]; // extract
  assign n3004_o = this_r[61:52]; // extract
  assign n3005_o = this_r[87:66]; // extract
  assign n3006_o = this_r[97:89]; // extract
  assign n3007_o = {n2993_o, 1'b0, n3006_o, n2858_o, n3005_o, n2856_o, n3004_o, n2854_o, n2851_o, n2849_o, n3003_o, 4'b1111, n3002_o, 2'b00};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:126:37  */
  assign n3009_o = n3007_o[28:24]; // extract
  assign n3011_o = this_r[12:2]; // extract
  assign n3012_o = this_r[33:17]; // extract
  assign n3013_o = this_r[61:52]; // extract
  assign n3014_o = this_r[87:66]; // extract
  assign n3015_o = this_r[97:89]; // extract
  assign n3016_o = {n2993_o, 1'b0, n3015_o, n2858_o, n3014_o, n2856_o, n3013_o, n2854_o, n2851_o, n2849_o, n3012_o, 4'b1111, n3011_o, 2'b00};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:128:31  */
  assign n3018_o = n3016_o[28:24]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:128:34  */
  assign n3019_o = {27'b0, n3018_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:128:34  */
  assign n3021_o = n3019_o == 32'b00000000000000000000000000011111;
  assign n3023_o = this_r[12:2]; // extract
  assign n3024_o = this_r[33:17]; // extract
  assign n3025_o = this_r[61:52]; // extract
  assign n3026_o = this_r[87:66]; // extract
  assign n3027_o = this_r[97:89]; // extract
  assign n3028_o = {n2993_o, 1'b0, n3027_o, n2858_o, n3026_o, n2856_o, n3025_o, n2854_o, n2851_o, n2849_o, n3024_o, 4'b1111, n3023_o, 2'b00};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:131:46  */
  assign n3030_o = n3028_o[28:24]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:131:49  */
  assign n3031_o = {27'b0, n3030_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:131:49  */
  assign n3033_o = n3031_o + 32'b00000000000000000000000000000001;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:131:22  */
  assign n3034_o = n3033_o[4:0];  // trunc
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:128:19  */
  assign n3035_o = n3021_o ? 5'b00000 : n3034_o;
  assign n3036_o = this_r[12:2]; // extract
  assign n3037_o = this_r[23:17]; // extract
  assign n3038_o = this_r[33:29]; // extract
  assign n3039_o = this_r[61:52]; // extract
  assign n3040_o = this_r[87:66]; // extract
  assign n3041_o = this_r[97:89]; // extract
  assign n3042_o = {n2993_o, 1'b0, n3041_o, n2858_o, n3040_o, n2856_o, n3039_o, n2854_o, n2851_o, n2849_o, n3038_o, n3035_o, n3037_o, 4'b1111, n3036_o, 2'b00};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:133:31  */
  assign n3044_o = n3042_o[28:24]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:133:34  */
  assign n3045_o = {27'b0, n3044_o};  //  uext
  assign n3046_o = this_r[12:2]; // extract
  assign n3047_o = this_r[23:17]; // extract
  assign n3048_o = this_r[33:29]; // extract
  assign n3049_o = this_r[61:52]; // extract
  assign n3050_o = this_r[87:66]; // extract
  assign n3051_o = this_r[97:89]; // extract
  assign n3052_o = {n2993_o, 1'b0, n3051_o, n2858_o, n3050_o, n2856_o, n3049_o, n2854_o, n2851_o, n2849_o, n3048_o, n3035_o, n3047_o, 4'b1111, n3046_o, 2'b00};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:133:45  */
  assign n3054_o = n3052_o[33:29]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:133:34  */
  assign n3055_o = {27'b0, n3054_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:133:34  */
  assign n3056_o = n3045_o == n3055_o;
  assign n3058_o = this_r[17]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:133:19  */
  assign n3059_o = n3056_o ? 1'b1 : n3058_o;
  assign n3060_o = this_r[17]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:113:16  */
  assign n3061_o = n2963_o ? n3060_o : n3059_o;
  assign n3062_o = this_r[18]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:113:16  */
  assign n3063_o = n2963_o ? 1'b1 : n3062_o;
  assign n3064_o = this_r[28:24]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:113:16  */
  assign n3065_o = n2963_o ? n3064_o : n3035_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:113:16  */
  assign n3066_o = n2963_o ? n2859_o : n2993_o;
  assign n3067_o = {1'b1, n3001_o, n3009_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:113:16  */
  assign n3069_o = n2963_o ? 14'b00000000000000 : n3067_o;
  assign n3071_o = {n3063_o, n3061_o};
  assign n3072_o = this_r[18:17]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:112:13  */
  assign n3073_o = n2955_o ? n3071_o : n3072_o;
  assign n3074_o = this_r[19]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:112:13  */
  assign n3075_o = n2955_o ? n3074_o : 1'b1;
  assign n3076_o = this_r[28:24]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:108:10  */
  assign n3077_o = n3252_o ? n3065_o : n3076_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:108:10  */
  assign n3078_o = n3253_o ? n3066_o : n2859_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:112:13  */
  assign n3080_o = n2955_o ? n3069_o : 14'b00000000000000;
  assign n3081_o = this_r[33:0]; // extract
  assign n3082_o = this_r[61:52]; // extract
  assign n3083_o = this_r[87:66]; // extract
  assign n3084_o = this_r[97:89]; // extract
  assign n3085_o = {n2859_o, 1'b0, n3084_o, n2858_o, n3083_o, n2856_o, n3082_o, n2854_o, n2851_o, n2849_o, n3081_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:138:24  */
  assign n3087_o = n3085_o[16:13]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:138:28  */
  assign n3088_o = {28'b0, n3087_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:138:28  */
  assign n3090_o = n3088_o == 32'b00000000000000000000000000001111;
  assign n3091_o = this_r[33:0]; // extract
  assign n3092_o = this_r[61:52]; // extract
  assign n3093_o = this_r[87:66]; // extract
  assign n3094_o = this_r[97:89]; // extract
  assign n3095_o = {n2859_o, 1'b0, n3094_o, n2858_o, n3093_o, n2856_o, n3092_o, n2854_o, n2851_o, n2849_o, n3091_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:140:24  */
  assign n3097_o = n3095_o[1:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:140:26  */
  assign n3099_o = n3097_o == 2'b10;
  assign n3100_o = this_r[33:0]; // extract
  assign n3101_o = this_r[61:52]; // extract
  assign n3102_o = this_r[87:66]; // extract
  assign n3103_o = this_r[97:89]; // extract
  assign n3104_o = {n2859_o, 1'b0, n3103_o, n2858_o, n3102_o, n2856_o, n3101_o, n2854_o, n2851_o, n2849_o, n3100_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:141:27  */
  assign n3106_o = n3104_o[23:22]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:141:29  */
  assign n3107_o = {30'b0, n3106_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:141:29  */
  assign n3109_o = $signed(n3107_o) > $signed(32'b00000000000000000000000000000001);
  assign n3110_o = this_r[33:0]; // extract
  assign n3111_o = this_r[61:52]; // extract
  assign n3112_o = this_r[87:66]; // extract
  assign n3113_o = this_r[97:89]; // extract
  assign n3114_o = {n2859_o, 1'b0, n3113_o, n2858_o, n3112_o, n2856_o, n3111_o, n2854_o, n2851_o, n2849_o, n3110_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:141:68  */
  assign n3115_o = n3114_o[9:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:141:56  */
  assign n3117_o = {1'b1, n3115_o};
  assign n3118_o = this_r[33:0]; // extract
  assign n3119_o = this_r[61:52]; // extract
  assign n3120_o = this_r[87:66]; // extract
  assign n3121_o = this_r[97:89]; // extract
  assign n3122_o = {n2859_o, 1'b0, n3121_o, n2858_o, n3120_o, n2856_o, n3119_o, n2854_o, n2851_o, n2849_o, n3118_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:142:51  */
  assign n3123_o = n3122_o[9:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:142:39  */
  assign n3125_o = {1'b0, n3123_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:141:16  */
  assign n3126_o = n3109_o ? n3117_o : n3125_o;
  assign n3127_o = this_r[9:2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:140:13  */
  assign n3128_o = n3099_o ? n3126_o : n3127_o;
  assign n3129_o = this_r[1:0]; // extract
  assign n3130_o = this_r[33:10]; // extract
  assign n3131_o = this_r[61:52]; // extract
  assign n3132_o = this_r[87:66]; // extract
  assign n3133_o = this_r[97:89]; // extract
  assign n3134_o = {n2859_o, 1'b0, n3133_o, n2858_o, n3132_o, n2856_o, n3131_o, n2854_o, n2851_o, n2849_o, n3130_o, n3128_o, n3129_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:146:26  */
  assign n3136_o = n3134_o[1:0]; // extract
  assign n3137_o = this_r[1:0]; // extract
  assign n3138_o = this_r[33:10]; // extract
  assign n3139_o = this_r[61:52]; // extract
  assign n3140_o = this_r[87:66]; // extract
  assign n3141_o = this_r[97:89]; // extract
  assign n3142_o = {n2859_o, 1'b0, n3141_o, n2858_o, n3140_o, n2856_o, n3139_o, n2854_o, n2851_o, n2849_o, n3138_o, n3128_o, n3137_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:148:28  */
  assign n3143_o = n3142_o[21]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:148:32  */
  assign n3144_o = ~n3143_o;
  assign n3147_o = this_r[1:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:148:16  */
  assign n3148_o = n3144_o ? 2'b01 : n3147_o;
  assign n3149_o = this_r[16:13]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:148:16  */
  assign n3150_o = n3144_o ? 4'b0000 : n3149_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:147:13  */
  assign n3152_o = n3136_o == 2'b00;
  assign n3153_o = this_r[1:0]; // extract
  assign n3154_o = this_r[33:10]; // extract
  assign n3155_o = this_r[61:52]; // extract
  assign n3156_o = this_r[87:66]; // extract
  assign n3157_o = this_r[97:89]; // extract
  assign n3158_o = {n2859_o, 1'b0, n3157_o, n2858_o, n3156_o, n2856_o, n3155_o, n2854_o, n2851_o, n2849_o, n3154_o, n3128_o, n3153_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:153:27  */
  assign n3160_o = n3158_o[23:22]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:153:29  */
  assign n3161_o = {30'b0, n3160_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:153:29  */
  assign n3163_o = $signed(n3161_o) > $signed(32'b00000000000000000000000000000001);
  assign n3168_o = {4'b0000, 3'b000};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:153:16  */
  assign n3169_o = n3163_o ? 2'b00 : 2'b10;
  assign n3170_o = this_r[16:10]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:153:16  */
  assign n3171_o = n3163_o ? n3170_o : n3168_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:152:13  */
  assign n3173_o = n3136_o == 2'b01;
  assign n3175_o = this_r[1:0]; // extract
  assign n3176_o = this_r[12:10]; // extract
  assign n3177_o = this_r[33:17]; // extract
  assign n3178_o = this_r[61:52]; // extract
  assign n3179_o = this_r[87:66]; // extract
  assign n3180_o = this_r[97:89]; // extract
  assign n3181_o = {n2859_o, 1'b0, n3180_o, n2858_o, n3179_o, n2856_o, n3178_o, n2854_o, n2851_o, n2849_o, n3177_o, 4'b0000, n3176_o, n3128_o, n3175_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:162:27  */
  assign n3183_o = n3181_o[12:10]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:162:29  */
  assign n3184_o = {29'b0, n3183_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:162:29  */
  assign n3186_o = n3184_o == 32'b00000000000000000000000000000111;
  assign n3188_o = this_r[1:0]; // extract
  assign n3189_o = this_r[12:10]; // extract
  assign n3190_o = this_r[33:17]; // extract
  assign n3191_o = this_r[61:52]; // extract
  assign n3192_o = this_r[87:66]; // extract
  assign n3193_o = this_r[97:89]; // extract
  assign n3194_o = {n2859_o, 1'b0, n3193_o, n2858_o, n3192_o, n2856_o, n3191_o, n2854_o, n2851_o, n2849_o, n3190_o, 4'b0000, n3189_o, n3128_o, n3188_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:165:40  */
  assign n3196_o = n3194_o[12:10]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:165:42  */
  assign n3197_o = {29'b0, n3196_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:165:42  */
  assign n3199_o = n3197_o + 32'b00000000000000000000000000000001;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:165:19  */
  assign n3200_o = n3199_o[2:0];  // trunc
  assign n3201_o = this_r[1:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:162:16  */
  assign n3202_o = n3186_o ? 2'b11 : n3201_o;
  assign n3203_o = this_r[12:10]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:162:16  */
  assign n3204_o = n3186_o ? n3203_o : n3200_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:160:13  */
  assign n3206_o = n3136_o == 2'b10;
  assign n3207_o = {n3206_o, n3173_o, n3152_o};
  assign n3208_o = this_r[1:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:146:13  */
  always @*
    case (n3207_o)
      3'b100: n3209_o = n3202_o;
      3'b010: n3209_o = n3169_o;
      3'b001: n3209_o = n3148_o;
      default: n3209_o = n3208_o;
    endcase
  assign n3210_o = n3171_o[2:0]; // extract
  assign n3211_o = this_r[12:10]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:146:13  */
  always @*
    case (n3207_o)
      3'b100: n3212_o = n3204_o;
      3'b010: n3212_o = n3210_o;
      3'b001: n3212_o = n3211_o;
      default: n3212_o = n3211_o;
    endcase
  assign n3213_o = n3171_o[6:3]; // extract
  assign n3214_o = this_r[16:13]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:146:13  */
  always @*
    case (n3207_o)
      3'b100: n3215_o = 4'b0000;
      3'b010: n3215_o = n3213_o;
      3'b001: n3215_o = n3150_o;
      default: n3215_o = n3214_o;
    endcase
  assign n3217_o = this_r[33:0]; // extract
  assign n3218_o = this_r[61:52]; // extract
  assign n3219_o = this_r[87:66]; // extract
  assign n3220_o = this_r[97:89]; // extract
  assign n3221_o = {n2859_o, 1'b0, n3220_o, n2858_o, n3219_o, n2856_o, n3218_o, n2854_o, n2851_o, n2849_o, n3217_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:171:36  */
  assign n3223_o = n3221_o[16:13]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:171:40  */
  assign n3224_o = {28'b0, n3223_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:171:40  */
  assign n3226_o = n3224_o + 32'b00000000000000000000000000000001;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:171:13  */
  assign n3227_o = n3226_o[3:0];  // trunc
  assign n3228_o = {n3215_o, n3212_o, n3128_o, n3209_o};
  assign n3229_o = n3228_o[12:0]; // extract
  assign n3230_o = this_r[12:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:138:10  */
  assign n3231_o = n3090_o ? n3229_o : n3230_o;
  assign n3232_o = n3228_o[16:13]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:138:10  */
  assign n3233_o = n3090_o ? n3232_o : n3227_o;
  assign n3234_o = this_r[23:22]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:138:10  */
  assign n3235_o = n3090_o ? 2'b00 : n3234_o;
  assign n3236_o = {n3233_o, n3231_o};
  assign n3237_o = {n3075_o, n3073_o, 4'b1111};
  assign n3238_o = n3236_o[1:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:108:10  */
  assign n3239_o = n2942_o ? 2'b00 : n3238_o;
  assign n3240_o = n3236_o[12:2]; // extract
  assign n3241_o = this_r[12:2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:108:10  */
  assign n3242_o = n2942_o ? n3241_o : n3240_o;
  assign n3243_o = n3236_o[16:13]; // extract
  assign n3244_o = n3237_o[3:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:108:10  */
  assign n3245_o = n2942_o ? n3244_o : n3243_o;
  assign n3246_o = n3237_o[6:4]; // extract
  assign n3247_o = this_r[19:17]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:108:10  */
  assign n3248_o = n2942_o ? n3246_o : n3247_o;
  assign n3249_o = this_r[23:22]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:108:10  */
  assign n3250_o = n2942_o ? n3249_o : n3235_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:108:10  */
  assign n3252_o = n2955_o & n2942_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:108:10  */
  assign n3253_o = n2955_o & n2942_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:108:10  */
  assign n3255_o = n2942_o ? n3080_o : 14'b00000000000000;
  assign n3256_o = {n3248_o, n3245_o, n3242_o, n3239_o};
  assign n3257_o = {n3077_o, n3250_o};
  assign n3258_o = n3256_o[12:0]; // extract
  assign n3259_o = this_r[12:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:104:10  */
  assign n3260_o = n2891_o ? n3259_o : n3258_o;
  assign n3261_o = n3256_o[16:13]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:104:10  */
  assign n3262_o = n2891_o ? n2922_o : n3261_o;
  assign n3263_o = n3256_o[19:17]; // extract
  assign n3264_o = this_r[19:17]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:104:10  */
  assign n3265_o = n2891_o ? n3264_o : n3263_o;
  assign n3266_o = n3257_o[1:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:104:10  */
  assign n3267_o = n2891_o ? n2910_o : n3266_o;
  assign n3268_o = n3257_o[6:2]; // extract
  assign n3269_o = this_r[28:24]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:104:10  */
  assign n3270_o = n2891_o ? n3269_o : n3268_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:104:10  */
  assign n3271_o = n2891_o ? n2859_o : n3078_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:104:10  */
  assign n3273_o = n2891_o ? 14'b00000000000000 : n3255_o;
  assign n3276_o = {n3265_o, n3262_o, n3260_o};
  assign n3277_o = {n3270_o, n3267_o};
  assign n3278_o = {n2854_o, n2851_o, n2849_o};
  assign n3279_o = {1'b1, 7'b0000000};
  assign n3280_o = this_r[19:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:52:7  */
  assign n3281_o = n2612_o ? n3276_o : n3280_o;
  assign n3282_o = this_r[28:22]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:52:7  */
  assign n3283_o = n2612_o ? n3277_o : n3282_o;
  assign n3284_o = this_r[51:34]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:52:7  */
  assign n3285_o = n2612_o ? n3278_o : n3284_o;
  assign n3286_o = this_r[65:62]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:52:7  */
  assign n3287_o = n2612_o ? n2856_o : n3286_o;
  assign n3288_o = this_r[86:79]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:52:7  */
  assign n3289_o = n2612_o ? n3279_o : n3288_o;
  assign n3290_o = this_r[88]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:52:7  */
  assign n3291_o = n2612_o ? n2858_o : n3290_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:52:7  */
  assign n3292_o = n2612_o ? n3271_o : 1'b0;
  assign n3295_o = this_r[21:20]; // extract
  assign n3297_o = this_r[33:29]; // extract
  assign n3299_o = this_r[61:52]; // extract
  assign n3301_o = this_r[78:66]; // extract
  assign n3302_o = this_r[97:89]; // extract
  assign n3303_o = this_r[87]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:52:7  */
  assign n3305_o = n2612_o ? n3273_o : 14'b00000000000000;
  assign n3307_o = {n3292_o, 1'b0, n3302_o, n3291_o, n3303_o, n3289_o, n3301_o, n3287_o, n3299_o, n3285_o, n3297_o, n3283_o, n3295_o, n3281_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:192:34  */
  assign n3308_o = n3307_o[77:66]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:192:24  */
  assign n3310_o = {1'b0, n3308_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:192:62  */
  assign n3312_o = n3310_o + 13'b0000000011001;
  assign n3313_o = {n3292_o, 1'b0, n3302_o, n3291_o, n3303_o, n3289_o, n3312_o, n3287_o, n3299_o, n3285_o, n3297_o, n3283_o, n3295_o, n3281_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:194:15  */
  assign n3314_o = n3313_o[89]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:194:18  */
  assign n3315_o = ~n3314_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:194:30  */
  assign n3316_o = n2556_o[9]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:194:24  */
  assign n3317_o = n3316_o & n3315_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:194:45  */
  assign n3318_o = n2556_o[10]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:194:48  */
  assign n3319_o = ~n3318_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:194:39  */
  assign n3320_o = n3319_o & n3317_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:195:15  */
  assign n3321_o = n2556_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:195:18  */
  assign n3323_o = n3321_o == 1'b0;
  assign n3324_o = {n3292_o, 1'b0, n3302_o, n3291_o, n3303_o, n3289_o, n3312_o, n3287_o, n3299_o, n3285_o, n3297_o, n3283_o, n3295_o, n3281_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:196:25  */
  assign n3326_o = n3324_o[28:24]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:196:28  */
  assign n3327_o = {27'b0, n3326_o};  //  uext
  assign n3328_o = {n3292_o, 1'b0, n3302_o, n3291_o, n3303_o, n3289_o, n3312_o, n3287_o, n3299_o, n3285_o, n3297_o, n3283_o, n3295_o, n3281_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:196:40  */
  assign n3330_o = n3328_o[33:29]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:196:28  */
  assign n3331_o = {27'b0, n3330_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:196:28  */
  assign n3332_o = n3327_o != n3331_o;
  assign n3333_o = {n3292_o, 1'b0, n3302_o, n3291_o, n3303_o, n3289_o, n3312_o, n3287_o, n3299_o, n3285_o, n3297_o, n3283_o, n3295_o, n3281_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:196:54  */
  assign n3335_o = n3333_o[17]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:196:43  */
  assign n3336_o = n3332_o | n3335_o;
  assign n3337_o = {n3292_o, 1'b0, n3302_o, n3291_o, n3303_o, n3289_o, n3312_o, n3287_o, n3299_o, n3285_o, n3297_o, n3283_o, n3295_o, n3281_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:197:41  */
  assign n3339_o = n3337_o[33:29]; // extract
  assign n3344_o = this_r[89]; // extract
  assign n3345_o = {n3292_o, 1'b0, n3578_data, n3344_o, n3291_o, n3303_o, n3289_o, n3312_o, n3287_o, n3299_o, n3285_o, n3297_o, n3283_o, n3295_o, n3281_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:198:28  */
  assign n3347_o = n3345_o[33:29]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:198:31  */
  assign n3348_o = {27'b0, n3347_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:198:31  */
  assign n3350_o = n3348_o == 32'b00000000000000000000000000011111;
  assign n3352_o = this_r[89]; // extract
  assign n3353_o = {n3292_o, 1'b0, n3578_data, n3352_o, n3291_o, n3303_o, n3289_o, n3312_o, n3287_o, n3299_o, n3285_o, n3297_o, n3283_o, n3295_o, n3281_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:201:43  */
  assign n3355_o = n3353_o[33:29]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:201:46  */
  assign n3356_o = {27'b0, n3355_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:201:46  */
  assign n3358_o = n3356_o + 32'b00000000000000000000000000000001;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:201:19  */
  assign n3359_o = n3358_o[4:0];  // trunc
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:198:16  */
  assign n3360_o = n3350_o ? 5'b00000 : n3359_o;
  assign n3362_o = n3281_o[17]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:195:10  */
  assign n3363_o = n3394_o ? 1'b0 : n3362_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:194:7  */
  assign n3364_o = n3404_o ? n3360_o : n3297_o;
  assign n3365_o = this_r[97:90]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:196:13  */
  assign n3366_o = n3336_o ? n3578_data : n3365_o;
  assign n3367_o = {n3292_o, 1'b0, n3302_o, n3291_o, n3303_o, n3289_o, n3312_o, n3287_o, n3299_o, n3285_o, n3297_o, n3283_o, n3295_o, n3281_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:209:39  */
  assign n3369_o = n3367_o[19]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:209:29  */
  assign n3371_o = {1'b0, n3369_o};
  assign n3372_o = {n3292_o, 1'b0, n3302_o, n3291_o, n3303_o, n3289_o, n3312_o, n3287_o, n3299_o, n3285_o, n3297_o, n3283_o, n3295_o, n3281_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:209:54  */
  assign n3374_o = n3372_o[18]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:209:44  */
  assign n3375_o = {n3371_o, n3374_o};
  assign n3376_o = {n3292_o, 1'b0, n3302_o, n3291_o, n3303_o, n3289_o, n3312_o, n3287_o, n3299_o, n3285_o, n3297_o, n3283_o, n3295_o, n3281_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:209:65  */
  assign n3377_o = n3376_o[87]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:209:58  */
  assign n3378_o = {n3375_o, n3377_o};
  assign n3379_o = {n3292_o, 1'b0, n3302_o, n3291_o, n3303_o, n3289_o, n3312_o, n3287_o, n3299_o, n3285_o, n3297_o, n3283_o, n3295_o, n3281_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:209:79  */
  assign n3381_o = n3379_o[51]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:209:69  */
  assign n3382_o = {n3378_o, n3381_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:209:84  */
  assign n3383_o = {n3382_o, n2605_o};
  assign n3384_o = {n3292_o, 1'b0, n3302_o, n3291_o, n3303_o, n3289_o, n3312_o, n3287_o, n3299_o, n3285_o, n3297_o, n3283_o, n3295_o, n3281_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:209:100  */
  assign n3386_o = n3384_o[17]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:209:90  */
  assign n3387_o = {n3383_o, n3386_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:209:107  */
  assign n3388_o = ~n2590_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:209:105  */
  assign n3389_o = {n3387_o, n3388_o};
  assign n3392_o = {1'b0, 1'b0};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:195:10  */
  assign n3394_o = n3336_o & n3323_o;
  assign n3395_o = n3281_o[19:18]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:195:10  */
  assign n3396_o = n3323_o ? n3395_o : n3392_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:195:10  */
  assign n3397_o = n3336_o & n3323_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:195:10  */
  assign n3398_o = n3323_o ? n3366_o : n3389_o;
  assign n3400_o = {n3396_o, n3363_o};
  assign n3401_o = {1'b1, n3398_o};
  assign n3402_o = n3281_o[19:17]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:194:7  */
  assign n3403_o = n3320_o ? n3400_o : n3402_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:194:7  */
  assign n3404_o = n3397_o & n3320_o;
  assign n3405_o = this_r[97:90]; // extract
  assign n3406_o = {1'b0, n3405_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:194:7  */
  assign n3407_o = n3320_o ? n3401_o : n3406_o;
  assign n3408_o = n3281_o[16:0]; // extract
  assign n3409_o = this_r[89]; // extract
  assign n3410_o = {n3292_o, n3407_o, n3409_o, n3291_o, n3303_o, n3289_o, n3312_o, n3287_o, n3299_o, n3285_o, n3364_o, n3283_o, n3295_o, n3403_o, n3408_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:216:15  */
  assign n3411_o = n3410_o[89]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:216:18  */
  assign n3412_o = ~n3411_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:216:30  */
  assign n3413_o = n2556_o[9]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:216:24  */
  assign n3414_o = n3413_o & n3412_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:216:45  */
  assign n3415_o = n2556_o[10]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:216:39  */
  assign n3416_o = n3415_o & n3414_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:217:15  */
  assign n3417_o = n2556_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:217:18  */
  assign n3419_o = n3417_o == 1'b0;
  assign n3420_o = {n3292_o, n3407_o, n3409_o, n3291_o, n3303_o, n3289_o, n3312_o, n3287_o, n3299_o, n3285_o, n3364_o, n3283_o, n3295_o, n3403_o, n3408_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:218:24  */
  assign n3422_o = n3420_o[51]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:221:27  */
  assign n3424_o = n2556_o[8:1]; // extract
  assign n3425_o = {n3292_o, n3407_o, n3409_o, n3291_o, n3303_o, n3289_o, n3312_o, n3287_o, n3299_o, n3285_o, n3364_o, n3283_o, n3295_o, n3403_o, n3408_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:222:34  */
  assign n3427_o = n3425_o[61:58]; // extract
  assign n3429_o = {n3292_o, n3407_o, n3409_o, n3291_o, n3303_o, n3289_o, n3312_o, n3287_o, n3299_o, n3285_o, n3364_o, n3283_o, n3295_o, n3403_o, n3408_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:224:28  */
  assign n3431_o = n3429_o[61:58]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:224:31  */
  assign n3432_o = {28'b0, n3431_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:224:31  */
  assign n3434_o = n3432_o == 32'b00000000000000000000000000001111;
  assign n3436_o = {n3292_o, n3407_o, n3409_o, n3291_o, n3303_o, n3289_o, n3312_o, n3287_o, n3299_o, n3285_o, n3364_o, n3283_o, n3295_o, n3403_o, n3408_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:227:43  */
  assign n3438_o = n3436_o[61:58]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:227:46  */
  assign n3439_o = {28'b0, n3438_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:227:46  */
  assign n3441_o = n3439_o + 32'b00000000000000000000000000000001;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:227:19  */
  assign n3442_o = n3441_o[3:0];  // trunc
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:224:16  */
  assign n3443_o = n3434_o ? 4'b0000 : n3442_o;
  assign n3444_o = this_r[57:52]; // extract
  assign n3445_o = {n3292_o, n3407_o, n3409_o, n3291_o, n3303_o, n3289_o, n3312_o, n3287_o, n3443_o, n3444_o, n3285_o, n3364_o, n3283_o, n3295_o, n3403_o, n3408_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:229:28  */
  assign n3447_o = n3445_o[61:58]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:229:31  */
  assign n3448_o = {28'b0, n3447_o};  //  uext
  assign n3449_o = this_r[57:52]; // extract
  assign n3450_o = {n3292_o, n3407_o, n3409_o, n3291_o, n3303_o, n3289_o, n3312_o, n3287_o, n3443_o, n3449_o, n3285_o, n3364_o, n3283_o, n3295_o, n3403_o, n3408_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:229:42  */
  assign n3452_o = n3450_o[65:62]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:229:31  */
  assign n3453_o = {28'b0, n3452_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:229:31  */
  assign n3454_o = n3448_o == n3453_o;
  assign n3456_o = n3285_o[17]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:229:16  */
  assign n3457_o = n3454_o ? 1'b1 : n3456_o;
  assign n3458_o = n3285_o[17]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:218:13  */
  assign n3459_o = n3422_o ? n3458_o : n3457_o;
  assign n3460_o = this_r[52]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:218:13  */
  assign n3461_o = n3422_o ? 1'b1 : n3460_o;
  assign n3462_o = this_r[61:58]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:218:13  */
  assign n3463_o = n3422_o ? n3462_o : n3443_o;
  assign n3464_o = {1'b1, n3424_o, n3427_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:218:13  */
  assign n3466_o = n3422_o ? 13'b0000000000000 : n3464_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:233:19  */
  assign n3467_o = n2556_o[1]; // extract
  assign n3471_o = {4'b0000, 4'b0000};
  assign n3472_o = n3285_o[17]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:233:13  */
  assign n3473_o = n3467_o ? 1'b0 : n3472_o;
  assign n3474_o = this_r[61:58]; // extract
  assign n3475_o = {n3287_o, n3474_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:233:13  */
  assign n3476_o = n3467_o ? n3471_o : n3475_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:234:19  */
  assign n3477_o = n2556_o[2]; // extract
  assign n3481_o = {5'b00000, 5'b00000};
  assign n3482_o = n3403_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:234:13  */
  assign n3483_o = n3477_o ? 1'b0 : n3482_o;
  assign n3484_o = n3283_o[6:2]; // extract
  assign n3485_o = {n3364_o, n3484_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:234:13  */
  assign n3486_o = n3477_o ? n3481_o : n3485_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:235:28  */
  assign n3487_o = n2556_o[5]; // extract
  assign n3488_o = {n3461_o, n3459_o};
  assign n3489_o = n3403_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:217:10  */
  assign n3490_o = n3419_o ? n3489_o : n3483_o;
  assign n3491_o = n3283_o[6:2]; // extract
  assign n3492_o = {n3364_o, n3491_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:217:10  */
  assign n3493_o = n3419_o ? n3492_o : n3486_o;
  assign n3494_o = n3488_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:217:10  */
  assign n3495_o = n3419_o ? n3494_o : n3473_o;
  assign n3496_o = n3488_o[1]; // extract
  assign n3497_o = this_r[52]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:217:10  */
  assign n3498_o = n3419_o ? n3496_o : n3497_o;
  assign n3499_o = n3476_o[3:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:217:10  */
  assign n3500_o = n3419_o ? n3463_o : n3499_o;
  assign n3501_o = n3476_o[7:4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:217:10  */
  assign n3502_o = n3419_o ? n3287_o : n3501_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:217:10  */
  assign n3503_o = n3419_o ? n3303_o : n3487_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:217:10  */
  assign n3505_o = n3419_o ? n3466_o : 13'b0000000000000;
  assign n3507_o = {n3498_o, n3495_o};
  assign n3508_o = {n3502_o, n3500_o};
  assign n3509_o = n3403_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:216:7  */
  assign n3510_o = n3416_o ? n3490_o : n3509_o;
  assign n3511_o = n3283_o[6:2]; // extract
  assign n3512_o = {n3364_o, n3511_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:216:7  */
  assign n3513_o = n3416_o ? n3493_o : n3512_o;
  assign n3514_o = n3285_o[17]; // extract
  assign n3515_o = this_r[52]; // extract
  assign n3516_o = {n3515_o, n3514_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:216:7  */
  assign n3517_o = n3416_o ? n3507_o : n3516_o;
  assign n3518_o = this_r[61:58]; // extract
  assign n3519_o = {n3287_o, n3518_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:216:7  */
  assign n3520_o = n3416_o ? n3508_o : n3519_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:216:7  */
  assign n3521_o = n3416_o ? n3503_o : n3303_o;
  assign n3522_o = n3407_o[8]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:216:7  */
  assign n3523_o = n3416_o ? 1'b1 : n3522_o;
  assign n3524_o = n3403_o[2:1]; // extract
  assign n3525_o = n3283_o[1:0]; // extract
  assign n3526_o = n3285_o[16:0]; // extract
  assign n3528_o = this_r[57:53]; // extract
  assign n3529_o = n3407_o[7:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:216:7  */
  assign n3531_o = n3416_o ? n3505_o : 13'b0000000000000;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:240:20  */
  assign n3533_o = n2556_o[9]; // extract
  assign n3534_o = {n3292_o, n3523_o, n3529_o, n3533_o, n3291_o, n3521_o, n3289_o, n3312_o, n3520_o, n3528_o, n3517_o, n3526_o, n3513_o, n3525_o, n3295_o, n3524_o, n3510_o, n3408_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:242:29  */
  assign n3535_o = n3534_o[20]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:242:33  */
  assign n3536_o = {n3535_o, rx};
  assign n3537_o = {n3292_o, n3523_o, n3529_o, n3533_o, n3291_o, n3521_o, n3289_o, n3312_o, n3520_o, n3528_o, n3517_o, n3526_o, n3513_o, n3525_o, n3536_o, n3524_o, n3510_o, n3408_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:260:18  */
  assign n3550_o = txfw[12]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:260:41  */
  assign n3551_o = txfw[3:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:260:52  */
  assign n3555_o = txfw[11:4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:261:18  */
  assign n3558_o = rxfw[13]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:261:41  */
  assign n3559_o = rxfw[4:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:261:52  */
  assign n3563_o = rxfw[12:5]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:265:16  */
  assign n3569_o = this_r[99:90]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:266:17  */
  assign n3570_o = this_r[88]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:252:7  */
  always @(posedge clk or posedge rst)
    if (rst)
      n3571_q <= 100'b0000000000010100000000000000000000000000000000000111100000000000000000000000000000011110000000000000;
    else
      n3571_q <= this_c;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:60:43  */
  reg [7:0] txf[15:0] ; // memory
  assign n3576_data = txf[n2630_o];
  always @(posedge clk)
    if (n3550_o)
      txf[n3551_o] <= n3555_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:60:43  */
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:260:41  */
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:197:41  */
  reg [7:0] rxf[31:0] ; // memory
  assign n3578_data = rxf[n3339_o];
  always @(posedge clk)
    if (n3558_o)
      rxf[n3559_o] <= n3563_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:197:41  */
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/uart.vhd:261:41  */
endmodule

module ref_devices__aic_edgedet
  (input  clk,
   input  rst,
   input  irq,
   input  en_i,
   input  clr_i,
   output q);
  reg reg0;
  reg reg1;
  reg w_edge;
  wire n2536_o;
  wire n2537_o;
  wire n2549_o;
  wire n2550_o;
  wire n2551_o;
  reg n2553_q;
  reg n2554_q;
  reg n2555_q;
  assign q = n2555_q; //(module output)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/ref_devices__aic_edgedet.vhd:16:16  */
  always @*
    reg0 = n2553_q; // (isignal)
  initial
    reg0 = 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/ref_devices__aic_edgedet.vhd:16:22  */
  always @*
    reg1 = n2554_q; // (isignal)
  initial
    reg1 = 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/ref_devices__aic_edgedet.vhd:17:16  */
  always @*
    w_edge = n2551_o; // (isignal)
  initial
    w_edge = 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/ref_devices__aic_edgedet.vhd:30:25  */
  assign n2536_o = clr_i ? 1'b0 : n2555_q;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/ref_devices__aic_edgedet.vhd:28:25  */
  assign n2537_o = w_edge ? en_i : n2536_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/ref_devices__aic_edgedet.vhd:35:33  */
  assign n2549_o = ~reg1;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/ref_devices__aic_edgedet.vhd:35:39  */
  assign n2550_o = reg0 & n2549_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/ref_devices__aic_edgedet.vhd:35:23  */
  assign n2551_o = n2550_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/ref_devices__aic_edgedet.vhd:25:17  */
  always @(posedge clk or posedge rst)
    if (rst)
      n2553_q <= 1'b0;
    else
      n2553_q <= irq;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/ref_devices__aic_edgedet.vhd:25:17  */
  always @(posedge clk or posedge rst)
    if (rst)
      n2554_q <= 1'b0;
    else
      n2554_q <= reg0;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/ref_devices__aic_edgedet.vhd:25:17  */
  always @(posedge clk or posedge rst)
    if (rst)
      n2555_q <= 1'b0;
    else
      n2555_q <= n2537_o;
endmodule

module ref_devices__uartlitedb_1_eee99cc82b436e2be5204cecddaa56d739e34653
  (input  rst,
   input  clk,
   input  db_i_en,
   input  [31:0] db_i_a,
   input  db_i_rd,
   input  db_i_wr,
   input  [3:0] db_i_we,
   input  [31:0] db_i_d,
   input  rx,
   output [31:0] db_o_d,
   output db_o_ack,
   output int_i,
   output tx);
  wire [70:0] n2477_o;
  wire [31:0] n2479_o;
  wire n2480_o;
  wire n2481_o;
  wire [9:0] uart_o;
  wire n2489_o;
  wire n2490_o;
  wire n2493_o;
  wire [7:0] n2496_o;
  wire n2498_o;
  wire n2500_o;
  wire [10:0] n2501_o;
  wire [9:0] uart_n2502;
  wire uart_n2503;
  wire [7:0] uart_y_d;
  wire uart_y_ack;
  wire uart_y_int;
  wire uart_tx;
  wire n2504_o;
  wire [7:0] n2505_o;
  wire n2506_o;
  wire n2507_o;
  wire [9:0] n2508_o;
  wire n2519_o;
  wire [7:0] n2524_o;
  wire [32:0] n2525_o;
  wire n2526_o;
  assign db_o_d = n2479_o; //(module output)
  assign db_o_ack = n2480_o; //(module output)
  assign int_i = n2481_o; //(module output)
  assign tx = uart_n2503; //(module output)
  assign n2477_o = {db_i_d, db_i_we, db_i_wr, db_i_rd, db_i_a, db_i_en};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:50:25  */
  assign n2479_o = n2525_o[31:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:50:25  */
  assign n2480_o = n2525_o[32]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/uartlite/uartlitedb.vhd:22:5  */
  assign n2481_o = n2526_o; // (output)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/uartlite/uartlitedb.vhd:58:10  */
  assign uart_o = uart_n2502; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/uartlite/uartlitedb.vhd:37:11  */
  assign n2489_o = n2477_o[4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/uartlite/uartlitedb.vhd:37:15  */
  assign n2490_o = ~n2489_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/uartlite/uartlitedb.vhd:37:5  */
  assign n2493_o = n2490_o ? 1'b0 : 1'b1;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/uartlite/uartlitedb.vhd:42:16  */
  assign n2496_o = n2477_o[46:39]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/uartlite/uartlitedb.vhd:43:15  */
  assign n2498_o = n2477_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/uartlite/uartlitedb.vhd:44:15  */
  assign n2500_o = n2477_o[34]; // extract
  assign n2501_o = {n2500_o, n2498_o, n2496_o, n2493_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/uartlite/uartlitedb.vhd:68:12  */
  assign uart_n2502 = n2508_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/uartlite/uartlitedb.vhd:70:13  */
  assign uart_n2503 = uart_tx; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/uartlite/uartlitedb.vhd:61:3  */
  ref_devices__uartlite_1_eee99cc82b436e2be5204cecddaa56d739e34653 uart (
    .rst(rst),
    .clk(clk),
    .a_dc(n2504_o),
    .a_d(n2505_o),
    .a_en(n2506_o),
    .a_we(n2507_o),
    .rx(rx),
    .y_d(uart_y_d),
    .y_ack(uart_y_ack),
    .y_int(uart_y_int),
    .tx(uart_tx));
  assign n2504_o = n2501_o[0]; // extract
  assign n2505_o = n2501_o[8:1]; // extract
  assign n2506_o = n2501_o[9]; // extract
  assign n2507_o = n2501_o[10]; // extract
  assign n2508_o = {uart_y_int, uart_y_ack, uart_y_d};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/uartlite/uartlitedb.vhd:52:16  */
  assign n2519_o = uart_o[8]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/uartlite/uartlitedb.vhd:54:27  */
  assign n2524_o = uart_o[7:0]; // extract
  assign n2525_o = {n2519_o, 24'b000000000000000000000000, n2524_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/uartlite/uartlitedb.vhd:73:17  */
  assign n2526_o = uart_o[9]; // extract
endmodule

module ref_devices__pio_34d7de1b571aa545cf571b84dc4b40d1f42fed39
  (input  clk_bus,
   input  reset,
   input  db_i_en,
   input  [31:0] db_i_a,
   input  db_i_rd,
   input  db_i_wr,
   input  [3:0] db_i_we,
   input  [31:0] db_i_d,
   input  [31:0] p_i,
   output [31:0] db_o_d,
   output db_o_ack,
   output irq,
   output [31:0] p_o);
  wire [70:0] n1778_o;
  wire [31:0] n1780_o;
  wire n1781_o;
  wire n1782_o;
  wire [31:0] n1783_o;
  wire [31:0] pio_dout;
  wire [31:0] pi_reg2;
  wire [31:0] pi_reg;
  wire [31:0] pi_edge;
  wire [31:0] pi_changes;
  wire [31:0] pi_mask;
  wire pi_chread;
  wire irq_r0;
  wire irq_r1;
  wire [3:0] n1784_o;
  wire n1786_o;
  wire [31:0] n1787_o;
  wire [3:0] n1788_o;
  wire n1790_o;
  wire [31:0] n1791_o;
  wire [3:0] n1792_o;
  wire n1794_o;
  wire [31:0] n1795_o;
  wire n1796_o;
  wire n1797_o;
  wire n1798_o;
  wire n1802_o;
  wire [3:0] n1803_o;
  wire n1805_o;
  wire n1806_o;
  wire [7:0] n1807_o;
  wire [7:0] n1808_o;
  wire [7:0] n1809_o;
  wire n1810_o;
  wire [7:0] n1811_o;
  wire [7:0] n1812_o;
  wire [7:0] n1813_o;
  wire n1814_o;
  wire [7:0] n1815_o;
  wire [7:0] n1816_o;
  wire [7:0] n1817_o;
  wire n1818_o;
  wire [7:0] n1819_o;
  wire [7:0] n1820_o;
  wire [7:0] n1821_o;
  wire [3:0] n1822_o;
  wire n1824_o;
  wire [31:0] n1825_o;
  wire [3:0] n1826_o;
  wire n1828_o;
  wire [31:0] n1829_o;
  wire [31:0] n1830_o;
  wire [31:0] n1831_o;
  wire [31:0] n1832_o;
  wire [31:0] n1833_o;
  wire [31:0] n1835_o;
  wire [31:0] n1836_o;
  wire n1837_o;
  wire [3:0] n1838_o;
  wire n1840_o;
  wire n1841_o;
  wire n1844_o;
  wire n1845_o;
  wire n1849_o;
  wire n1852_o;
  wire n1853_o;
  wire n1854_o;
  wire n1855_o;
  wire n1857_o;
  wire n1858_o;
  wire n1859_o;
  wire n1860_o;
  wire n1861_o;
  wire n1863_o;
  wire n1864_o;
  wire n1866_o;
  wire n1867_o;
  wire n1868_o;
  wire n1870_o;
  wire n1871_o;
  wire n1872_o;
  wire n1873_o;
  wire n1875_o;
  wire n1876_o;
  wire n1877_o;
  wire n1878_o;
  wire n1879_o;
  wire n1881_o;
  wire n1882_o;
  wire n1884_o;
  wire n1885_o;
  wire n1886_o;
  wire n1888_o;
  wire n1889_o;
  wire n1890_o;
  wire n1891_o;
  wire n1893_o;
  wire n1894_o;
  wire n1895_o;
  wire n1896_o;
  wire n1897_o;
  wire n1899_o;
  wire n1900_o;
  wire n1902_o;
  wire n1903_o;
  wire n1904_o;
  wire n1906_o;
  wire n1907_o;
  wire n1908_o;
  wire n1909_o;
  wire n1911_o;
  wire n1912_o;
  wire n1913_o;
  wire n1914_o;
  wire n1915_o;
  wire n1917_o;
  wire n1918_o;
  wire n1920_o;
  wire n1921_o;
  wire n1922_o;
  wire n1924_o;
  wire n1925_o;
  wire n1926_o;
  wire n1927_o;
  wire n1929_o;
  wire n1930_o;
  wire n1931_o;
  wire n1932_o;
  wire n1933_o;
  wire n1935_o;
  wire n1936_o;
  wire n1938_o;
  wire n1939_o;
  wire n1940_o;
  wire n1942_o;
  wire n1943_o;
  wire n1944_o;
  wire n1945_o;
  wire n1947_o;
  wire n1948_o;
  wire n1949_o;
  wire n1950_o;
  wire n1951_o;
  wire n1953_o;
  wire n1954_o;
  wire n1956_o;
  wire n1957_o;
  wire n1958_o;
  wire n1960_o;
  wire n1961_o;
  wire n1962_o;
  wire n1963_o;
  wire n1965_o;
  wire n1966_o;
  wire n1967_o;
  wire n1968_o;
  wire n1969_o;
  wire n1971_o;
  wire n1972_o;
  wire n1974_o;
  wire n1975_o;
  wire n1976_o;
  wire n1978_o;
  wire n1979_o;
  wire n1980_o;
  wire n1981_o;
  wire n1983_o;
  wire n1984_o;
  wire n1985_o;
  wire n1986_o;
  wire n1987_o;
  wire n1989_o;
  wire n1990_o;
  wire n1992_o;
  wire n1993_o;
  wire n1994_o;
  wire n1996_o;
  wire n1997_o;
  wire n1998_o;
  wire n1999_o;
  wire n2001_o;
  wire n2002_o;
  wire n2003_o;
  wire n2004_o;
  wire n2005_o;
  wire n2007_o;
  wire n2008_o;
  wire n2010_o;
  wire n2011_o;
  wire n2012_o;
  wire n2014_o;
  wire n2015_o;
  wire n2016_o;
  wire n2017_o;
  wire n2019_o;
  wire n2020_o;
  wire n2021_o;
  wire n2022_o;
  wire n2023_o;
  wire n2025_o;
  wire n2026_o;
  wire n2028_o;
  wire n2029_o;
  wire n2030_o;
  wire n2032_o;
  wire n2033_o;
  wire n2034_o;
  wire n2035_o;
  wire n2037_o;
  wire n2038_o;
  wire n2039_o;
  wire n2040_o;
  wire n2041_o;
  wire n2043_o;
  wire n2044_o;
  wire n2046_o;
  wire n2047_o;
  wire n2048_o;
  wire n2050_o;
  wire n2051_o;
  wire n2052_o;
  wire n2053_o;
  wire n2055_o;
  wire n2056_o;
  wire n2057_o;
  wire n2058_o;
  wire n2059_o;
  wire n2061_o;
  wire n2062_o;
  wire n2064_o;
  wire n2065_o;
  wire n2066_o;
  wire n2068_o;
  wire n2069_o;
  wire n2070_o;
  wire n2071_o;
  wire n2073_o;
  wire n2074_o;
  wire n2075_o;
  wire n2076_o;
  wire n2077_o;
  wire n2079_o;
  wire n2080_o;
  wire n2082_o;
  wire n2083_o;
  wire n2084_o;
  wire n2086_o;
  wire n2087_o;
  wire n2088_o;
  wire n2089_o;
  wire n2091_o;
  wire n2092_o;
  wire n2093_o;
  wire n2094_o;
  wire n2095_o;
  wire n2097_o;
  wire n2098_o;
  wire n2100_o;
  wire n2101_o;
  wire n2102_o;
  wire n2104_o;
  wire n2105_o;
  wire n2106_o;
  wire n2107_o;
  wire n2109_o;
  wire n2110_o;
  wire n2111_o;
  wire n2112_o;
  wire n2113_o;
  wire n2115_o;
  wire n2116_o;
  wire n2118_o;
  wire n2119_o;
  wire n2120_o;
  wire n2122_o;
  wire n2123_o;
  wire n2124_o;
  wire n2125_o;
  wire n2127_o;
  wire n2128_o;
  wire n2129_o;
  wire n2130_o;
  wire n2131_o;
  wire n2133_o;
  wire n2134_o;
  wire n2136_o;
  wire n2137_o;
  wire n2138_o;
  wire n2140_o;
  wire n2141_o;
  wire n2142_o;
  wire n2143_o;
  wire n2145_o;
  wire n2146_o;
  wire n2147_o;
  wire n2148_o;
  wire n2149_o;
  wire n2151_o;
  wire n2152_o;
  wire n2154_o;
  wire n2155_o;
  wire n2156_o;
  wire n2158_o;
  wire n2159_o;
  wire n2160_o;
  wire n2161_o;
  wire n2163_o;
  wire n2164_o;
  wire n2165_o;
  wire n2166_o;
  wire n2167_o;
  wire n2169_o;
  wire n2170_o;
  wire n2172_o;
  wire n2173_o;
  wire n2174_o;
  wire n2176_o;
  wire n2177_o;
  wire n2178_o;
  wire n2179_o;
  wire n2181_o;
  wire n2182_o;
  wire n2183_o;
  wire n2184_o;
  wire n2185_o;
  wire n2187_o;
  wire n2188_o;
  wire n2190_o;
  wire n2191_o;
  wire n2192_o;
  wire n2194_o;
  wire n2195_o;
  wire n2196_o;
  wire n2197_o;
  wire n2199_o;
  wire n2200_o;
  wire n2201_o;
  wire n2202_o;
  wire n2203_o;
  wire n2205_o;
  wire n2206_o;
  wire n2208_o;
  wire n2209_o;
  wire n2210_o;
  wire n2212_o;
  wire n2213_o;
  wire n2214_o;
  wire n2215_o;
  wire n2217_o;
  wire n2218_o;
  wire n2219_o;
  wire n2220_o;
  wire n2221_o;
  wire n2223_o;
  wire n2224_o;
  wire n2226_o;
  wire n2227_o;
  wire n2228_o;
  wire n2230_o;
  wire n2231_o;
  wire n2232_o;
  wire n2233_o;
  wire n2235_o;
  wire n2236_o;
  wire n2237_o;
  wire n2238_o;
  wire n2239_o;
  wire n2241_o;
  wire n2242_o;
  wire n2244_o;
  wire n2245_o;
  wire n2246_o;
  wire n2248_o;
  wire n2249_o;
  wire n2250_o;
  wire n2251_o;
  wire n2253_o;
  wire n2254_o;
  wire n2255_o;
  wire n2256_o;
  wire n2257_o;
  wire n2259_o;
  wire n2260_o;
  wire n2262_o;
  wire n2263_o;
  wire n2264_o;
  wire n2266_o;
  wire n2267_o;
  wire n2268_o;
  wire n2269_o;
  wire n2271_o;
  wire n2272_o;
  wire n2273_o;
  wire n2274_o;
  wire n2275_o;
  wire n2277_o;
  wire n2278_o;
  wire n2280_o;
  wire n2281_o;
  wire n2282_o;
  wire n2284_o;
  wire n2285_o;
  wire n2286_o;
  wire n2287_o;
  wire n2289_o;
  wire n2290_o;
  wire n2291_o;
  wire n2292_o;
  wire n2293_o;
  wire n2295_o;
  wire n2296_o;
  wire n2298_o;
  wire n2299_o;
  wire n2300_o;
  wire n2302_o;
  wire n2303_o;
  wire n2304_o;
  wire n2305_o;
  wire n2307_o;
  wire n2308_o;
  wire n2309_o;
  wire n2310_o;
  wire n2311_o;
  wire n2313_o;
  wire n2314_o;
  wire n2316_o;
  wire n2317_o;
  wire n2318_o;
  wire n2320_o;
  wire n2321_o;
  wire n2322_o;
  wire n2323_o;
  wire n2325_o;
  wire n2326_o;
  wire n2327_o;
  wire n2328_o;
  wire n2329_o;
  wire n2331_o;
  wire n2332_o;
  wire n2334_o;
  wire n2335_o;
  wire n2336_o;
  wire n2338_o;
  wire n2339_o;
  wire n2340_o;
  wire n2341_o;
  wire n2343_o;
  wire n2344_o;
  wire n2345_o;
  wire n2346_o;
  wire n2347_o;
  wire n2349_o;
  wire n2350_o;
  wire n2352_o;
  wire n2353_o;
  wire n2354_o;
  wire n2356_o;
  wire n2357_o;
  wire n2358_o;
  wire n2359_o;
  wire n2361_o;
  wire n2362_o;
  wire n2363_o;
  wire n2364_o;
  wire n2365_o;
  wire n2367_o;
  wire n2368_o;
  wire n2370_o;
  wire n2371_o;
  wire n2372_o;
  wire n2374_o;
  wire n2375_o;
  wire n2376_o;
  wire n2377_o;
  wire n2379_o;
  wire n2380_o;
  wire n2381_o;
  wire n2382_o;
  wire n2383_o;
  wire n2385_o;
  wire n2386_o;
  wire n2388_o;
  wire n2389_o;
  wire n2390_o;
  wire n2392_o;
  wire n2393_o;
  wire n2394_o;
  wire n2395_o;
  wire n2397_o;
  wire n2398_o;
  wire n2399_o;
  wire n2400_o;
  wire n2401_o;
  wire n2403_o;
  wire n2404_o;
  wire n2406_o;
  wire n2407_o;
  wire n2408_o;
  wire n2410_o;
  wire n2411_o;
  wire n2412_o;
  wire n2413_o;
  wire n2415_o;
  wire n2416_o;
  wire n2417_o;
  wire n2418_o;
  wire n2419_o;
  wire n2421_o;
  wire n2422_o;
  wire n2424_o;
  wire n2425_o;
  wire n2426_o;
  wire [31:0] n2427_o;
  wire n2429_o;
  wire n2432_o;
  wire [31:0] n2437_o;
  wire [31:0] n2460_o;
  reg [31:0] n2461_q;
  reg [31:0] n2462_q;
  reg [31:0] n2463_q;
  wire [31:0] n2464_o;
  reg [31:0] n2465_q;
  wire n2466_o;
  wire [31:0] n2467_o;
  reg [31:0] n2468_q;
  wire [31:0] n2469_o;
  reg [31:0] n2470_q;
  wire n2471_o;
  wire n2472_o;
  reg n2473_q;
  reg n2474_q;
  reg n2475_q;
  wire [32:0] n2476_o;
  assign db_o_d = n1780_o; //(module output)
  assign db_o_ack = n1781_o; //(module output)
  assign irq = n1782_o; //(module output)
  assign p_o = n1783_o; //(module output)
  assign n1778_o = {db_i_d, db_i_we, db_i_wr, db_i_rd, db_i_a, db_i_en};
  assign n1780_o = n2476_o[31:0]; // extract
  assign n1781_o = n2476_o[32]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:14:9  */
  assign n1782_o = n1798_o; // (output)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:16:9  */
  assign n1783_o = pio_dout; // (output)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:27:16  */
  assign pio_dout = n2461_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:28:16  */
  assign pi_reg2 = n2462_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:28:25  */
  assign pi_reg = n2463_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:28:33  */
  assign pi_edge = n2465_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:28:42  */
  assign pi_changes = n2468_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:28:54  */
  assign pi_mask = n2470_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:29:16  */
  assign pi_chread = n2473_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:30:16  */
  assign irq_r0 = n2474_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:30:24  */
  assign irq_r1 = n2475_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:33:41  */
  assign n1784_o = n1778_o[6:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:33:54  */
  assign n1786_o = n1784_o == 4'b0011;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:33:30  */
  assign n1787_o = n1786_o ? pi_changes : n1791_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:34:38  */
  assign n1788_o = n1778_o[6:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:34:51  */
  assign n1790_o = n1788_o == 4'b0010;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:33:63  */
  assign n1791_o = n1790_o ? pi_edge : n1795_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:35:38  */
  assign n1792_o = n1778_o[6:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:35:51  */
  assign n1794_o = n1792_o == 4'b0001;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:34:60  */
  assign n1795_o = n1794_o ? pi_mask : pi_reg;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:37:26  */
  assign n1796_o = n1778_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:38:29  */
  assign n1797_o = ~irq_r1;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:38:25  */
  assign n1798_o = irq_r0 & n1797_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:54:41  */
  assign n1802_o = n1778_o[34]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:55:42  */
  assign n1803_o = n1778_o[6:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:55:55  */
  assign n1805_o = n1803_o == 4'b0000;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:56:51  */
  assign n1806_o = n1778_o[38]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:57:81  */
  assign n1807_o = n1778_o[70:63]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:373:17  */
  assign n1808_o = pio_dout[31:24]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:56:41  */
  assign n1809_o = n1806_o ? n1807_o : n1808_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:59:51  */
  assign n1810_o = n1778_o[37]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:60:81  */
  assign n1811_o = n1778_o[62:55]; // extract
  assign n1812_o = pio_dout[23:16]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:59:41  */
  assign n1813_o = n1810_o ? n1811_o : n1812_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:62:51  */
  assign n1814_o = n1778_o[36]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:63:80  */
  assign n1815_o = n1778_o[54:47]; // extract
  assign n1816_o = pio_dout[15:8]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:62:41  */
  assign n1817_o = n1814_o ? n1815_o : n1816_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:65:51  */
  assign n1818_o = n1778_o[35]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:66:79  */
  assign n1819_o = n1778_o[46:39]; // extract
  assign n1820_o = pio_dout[7:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:65:41  */
  assign n1821_o = n1818_o ? n1819_o : n1820_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:68:45  */
  assign n1822_o = n1778_o[6:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:68:58  */
  assign n1824_o = n1822_o == 4'b0001;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:69:57  */
  assign n1825_o = n1778_o[70:39]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:70:45  */
  assign n1826_o = n1778_o[6:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:70:58  */
  assign n1828_o = n1826_o == 4'b0010;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:71:57  */
  assign n1829_o = n1778_o[70:39]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:70:33  */
  assign n1830_o = n1828_o ? n1829_o : pi_edge;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:68:33  */
  assign n1831_o = n1824_o ? pi_edge : n1830_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:68:33  */
  assign n1832_o = n1824_o ? n1825_o : pi_mask;
  assign n1833_o = {n1809_o, n1813_o, n1817_o, n1821_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:55:33  */
  assign n1835_o = n1805_o ? pi_edge : n1831_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:55:33  */
  assign n1836_o = n1805_o ? pi_mask : n1832_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:73:36  */
  assign n1837_o = n1778_o[33]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:73:55  */
  assign n1838_o = n1778_o[6:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:73:68  */
  assign n1840_o = n1838_o == 4'b0011;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:73:45  */
  assign n1841_o = n1840_o & n1837_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:73:25  */
  assign n1844_o = n1841_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:54:33  */
  assign n1845_o = n1805_o & n1802_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:54:33  */
  assign n1849_o = n1802_o ? 1'b0 : n1844_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n1852_o = pi_reg2[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n1853_o = pi_reg[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n1854_o = ~n1853_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n1855_o = n1854_o & n1852_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n1857_o = pi_reg2[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n1858_o = ~n1857_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n1859_o = pi_reg[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n1860_o = n1859_o & n1858_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n1861_o = pi_edge[0]; // extract
  assign n1863_o = pi_changes[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n1864_o = n1866_o ? 1'b1 : n1863_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n1866_o = n1861_o & n1860_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n1867_o = n1855_o ? 1'b1 : n1864_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n1868_o = pi_chread ? 1'b0 : n1867_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n1870_o = pi_reg2[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n1871_o = pi_reg[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n1872_o = ~n1871_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n1873_o = n1872_o & n1870_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n1875_o = pi_reg2[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n1876_o = ~n1875_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n1877_o = pi_reg[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n1878_o = n1877_o & n1876_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n1879_o = pi_edge[1]; // extract
  assign n1881_o = pi_changes[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n1882_o = n1884_o ? 1'b1 : n1881_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n1884_o = n1879_o & n1878_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n1885_o = n1873_o ? 1'b1 : n1882_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n1886_o = pi_chread ? 1'b0 : n1885_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n1888_o = pi_reg2[2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n1889_o = pi_reg[2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n1890_o = ~n1889_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n1891_o = n1890_o & n1888_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n1893_o = pi_reg2[2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n1894_o = ~n1893_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n1895_o = pi_reg[2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n1896_o = n1895_o & n1894_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n1897_o = pi_edge[2]; // extract
  assign n1899_o = pi_changes[2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n1900_o = n1902_o ? 1'b1 : n1899_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n1902_o = n1897_o & n1896_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n1903_o = n1891_o ? 1'b1 : n1900_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n1904_o = pi_chread ? 1'b0 : n1903_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n1906_o = pi_reg2[3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n1907_o = pi_reg[3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n1908_o = ~n1907_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n1909_o = n1908_o & n1906_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n1911_o = pi_reg2[3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n1912_o = ~n1911_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n1913_o = pi_reg[3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n1914_o = n1913_o & n1912_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n1915_o = pi_edge[3]; // extract
  assign n1917_o = pi_changes[3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n1918_o = n1920_o ? 1'b1 : n1917_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n1920_o = n1915_o & n1914_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n1921_o = n1909_o ? 1'b1 : n1918_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n1922_o = pi_chread ? 1'b0 : n1921_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n1924_o = pi_reg2[4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n1925_o = pi_reg[4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n1926_o = ~n1925_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n1927_o = n1926_o & n1924_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n1929_o = pi_reg2[4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n1930_o = ~n1929_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n1931_o = pi_reg[4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n1932_o = n1931_o & n1930_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n1933_o = pi_edge[4]; // extract
  assign n1935_o = pi_changes[4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n1936_o = n1938_o ? 1'b1 : n1935_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n1938_o = n1933_o & n1932_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n1939_o = n1927_o ? 1'b1 : n1936_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n1940_o = pi_chread ? 1'b0 : n1939_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n1942_o = pi_reg2[5]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n1943_o = pi_reg[5]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n1944_o = ~n1943_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n1945_o = n1944_o & n1942_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n1947_o = pi_reg2[5]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n1948_o = ~n1947_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n1949_o = pi_reg[5]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n1950_o = n1949_o & n1948_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n1951_o = pi_edge[5]; // extract
  assign n1953_o = pi_changes[5]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n1954_o = n1956_o ? 1'b1 : n1953_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n1956_o = n1951_o & n1950_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n1957_o = n1945_o ? 1'b1 : n1954_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n1958_o = pi_chread ? 1'b0 : n1957_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n1960_o = pi_reg2[6]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n1961_o = pi_reg[6]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n1962_o = ~n1961_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n1963_o = n1962_o & n1960_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n1965_o = pi_reg2[6]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n1966_o = ~n1965_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n1967_o = pi_reg[6]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n1968_o = n1967_o & n1966_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n1969_o = pi_edge[6]; // extract
  assign n1971_o = pi_changes[6]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n1972_o = n1974_o ? 1'b1 : n1971_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n1974_o = n1969_o & n1968_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n1975_o = n1963_o ? 1'b1 : n1972_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n1976_o = pi_chread ? 1'b0 : n1975_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n1978_o = pi_reg2[7]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n1979_o = pi_reg[7]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n1980_o = ~n1979_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n1981_o = n1980_o & n1978_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n1983_o = pi_reg2[7]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n1984_o = ~n1983_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n1985_o = pi_reg[7]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n1986_o = n1985_o & n1984_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n1987_o = pi_edge[7]; // extract
  assign n1989_o = pi_changes[7]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n1990_o = n1992_o ? 1'b1 : n1989_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n1992_o = n1987_o & n1986_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n1993_o = n1981_o ? 1'b1 : n1990_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n1994_o = pi_chread ? 1'b0 : n1993_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n1996_o = pi_reg2[8]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n1997_o = pi_reg[8]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n1998_o = ~n1997_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n1999_o = n1998_o & n1996_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2001_o = pi_reg2[8]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2002_o = ~n2001_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2003_o = pi_reg[8]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2004_o = n2003_o & n2002_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2005_o = pi_edge[8]; // extract
  assign n2007_o = pi_changes[8]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2008_o = n2010_o ? 1'b1 : n2007_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2010_o = n2005_o & n2004_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2011_o = n1999_o ? 1'b1 : n2008_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2012_o = pi_chread ? 1'b0 : n2011_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2014_o = pi_reg2[9]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2015_o = pi_reg[9]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2016_o = ~n2015_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2017_o = n2016_o & n2014_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2019_o = pi_reg2[9]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2020_o = ~n2019_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2021_o = pi_reg[9]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2022_o = n2021_o & n2020_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2023_o = pi_edge[9]; // extract
  assign n2025_o = pi_changes[9]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2026_o = n2028_o ? 1'b1 : n2025_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2028_o = n2023_o & n2022_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2029_o = n2017_o ? 1'b1 : n2026_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2030_o = pi_chread ? 1'b0 : n2029_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2032_o = pi_reg2[10]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2033_o = pi_reg[10]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2034_o = ~n2033_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2035_o = n2034_o & n2032_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2037_o = pi_reg2[10]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2038_o = ~n2037_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2039_o = pi_reg[10]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2040_o = n2039_o & n2038_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2041_o = pi_edge[10]; // extract
  assign n2043_o = pi_changes[10]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2044_o = n2046_o ? 1'b1 : n2043_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2046_o = n2041_o & n2040_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2047_o = n2035_o ? 1'b1 : n2044_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2048_o = pi_chread ? 1'b0 : n2047_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2050_o = pi_reg2[11]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2051_o = pi_reg[11]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2052_o = ~n2051_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2053_o = n2052_o & n2050_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2055_o = pi_reg2[11]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2056_o = ~n2055_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2057_o = pi_reg[11]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2058_o = n2057_o & n2056_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2059_o = pi_edge[11]; // extract
  assign n2061_o = pi_changes[11]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2062_o = n2064_o ? 1'b1 : n2061_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2064_o = n2059_o & n2058_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2065_o = n2053_o ? 1'b1 : n2062_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2066_o = pi_chread ? 1'b0 : n2065_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2068_o = pi_reg2[12]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2069_o = pi_reg[12]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2070_o = ~n2069_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2071_o = n2070_o & n2068_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2073_o = pi_reg2[12]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2074_o = ~n2073_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2075_o = pi_reg[12]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2076_o = n2075_o & n2074_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2077_o = pi_edge[12]; // extract
  assign n2079_o = pi_changes[12]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2080_o = n2082_o ? 1'b1 : n2079_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2082_o = n2077_o & n2076_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2083_o = n2071_o ? 1'b1 : n2080_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2084_o = pi_chread ? 1'b0 : n2083_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2086_o = pi_reg2[13]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2087_o = pi_reg[13]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2088_o = ~n2087_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2089_o = n2088_o & n2086_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2091_o = pi_reg2[13]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2092_o = ~n2091_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2093_o = pi_reg[13]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2094_o = n2093_o & n2092_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2095_o = pi_edge[13]; // extract
  assign n2097_o = pi_changes[13]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2098_o = n2100_o ? 1'b1 : n2097_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2100_o = n2095_o & n2094_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2101_o = n2089_o ? 1'b1 : n2098_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2102_o = pi_chread ? 1'b0 : n2101_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2104_o = pi_reg2[14]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2105_o = pi_reg[14]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2106_o = ~n2105_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2107_o = n2106_o & n2104_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2109_o = pi_reg2[14]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2110_o = ~n2109_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2111_o = pi_reg[14]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2112_o = n2111_o & n2110_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2113_o = pi_edge[14]; // extract
  assign n2115_o = pi_changes[14]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2116_o = n2118_o ? 1'b1 : n2115_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2118_o = n2113_o & n2112_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2119_o = n2107_o ? 1'b1 : n2116_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2120_o = pi_chread ? 1'b0 : n2119_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2122_o = pi_reg2[15]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2123_o = pi_reg[15]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2124_o = ~n2123_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2125_o = n2124_o & n2122_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2127_o = pi_reg2[15]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2128_o = ~n2127_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2129_o = pi_reg[15]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2130_o = n2129_o & n2128_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2131_o = pi_edge[15]; // extract
  assign n2133_o = pi_changes[15]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2134_o = n2136_o ? 1'b1 : n2133_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2136_o = n2131_o & n2130_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2137_o = n2125_o ? 1'b1 : n2134_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2138_o = pi_chread ? 1'b0 : n2137_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2140_o = pi_reg2[16]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2141_o = pi_reg[16]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2142_o = ~n2141_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2143_o = n2142_o & n2140_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2145_o = pi_reg2[16]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2146_o = ~n2145_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2147_o = pi_reg[16]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2148_o = n2147_o & n2146_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2149_o = pi_edge[16]; // extract
  assign n2151_o = pi_changes[16]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2152_o = n2154_o ? 1'b1 : n2151_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2154_o = n2149_o & n2148_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2155_o = n2143_o ? 1'b1 : n2152_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2156_o = pi_chread ? 1'b0 : n2155_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2158_o = pi_reg2[17]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2159_o = pi_reg[17]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2160_o = ~n2159_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2161_o = n2160_o & n2158_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2163_o = pi_reg2[17]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2164_o = ~n2163_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2165_o = pi_reg[17]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2166_o = n2165_o & n2164_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2167_o = pi_edge[17]; // extract
  assign n2169_o = pi_changes[17]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2170_o = n2172_o ? 1'b1 : n2169_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2172_o = n2167_o & n2166_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2173_o = n2161_o ? 1'b1 : n2170_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2174_o = pi_chread ? 1'b0 : n2173_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2176_o = pi_reg2[18]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2177_o = pi_reg[18]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2178_o = ~n2177_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2179_o = n2178_o & n2176_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2181_o = pi_reg2[18]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2182_o = ~n2181_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2183_o = pi_reg[18]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2184_o = n2183_o & n2182_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2185_o = pi_edge[18]; // extract
  assign n2187_o = pi_changes[18]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2188_o = n2190_o ? 1'b1 : n2187_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2190_o = n2185_o & n2184_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2191_o = n2179_o ? 1'b1 : n2188_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2192_o = pi_chread ? 1'b0 : n2191_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2194_o = pi_reg2[19]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2195_o = pi_reg[19]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2196_o = ~n2195_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2197_o = n2196_o & n2194_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2199_o = pi_reg2[19]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2200_o = ~n2199_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2201_o = pi_reg[19]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2202_o = n2201_o & n2200_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2203_o = pi_edge[19]; // extract
  assign n2205_o = pi_changes[19]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2206_o = n2208_o ? 1'b1 : n2205_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2208_o = n2203_o & n2202_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2209_o = n2197_o ? 1'b1 : n2206_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2210_o = pi_chread ? 1'b0 : n2209_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2212_o = pi_reg2[20]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2213_o = pi_reg[20]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2214_o = ~n2213_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2215_o = n2214_o & n2212_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2217_o = pi_reg2[20]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2218_o = ~n2217_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2219_o = pi_reg[20]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2220_o = n2219_o & n2218_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2221_o = pi_edge[20]; // extract
  assign n2223_o = pi_changes[20]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2224_o = n2226_o ? 1'b1 : n2223_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2226_o = n2221_o & n2220_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2227_o = n2215_o ? 1'b1 : n2224_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2228_o = pi_chread ? 1'b0 : n2227_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2230_o = pi_reg2[21]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2231_o = pi_reg[21]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2232_o = ~n2231_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2233_o = n2232_o & n2230_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2235_o = pi_reg2[21]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2236_o = ~n2235_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2237_o = pi_reg[21]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2238_o = n2237_o & n2236_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2239_o = pi_edge[21]; // extract
  assign n2241_o = pi_changes[21]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2242_o = n2244_o ? 1'b1 : n2241_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2244_o = n2239_o & n2238_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2245_o = n2233_o ? 1'b1 : n2242_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2246_o = pi_chread ? 1'b0 : n2245_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2248_o = pi_reg2[22]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2249_o = pi_reg[22]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2250_o = ~n2249_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2251_o = n2250_o & n2248_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2253_o = pi_reg2[22]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2254_o = ~n2253_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2255_o = pi_reg[22]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2256_o = n2255_o & n2254_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2257_o = pi_edge[22]; // extract
  assign n2259_o = pi_changes[22]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2260_o = n2262_o ? 1'b1 : n2259_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2262_o = n2257_o & n2256_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2263_o = n2251_o ? 1'b1 : n2260_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2264_o = pi_chread ? 1'b0 : n2263_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2266_o = pi_reg2[23]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2267_o = pi_reg[23]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2268_o = ~n2267_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2269_o = n2268_o & n2266_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2271_o = pi_reg2[23]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2272_o = ~n2271_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2273_o = pi_reg[23]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2274_o = n2273_o & n2272_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2275_o = pi_edge[23]; // extract
  assign n2277_o = pi_changes[23]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2278_o = n2280_o ? 1'b1 : n2277_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2280_o = n2275_o & n2274_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2281_o = n2269_o ? 1'b1 : n2278_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2282_o = pi_chread ? 1'b0 : n2281_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2284_o = pi_reg2[24]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2285_o = pi_reg[24]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2286_o = ~n2285_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2287_o = n2286_o & n2284_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2289_o = pi_reg2[24]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2290_o = ~n2289_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2291_o = pi_reg[24]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2292_o = n2291_o & n2290_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2293_o = pi_edge[24]; // extract
  assign n2295_o = pi_changes[24]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2296_o = n2298_o ? 1'b1 : n2295_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2298_o = n2293_o & n2292_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2299_o = n2287_o ? 1'b1 : n2296_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2300_o = pi_chread ? 1'b0 : n2299_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2302_o = pi_reg2[25]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2303_o = pi_reg[25]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2304_o = ~n2303_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2305_o = n2304_o & n2302_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2307_o = pi_reg2[25]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2308_o = ~n2307_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2309_o = pi_reg[25]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2310_o = n2309_o & n2308_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2311_o = pi_edge[25]; // extract
  assign n2313_o = pi_changes[25]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2314_o = n2316_o ? 1'b1 : n2313_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2316_o = n2311_o & n2310_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2317_o = n2305_o ? 1'b1 : n2314_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2318_o = pi_chread ? 1'b0 : n2317_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2320_o = pi_reg2[26]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2321_o = pi_reg[26]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2322_o = ~n2321_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2323_o = n2322_o & n2320_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2325_o = pi_reg2[26]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2326_o = ~n2325_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2327_o = pi_reg[26]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2328_o = n2327_o & n2326_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2329_o = pi_edge[26]; // extract
  assign n2331_o = pi_changes[26]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2332_o = n2334_o ? 1'b1 : n2331_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2334_o = n2329_o & n2328_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2335_o = n2323_o ? 1'b1 : n2332_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2336_o = pi_chread ? 1'b0 : n2335_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2338_o = pi_reg2[27]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2339_o = pi_reg[27]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2340_o = ~n2339_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2341_o = n2340_o & n2338_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2343_o = pi_reg2[27]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2344_o = ~n2343_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2345_o = pi_reg[27]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2346_o = n2345_o & n2344_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2347_o = pi_edge[27]; // extract
  assign n2349_o = pi_changes[27]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2350_o = n2352_o ? 1'b1 : n2349_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2352_o = n2347_o & n2346_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2353_o = n2341_o ? 1'b1 : n2350_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2354_o = pi_chread ? 1'b0 : n2353_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2356_o = pi_reg2[28]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2357_o = pi_reg[28]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2358_o = ~n2357_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2359_o = n2358_o & n2356_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2361_o = pi_reg2[28]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2362_o = ~n2361_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2363_o = pi_reg[28]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2364_o = n2363_o & n2362_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2365_o = pi_edge[28]; // extract
  assign n2367_o = pi_changes[28]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2368_o = n2370_o ? 1'b1 : n2367_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2370_o = n2365_o & n2364_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2371_o = n2359_o ? 1'b1 : n2368_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2372_o = pi_chread ? 1'b0 : n2371_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2374_o = pi_reg2[29]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2375_o = pi_reg[29]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2376_o = ~n2375_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2377_o = n2376_o & n2374_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2379_o = pi_reg2[29]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2380_o = ~n2379_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2381_o = pi_reg[29]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2382_o = n2381_o & n2380_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2383_o = pi_edge[29]; // extract
  assign n2385_o = pi_changes[29]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2386_o = n2388_o ? 1'b1 : n2385_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2388_o = n2383_o & n2382_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2389_o = n2377_o ? 1'b1 : n2386_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2390_o = pi_chread ? 1'b0 : n2389_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2392_o = pi_reg2[30]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2393_o = pi_reg[30]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2394_o = ~n2393_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2395_o = n2394_o & n2392_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2397_o = pi_reg2[30]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2398_o = ~n2397_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2399_o = pi_reg[30]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2400_o = n2399_o & n2398_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2401_o = pi_edge[30]; // extract
  assign n2403_o = pi_changes[30]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2404_o = n2406_o ? 1'b1 : n2403_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2406_o = n2401_o & n2400_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2407_o = n2395_o ? 1'b1 : n2404_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2408_o = pi_chread ? 1'b0 : n2407_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:46  */
  assign n2410_o = pi_reg2[31]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:66  */
  assign n2411_o = pi_reg[31]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:70  */
  assign n2412_o = ~n2411_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:56  */
  assign n2413_o = n2412_o & n2410_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:46  */
  assign n2415_o = pi_reg2[31]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:50  */
  assign n2416_o = ~n2415_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:66  */
  assign n2417_o = pi_reg[31]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:56  */
  assign n2418_o = n2417_o & n2416_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:83:51  */
  assign n2419_o = pi_edge[31]; // extract
  assign n2421_o = pi_changes[31]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2422_o = n2424_o ? 1'b1 : n2421_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:82:33  */
  assign n2424_o = n2419_o & n2418_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:80:33  */
  assign n2425_o = n2413_o ? 1'b1 : n2422_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:78:33  */
  assign n2426_o = pi_chread ? 1'b0 : n2425_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:88:37  */
  assign n2427_o = pi_mask & pi_changes;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:88:53  */
  assign n2429_o = n2427_o == 32'b00000000000000000000000000000000;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:88:25  */
  assign n2432_o = n2429_o ? 1'b0 : 1'b1;
  assign n2437_o = {n2426_o, n2408_o, n2390_o, n2372_o, n2354_o, n2336_o, n2318_o, n2300_o, n2282_o, n2264_o, n2246_o, n2228_o, n2210_o, n2192_o, n2174_o, n2156_o, n2138_o, n2120_o, n2102_o, n2084_o, n2066_o, n2048_o, n2030_o, n2012_o, n1994_o, n1976_o, n1958_o, n1940_o, n1922_o, n1904_o, n1886_o, n1868_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:50:25  */
  assign n2460_o = n1845_o ? n1833_o : pio_dout;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:50:25  */
  always @(posedge clk_bus or posedge reset)
    if (reset)
      n2461_q <= 32'b10000000000000000000000000000000;
    else
      n2461_q <= n2460_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:50:25  */
  always @(posedge clk_bus or posedge reset)
    if (reset)
      n2462_q <= 32'b00000000000000000000000000000000;
    else
      n2462_q <= pi_reg;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:50:25  */
  always @(posedge clk_bus or posedge reset)
    if (reset)
      n2463_q <= 32'b00000000000000000000000000000000;
    else
      n2463_q <= p_i;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:50:25  */
  assign n2464_o = n1802_o ? n1835_o : pi_edge;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:50:25  */
  always @(posedge clk_bus or posedge reset)
    if (reset)
      n2465_q <= 32'b00000000000000000000000000000000;
    else
      n2465_q <= n2464_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:40:9  */
  assign n2466_o = ~reset;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:50:25  */
  assign n2467_o = n2466_o ? n2437_o : pi_changes;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:50:25  */
  always @(posedge clk_bus)
    n2468_q <= n2467_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:50:25  */
  assign n2469_o = n1802_o ? n1836_o : pi_mask;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:50:25  */
  always @(posedge clk_bus or posedge reset)
    if (reset)
      n2470_q <= 32'b00000000000000000000000000000000;
    else
      n2470_q <= n2469_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:40:9  */
  assign n2471_o = ~reset;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:50:25  */
  assign n2472_o = n2471_o ? n1849_o : pi_chread;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:50:25  */
  always @(posedge clk_bus)
    n2473_q <= n2472_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:50:25  */
  always @(posedge clk_bus or posedge reset)
    if (reset)
      n2474_q <= 1'b0;
    else
      n2474_q <= n2432_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:50:25  */
  always @(posedge clk_bus or posedge reset)
    if (reset)
      n2475_q <= 1'b0;
    else
      n2475_q <= irq_r0;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/pio.vhd:42:17  */
  assign n2476_o = {n1796_o, n1787_o};
endmodule

module ref_devices__spi2_2_89fb3ab272c6c870879ac5ed9b6f8e6cfb09dc2d
  (input  clk,
   input  rst,
   input  db_i_en,
   input  [31:0] db_i_a,
   input  db_i_rd,
   input  db_i_wr,
   input  [3:0] db_i_we,
   input  [31:0] db_i_d,
   input  miso,
   output [31:0] db_o_d,
   output db_o_ack,
   output spi_clk,
   output [1:0] cs,
   output mosi);
  wire [70:0] n1513_o;
  wire [31:0] n1515_o;
  wire n1516_o;
  wire n1517_o;
  wire [1:0] n1518_o;
  wire n1519_o;
  wire [85:0] this_c;
  reg [85:0] this_r;
  wire n1531_o;
  wire [49:0] n1533_o;
  localparam [31:0] n1535_o = 32'b00000000000000000000000000000000;
  wire [2:0] n1536_o;
  wire n1537_o;
  wire n1538_o;
  wire n1539_o;
  wire n1540_o;
  wire n1541_o;
  wire n1542_o;
  wire n1543_o;
  wire n1544_o;
  wire n1545_o;
  wire n1546_o;
  wire [4:0] n1547_o;
  wire [7:0] n1548_o;
  wire [7:0] n1549_o;
  wire [7:0] n1550_o;
  wire [7:0] n1551_o;
  wire [7:0] n1552_o;
  wire [7:0] n1553_o;
  wire n1555_o;
  wire n1556_o;
  wire n1557_o;
  wire [85:0] n1558_o;
  wire n1559_o;
  wire [30:0] n1561_o;
  wire [85:0] n1562_o;
  wire [1:0] n1563_o;
  wire n1565_o;
  wire n1572_o;
  wire [29:0] n1573_o;
  wire [85:0] n1574_o;
  wire n1575_o;
  wire [28:0] n1577_o;
  wire [85:0] n1578_o;
  wire n1579_o;
  wire n1586_o;
  wire [85:0] n1587_o;
  wire [7:0] n1588_o;
  wire [3:0] n1589_o;
  wire [3:0] n1590_o;
  wire [3:0] n1591_o;
  wire [3:0] n1592_o;
  wire [3:0] n1593_o;
  wire [3:0] n1594_o;
  wire [7:0] n1595_o;
  wire [7:0] n1596_o;
  wire [7:0] n1597_o;
  wire n1599_o;
  wire [7:0] n1600_o;
  wire [7:0] n1601_o;
  wire n1603_o;
  wire [7:0] n1605_o;
  wire [7:0] n1606_o;
  wire n1607_o;
  wire n1609_o;
  wire n1611_o;
  wire [23:0] n1612_o;
  wire [8:0] n1614_o;
  wire [16:0] n1615_o;
  wire [7:0] n1616_o;
  wire n1618_o;
  wire [85:0] n1620_o;
  wire [5:0] n1621_o;
  wire [6:0] n1623_o;
  wire [6:0] n1625_o;
  wire n1626_o;
  wire n1627_o;
  wire [85:0] n1628_o;
  wire [1:0] n1629_o;
  wire n1631_o;
  wire n1632_o;
  wire [85:0] n1633_o;
  wire [4:0] n1634_o;
  wire n1636_o;
  wire [85:0] n1637_o;
  wire [4:0] n1638_o;
  wire n1640_o;
  wire n1641_o;
  wire [85:0] n1643_o;
  wire [4:0] n1644_o;
  wire [30:0] n1645_o;
  wire [31:0] n1646_o;
  wire [31:0] n1648_o;
  wire [30:0] n1649_o;
  wire [5:0] n1650_o;
  wire [5:0] n1651_o;
  wire [5:0] n1652_o;
  wire [5:0] n1653_o;
  wire [2:0] n1654_o;
  wire [85:0] n1655_o;
  wire [1:0] n1656_o;
  wire n1658_o;
  wire n1660_o;
  wire [85:0] n1661_o;
  wire [1:0] n1662_o;
  wire [85:0] n1665_o;
  wire [7:0] n1666_o;
  wire [8:0] n1668_o;
  wire [1:0] n1669_o;
  wire [1:0] n1670_o;
  wire [8:0] n1671_o;
  wire [8:0] n1672_o;
  wire n1675_o;
  wire n1677_o;
  wire [2:0] n1680_o;
  wire [2:0] n1681_o;
  wire n1684_o;
  wire n1686_o;
  wire [1:0] n1688_o;
  wire [85:0] n1689_o;
  wire [2:0] n1690_o;
  wire n1692_o;
  wire [1:0] n1695_o;
  wire [85:0] n1696_o;
  wire [2:0] n1697_o;
  wire [2:0] n1699_o;
  wire [2:0] n1700_o;
  wire [2:0] n1701_o;
  wire [2:0] n1702_o;
  wire n1705_o;
  wire n1707_o;
  wire n1709_o;
  wire [85:0] n1710_o;
  wire [7:0] n1711_o;
  wire [1:0] n1712_o;
  wire [1:0] n1713_o;
  wire [7:0] n1714_o;
  wire n1717_o;
  wire n1719_o;
  wire [3:0] n1720_o;
  wire [1:0] n1721_o;
  wire [1:0] n1722_o;
  reg [1:0] n1724_o;
  wire n1725_o;
  wire n1726_o;
  wire n1727_o;
  reg n1729_o;
  reg [2:0] n1731_o;
  reg [7:0] n1733_o;
  wire [8:0] n1734_o;
  reg [8:0] n1736_o;
  wire [7:0] n1738_o;
  reg n1741_o;
  reg n1745_o;
  wire [85:0] n1747_o;
  wire n1748_o;
  wire [85:0] n1749_o;
  wire n1750_o;
  wire n1751_o;
  wire [85:0] n1752_o;
  wire [6:0] n1753_o;
  wire [7:0] n1754_o;
  wire [7:0] n1755_o;
  wire [85:0] n1756_o;
  wire [7:0] n1757_o;
  wire [8:0] n1759_o;
  wire [8:0] n1760_o;
  wire [85:0] n1761_o;
  wire n1770_o;
  wire n1771_o;
  wire [32:0] n1772_o;
  wire n1773_o;
  wire n1774_o;
  wire n1775_o;
  reg [85:0] n1776_q;
  wire [1:0] n1777_o;
  assign db_o_d = n1515_o; //(module output)
  assign db_o_ack = n1516_o; //(module output)
  assign spi_clk = n1517_o; //(module output)
  assign cs = n1518_o; //(module output)
  assign mosi = n1519_o; //(module output)
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:24:4  */
  assign n1513_o = {db_i_d, db_i_we, db_i_wr, db_i_rd, db_i_a, db_i_en};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:14:4  */
  assign n1515_o = n1772_o[31:0]; // extract
  assign n1516_o = n1772_o[32]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:39:5  */
  assign n1517_o = n1770_o; // (output)
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:40:5  */
  assign n1518_o = n1777_o; // (output)
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:42:5  */
  assign n1519_o = n1771_o; // (output)
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:120:10  */
  assign this_c = n1761_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:121:10  */
  always @*
    this_r = n1776_q; // (isignal)
  initial
    this_r = 86'b00000000111111111000000000000000000111111000000000000000000000000000000000000000000000;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:146:28  */
  assign n1531_o = this_r[35]; // extract
  assign n1533_o = this_r[85:36]; // extract
  assign n1536_o = this_r[2:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:149:13  */
  assign n1537_o = n1513_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:149:36  */
  assign n1538_o = ~n1531_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:149:22  */
  assign n1539_o = n1538_o & n1537_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:150:15  */
  assign n1540_o = n1513_o[34]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:151:18  */
  assign n1541_o = n1513_o[3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:151:22  */
  assign n1542_o = ~n1541_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:153:31  */
  assign n1543_o = n1513_o[39]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:154:30  */
  assign n1544_o = n1513_o[40]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:155:31  */
  assign n1545_o = n1513_o[41]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:156:34  */
  assign n1546_o = n1513_o[42]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:160:40  */
  assign n1547_o = n1513_o[70:66]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:163:28  */
  assign n1548_o = n1513_o[46:39]; // extract
  assign n1549_o = {n1546_o, n1545_o, n1543_o, n1547_o};
  assign n1550_o = this_r[52:45]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:149:5  */
  assign n1551_o = n1609_o ? n1549_o : n1550_o;
  assign n1552_o = this_r[68:61]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:151:9  */
  assign n1553_o = n1542_o ? n1552_o : n1548_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:151:9  */
  assign n1555_o = n1542_o ? n1544_o : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:166:18  */
  assign n1556_o = n1513_o[3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:166:22  */
  assign n1557_o = ~n1556_o;
  assign n1558_o = {n1533_o, 1'b0, 32'b00000000000000000000000000000000, n1536_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:168:36  */
  assign n1559_o = n1558_o[50]; // extract
  assign n1561_o = n1535_o[31:1]; // extract
  assign n1562_o = {n1533_o, 1'b0, n1561_o, n1559_o, n1536_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:169:41  */
  assign n1563_o = n1562_o[1:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:169:47  */
  assign n1565_o = n1563_o != 2'b00;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:124:5  */
  assign n1572_o = n1565_o ? 1'b1 : 1'b0;
  assign n1573_o = n1535_o[31:2]; // extract
  assign n1574_o = {n1533_o, 1'b0, n1573_o, n1572_o, n1559_o, n1536_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:170:36  */
  assign n1575_o = n1574_o[51]; // extract
  assign n1577_o = n1535_o[31:3]; // extract
  assign n1578_o = {n1533_o, 1'b0, n1577_o, n1575_o, n1572_o, n1559_o, n1536_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:171:41  */
  assign n1579_o = n1578_o[52]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:124:5  */
  assign n1586_o = n1579_o ? 1'b1 : 1'b0;
  assign n1587_o = {n1533_o, 1'b0, 32'b00000000000000000000000000000000, n1536_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:179:43  */
  assign n1588_o = n1587_o[60:53]; // extract
  assign n1589_o = {n1586_o, n1575_o, n1572_o, n1559_o};
  assign n1590_o = n1588_o[3:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:166:9  */
  assign n1591_o = n1557_o ? n1589_o : n1590_o;
  assign n1592_o = n1588_o[7:4]; // extract
  assign n1593_o = n1535_o[7:4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:166:9  */
  assign n1594_o = n1557_o ? n1593_o : n1592_o;
  assign n1595_o = {n1594_o, n1591_o};
  assign n1596_o = n1535_o[7:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:150:7  */
  assign n1597_o = n1540_o ? n1596_o : n1595_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:150:7  */
  assign n1599_o = n1542_o & n1540_o;
  assign n1600_o = this_r[68:61]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:149:5  */
  assign n1601_o = n1611_o ? n1553_o : n1600_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:150:7  */
  assign n1603_o = n1540_o ? n1555_o : 1'b0;
  assign n1605_o = n1535_o[7:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:149:5  */
  assign n1606_o = n1539_o ? n1597_o : n1605_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:149:5  */
  assign n1607_o = n1539_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:149:5  */
  assign n1609_o = n1599_o & n1539_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:149:5  */
  assign n1611_o = n1540_o & n1539_o;
  assign n1612_o = n1535_o[31:8]; // extract
  assign n1614_o = this_r[44:36]; // extract
  assign n1615_o = this_r[85:69]; // extract
  assign n1616_o = this_r[60:53]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:149:5  */
  assign n1618_o = n1539_o ? n1603_o : 1'b0;
  assign n1620_o = {n1615_o, n1601_o, n1616_o, n1551_o, n1614_o, n1607_o, n1612_o, n1606_o, n1536_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:185:28  */
  assign n1621_o = n1620_o[44:39]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:185:21  */
  assign n1623_o = {1'b1, n1621_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:185:37  */
  assign n1625_o = n1623_o - 7'b0000001;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:186:27  */
  assign n1626_o = n1625_o[6]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:186:42  */
  assign n1627_o = ~n1626_o;
  assign n1628_o = {n1615_o, n1601_o, n1616_o, n1551_o, n1614_o, n1607_o, n1612_o, n1606_o, n1536_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:187:13  */
  assign n1629_o = n1628_o[1:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:187:19  */
  assign n1631_o = n1629_o == 2'b00;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:187:26  */
  assign n1632_o = n1631_o | n1627_o;
  assign n1633_o = {n1615_o, n1601_o, n1616_o, n1551_o, n1614_o, n1607_o, n1612_o, n1606_o, n1536_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:194:15  */
  assign n1634_o = n1633_o[49:45]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:194:21  */
  assign n1636_o = n1634_o == 5'b11111;
  assign n1637_o = {n1615_o, n1601_o, n1616_o, n1551_o, n1614_o, n1607_o, n1612_o, n1606_o, n1536_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:194:34  */
  assign n1638_o = n1637_o[49:45]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:194:40  */
  assign n1640_o = n1638_o == 5'b11110;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:194:26  */
  assign n1641_o = n1636_o | n1640_o;
  assign n1643_o = {n1615_o, n1601_o, n1616_o, n1551_o, n1614_o, n1607_o, n1612_o, n1606_o, n1536_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:204:53  */
  assign n1644_o = n1643_o[49:45]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:204:37  */
  assign n1645_o = {26'b0, n1644_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:204:60  */
  assign n1646_o = {1'b0, n1645_o};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:204:60  */
  assign n1648_o = n1646_o + 32'b00000000000000000000000000000001;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:204:37  */
  assign n1649_o = n1648_o[30:0];  // trunc
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:204:25  */
  assign n1650_o = n1649_o[5:0];  // trunc
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:194:7  */
  assign n1651_o = n1641_o ? 6'b111110 : n1650_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:207:30  */
  assign n1652_o = n1625_o[5:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:187:5  */
  assign n1653_o = n1632_o ? n1651_o : n1652_o;
  assign n1654_o = this_r[38:36]; // extract
  assign n1655_o = {n1615_o, n1601_o, n1616_o, n1551_o, n1653_o, n1654_o, n1607_o, n1612_o, n1606_o, n1536_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:210:13  */
  assign n1656_o = n1655_o[1:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:210:19  */
  assign n1658_o = n1656_o == 2'b00;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:210:5  */
  assign n1660_o = n1658_o ? 1'b0 : n1627_o;
  assign n1661_o = {n1615_o, n1601_o, n1616_o, n1551_o, n1653_o, n1654_o, n1607_o, n1612_o, n1606_o, n1536_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:216:15  */
  assign n1662_o = n1661_o[1:0]; // extract
  assign n1665_o = {n1615_o, n1601_o, n1616_o, n1551_o, n1653_o, n1654_o, n1607_o, n1612_o, n1606_o, 1'b0, 2'b01};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:221:39  */
  assign n1666_o = n1665_o[68:61]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:221:32  */
  assign n1668_o = {1'b1, n1666_o};
  assign n1669_o = this_r[1:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:219:9  */
  assign n1670_o = n1618_o ? 2'b01 : n1669_o;
  assign n1671_o = this_r[77:69]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:219:9  */
  assign n1672_o = n1618_o ? n1668_o : n1671_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:219:9  */
  assign n1675_o = n1618_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:217:7  */
  assign n1677_o = n1662_o == 2'b00;
  assign n1680_o = {1'b1, 2'b10};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:225:9  */
  assign n1681_o = n1660_o ? n1680_o : n1536_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:225:9  */
  assign n1684_o = n1660_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:224:7  */
  assign n1686_o = n1662_o == 2'b01;
  assign n1688_o = this_r[1:0]; // extract
  assign n1689_o = {n1615_o, n1601_o, n1616_o, n1551_o, n1653_o, n1654_o, n1607_o, n1612_o, n1606_o, 1'b0, n1688_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:234:19  */
  assign n1690_o = n1689_o[38:36]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:234:33  */
  assign n1692_o = n1690_o == 3'b111;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:234:11  */
  assign n1695_o = n1692_o ? 2'b11 : 2'b01;
  assign n1696_o = {n1615_o, n1601_o, n1616_o, n1551_o, n1653_o, n1654_o, n1607_o, n1612_o, n1606_o, 1'b0, n1695_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:242:38  */
  assign n1697_o = n1696_o[38:36]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:242:52  */
  assign n1699_o = n1697_o + 3'b001;
  assign n1700_o = {1'b0, n1695_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:232:9  */
  assign n1701_o = n1660_o ? n1700_o : n1536_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:232:9  */
  assign n1702_o = n1660_o ? n1699_o : n1654_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:232:9  */
  assign n1705_o = n1660_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:231:7  */
  assign n1707_o = n1662_o == 2'b10;
  assign n1709_o = this_r[2]; // extract
  assign n1710_o = {n1615_o, n1601_o, n1616_o, n1551_o, n1653_o, n1654_o, n1607_o, n1612_o, n1606_o, n1709_o, 2'b00};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:248:27  */
  assign n1711_o = n1710_o[85:78]; // extract
  assign n1712_o = this_r[1:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:245:9  */
  assign n1713_o = n1660_o ? 2'b00 : n1712_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:245:9  */
  assign n1714_o = n1660_o ? n1711_o : n1616_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:245:9  */
  assign n1717_o = n1660_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:244:7  */
  assign n1719_o = n1662_o == 2'b11;
  assign n1720_o = {n1719_o, n1707_o, n1686_o, n1677_o};
  assign n1721_o = n1681_o[1:0]; // extract
  assign n1722_o = n1701_o[1:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:216:5  */
  always @*
    case (n1720_o)
      4'b1000: n1724_o = n1713_o;
      4'b0100: n1724_o = n1722_o;
      4'b0010: n1724_o = n1721_o;
      4'b0001: n1724_o = n1670_o;
      default: n1724_o = 2'bX;
    endcase
  assign n1725_o = n1681_o[2]; // extract
  assign n1726_o = n1701_o[2]; // extract
  assign n1727_o = this_r[2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:216:5  */
  always @*
    case (n1720_o)
      4'b1000: n1729_o = n1727_o;
      4'b0100: n1729_o = n1726_o;
      4'b0010: n1729_o = n1725_o;
      4'b0001: n1729_o = 1'b0;
      default: n1729_o = 1'bX;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:216:5  */
  always @*
    case (n1720_o)
      4'b1000: n1731_o = n1654_o;
      4'b0100: n1731_o = n1702_o;
      4'b0010: n1731_o = n1654_o;
      4'b0001: n1731_o = n1654_o;
      default: n1731_o = 3'bX;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:216:5  */
  always @*
    case (n1720_o)
      4'b1000: n1733_o = n1714_o;
      4'b0100: n1733_o = n1616_o;
      4'b0010: n1733_o = n1616_o;
      4'b0001: n1733_o = n1616_o;
      default: n1733_o = 8'bX;
    endcase
  assign n1734_o = this_r[77:69]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:216:5  */
  always @*
    case (n1720_o)
      4'b1000: n1736_o = n1734_o;
      4'b0100: n1736_o = n1734_o;
      4'b0010: n1736_o = n1734_o;
      4'b0001: n1736_o = n1672_o;
      default: n1736_o = 9'bX;
    endcase
  assign n1738_o = this_r[85:78]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:216:5  */
  always @*
    case (n1720_o)
      4'b1000: n1741_o = n1717_o;
      4'b0100: n1741_o = n1705_o;
      4'b0010: n1741_o = 1'b0;
      4'b0001: n1741_o = n1675_o;
      default: n1741_o = 1'bX;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:216:5  */
  always @*
    case (n1720_o)
      4'b1000: n1745_o = 1'b0;
      4'b0100: n1745_o = 1'b0;
      4'b0010: n1745_o = n1684_o;
      4'b0001: n1745_o = 1'b0;
      default: n1745_o = 1'bX;
    endcase
  assign n1747_o = {n1738_o, n1736_o, n1601_o, n1733_o, n1551_o, n1653_o, n1731_o, n1607_o, n1612_o, n1606_o, n1729_o, n1724_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:253:13  */
  assign n1748_o = n1747_o[52]; // extract
  assign n1749_o = {n1738_o, n1736_o, n1601_o, n1733_o, n1551_o, n1653_o, n1731_o, n1607_o, n1612_o, n1606_o, n1729_o, n1724_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:254:29  */
  assign n1750_o = n1749_o[77]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:253:5  */
  assign n1751_o = n1748_o ? n1750_o : miso;
  assign n1752_o = {n1738_o, n1736_o, n1601_o, n1733_o, n1551_o, n1653_o, n1731_o, n1607_o, n1612_o, n1606_o, n1729_o, n1724_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:259:37  */
  assign n1753_o = n1752_o[84:78]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:259:50  */
  assign n1754_o = {n1753_o, n1751_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:258:5  */
  assign n1755_o = n1745_o ? n1754_o : n1738_o;
  assign n1756_o = {n1755_o, n1736_o, n1601_o, n1733_o, n1551_o, n1653_o, n1731_o, n1607_o, n1612_o, n1606_o, n1729_o, n1724_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:263:37  */
  assign n1757_o = n1756_o[76:69]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:263:50  */
  assign n1759_o = {n1757_o, 1'b1};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:261:5  */
  assign n1760_o = n1741_o ? n1759_o : n1736_o;
  assign n1761_o = {n1755_o, n1760_o, n1601_o, n1733_o, n1551_o, n1653_o, n1731_o, n1607_o, n1612_o, n1606_o, n1729_o, n1724_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:275:21  */
  assign n1770_o = this_r[2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:276:26  */
  assign n1771_o = this_r[77]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:277:18  */
  assign n1772_o = this_r[35:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:280:21  */
  assign n1773_o = this_r[50]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:281:41  */
  assign n1774_o = this_r[51]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:281:28  */
  assign n1775_o = ~n1774_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:271:6  */
  always @(posedge clk or posedge rst)
    if (rst)
      n1776_q <= 86'b00000000111111111000000000000000000111111000000000000000000000000000000000000000000000;
    else
      n1776_q <= this_c;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/spi2.vhd:269:6  */
  assign n1777_o = {n1775_o, n1773_o};
endmodule

module ref_devices__icache_modereg
  (input  rst,
   input  clk,
   input  db_i_en,
   input  [31:0] db_i_a,
   input  db_i_rd,
   input  db_i_wr,
   input  [3:0] db_i_we,
   input  [31:0] db_i_d,
   input  cpu0_ddr_ibus_o_en,
   input  [30:0] cpu0_ddr_ibus_o_a,
   input  cpu0_ddr_ibus_o_jp,
   input  cpu1_ddr_ibus_o_en,
   input  [30:0] cpu1_ddr_ibus_o_a,
   input  cpu1_ddr_ibus_o_jp,
   output [31:0] db_o_d,
   output db_o_ack,
   output cache0_ctrl_ic_en,
   output cache0_ctrl_ic_inv,
   output cache1_ctrl_ic_en,
   output cache1_ctrl_ic_inv,
   output cache0_ctrl_dc_en,
   output cache0_ctrl_dc_inv,
   output cache1_ctrl_dc_en,
   output cache1_ctrl_dc_inv,
   output int0,
   output int1,
   output cache01sel_ctrl_temp);
  wire [70:0] n1356_o;
  wire [31:0] n1358_o;
  wire n1359_o;
  wire [32:0] n1360_o;
  wire [32:0] n1361_o;
  wire [1:0] n1362_o;
  wire n1363_o;
  wire n1364_o;
  wire [1:0] n1365_o;
  wire n1366_o;
  wire n1367_o;
  wire [1:0] n1368_o;
  wire n1369_o;
  wire n1370_o;
  wire [1:0] n1371_o;
  wire n1372_o;
  wire n1373_o;
  wire n1376_o;
  wire [10:0] this_c;
  reg [10:0] this_r;
  wire [3:0] n1380_o;
  wire n1382_o;
  wire n1383_o;
  wire n1385_o;
  wire n1387_o;
  wire n1388_o;
  wire n1390_o;
  wire [30:0] n1391_o;
  wire [31:0] n1393_o;
  wire n1395_o;
  wire [30:0] n1396_o;
  wire [31:0] n1398_o;
  wire n1400_o;
  localparam [30:0] n1401_o = 31'b0000000000000000000000000000000;
  wire n1402_o;
  wire n1404_o;
  localparam [31:0] n1405_o = 32'b00000000000000000000000000000000;
  wire [4:0] n1406_o;
  wire n1407_o;
  wire n1408_o;
  wire n1409_o;
  reg n1410_o;
  wire n1411_o;
  wire n1412_o;
  wire n1413_o;
  wire n1414_o;
  reg n1415_o;
  wire [29:0] n1416_o;
  wire [29:0] n1417_o;
  wire [29:0] n1418_o;
  wire [29:0] n1419_o;
  reg [29:0] n1420_o;
  wire [1:0] n1423_o;
  wire [1:0] n1428_o;
  wire n1434_o;
  wire n1435_o;
  wire n1436_o;
  wire n1437_o;
  wire [3:0] n1438_o;
  wire n1439_o;
  wire n1440_o;
  wire n1441_o;
  wire n1443_o;
  wire n1444_o;
  wire n1446_o;
  wire n1447_o;
  wire n1449_o;
  wire n1451_o;
  wire n1452_o;
  wire n1453_o;
  wire n1454_o;
  wire n1456_o;
  wire n1457_o;
  wire n1459_o;
  wire n1460_o;
  wire n1462_o;
  wire n1464_o;
  wire n1465_o;
  wire n1467_o;
  wire [2:0] n1468_o;
  wire n1469_o;
  reg n1470_o;
  wire n1471_o;
  reg n1472_o;
  reg n1473_o;
  reg n1474_o;
  wire n1475_o;
  reg n1476_o;
  wire n1477_o;
  reg n1478_o;
  reg n1479_o;
  reg n1480_o;
  reg n1481_o;
  reg n1482_o;
  reg n1483_o;
  wire [10:0] n1484_o;
  wire [10:0] n1485_o;
  wire [10:0] n1486_o;
  wire n1495_o;
  wire n1496_o;
  wire n1497_o;
  wire n1498_o;
  wire n1499_o;
  wire n1500_o;
  wire n1501_o;
  wire n1502_o;
  wire n1503_o;
  wire n1504_o;
  wire n1505_o;
  wire n1506_o;
  reg [10:0] n1507_q;
  wire [32:0] n1508_o;
  wire [1:0] n1509_o;
  wire [1:0] n1510_o;
  wire [1:0] n1511_o;
  wire [1:0] n1512_o;
  assign db_o_d = n1358_o; //(module output)
  assign db_o_ack = n1359_o; //(module output)
  assign cache0_ctrl_ic_en = n1363_o; //(module output)
  assign cache0_ctrl_ic_inv = n1364_o; //(module output)
  assign cache1_ctrl_ic_en = n1366_o; //(module output)
  assign cache1_ctrl_ic_inv = n1367_o; //(module output)
  assign cache0_ctrl_dc_en = n1369_o; //(module output)
  assign cache0_ctrl_dc_inv = n1370_o; //(module output)
  assign cache1_ctrl_dc_en = n1372_o; //(module output)
  assign cache1_ctrl_dc_inv = n1373_o; //(module output)
  assign int0 = n1504_o; //(module output)
  assign int1 = n1505_o; //(module output)
  assign cache01sel_ctrl_temp = n1376_o; //(module output)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:234:81  */
  assign n1356_o = {db_i_d, db_i_we, db_i_wr, db_i_rd, db_i_a, db_i_en};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:17  */
  assign n1358_o = n1508_o[31:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:28:9  */
  assign n1359_o = n1508_o[32]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:24:9  */
  assign n1360_o = {cpu0_ddr_ibus_o_jp, cpu0_ddr_ibus_o_a, cpu0_ddr_ibus_o_en};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:23:9  */
  assign n1361_o = {cpu1_ddr_ibus_o_jp, cpu1_ddr_ibus_o_a, cpu1_ddr_ibus_o_en};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:19:4  */
  assign n1362_o = n1509_o; // (output)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:125:17  */
  assign n1363_o = n1362_o[0]; // extract
  assign n1364_o = n1362_o[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:20:4  */
  assign n1365_o = n1510_o; // (output)
  assign n1366_o = n1365_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  assign n1367_o = n1365_o[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:21:4  */
  assign n1368_o = n1511_o; // (output)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  assign n1369_o = n1368_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  assign n1370_o = n1368_o[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:22:4  */
  assign n1371_o = n1512_o; // (output)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  assign n1372_o = n1371_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  assign n1373_o = n1371_o[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:25:4  */
  assign n1376_o = n1506_o; // (output)
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:35:10  */
  assign this_c = n1486_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:36:10  */
  always @*
    this_r = n1507_q; // (isignal)
  initial
    this_r = 11'b00000000000;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:43:16  */
  assign n1380_o = n1356_o[6:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:46:26  */
  assign n1382_o = this_r[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:47:26  */
  assign n1383_o = this_r[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:44:5  */
  assign n1385_o = n1380_o == 4'b0000;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:50:26  */
  assign n1387_o = this_r[5]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:51:26  */
  assign n1388_o = this_r[4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:48:5  */
  assign n1390_o = n1380_o == 4'b0001;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:54:33  */
  assign n1391_o = n1360_o[31:1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:54:35  */
  assign n1393_o = {n1391_o, 1'b0};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:53:5  */
  assign n1395_o = n1380_o == 4'b1100;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:56:33  */
  assign n1396_o = n1361_o[31:1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:56:35  */
  assign n1398_o = {n1396_o, 1'b0};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:55:5  */
  assign n1400_o = n1380_o == 4'b1101;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:61:26  */
  assign n1402_o = this_r[10]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:59:5  */
  assign n1404_o = n1380_o == 4'b1111;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:56:9  */
  assign n1406_o = {n1404_o, n1400_o, n1395_o, n1390_o, n1385_o};
  assign n1407_o = n1393_o[0]; // extract
  assign n1408_o = n1398_o[0]; // extract
  assign n1409_o = n1405_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:43:5  */
  always @*
    case (n1406_o)
      5'b10000: n1410_o = n1402_o;
      5'b01000: n1410_o = n1408_o;
      5'b00100: n1410_o = n1407_o;
      5'b00010: n1410_o = n1388_o;
      5'b00001: n1410_o = n1383_o;
      default: n1410_o = n1409_o;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/misc_pkg.vhd:92:14  */
  assign n1411_o = n1393_o[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:36:12  */
  assign n1412_o = n1398_o[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/misc_pkg.vhd:82:12  */
  assign n1413_o = n1401_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/misc_pkg.vhd:82:12  */
  assign n1414_o = n1405_o[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:43:5  */
  always @*
    case (n1406_o)
      5'b10000: n1415_o = n1413_o;
      5'b01000: n1415_o = n1412_o;
      5'b00100: n1415_o = n1411_o;
      5'b00010: n1415_o = n1387_o;
      5'b00001: n1415_o = n1382_o;
      default: n1415_o = n1414_o;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/misc_pkg.vhd:82:12  */
  assign n1416_o = n1393_o[31:2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:79:26  */
  assign n1417_o = n1398_o[31:2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:120:17  */
  assign n1418_o = n1401_o[30:1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:120:17  */
  assign n1419_o = n1405_o[31:2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:43:5  */
  always @*
    case (n1406_o)
      5'b10000: n1420_o = n1418_o;
      5'b01000: n1420_o = n1417_o;
      5'b00100: n1420_o = n1416_o;
      5'b00010: n1420_o = 30'b100000000000000000000000000000;
      5'b00001: n1420_o = 30'b100000000000000000000000000000;
      default: n1420_o = n1419_o;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:373:17  */
  assign n1423_o = this_r[1:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:241:17  */
  assign n1428_o = this_r[5:4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:209:17  */
  assign n1434_o = this_r[10]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:74:14  */
  assign n1435_o = n1356_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:74:34  */
  assign n1436_o = n1356_o[34]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:74:24  */
  assign n1437_o = n1436_o & n1435_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:75:18  */
  assign n1438_o = n1356_o[6:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:78:30  */
  assign n1439_o = n1356_o[39]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:79:30  */
  assign n1440_o = n1356_o[40]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:80:18  */
  assign n1441_o = n1356_o[47]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:80:9  */
  assign n1443_o = n1441_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:81:18  */
  assign n1444_o = n1356_o[48]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:81:9  */
  assign n1446_o = n1444_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:82:18  */
  assign n1447_o = n1356_o[67]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:82:9  */
  assign n1449_o = n1447_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:76:7  */
  assign n1451_o = n1438_o == 4'b0000;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:85:30  */
  assign n1452_o = n1356_o[39]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:86:30  */
  assign n1453_o = n1356_o[40]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:87:18  */
  assign n1454_o = n1356_o[47]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:87:9  */
  assign n1456_o = n1454_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:88:18  */
  assign n1457_o = n1356_o[48]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:88:9  */
  assign n1459_o = n1457_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:89:18  */
  assign n1460_o = n1356_o[67]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:89:9  */
  assign n1462_o = n1460_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:83:7  */
  assign n1464_o = n1438_o == 4'b0001;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:92:44  */
  assign n1465_o = n1356_o[39]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:91:7  */
  assign n1467_o = n1438_o == 4'b1111;
  assign n1468_o = {n1467_o, n1464_o, n1451_o};
  assign n1469_o = this_r[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:75:7  */
  always @*
    case (n1468_o)
      3'b100: n1470_o = n1469_o;
      3'b010: n1470_o = n1469_o;
      3'b001: n1470_o = n1439_o;
      default: n1470_o = n1469_o;
    endcase
  assign n1471_o = this_r[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:75:7  */
  always @*
    case (n1468_o)
      3'b100: n1472_o = n1471_o;
      3'b010: n1472_o = n1471_o;
      3'b001: n1472_o = n1440_o;
      default: n1472_o = n1471_o;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:75:7  */
  always @*
    case (n1468_o)
      3'b100: n1473_o = 1'b0;
      3'b010: n1473_o = 1'b0;
      3'b001: n1473_o = n1443_o;
      default: n1473_o = 1'b0;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:75:7  */
  always @*
    case (n1468_o)
      3'b100: n1474_o = 1'b0;
      3'b010: n1474_o = 1'b0;
      3'b001: n1474_o = n1446_o;
      default: n1474_o = 1'b0;
    endcase
  assign n1475_o = this_r[4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:75:7  */
  always @*
    case (n1468_o)
      3'b100: n1476_o = n1475_o;
      3'b010: n1476_o = n1452_o;
      3'b001: n1476_o = n1475_o;
      default: n1476_o = n1475_o;
    endcase
  assign n1477_o = this_r[5]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:75:7  */
  always @*
    case (n1468_o)
      3'b100: n1478_o = n1477_o;
      3'b010: n1478_o = n1453_o;
      3'b001: n1478_o = n1477_o;
      default: n1478_o = n1477_o;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:75:7  */
  always @*
    case (n1468_o)
      3'b100: n1479_o = 1'b0;
      3'b010: n1479_o = n1456_o;
      3'b001: n1479_o = 1'b0;
      default: n1479_o = 1'b0;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:75:7  */
  always @*
    case (n1468_o)
      3'b100: n1480_o = 1'b0;
      3'b010: n1480_o = n1459_o;
      3'b001: n1480_o = 1'b0;
      default: n1480_o = 1'b0;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:75:7  */
  always @*
    case (n1468_o)
      3'b100: n1481_o = 1'b0;
      3'b010: n1481_o = 1'b0;
      3'b001: n1481_o = n1449_o;
      default: n1481_o = 1'b0;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:75:7  */
  always @*
    case (n1468_o)
      3'b100: n1482_o = 1'b0;
      3'b010: n1482_o = n1462_o;
      3'b001: n1482_o = 1'b0;
      default: n1482_o = 1'b0;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:75:7  */
  always @*
    case (n1468_o)
      3'b100: n1483_o = n1465_o;
      3'b010: n1483_o = n1434_o;
      3'b001: n1483_o = n1434_o;
      default: n1483_o = n1434_o;
    endcase
  assign n1484_o = {n1483_o, n1482_o, n1481_o, n1480_o, n1479_o, n1478_o, n1476_o, n1474_o, n1473_o, n1472_o, n1470_o};
  assign n1485_o = {n1434_o, 1'b0, 1'b0, 1'b0, 1'b0, n1428_o, 1'b0, 1'b0, n1423_o};
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:74:5  */
  assign n1486_o = n1437_o ? n1484_o : n1485_o;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:115:20  */
  assign n1495_o = n1356_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:116:31  */
  assign n1496_o = this_r[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:117:32  */
  assign n1497_o = this_r[2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:120:31  */
  assign n1498_o = this_r[4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:121:32  */
  assign n1499_o = this_r[6]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:122:31  */
  assign n1500_o = this_r[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:123:32  */
  assign n1501_o = this_r[3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:124:31  */
  assign n1502_o = this_r[5]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:125:32  */
  assign n1503_o = this_r[7]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:126:18  */
  assign n1504_o = this_r[8]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:127:18  */
  assign n1505_o = this_r[9]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:128:34  */
  assign n1506_o = this_r[10]; // extract
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:104:6  */
  always @(posedge clk or posedge rst)
    if (rst)
      n1507_q <= 11'b00000000000;
    else
      n1507_q <= this_c;
  /* /home/imi415/Documents/Workspaces/J2/build/ref/pre/ref_devices__icache_modereg.vhd:102:6  */
  assign n1508_o = {n1495_o, n1420_o, n1415_o, n1410_o};
  assign n1509_o = {n1497_o, n1496_o};
  assign n1510_o = {n1499_o, n1498_o};
  assign n1511_o = {n1501_o, n1500_o};
  assign n1512_o = {n1503_o, n1502_o};
endmodule

module ref_devices__aic_20_e72b4ff27ee3ed4623c72c79d0e6ca011b4a0698
  (input  clk_bus,
   input  rst_i,
   input  db_i_en,
   input  [31:0] db_i_a,
   input  db_i_rd,
   input  db_i_wr,
   input  [3:0] db_i_we,
   input  [31:0] db_i_d,
   input  bstb_i,
   input  back_i,
   input  [7:0] irq_i,
   input  enmi_i,
   input  event_i_ack,
   input  [3:0] event_i_lvl,
   input  event_i_slp,
   input  event_i_dbg,
   output [31:0] db_o_d,
   output db_o_ack,
   output [63:0] rtc_sec,
   output [31:0] rtc_nsec,
   output event_o_en,
   output [1:0] event_o_cmd,
   output [7:0] event_o_vec,
   output event_o_msk,
   output [3:0] event_o_lvl);
  wire [70:0] n473_o;
  wire [31:0] n475_o;
  wire n476_o;
  wire [6:0] n479_o;
  wire n481_o;
  wire [1:0] n482_o;
  wire [7:0] n483_o;
  wire n484_o;
  wire [3:0] n485_o;
  wire [24:0] reg_event;
  wire [24:0] w_event;
  wire [24:0] w_irqevent;
  wire w_ack;
  wire s_enmi;
  wire s_eirq;
  wire s_eirq2;
  wire s_cer;
  wire s_der;
  wire s_mrs;
  wire w_wctrl;
  wire w_enmi;
  wire w_cer1;
  wire w_cer2;
  wire w_cer3;
  wire [11:0] testvect;
  wire count_enable;
  wire pit_enable;
  wire brk_enable;
  wire pit_event;
  wire [11:0] count;
  wire [31:0] brkadr;
  wire r_nmi;
  wire r_irq1;
  wire r_irq10;
  wire r_cpuerr;
  wire r_dmaerr;
  wire r_mrst;
  wire [31:0] w_debug;
  wire [31:0] w_pitout;
  wire [31:0] w_rtcout;
  wire [31:0] pit_cntr;
  wire [31:0] pit_throttle;
  wire [63:0] reg_rtc_sec;
  wire [31:0] reg_rtc_nsec;
  wire [7:0] es_irqs;
  wire [7:0] q_irqs;
  wire [7:0] ec_irqs;
  wire [31:0] ilevel;
  wire qq_irqs;
  wire vnmi;
  wire [20:0] vcount;
  wire [1:0] vstate;
  wire db_state;
  wire [3:0] db_count;
  wire [10:0] db_ackcount;
  wire pit_flag;
  wire [2:0] event_req;
  wire [11:0] event_info;
  wire n493_o;
  wire n496_o;
  wire n501_o;
  wire n503_o;
  wire n504_o;
  wire n507_o;
  wire n509_o;
  wire n510_o;
  wire n513_o;
  wire [2:0] n515_o;
  reg [1:0] n516_o;
  wire n519_o;
  wire n522_o;
  wire [3:0] n525_o;
  wire [7:0] n526_o;
  wire [15:0] n527_o;
  wire get_irqs_n1_iedge_inst_n528;
  wire n529_o;
  wire n530_o;
  wire n531_o;
  wire get_irqs_n1_iedge_inst_q;
  wire get_irqs_n2_iedge_inst_n534;
  wire n535_o;
  wire n536_o;
  wire n537_o;
  wire get_irqs_n2_iedge_inst_q;
  wire get_irqs_n3_iedge_inst_n540;
  wire n541_o;
  wire n542_o;
  wire n543_o;
  wire get_irqs_n3_iedge_inst_q;
  wire get_irqs_n4_iedge_inst_n546;
  wire n547_o;
  wire n548_o;
  wire n549_o;
  wire get_irqs_n4_iedge_inst_q;
  wire get_irqs_n5_iedge_inst_n552;
  wire n553_o;
  wire n554_o;
  wire n555_o;
  wire get_irqs_n5_iedge_inst_q;
  wire get_irqs_n6_iedge_inst_n558;
  wire n559_o;
  wire n560_o;
  wire n561_o;
  wire get_irqs_n6_iedge_inst_q;
  wire get_irqs_n7_iedge_inst_n564;
  wire n565_o;
  wire n566_o;
  wire n567_o;
  wire get_irqs_n7_iedge_inst_q;
  wire get_irqs_n8_iedge_inst_n570;
  wire n571_o;
  wire n572_o;
  wire n573_o;
  wire get_irqs_n8_iedge_inst_q;
  wire n579_o;
  wire [31:0] n581_o;
  wire [63:0] n583_o;
  wire [31:0] n585_o;
  wire [63:0] n586_o;
  wire [31:0] n587_o;
  wire n588_o;
  wire n589_o;
  wire n590_o;
  wire [1:0] n591_o;
  wire n593_o;
  wire [31:0] n594_o;
  wire [1:0] n595_o;
  wire n597_o;
  wire [31:0] n598_o;
  wire [1:0] n599_o;
  wire n601_o;
  wire [31:0] n602_o;
  wire [31:0] n603_o;
  wire [31:0] n604_o;
  wire [31:0] n605_o;
  wire [31:0] n606_o;
  wire [31:0] n607_o;
  wire [31:0] n608_o;
  wire [31:0] n609_o;
  wire [31:0] n610_o;
  wire [31:0] n611_o;
  wire [63:0] n612_o;
  wire [63:0] n613_o;
  wire [31:0] n614_o;
  wire n624_o;
  wire [3:0] n626_o;
  wire n628_o;
  wire [3:0] n629_o;
  wire n631_o;
  wire n632_o;
  wire n633_o;
  wire n635_o;
  wire n637_o;
  wire [1:0] n638_o;
  reg n640_o;
  reg [3:0] n642_o;
  wire n672_o;
  wire n673_o;
  wire n674_o;
  wire n676_o;
  wire n677_o;
  wire n678_o;
  wire [31:0] n679_o;
  wire n680_o;
  wire [31:0] n681_o;
  wire n682_o;
  wire [31:0] n683_o;
  wire [5:0] n685_o;
  wire [6:0] n686_o;
  wire [7:0] n687_o;
  wire [19:0] n688_o;
  wire [31:0] n689_o;
  wire n690_o;
  wire n691_o;
  wire [31:0] n692_o;
  wire [3:0] n693_o;
  wire [3:0] n694_o;
  wire [7:0] n695_o;
  wire [3:0] n696_o;
  wire [11:0] n697_o;
  wire [3:0] n698_o;
  wire [15:0] n699_o;
  wire [3:0] n700_o;
  wire [19:0] n701_o;
  wire [3:0] n702_o;
  wire [23:0] n703_o;
  wire [3:0] n704_o;
  wire [27:0] n705_o;
  wire [3:0] n706_o;
  wire [31:0] n707_o;
  wire n708_o;
  wire n709_o;
  wire [31:0] n710_o;
  wire [15:0] n711_o;
  wire [16:0] n712_o;
  wire [27:0] n713_o;
  wire [31:0] n714_o;
  wire [1:0] n716_o;
  wire n718_o;
  wire [31:0] n719_o;
  wire n721_o;
  wire [31:0] n722_o;
  wire n723_o;
  wire n724_o;
  wire [31:0] n725_o;
  wire [31:0] n726_o;
  wire [1:0] n727_o;
  wire n729_o;
  wire [31:0] n730_o;
  wire [31:0] n731_o;
  wire [1:0] n732_o;
  wire n734_o;
  wire [31:0] n735_o;
  wire [1:0] n736_o;
  wire n738_o;
  wire [31:0] n739_o;
  wire n741_o;
  wire n742_o;
  wire n743_o;
  wire n744_o;
  wire n745_o;
  wire n746_o;
  wire n747_o;
  wire n748_o;
  wire n749_o;
  wire n750_o;
  wire n751_o;
  wire n752_o;
  wire n753_o;
  wire n754_o;
  wire n755_o;
  wire n756_o;
  wire n757_o;
  wire n758_o;
  wire n759_o;
  wire n760_o;
  wire n761_o;
  wire n762_o;
  wire n763_o;
  wire n764_o;
  wire n765_o;
  wire n766_o;
  wire n767_o;
  wire n768_o;
  wire n769_o;
  wire n770_o;
  wire n771_o;
  wire n772_o;
  wire n773_o;
  wire n774_o;
  wire n775_o;
  wire n776_o;
  wire n777_o;
  wire n778_o;
  wire n779_o;
  wire n780_o;
  wire n781_o;
  wire n782_o;
  wire n783_o;
  wire n784_o;
  wire n785_o;
  wire n786_o;
  wire n787_o;
  wire n788_o;
  wire n789_o;
  wire n790_o;
  wire n791_o;
  wire n792_o;
  wire n793_o;
  wire n794_o;
  wire n795_o;
  wire n796_o;
  wire n797_o;
  wire n798_o;
  wire n799_o;
  wire n800_o;
  wire n801_o;
  wire n802_o;
  wire n803_o;
  wire n804_o;
  wire n805_o;
  wire n806_o;
  wire n807_o;
  wire n808_o;
  wire n809_o;
  wire n810_o;
  wire n811_o;
  wire [24:0] n813_o;
  wire [24:0] n815_o;
  wire [24:0] n817_o;
  wire [24:0] n819_o;
  wire [24:0] n821_o;
  wire [24:0] n822_o;
  wire [24:0] n823_o;
  wire [24:0] n825_o;
  wire [24:0] n833_o;
  wire [2:0] n836_o;
  wire [11:0] n837_o;
  wire n841_o;
  wire [3:0] n842_o;
  wire n844_o;
  wire [3:0] n845_o;
  wire [2:0] n848_o;
  wire [3:0] n850_o;
  wire [2:0] n852_o;
  wire [3:0] n855_o;
  wire n857_o;
  wire [3:0] n858_o;
  wire n859_o;
  wire [3:0] n860_o;
  wire [2:0] n862_o;
  wire [3:0] n863_o;
  wire n864_o;
  wire n865_o;
  wire n866_o;
  wire [3:0] n867_o;
  wire n868_o;
  wire [3:0] n869_o;
  wire [2:0] n871_o;
  wire [3:0] n872_o;
  wire n873_o;
  wire n874_o;
  wire n875_o;
  wire [3:0] n876_o;
  wire n877_o;
  wire [3:0] n878_o;
  wire [2:0] n880_o;
  wire [3:0] n881_o;
  wire n882_o;
  wire n883_o;
  wire n884_o;
  wire [3:0] n885_o;
  wire n886_o;
  wire [3:0] n887_o;
  wire [2:0] n889_o;
  wire [3:0] n890_o;
  wire n891_o;
  wire n892_o;
  wire n893_o;
  wire [3:0] n894_o;
  wire n895_o;
  wire [3:0] n896_o;
  wire [2:0] n898_o;
  wire [3:0] n899_o;
  wire n900_o;
  wire n901_o;
  wire n902_o;
  wire [3:0] n903_o;
  wire n904_o;
  wire [3:0] n905_o;
  wire [2:0] n907_o;
  wire [3:0] n908_o;
  wire n909_o;
  wire n910_o;
  wire n911_o;
  wire [3:0] n912_o;
  wire n913_o;
  wire [2:0] n916_o;
  wire n918_o;
  wire [2:0] n921_o;
  wire [8:0] n926_o;
  wire [9:0] n928_o;
  wire [12:0] n930_o;
  wire [2:0] n932_o;
  wire [16:0] n935_o;
  wire [2:0] n937_o;
  wire [24:0] n941_o;
  wire n944_o;
  wire n945_o;
  wire n957_o;
  wire n958_o;
  wire n959_o;
  wire n960_o;
  wire n961_o;
  wire n962_o;
  wire n963_o;
  wire n964_o;
  wire n965_o;
  wire n966_o;
  wire n967_o;
  wire n968_o;
  wire [11:0] n969_o;
  wire n971_o;
  wire n972_o;
  wire n973_o;
  wire [11:0] n974_o;
  wire [31:0] n975_o;
  wire n976_o;
  wire [11:0] n980_o;
  wire [31:0] n981_o;
  wire n982_o;
  wire n983_o;
  wire [3:0] n984_o;
  wire [3:0] n985_o;
  wire [3:0] n986_o;
  wire [3:0] n987_o;
  wire [3:0] n988_o;
  wire [3:0] n989_o;
  wire [3:0] n990_o;
  wire [3:0] n991_o;
  wire [31:0] n992_o;
  wire [31:0] n993_o;
  wire n994_o;
  wire n995_o;
  wire n996_o;
  wire n997_o;
  wire n998_o;
  wire [31:0] n1000_o;
  wire [1:0] n1001_o;
  wire n1003_o;
  wire n1004_o;
  wire [31:0] n1005_o;
  wire [31:0] n1006_o;
  wire n1007_o;
  wire n1008_o;
  wire n1009_o;
  wire n1010_o;
  wire n1011_o;
  wire n1012_o;
  wire n1013_o;
  wire [31:0] n1014_o;
  wire n1016_o;
  wire n1017_o;
  wire n1018_o;
  wire n1019_o;
  wire n1020_o;
  wire n1021_o;
  wire n1023_o;
  wire [11:0] n1025_o;
  wire [11:0] n1026_o;
  wire n1027_o;
  wire [31:0] n1029_o;
  wire [31:0] n1031_o;
  wire [31:0] n1034_o;
  wire n1035_o;
  wire n1037_o;
  wire n1039_o;
  wire n1041_o;
  wire n1043_o;
  wire n1045_o;
  wire n1047_o;
  wire n1048_o;
  wire [2:0] n1049_o;
  wire n1051_o;
  wire [2:0] n1052_o;
  wire n1054_o;
  wire [2:0] n1055_o;
  wire n1057_o;
  wire [2:0] n1058_o;
  wire n1060_o;
  wire [2:0] n1061_o;
  wire n1063_o;
  wire n1064_o;
  wire n1065_o;
  wire n1067_o;
  wire n1069_o;
  wire n1070_o;
  wire [7:0] n1071_o;
  wire n1072_o;
  wire n1073_o;
  wire [7:0] n1075_o;
  wire n1077_o;
  wire n1078_o;
  wire n1079_o;
  wire [7:0] n1081_o;
  wire n1082_o;
  wire n1083_o;
  wire n1084_o;
  wire n1086_o;
  wire [7:0] n1088_o;
  wire n1089_o;
  wire n1090_o;
  wire n1091_o;
  wire n1093_o;
  wire n1094_o;
  wire [7:0] n1096_o;
  wire n1097_o;
  wire n1098_o;
  wire n1099_o;
  wire n1100_o;
  wire n1101_o;
  wire n1103_o;
  wire [7:0] n1105_o;
  wire n1107_o;
  wire n1108_o;
  wire n1109_o;
  wire n1110_o;
  wire n1111_o;
  wire n1112_o;
  wire [7:0] n1114_o;
  wire [31:0] n1165_o;
  wire n1171_o;
  wire n1172_o;
  wire n1173_o;
  wire [3:0] n1175_o;
  wire n1177_o;
  wire n1178_o;
  wire n1180_o;
  wire n1181_o;
  wire n1182_o;
  wire n1184_o;
  wire n1185_o;
  wire n1186_o;
  wire n1187_o;
  wire n1188_o;
  wire n1189_o;
  wire n1190_o;
  wire n1191_o;
  wire n1192_o;
  wire n1193_o;
  wire n1194_o;
  wire n1195_o;
  wire n1196_o;
  wire n1197_o;
  wire n1198_o;
  wire n1199_o;
  wire n1200_o;
  wire n1201_o;
  wire n1202_o;
  wire n1203_o;
  wire n1204_o;
  wire n1205_o;
  wire n1206_o;
  wire n1207_o;
  wire n1208_o;
  wire n1209_o;
  wire n1210_o;
  wire n1211_o;
  wire n1212_o;
  wire n1213_o;
  wire n1214_o;
  wire n1215_o;
  wire n1216_o;
  wire n1217_o;
  wire n1218_o;
  wire n1219_o;
  wire n1220_o;
  wire n1221_o;
  wire n1222_o;
  wire n1223_o;
  wire n1224_o;
  wire n1225_o;
  wire n1226_o;
  wire n1227_o;
  wire n1228_o;
  wire n1229_o;
  wire n1230_o;
  wire n1231_o;
  wire n1232_o;
  wire n1233_o;
  wire n1234_o;
  wire n1235_o;
  wire n1237_o;
  wire n1238_o;
  wire n1240_o;
  wire n1241_o;
  wire n1242_o;
  wire n1243_o;
  wire n1244_o;
  wire n1245_o;
  wire [31:0] n1246_o;
  wire n1247_o;
  wire n1248_o;
  wire n1253_o;
  wire n1255_o;
  wire [1:0] n1257_o;
  wire n1259_o;
  wire n1261_o;
  wire [23:0] n1262_o;
  wire n1264_o;
  wire [20:0] n1266_o;
  wire [20:0] n1267_o;
  wire [1:0] n1269_o;
  wire n1271_o;
  wire [20:0] n1273_o;
  wire [1:0] n1276_o;
  wire n1278_o;
  wire [3:0] n1279_o;
  reg n1282_o;
  reg [20:0] n1285_o;
  reg [1:0] n1288_o;
  reg [24:0] n1299_q;
  reg n1300_q;
  wire [11:0] n1301_o;
  reg [11:0] n1302_q;
  wire n1303_o;
  reg n1304_q;
  wire n1305_o;
  reg n1306_q;
  wire n1307_o;
  reg n1308_q;
  reg [11:0] n1309_q;
  wire [31:0] n1310_o;
  reg [31:0] n1311_q;
  reg n1312_q;
  reg n1313_q;
  reg n1314_q;
  reg n1315_q;
  reg n1316_q;
  reg n1317_q;
  reg [31:0] n1318_q;
  wire [31:0] n1319_o;
  reg [31:0] n1320_q;
  reg [63:0] n1321_q;
  reg [31:0] n1322_q;
  wire [7:0] n1323_o;
  wire [7:0] n1324_o;
  reg [7:0] n1325_q;
  wire [31:0] n1326_o;
  reg [31:0] n1327_q;
  reg n1328_q;
  reg [20:0] n1329_q;
  reg [1:0] n1330_q;
  reg n1331_q;
  reg [3:0] n1333_q;
  reg [10:0] n1334_q;
  wire n1335_o;
  reg n1336_q;
  wire [32:0] n1337_o;
  wire [7:0] n1339_data; // mem_rd
  wire [7:0] n1341_data; // mem_rd
  wire [3:0] n1342_o;
  wire [3:0] n1343_o;
  wire [3:0] n1344_o;
  wire [3:0] n1345_o;
  wire [3:0] n1346_o;
  wire [3:0] n1347_o;
  wire [3:0] n1348_o;
  wire [3:0] n1349_o;
  wire [1:0] n1350_o;
  reg [3:0] n1351_o;
  wire [1:0] n1352_o;
  reg [3:0] n1353_o;
  wire n1354_o;
  wire [3:0] n1355_o;
  assign db_o_d = n475_o; //(module output)
  assign db_o_ack = n476_o; //(module output)
  assign rtc_sec = reg_rtc_sec; //(module output)
  assign rtc_nsec = reg_rtc_nsec; //(module output)
  assign event_o_en = n481_o; //(module output)
  assign event_o_cmd = n482_o; //(module output)
  assign event_o_vec = n483_o; //(module output)
  assign event_o_msk = n484_o; //(module output)
  assign event_o_lvl = n485_o; //(module output)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:88:38  */
  assign n473_o = {db_i_d, db_i_we, db_i_wr, db_i_rd, db_i_a, db_i_en};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:116:31  */
  assign n475_o = n1337_o[31:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:119:31  */
  assign n476_o = n1337_o[32]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:107:24  */
  assign n479_o = {event_i_dbg, event_i_slp, event_i_lvl, event_i_ack};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:42:9  */
  assign n481_o = n527_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:39:9  */
  assign n482_o = n527_o[2:1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:37:9  */
  assign n483_o = n527_o[10:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:36:9  */
  assign n484_o = n527_o[11]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:35:9  */
  assign n485_o = n527_o[15:12]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:55:16  */
  assign reg_event = n1299_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:55:27  */
  assign w_event = n813_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:55:36  */
  assign w_irqevent = n941_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:56:17  */
  assign w_ack = n1300_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:57:16  */
  assign s_enmi = n1243_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:57:24  */
  assign s_eirq = n1235_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:57:32  */
  assign s_eirq2 = n1238_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:57:41  */
  assign s_cer = n1192_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:57:48  */
  assign s_der = n1187_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:57:55  */
  assign s_mrs = n1185_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:57:62  */
  assign w_wctrl = n1173_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:57:71  */
  assign w_enmi = n1248_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:58:16  */
  assign w_cer1 = n1205_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:58:24  */
  assign w_cer2 = n1219_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:58:32  */
  assign w_cer3 = n1232_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:59:16  */
  assign testvect = n1302_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:60:16  */
  assign count_enable = n1304_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:60:30  */
  assign pit_enable = n1306_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:60:42  */
  assign brk_enable = n1308_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:60:54  */
  assign pit_event = n945_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:61:16  */
  assign count = n1309_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:62:16  */
  assign brkadr = n1311_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:63:16  */
  assign r_nmi = n1312_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:63:23  */
  assign r_irq1 = n1313_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:63:31  */
  assign r_irq10 = n1314_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:63:40  */
  assign r_cpuerr = n1315_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:63:50  */
  assign r_dmaerr = n1316_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:63:60  */
  assign r_mrst = n1317_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:64:16  */
  assign w_debug = n710_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:64:25  */
  assign w_pitout = n719_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:64:35  */
  assign w_rtcout = n730_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:65:16  */
  assign pit_cntr = n1318_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:65:26  */
  assign pit_throttle = n1320_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:66:16  */
  assign reg_rtc_sec = n1321_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:67:16  */
  assign reg_rtc_nsec = n1322_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:68:16  */
  assign es_irqs = n1323_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:68:25  */
  assign q_irqs = n1324_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:68:33  */
  assign ec_irqs = n1325_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:70:16  */
  assign ilevel = n1327_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:71:16  */
  assign qq_irqs = n811_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:72:16  */
  assign vnmi = n1328_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:73:16  */
  assign vcount = n1329_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:75:16  */
  assign vstate = n1330_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:79:16  */
  assign db_state = n1331_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:80:16  */
  assign db_count = n1333_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:81:16  */
  assign db_ackcount = n1334_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:82:16  */
  assign pit_flag = n1336_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:84:16  */
  assign event_req = n836_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:85:16  */
  assign event_info = n837_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/misc_pkg.vhd:94:18  */
  assign n493_o = event_req == 3'b111;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/misc_pkg.vhd:94:5  */
  assign n496_o = n493_o ? 1'b0 : 1'b1;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/misc_pkg.vhd:100:7  */
  assign n501_o = event_req == 3'b000;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/misc_pkg.vhd:100:18  */
  assign n503_o = event_req == 3'b001;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/misc_pkg.vhd:100:18  */
  assign n504_o = n501_o | n503_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/misc_pkg.vhd:102:7  */
  assign n507_o = event_req == 3'b010;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/misc_pkg.vhd:102:18  */
  assign n509_o = event_req == 3'b011;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/misc_pkg.vhd:102:18  */
  assign n510_o = n507_o | n509_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/misc_pkg.vhd:104:7  */
  assign n513_o = event_req == 3'b100;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:28:12  */
  assign n515_o = {n513_o, n510_o, n504_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/misc_pkg.vhd:99:5  */
  always @*
    case (n515_o)
      3'b100: n516_o = 2'b10;
      3'b010: n516_o = 2'b01;
      3'b001: n516_o = 2'b00;
      default: n516_o = 2'b11;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/misc_pkg.vhd:109:18  */
  assign n519_o = event_req == 3'b000;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/misc_pkg.vhd:109:5  */
  assign n522_o = n519_o ? 1'b0 : 1'b1;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/misc_pkg.vhd:114:30  */
  assign n525_o = event_info[11:8]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/misc_pkg.vhd:115:30  */
  assign n526_o = event_info[7:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:57:13  */
  assign n527_o = {n525_o, n522_o, n526_o, n516_o, n496_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:57  */
  assign get_irqs_n1_iedge_inst_n528 = get_irqs_n1_iedge_inst_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:112  */
  assign n529_o = irq_i[7]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:134  */
  assign n530_o = es_irqs[7]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:157  */
  assign n531_o = ec_irqs[7]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:17  */
  ref_devices__aic_edgedet get_irqs_n1_iedge_inst (
    .clk(clk_bus),
    .rst(rst_i),
    .irq(n529_o),
    .en_i(n530_o),
    .clr_i(n531_o),
    .q(get_irqs_n1_iedge_inst_q));
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:57  */
  assign get_irqs_n2_iedge_inst_n534 = get_irqs_n2_iedge_inst_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:112  */
  assign n535_o = irq_i[6]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:134  */
  assign n536_o = es_irqs[6]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:157  */
  assign n537_o = ec_irqs[6]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:17  */
  ref_devices__aic_edgedet get_irqs_n2_iedge_inst (
    .clk(clk_bus),
    .rst(rst_i),
    .irq(n535_o),
    .en_i(n536_o),
    .clr_i(n537_o),
    .q(get_irqs_n2_iedge_inst_q));
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:57  */
  assign get_irqs_n3_iedge_inst_n540 = get_irqs_n3_iedge_inst_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:112  */
  assign n541_o = irq_i[5]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:134  */
  assign n542_o = es_irqs[5]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:157  */
  assign n543_o = ec_irqs[5]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:17  */
  ref_devices__aic_edgedet get_irqs_n3_iedge_inst (
    .clk(clk_bus),
    .rst(rst_i),
    .irq(n541_o),
    .en_i(n542_o),
    .clr_i(n543_o),
    .q(get_irqs_n3_iedge_inst_q));
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:57  */
  assign get_irqs_n4_iedge_inst_n546 = get_irqs_n4_iedge_inst_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:112  */
  assign n547_o = irq_i[4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:134  */
  assign n548_o = es_irqs[4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:157  */
  assign n549_o = ec_irqs[4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:17  */
  ref_devices__aic_edgedet get_irqs_n4_iedge_inst (
    .clk(clk_bus),
    .rst(rst_i),
    .irq(n547_o),
    .en_i(n548_o),
    .clr_i(n549_o),
    .q(get_irqs_n4_iedge_inst_q));
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:57  */
  assign get_irqs_n5_iedge_inst_n552 = get_irqs_n5_iedge_inst_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:112  */
  assign n553_o = irq_i[3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:134  */
  assign n554_o = es_irqs[3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:157  */
  assign n555_o = ec_irqs[3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:17  */
  ref_devices__aic_edgedet get_irqs_n5_iedge_inst (
    .clk(clk_bus),
    .rst(rst_i),
    .irq(n553_o),
    .en_i(n554_o),
    .clr_i(n555_o),
    .q(get_irqs_n5_iedge_inst_q));
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:57  */
  assign get_irqs_n6_iedge_inst_n558 = get_irqs_n6_iedge_inst_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:112  */
  assign n559_o = irq_i[2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:134  */
  assign n560_o = es_irqs[2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:157  */
  assign n561_o = ec_irqs[2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:17  */
  ref_devices__aic_edgedet get_irqs_n6_iedge_inst (
    .clk(clk_bus),
    .rst(rst_i),
    .irq(n559_o),
    .en_i(n560_o),
    .clr_i(n561_o),
    .q(get_irqs_n6_iedge_inst_q));
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:57  */
  assign get_irqs_n7_iedge_inst_n564 = get_irqs_n7_iedge_inst_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:112  */
  assign n565_o = irq_i[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:134  */
  assign n566_o = es_irqs[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:157  */
  assign n567_o = ec_irqs[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:17  */
  ref_devices__aic_edgedet get_irqs_n7_iedge_inst (
    .clk(clk_bus),
    .rst(rst_i),
    .irq(n565_o),
    .en_i(n566_o),
    .clr_i(n567_o),
    .q(get_irqs_n7_iedge_inst_q));
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:57  */
  assign get_irqs_n8_iedge_inst_n570 = get_irqs_n8_iedge_inst_q; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:112  */
  assign n571_o = irq_i[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:134  */
  assign n572_o = es_irqs[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:157  */
  assign n573_o = ec_irqs[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:17  */
  ref_devices__aic_edgedet get_irqs_n8_iedge_inst (
    .clk(clk_bus),
    .rst(rst_i),
    .irq(n571_o),
    .en_i(n572_o),
    .clr_i(n573_o),
    .q(get_irqs_n8_iedge_inst_q));
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:100:41  */
  assign n579_o = $unsigned(reg_rtc_nsec) >= $unsigned(32'b00111011100110101100101000000000);
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:101:62  */
  assign n581_o = reg_rtc_nsec - 32'b00111011100110101100100111101100;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:102:60  */
  assign n583_o = reg_rtc_sec + 64'b0000000000000000000000000000000000000000000000000000000000000001;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:104:62  */
  assign n585_o = reg_rtc_nsec + 32'b00000000000000000000000000010100;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:100:25  */
  assign n586_o = n579_o ? n583_o : reg_rtc_sec;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:100:25  */
  assign n587_o = n579_o ? n581_o : n585_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:106:34  */
  assign n588_o = n473_o[34]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:106:47  */
  assign n589_o = n473_o[6]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:106:37  */
  assign n590_o = n588_o & n589_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:107:42  */
  assign n591_o = n473_o[4:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:107:55  */
  assign n593_o = n591_o == 2'b00;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:108:75  */
  assign n594_o = n473_o[70:39]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:109:45  */
  assign n595_o = n473_o[4:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:109:58  */
  assign n597_o = n595_o == 2'b01;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:110:74  */
  assign n598_o = n473_o[70:39]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:111:45  */
  assign n599_o = n473_o[4:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:111:58  */
  assign n601_o = n599_o == 2'b10;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:112:62  */
  assign n602_o = n473_o[70:39]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:111:33  */
  assign n603_o = n601_o ? n602_o : n587_o;
  assign n604_o = n586_o[31:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:109:33  */
  assign n605_o = n597_o ? n598_o : n604_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:109:33  */
  assign n606_o = n597_o ? n587_o : n603_o;
  assign n607_o = n586_o[31:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:107:33  */
  assign n608_o = n593_o ? n607_o : n605_o;
  assign n609_o = n586_o[63:32]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:107:33  */
  assign n610_o = n593_o ? n594_o : n609_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:107:33  */
  assign n611_o = n593_o ? n587_o : n606_o;
  assign n612_o = {n610_o, n608_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:106:25  */
  assign n613_o = n590_o ? n612_o : n586_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:106:25  */
  assign n614_o = n590_o ? n611_o : n587_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:129:50  */
  assign n624_o = q_irqs[6]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:131:70  */
  assign n626_o = db_count + 4'b0001;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:129:41  */
  assign n628_o = n624_o ? 1'b1 : db_state;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:129:41  */
  assign n629_o = n624_o ? n626_o : db_count;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:128:33  */
  assign n631_o = db_state == 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:134:50  */
  assign n632_o = q_irqs[6]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:134:54  */
  assign n633_o = ~n632_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:134:41  */
  assign n635_o = n633_o ? 1'b0 : db_state;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:133:33  */
  assign n637_o = db_state == 1'b1;
  assign n638_o = {n637_o, n631_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:127:25  */
  always @*
    case (n638_o)
      2'b10: n640_o = n635_o;
      2'b01: n640_o = n628_o;
      default: n640_o = 1'bX;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:127:25  */
  always @*
    case (n638_o)
      2'b10: n642_o = db_count;
      2'b01: n642_o = n629_o;
      default: n642_o = 4'bX;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:152:35  */
  assign n672_o = n473_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:152:38  */
  assign n673_o = ~n672_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:152:25  */
  assign n674_o = n673_o ? 1'b0 : n677_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:153:36  */
  assign n676_o = n473_o[33]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:152:44  */
  assign n677_o = n676_o ? 1'b1 : w_ack;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:172:39  */
  assign n678_o = n473_o[6]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:172:28  */
  assign n679_o = n678_o ? w_rtcout : n681_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:173:39  */
  assign n680_o = n473_o[5]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:172:49  */
  assign n681_o = n680_o ? w_pitout : n683_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:174:38  */
  assign n682_o = n473_o[4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:173:49  */
  assign n683_o = n682_o ? w_debug : n692_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:175:27  */
  assign n685_o = {5'b00000, pit_enable};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:175:40  */
  assign n686_o = {n685_o, count_enable};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:175:55  */
  assign n687_o = {n686_o, brk_enable};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:175:68  */
  assign n688_o = {n687_o, testvect};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:175:79  */
  assign n689_o = {n688_o, count};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:175:98  */
  assign n690_o = n473_o[3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:175:102  */
  assign n691_o = ~n690_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:174:48  */
  assign n692_o = n691_o ? n689_o : brkadr;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:177:26  */
  assign n693_o = ilevel[3:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:177:38  */
  assign n694_o = ilevel[7:4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:177:30  */
  assign n695_o = {n693_o, n694_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:177:50  */
  assign n696_o = ilevel[11:8]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:177:42  */
  assign n697_o = {n695_o, n696_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:177:62  */
  assign n698_o = ilevel[15:12]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:177:54  */
  assign n699_o = {n697_o, n698_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:177:74  */
  assign n700_o = ilevel[19:16]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:177:66  */
  assign n701_o = {n699_o, n700_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:177:86  */
  assign n702_o = ilevel[23:20]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:177:78  */
  assign n703_o = {n701_o, n702_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:177:98  */
  assign n704_o = ilevel[27:24]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:177:90  */
  assign n705_o = {n703_o, n704_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:177:110  */
  assign n706_o = ilevel[31:28]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:177:102  */
  assign n707_o = {n705_o, n706_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:177:125  */
  assign n708_o = n473_o[3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:177:129  */
  assign n709_o = ~n708_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:177:114  */
  assign n710_o = n709_o ? n707_o : n714_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:178:26  */
  assign n711_o = {irq_i, q_irqs};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:178:35  */
  assign n712_o = {n711_o, pit_flag};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:178:46  */
  assign n713_o = {n712_o, db_ackcount};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:178:60  */
  assign n714_o = {n713_o, db_count};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:179:48  */
  assign n716_o = n473_o[4:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:179:61  */
  assign n718_o = n716_o == 2'b11;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:179:37  */
  assign n719_o = n718_o ? 32'b00000000000000000000000000000000 : n722_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:180:92  */
  assign n721_o = n473_o[4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:179:68  */
  assign n722_o = n721_o ? 32'b00000000000000000000000000010100 : n725_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:181:45  */
  assign n723_o = n473_o[3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:181:49  */
  assign n724_o = ~n723_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:180:102  */
  assign n725_o = n724_o ? pit_throttle : pit_cntr;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:183:32  */
  assign n726_o = reg_rtc_sec[63:32]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:183:58  */
  assign n727_o = n473_o[4:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:183:71  */
  assign n729_o = n727_o == 2'b00;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:183:47  */
  assign n730_o = n729_o ? n726_o : n735_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:184:32  */
  assign n731_o = reg_rtc_sec[31:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:184:57  */
  assign n732_o = n473_o[4:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:184:70  */
  assign n734_o = n732_o == 2'b01;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:183:78  */
  assign n735_o = n734_o ? n731_o : n739_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:185:45  */
  assign n736_o = n473_o[4:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:185:58  */
  assign n738_o = n736_o == 2'b10;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:184:77  */
  assign n739_o = n738_o ? reg_rtc_nsec : 32'b00000000000000000000000000000000;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:189:32  */
  assign n741_o = ilevel[28]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:189:48  */
  assign n742_o = ilevel[29]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:189:36  */
  assign n743_o = n741_o | n742_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:189:64  */
  assign n744_o = ilevel[30]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:189:52  */
  assign n745_o = n743_o | n744_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:189:80  */
  assign n746_o = ilevel[31]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:189:68  */
  assign n747_o = n745_o | n746_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:190:32  */
  assign n748_o = ilevel[24]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:190:48  */
  assign n749_o = ilevel[25]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:190:36  */
  assign n750_o = n748_o | n749_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:190:64  */
  assign n751_o = ilevel[26]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:190:52  */
  assign n752_o = n750_o | n751_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:190:80  */
  assign n753_o = ilevel[27]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:190:68  */
  assign n754_o = n752_o | n753_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:191:32  */
  assign n755_o = ilevel[20]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:191:48  */
  assign n756_o = ilevel[21]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:191:36  */
  assign n757_o = n755_o | n756_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:191:64  */
  assign n758_o = ilevel[22]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:191:52  */
  assign n759_o = n757_o | n758_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:191:80  */
  assign n760_o = ilevel[23]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:191:68  */
  assign n761_o = n759_o | n760_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:192:32  */
  assign n762_o = ilevel[16]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:192:48  */
  assign n763_o = ilevel[17]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:192:36  */
  assign n764_o = n762_o | n763_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:192:64  */
  assign n765_o = ilevel[18]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:192:52  */
  assign n766_o = n764_o | n765_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:192:80  */
  assign n767_o = ilevel[19]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:192:68  */
  assign n768_o = n766_o | n767_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:193:32  */
  assign n769_o = ilevel[12]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:193:48  */
  assign n770_o = ilevel[13]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:193:36  */
  assign n771_o = n769_o | n770_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:193:64  */
  assign n772_o = ilevel[14]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:193:52  */
  assign n773_o = n771_o | n772_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:193:80  */
  assign n774_o = ilevel[15]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:193:68  */
  assign n775_o = n773_o | n774_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:194:32  */
  assign n776_o = ilevel[8]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:194:48  */
  assign n777_o = ilevel[9]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:194:36  */
  assign n778_o = n776_o | n777_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:194:64  */
  assign n779_o = ilevel[10]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:194:52  */
  assign n780_o = n778_o | n779_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:194:80  */
  assign n781_o = ilevel[11]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:194:68  */
  assign n782_o = n780_o | n781_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:195:32  */
  assign n783_o = ilevel[4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:195:48  */
  assign n784_o = ilevel[5]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:195:36  */
  assign n785_o = n783_o | n784_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:195:64  */
  assign n786_o = ilevel[6]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:195:52  */
  assign n787_o = n785_o | n786_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:195:80  */
  assign n788_o = ilevel[7]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:195:68  */
  assign n789_o = n787_o | n788_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:196:32  */
  assign n790_o = ilevel[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:196:48  */
  assign n791_o = ilevel[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:196:36  */
  assign n792_o = n790_o | n791_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:196:64  */
  assign n793_o = ilevel[2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:196:52  */
  assign n794_o = n792_o | n793_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:196:80  */
  assign n795_o = ilevel[3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:196:68  */
  assign n796_o = n794_o | n795_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:197:26  */
  assign n797_o = q_irqs[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:197:39  */
  assign n798_o = q_irqs[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:197:30  */
  assign n799_o = n797_o | n798_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:197:52  */
  assign n800_o = q_irqs[2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:197:43  */
  assign n801_o = n799_o | n800_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:197:65  */
  assign n802_o = q_irqs[3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:197:56  */
  assign n803_o = n801_o | n802_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:197:78  */
  assign n804_o = q_irqs[4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:197:69  */
  assign n805_o = n803_o | n804_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:197:91  */
  assign n806_o = q_irqs[5]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:197:82  */
  assign n807_o = n805_o | n806_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:197:104  */
  assign n808_o = q_irqs[6]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:197:95  */
  assign n809_o = n807_o | n808_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:197:117  */
  assign n810_o = q_irqs[7]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:197:108  */
  assign n811_o = n809_o | n810_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:199:57  */
  assign n813_o = r_mrst ? 25'b0000000000110111100000010 : n815_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:199:75  */
  assign n815_o = r_dmaerr ? 25'b0000000000011111100001010 : n817_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:200:76  */
  assign n817_o = r_cpuerr ? 25'b0000000000010111100001001 : n819_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:201:76  */
  assign n819_o = r_nmi ? 25'b0000000001001111100001011 : n822_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:203:40  */
  assign n821_o = {13'b0000000001000, testvect};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:202:66  */
  assign n822_o = r_irq1 ? n821_o : n823_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:203:69  */
  assign n823_o = qq_irqs ? w_irqevent : n825_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:204:50  */
  assign n825_o = r_irq10 ? 25'b1000000000000001100011001 : 25'b0000000000111111100011000;
  assign n833_o = {10'b0000000000, 3'b111, 12'b111100011000};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:217:31  */
  assign n836_o = reg_event[14:12]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:218:32  */
  assign n837_o = reg_event[11:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:34  */
  assign n841_o = q_irqs[7]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:228:42  */
  assign n842_o = ilevel[3:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:228:46  */
  assign n844_o = $unsigned(n842_o) > $unsigned(4'b0000);
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:229:61  */
  assign n845_o = ilevel[3:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:228:33  */
  assign n848_o = n844_o ? 3'b111 : 3'b000;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:228:33  */
  assign n850_o = n844_o ? n845_o : 4'b0000;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n852_o = n841_o ? n848_o : 3'b000;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n855_o = n841_o ? n850_o : 4'b0000;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:34  */
  assign n857_o = q_irqs[6]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:228:42  */
  assign n858_o = ilevel[7:4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:228:46  */
  assign n859_o = $unsigned(n858_o) > $unsigned(n855_o);
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:229:61  */
  assign n860_o = ilevel[7:4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n862_o = n864_o ? 3'b110 : n852_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n863_o = n865_o ? n860_o : n855_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n864_o = n859_o & n857_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n865_o = n859_o & n857_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:34  */
  assign n866_o = q_irqs[5]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:228:42  */
  assign n867_o = ilevel[11:8]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:228:46  */
  assign n868_o = $unsigned(n867_o) > $unsigned(n863_o);
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:229:61  */
  assign n869_o = ilevel[11:8]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n871_o = n873_o ? 3'b101 : n862_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n872_o = n874_o ? n869_o : n863_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n873_o = n868_o & n866_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n874_o = n868_o & n866_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:34  */
  assign n875_o = q_irqs[4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:228:42  */
  assign n876_o = ilevel[15:12]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:228:46  */
  assign n877_o = $unsigned(n876_o) > $unsigned(n872_o);
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:229:61  */
  assign n878_o = ilevel[15:12]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n880_o = n882_o ? 3'b100 : n871_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n881_o = n883_o ? n878_o : n872_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n882_o = n877_o & n875_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n883_o = n877_o & n875_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:34  */
  assign n884_o = q_irqs[3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:228:42  */
  assign n885_o = ilevel[19:16]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:228:46  */
  assign n886_o = $unsigned(n885_o) > $unsigned(n881_o);
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:229:61  */
  assign n887_o = ilevel[19:16]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n889_o = n891_o ? 3'b011 : n880_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n890_o = n892_o ? n887_o : n881_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n891_o = n886_o & n884_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n892_o = n886_o & n884_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:34  */
  assign n893_o = q_irqs[2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:228:42  */
  assign n894_o = ilevel[23:20]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:228:46  */
  assign n895_o = $unsigned(n894_o) > $unsigned(n890_o);
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:229:61  */
  assign n896_o = ilevel[23:20]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n898_o = n900_o ? 3'b010 : n889_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n899_o = n901_o ? n896_o : n890_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n900_o = n895_o & n893_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n901_o = n895_o & n893_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:34  */
  assign n902_o = q_irqs[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:228:42  */
  assign n903_o = ilevel[27:24]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:228:46  */
  assign n904_o = $unsigned(n903_o) > $unsigned(n899_o);
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:229:61  */
  assign n905_o = ilevel[27:24]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n907_o = n909_o ? 3'b001 : n898_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n908_o = n910_o ? n905_o : n899_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n909_o = n904_o & n902_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n910_o = n904_o & n902_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:34  */
  assign n911_o = q_irqs[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:228:42  */
  assign n912_o = ilevel[31:28]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:228:46  */
  assign n913_o = $unsigned(n912_o) > $unsigned(n908_o);
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n916_o = n918_o ? 3'b000 : n907_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:227:25  */
  assign n918_o = n913_o & n911_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:234:44  */
  assign n921_o = 3'b111 - n916_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:234:35  */
  assign n926_o = {1'b0, n1339_data};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:234:52  */
  assign n928_o = {n926_o, 1'b0};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:234:58  */
  assign n930_o = {n928_o, 3'b000};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:234:81  */
  assign n932_o = 3'b111 - n916_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:234:72  */
  assign n935_o = {n930_o, n1355_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:234:106  */
  assign n937_o = 3'b111 - n916_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:234:89  */
  assign n941_o = {n935_o, n1341_data};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:236:40  */
  assign n944_o = pit_cntr == pit_throttle;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:236:26  */
  assign n945_o = n944_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:265:39  */
  assign n957_o = n473_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:266:33  */
  assign n958_o = n473_o[34]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:266:52  */
  assign n959_o = n473_o[6]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:266:56  */
  assign n960_o = ~n959_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:266:42  */
  assign n961_o = n960_o & n958_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:267:42  */
  assign n962_o = n473_o[5]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:267:46  */
  assign n963_o = ~n962_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:268:50  */
  assign n964_o = n473_o[4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:268:54  */
  assign n965_o = ~n964_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:269:58  */
  assign n966_o = n473_o[3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:269:62  */
  assign n967_o = ~n966_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:270:71  */
  assign n968_o = ~pit_enable;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:271:83  */
  assign n969_o = n473_o[62:51]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:273:77  */
  assign n971_o = n473_o[63]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:274:79  */
  assign n972_o = n473_o[64]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:275:77  */
  assign n973_o = n473_o[65]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:276:72  */
  assign n974_o = n473_o[50:39]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:278:72  */
  assign n975_o = n473_o[70:39]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:269:49  */
  assign n976_o = n968_o & n967_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:266:25  */
  assign n980_o = n1020_o ? n974_o : count;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:269:49  */
  assign n981_o = n967_o ? brkadr : n975_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:280:53  */
  assign n982_o = n473_o[3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:280:57  */
  assign n983_o = ~n982_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:281:68  */
  assign n984_o = n473_o[70:67]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:282:68  */
  assign n985_o = n473_o[66:63]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:283:68  */
  assign n986_o = n473_o[62:59]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:284:68  */
  assign n987_o = n473_o[58:55]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:285:68  */
  assign n988_o = n473_o[54:51]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:286:68  */
  assign n989_o = n473_o[50:47]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:287:68  */
  assign n990_o = n473_o[46:43]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:288:68  */
  assign n991_o = n473_o[42:39]; // extract
  assign n992_o = {n991_o, n990_o, n989_o, n988_o, n987_o, n986_o, n985_o, n984_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:280:41  */
  assign n993_o = n983_o ? n992_o : ilevel;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:268:41  */
  assign n994_o = n976_o & n965_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:268:41  */
  assign n995_o = n967_o & n965_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:268:41  */
  assign n996_o = n967_o & n965_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:268:41  */
  assign n997_o = n967_o & n965_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:268:41  */
  assign n998_o = n967_o & n965_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:268:41  */
  assign n1000_o = n965_o ? ilevel : n993_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:291:50  */
  assign n1001_o = n473_o[4:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:291:63  */
  assign n1003_o = n1001_o == 2'b00;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:292:63  */
  assign n1004_o = ~pit_enable;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:293:78  */
  assign n1005_o = n473_o[70:39]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:291:41  */
  assign n1006_o = n1007_o ? n1005_o : pit_throttle;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:291:41  */
  assign n1007_o = n1004_o & n1003_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:267:33  */
  assign n1008_o = n994_o & n963_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:267:33  */
  assign n1009_o = n995_o & n963_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:267:33  */
  assign n1010_o = n996_o & n963_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:267:33  */
  assign n1011_o = n997_o & n963_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:267:33  */
  assign n1012_o = n998_o & n963_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:267:33  */
  assign n1013_o = n965_o & n963_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:267:33  */
  assign n1014_o = n963_o ? pit_throttle : n1006_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:266:25  */
  assign n1016_o = n1008_o & n961_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:266:25  */
  assign n1017_o = n1009_o & n961_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:266:25  */
  assign n1018_o = n1010_o & n961_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:266:25  */
  assign n1019_o = n1011_o & n961_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:266:25  */
  assign n1020_o = n1012_o & n961_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:266:25  */
  assign n1021_o = n1013_o & n961_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:266:25  */
  assign n1023_o = n963_o & n961_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:299:48  */
  assign n1025_o = count - 12'b000000000001;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:298:25  */
  assign n1026_o = count_enable ? n1025_o : n980_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:304:53  */
  assign n1027_o = ~pit_flag;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:306:62  */
  assign n1029_o = pit_cntr + 32'b00000000000000000000000000000001;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:302:33  */
  assign n1031_o = pit_event ? 32'b00000000000000000000000000000000 : n1029_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:301:25  */
  assign n1034_o = pit_enable ? n1031_o : 32'b00000000000000000000000000000000;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:301:25  */
  assign n1035_o = pit_event & pit_enable;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:311:25  */
  assign n1037_o = s_mrs ? 1'b1 : r_mrst;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:314:25  */
  assign n1039_o = s_cer ? 1'b1 : r_cpuerr;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:317:25  */
  assign n1041_o = s_der ? 1'b1 : r_dmaerr;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:320:25  */
  assign n1043_o = s_eirq ? 1'b1 : r_irq1;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:323:25  */
  assign n1045_o = s_eirq2 ? 1'b1 : r_irq10;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:326:25  */
  assign n1047_o = s_enmi ? 1'b1 : r_nmi;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:329:36  */
  assign n1048_o = n479_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:331:45  */
  assign n1049_o = reg_event[14:12]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:331:60  */
  assign n1051_o = n1049_o == 3'b110;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:333:56  */
  assign n1052_o = reg_event[14:12]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:333:71  */
  assign n1054_o = n1052_o == 3'b010;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:335:56  */
  assign n1055_o = reg_event[14:12]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:335:71  */
  assign n1057_o = n1055_o == 3'b011;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:337:56  */
  assign n1058_o = reg_event[14:12]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:337:71  */
  assign n1060_o = n1058_o == 3'b001;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:339:56  */
  assign n1061_o = reg_event[14:12]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:339:71  */
  assign n1063_o = n1061_o == 3'b000;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:340:61  */
  assign n1064_o = reg_event[15]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:342:56  */
  assign n1065_o = reg_event[24]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:342:41  */
  assign n1067_o = n1065_o ? 1'b0 : n1045_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:339:41  */
  assign n1069_o = n1072_o ? 1'b0 : n1043_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:340:49  */
  assign n1070_o = n1064_o ? n1045_o : n1067_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:345:61  */
  assign n1071_o = reg_event[23:16]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:339:41  */
  assign n1072_o = n1064_o & n1063_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:339:41  */
  assign n1073_o = n1063_o ? n1070_o : n1045_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:339:41  */
  assign n1075_o = n1063_o ? n1071_o : 8'b00000000;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:337:41  */
  assign n1077_o = n1060_o ? 1'b0 : n1047_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:337:41  */
  assign n1078_o = n1060_o ? n1043_o : n1069_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:337:41  */
  assign n1079_o = n1060_o ? n1045_o : n1073_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:337:41  */
  assign n1081_o = n1060_o ? 8'b00000000 : n1075_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:335:41  */
  assign n1082_o = n1057_o ? n1047_o : n1077_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:335:41  */
  assign n1083_o = n1057_o ? n1043_o : n1078_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:335:41  */
  assign n1084_o = n1057_o ? n1045_o : n1079_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:335:41  */
  assign n1086_o = n1057_o ? 1'b0 : n1041_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:335:41  */
  assign n1088_o = n1057_o ? 8'b00000000 : n1081_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:333:41  */
  assign n1089_o = n1054_o ? n1047_o : n1082_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:333:41  */
  assign n1090_o = n1054_o ? n1043_o : n1083_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:333:41  */
  assign n1091_o = n1054_o ? n1045_o : n1084_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:333:41  */
  assign n1093_o = n1054_o ? 1'b0 : n1039_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:333:41  */
  assign n1094_o = n1054_o ? n1041_o : n1086_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:333:41  */
  assign n1096_o = n1054_o ? 8'b00000000 : n1088_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:331:33  */
  assign n1097_o = n1051_o ? n1047_o : n1089_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:331:33  */
  assign n1098_o = n1051_o ? n1043_o : n1090_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:331:33  */
  assign n1099_o = n1051_o ? n1045_o : n1091_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:331:33  */
  assign n1100_o = n1051_o ? n1039_o : n1093_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:331:33  */
  assign n1101_o = n1051_o ? n1041_o : n1094_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:329:25  */
  assign n1103_o = n1112_o ? 1'b0 : n1037_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:331:33  */
  assign n1105_o = n1051_o ? 8'b00000000 : n1096_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:329:25  */
  assign n1107_o = n1048_o ? n1097_o : n1047_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:329:25  */
  assign n1108_o = n1048_o ? n1098_o : n1043_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:329:25  */
  assign n1109_o = n1048_o ? n1099_o : n1045_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:329:25  */
  assign n1110_o = n1048_o ? n1100_o : n1039_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:329:25  */
  assign n1111_o = n1048_o ? n1101_o : n1041_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:329:25  */
  assign n1112_o = n1051_o & n1048_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:329:25  */
  assign n1114_o = n1048_o ? n1105_o : 8'b00000000;
  assign n1165_o = {4'b0000, 4'b0000, 4'b0000, 4'b0000, 4'b0000, 4'b0000, 4'b0000, 4'b0000};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:353:34  */
  assign n1171_o = n473_o[34]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:353:37  */
  assign n1172_o = ~n1171_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:353:24  */
  assign n1173_o = n1172_o ? 1'b0 : n1178_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:354:35  */
  assign n1175_o = n473_o[6:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:354:48  */
  assign n1177_o = n1175_o != 4'b0000;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:353:43  */
  assign n1178_o = n1177_o ? 1'b0 : n1182_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:355:36  */
  assign n1180_o = n473_o[38]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:355:40  */
  assign n1181_o = ~n1180_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:354:58  */
  assign n1182_o = n1181_o ? 1'b0 : 1'b1;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:357:36  */
  assign n1184_o = n473_o[66]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:357:26  */
  assign n1185_o = w_wctrl & n1184_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:358:36  */
  assign n1186_o = n473_o[67]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:358:26  */
  assign n1187_o = w_wctrl & n1186_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:360:37  */
  assign n1188_o = n473_o[68]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:360:27  */
  assign n1189_o = w_wctrl & n1188_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:360:43  */
  assign n1190_o = n1189_o | w_cer1;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:360:53  */
  assign n1191_o = n1190_o | w_cer2;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:360:63  */
  assign n1192_o = n1191_o | w_cer3;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:361:37  */
  assign n1193_o = n473_o[38]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:361:26  */
  assign n1194_o = bstb_i & n1193_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:361:52  */
  assign n1195_o = n473_o[37]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:361:41  */
  assign n1196_o = n1194_o & n1195_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:361:71  */
  assign n1197_o = n473_o[36]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:361:60  */
  assign n1198_o = ~n1197_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:361:56  */
  assign n1199_o = n1196_o & n1198_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:361:90  */
  assign n1200_o = n473_o[35]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:361:79  */
  assign n1201_o = ~n1200_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:361:75  */
  assign n1202_o = n1199_o & n1201_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:361:94  */
  assign n1203_o = n1202_o & back_i;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:361:115  */
  assign n1204_o = n473_o[2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:361:105  */
  assign n1205_o = n1203_o & n1204_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:362:50  */
  assign n1206_o = n473_o[38]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:362:39  */
  assign n1207_o = ~n1206_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:362:35  */
  assign n1208_o = bstb_i & n1207_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:362:69  */
  assign n1209_o = n473_o[37]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:362:58  */
  assign n1210_o = ~n1209_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:362:54  */
  assign n1211_o = n1208_o & n1210_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:362:84  */
  assign n1212_o = n473_o[36]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:362:73  */
  assign n1213_o = n1211_o & n1212_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:362:99  */
  assign n1214_o = n473_o[35]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:362:88  */
  assign n1215_o = n1213_o & n1214_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:362:103  */
  assign n1216_o = n1215_o & back_i;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:362:128  */
  assign n1217_o = n473_o[2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:362:118  */
  assign n1218_o = ~n1217_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:362:114  */
  assign n1219_o = n1216_o & n1218_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:363:46  */
  assign n1220_o = n473_o[38]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:363:35  */
  assign n1221_o = bstb_i & n1220_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:363:61  */
  assign n1222_o = n473_o[37]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:363:50  */
  assign n1223_o = n1221_o & n1222_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:363:76  */
  assign n1224_o = n473_o[36]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:363:65  */
  assign n1225_o = n1223_o & n1224_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:363:91  */
  assign n1226_o = n473_o[35]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:363:80  */
  assign n1227_o = n1225_o & n1226_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:363:95  */
  assign n1228_o = n1227_o & back_i;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:363:117  */
  assign n1229_o = n473_o[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:363:130  */
  assign n1230_o = n473_o[2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:363:121  */
  assign n1231_o = n1229_o | n1230_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:363:106  */
  assign n1232_o = n1228_o & n1231_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:366:38  */
  assign n1233_o = n473_o[69]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:366:28  */
  assign n1234_o = w_wctrl & n1233_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:366:44  */
  assign n1235_o = n1234_o | pit_event;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:367:45  */
  assign n1237_o = count == 12'b000000000000;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:367:33  */
  assign n1238_o = n1237_o ? count_enable : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:368:38  */
  assign n1240_o = n473_o[70]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:368:28  */
  assign n1241_o = w_wctrl & n1240_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:368:44  */
  assign n1242_o = n1241_o | w_enmi;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:368:54  */
  assign n1243_o = n1242_o | vnmi;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:369:30  */
  assign n1244_o = brk_enable & bstb_i;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:369:41  */
  assign n1245_o = n1244_o & back_i;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:369:62  */
  assign n1246_o = n473_o[32:1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:369:64  */
  assign n1247_o = n1246_o == brkadr;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:369:52  */
  assign n1248_o = n1247_o ? n1245_o : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:380:51  */
  assign n1253_o = ~enmi_i;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:380:41  */
  assign n1255_o = n1253_o ? 1'b1 : vnmi;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:380:41  */
  assign n1257_o = n1253_o ? 2'b01 : vstate;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:379:33  */
  assign n1259_o = vstate == 2'b00;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:384:33  */
  assign n1261_o = vstate == 2'b01;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:389:51  */
  assign n1262_o = {3'b0, vcount};  //  uext
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:389:51  */
  assign n1264_o = $unsigned(n1262_o) > $unsigned(24'b000100110001001011010000);
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:392:66  */
  assign n1266_o = vcount + 21'b000000000000000000001;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:389:41  */
  assign n1267_o = n1264_o ? vcount : n1266_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:389:41  */
  assign n1269_o = n1264_o ? 2'b11 : vstate;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:388:33  */
  assign n1271_o = vstate == 2'b10;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:395:41  */
  assign n1273_o = enmi_i ? vcount : 21'b000000000000000000000;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:395:41  */
  assign n1276_o = enmi_i ? 2'b00 : 2'b10;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:394:33  */
  assign n1278_o = vstate == 2'b11;
  assign n1279_o = {n1278_o, n1271_o, n1261_o, n1259_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:378:25  */
  always @*
    case (n1279_o)
      4'b1000: n1282_o = vnmi;
      4'b0100: n1282_o = vnmi;
      4'b0010: n1282_o = 1'b0;
      4'b0001: n1282_o = n1255_o;
      default: n1282_o = 1'bX;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:378:25  */
  always @*
    case (n1279_o)
      4'b1000: n1285_o = n1273_o;
      4'b0100: n1285_o = n1267_o;
      4'b0010: n1285_o = 21'b000000000000000000000;
      4'b0001: n1285_o = vcount;
      default: n1285_o = 21'bX;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:378:25  */
  always @*
    case (n1279_o)
      4'b1000: n1288_o = n1276_o;
      4'b0100: n1288_o = n1269_o;
      4'b0010: n1288_o = 2'b10;
      4'b0001: n1288_o = n1257_o;
      default: n1288_o = 2'bX;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:213:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1299_q <= n833_o;
    else
      n1299_q <= w_event;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1300_q <= 1'b0;
    else
      n1300_q <= n957_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  assign n1301_o = n1016_o ? n969_o : testvect;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1302_q <= 12'b000000000000;
    else
      n1302_q <= n1301_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  assign n1303_o = n1017_o ? n972_o : count_enable;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1304_q <= 1'b0;
    else
      n1304_q <= n1303_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  assign n1305_o = n1018_o ? n973_o : pit_enable;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1306_q <= 1'b0;
    else
      n1306_q <= n1305_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  assign n1307_o = n1019_o ? n971_o : brk_enable;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1308_q <= 1'b0;
    else
      n1308_q <= n1307_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1309_q <= 12'b111111111111;
    else
      n1309_q <= n1026_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  assign n1310_o = n1021_o ? n981_o : brkadr;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1311_q <= 32'b00000000000000000000000000000000;
    else
      n1311_q <= n1310_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1312_q <= 1'b0;
    else
      n1312_q <= n1107_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1313_q <= 1'b0;
    else
      n1313_q <= n1108_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1314_q <= 1'b0;
    else
      n1314_q <= n1109_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1315_q <= 1'b0;
    else
      n1315_q <= n1110_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1316_q <= 1'b0;
    else
      n1316_q <= n1111_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1317_q <= 1'b0;
    else
      n1317_q <= n1103_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1318_q <= 32'b00000000000000000000000000000000;
    else
      n1318_q <= n1034_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  assign n1319_o = n961_o ? n1014_o : pit_throttle;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1320_q <= 32'b00000000000001111010000100100000;
    else
      n1320_q <= n1319_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:99:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1321_q <= 64'b0000000000000000000000000000000000000000000000000000000000000000;
    else
      n1321_q <= n613_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:99:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1322_q <= 32'b00000000000000000000000000000000;
    else
      n1322_q <= n614_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:96:17  */
  assign n1323_o = {n796_o, n789_o, n782_o, n775_o, n768_o, n761_o, n754_o, n747_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:96:17  */
  assign n1324_o = {get_irqs_n1_iedge_inst_n528, get_irqs_n2_iedge_inst_n534, get_irqs_n3_iedge_inst_n540, get_irqs_n4_iedge_inst_n546, get_irqs_n5_iedge_inst_n552, get_irqs_n6_iedge_inst_n558, get_irqs_n7_iedge_inst_n564, get_irqs_n8_iedge_inst_n570};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1325_q <= 8'b11111111;
    else
      n1325_q <= n1114_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  assign n1326_o = n1023_o ? n1000_o : ilevel;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1327_q <= n1165_o;
    else
      n1327_q <= n1326_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:377:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1328_q <= 1'b0;
    else
      n1328_q <= n1282_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:377:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1329_q <= 21'b000000000000000000000;
    else
      n1329_q <= n1285_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:377:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1330_q <= 2'b00;
    else
      n1330_q <= n1288_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:125:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1331_q <= 1'b0;
    else
      n1331_q <= n640_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:125:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1333_q <= 4'b0000;
    else
      n1333_q <= n642_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:125:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1334_q <= 11'b00000000000;
    else
      n1334_q <= 11'b11111111111;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  assign n1335_o = n1035_o ? n1027_o : pit_flag;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:264:17  */
  always @(posedge clk_bus or posedge rst_i)
    if (rst_i)
      n1336_q <= 1'b0;
    else
      n1336_q <= n1335_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:241:17  */
  assign n1337_o = {n674_o, n679_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:57  */
  reg [7:0] n1338[7:0] ; // memory
  initial begin
    n1338[7] = 8'b00000001;
    n1338[6] = 8'b00000010;
    n1338[5] = 8'b00000100;
    n1338[4] = 8'b00001000;
    n1338[3] = 8'b00010000;
    n1338[2] = 8'b00100000;
    n1338[1] = 8'b01000000;
    n1338[0] = 8'b10000000;
    end
  assign n1339_data = n1338[n921_o];
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:234:44  */
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:234:43  */
  reg [7:0] n1340[7:0] ; // memory
  initial begin
    n1340[7] = 8'b00000000;
    n1340[6] = 8'b00010010;
    n1340[5] = 8'b00000000;
    n1340[4] = 8'b00010100;
    n1340[3] = 8'b00010101;
    n1340[2] = 8'b00000000;
    n1340[1] = 8'b00000000;
    n1340[0] = 8'b00000000;
    end
  assign n1341_data = n1340[n937_o];
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:234:106  */
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:234:105  */
  assign n1342_o = ilevel[3:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:17  */
  assign n1343_o = ilevel[7:4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:57  */
  assign n1344_o = ilevel[11:8]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:17  */
  assign n1345_o = ilevel[15:12]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:57  */
  assign n1346_o = ilevel[19:16]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:17  */
  assign n1347_o = ilevel[23:20]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:57  */
  assign n1348_o = ilevel[27:24]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:89:17  */
  assign n1349_o = ilevel[31:28]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:234:80  */
  assign n1350_o = n932_o[1:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:234:80  */
  always @*
    case (n1350_o)
      2'b00: n1351_o = n1342_o;
      2'b01: n1351_o = n1343_o;
      2'b10: n1351_o = n1344_o;
      2'b11: n1351_o = n1345_o;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:234:80  */
  assign n1352_o = n932_o[1:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:234:80  */
  always @*
    case (n1352_o)
      2'b00: n1353_o = n1346_o;
      2'b01: n1353_o = n1347_o;
      2'b10: n1353_o = n1348_o;
      2'b11: n1353_o = n1349_o;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:234:80  */
  assign n1354_o = n932_o[2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/misc/aic.vhd:234:80  */
  assign n1355_o = n1354_o ? n1353_o : n1351_o;
endmodule

module ref_devices__devices
  (input  clk_sys,
   input  cpu0_data_master_ack,
   input  cpu0_data_master_en,
   input  cpu0_ddr_ibus_o_en,
   input  [30:0] cpu0_ddr_ibus_o_a,
   input  cpu0_ddr_ibus_o_jp,
   input  cpu0_event_o_ack,
   input  [3:0] cpu0_event_o_lvl,
   input  cpu0_event_o_slp,
   input  cpu0_event_o_dbg,
   input  cpu0_periph_dbus_o_en,
   input  [31:0] cpu0_periph_dbus_o_a,
   input  cpu0_periph_dbus_o_rd,
   input  cpu0_periph_dbus_o_wr,
   input  [3:0] cpu0_periph_dbus_o_we,
   input  [31:0] cpu0_periph_dbus_o_d,
   input  cpu1_ddr_ibus_o_en,
   input  [30:0] cpu1_ddr_ibus_o_a,
   input  cpu1_ddr_ibus_o_jp,
   input  cpu1_periph_dbus_o_en,
   input  [31:0] cpu1_periph_dbus_o_a,
   input  cpu1_periph_dbus_o_rd,
   input  cpu1_periph_dbus_o_wr,
   input  [3:0] cpu1_periph_dbus_o_we,
   input  [31:0] cpu1_periph_dbus_o_d,
   input  flash_miso,
   input  [31:0] pi,
   input  reset,
   input  uart0_rx,
   output cache01sel_ctrl_temp,
   output cpu0_event_i_en,
   output [1:0] cpu0_event_i_cmd,
   output [7:0] cpu0_event_i_vec,
   output cpu0_event_i_msk,
   output [3:0] cpu0_event_i_lvl,
   output [31:0] cpu0_periph_dbus_i_d,
   output cpu0_periph_dbus_i_ack,
   output [31:0] cpu1_periph_dbus_i_d,
   output cpu1_periph_dbus_i_ack,
   output dcache0_ctrl_en,
   output dcache0_ctrl_inv,
   output dcache1_ctrl_en,
   output dcache1_ctrl_inv,
   output flash_clk,
   output [1:0] flash_cs,
   output flash_mosi,
   output icache0_ctrl_en,
   output icache0_ctrl_inv,
   output icache1_ctrl_en,
   output icache1_ctrl_inv,
   output [31:0] po,
   output uart0_tx);
  wire [32:0] n72_o;
  wire n74_o;
  wire [1:0] n75_o;
  wire [7:0] n76_o;
  wire n77_o;
  wire [3:0] n78_o;
  wire [6:0] n79_o;
  wire [31:0] n81_o;
  wire n82_o;
  wire [70:0] n83_o;
  wire [32:0] n84_o;
  wire [31:0] n86_o;
  wire n87_o;
  wire [70:0] n88_o;
  wire n90_o;
  wire n91_o;
  wire n93_o;
  wire n94_o;
  wire n99_o;
  wire n100_o;
  wire n102_o;
  wire n103_o;
  wire [2:0] active_dev;
  wire [197:0] devs_bus_i;
  wire [425:0] devs_bus_o;
  localparam [7:0] n106_o = 8'b00000000;
  reg [7:0] irqs0;
  wire n113_o;
  wire [32:0] n117_o;
  wire [17:0] n124_o;
  wire n126_o;
  wire n127_o;
  wire n128_o;
  wire n129_o;
  wire n130_o;
  wire n131_o;
  wire n132_o;
  wire [2:0] n133_o;
  wire n135_o;
  wire [3:0] n137_o;
  wire n139_o;
  wire n143_o;
  wire [2:0] n147_o;
  wire n149_o;
  wire [2:0] n152_o;
  wire [1:0] n153_o;
  wire n155_o;
  wire n159_o;
  wire [2:0] n163_o;
  wire n164_o;
  wire [2:0] n166_o;
  wire [4:0] n167_o;
  wire n169_o;
  wire n173_o;
  wire [2:0] n177_o;
  wire n178_o;
  wire [2:0] n180_o;
  wire [3:0] n181_o;
  wire n183_o;
  wire n187_o;
  wire [2:0] n191_o;
  wire n192_o;
  wire [2:0] n194_o;
  wire n196_o;
  wire [2:0] n201_o;
  wire [2:0] n207_o;
  wire [2:0] n209_o;
  wire n215_o;
  wire n222_o;
  wire n227_o;
  wire n228_o;
  wire n230_o;
  wire n231_o;
  wire [31:0] n233_o;
  wire n234_o;
  wire n235_o;
  wire [35:0] n236_o;
  wire [70:0] n237_o;
  wire n241_o;
  wire n248_o;
  wire n253_o;
  wire n254_o;
  wire n256_o;
  wire n257_o;
  wire [31:0] n259_o;
  wire n260_o;
  wire n261_o;
  wire [35:0] n262_o;
  wire [70:0] n263_o;
  wire n267_o;
  wire n274_o;
  wire n279_o;
  wire n280_o;
  wire n282_o;
  wire n283_o;
  wire [31:0] n285_o;
  wire n286_o;
  wire n287_o;
  wire [35:0] n288_o;
  wire [70:0] n289_o;
  wire n293_o;
  wire n300_o;
  wire n305_o;
  wire n306_o;
  wire n308_o;
  wire n309_o;
  wire [31:0] n311_o;
  wire n312_o;
  wire n313_o;
  wire [35:0] n314_o;
  wire [70:0] n315_o;
  wire n319_o;
  wire n326_o;
  wire n331_o;
  wire n332_o;
  wire n334_o;
  wire n335_o;
  wire [31:0] n337_o;
  wire n338_o;
  wire n339_o;
  wire [35:0] n340_o;
  wire [70:0] n341_o;
  wire n345_o;
  wire n352_o;
  wire n357_o;
  wire n358_o;
  wire n360_o;
  wire n361_o;
  wire [31:0] n363_o;
  wire n364_o;
  wire n365_o;
  wire [35:0] n366_o;
  wire [70:0] n367_o;
  wire n375_o;
  wire [32:0] n379_o;
  wire [31:0] aic0_db_o_d;
  wire aic0_db_o_ack;
  wire [63:0] aic0_rtc_sec;
  wire [31:0] aic0_rtc_nsec;
  wire aic0_event_o_en;
  wire [1:0] aic0_event_o_cmd;
  wire [7:0] aic0_event_o_vec;
  wire aic0_event_o_msk;
  wire [3:0] aic0_event_o_lvl;
  wire [70:0] n380_o;
  wire n381_o;
  wire [31:0] n382_o;
  wire n383_o;
  wire n384_o;
  wire [3:0] n385_o;
  wire [31:0] n386_o;
  wire [32:0] n387_o;
  localparam n389_o = 1'b1;
  wire n390_o;
  wire [3:0] n391_o;
  wire n392_o;
  wire n393_o;
  wire [15:0] n394_o;
  wire [31:0] cache_ctrl_db_o_d;
  wire cache_ctrl_db_o_ack;
  wire cache_ctrl_cache0_ctrl_ic_en;
  wire cache_ctrl_cache0_ctrl_ic_inv;
  wire cache_ctrl_cache1_ctrl_ic_en;
  wire cache_ctrl_cache1_ctrl_ic_inv;
  wire cache_ctrl_cache0_ctrl_dc_en;
  wire cache_ctrl_cache0_ctrl_dc_inv;
  wire cache_ctrl_cache1_ctrl_dc_en;
  wire cache_ctrl_cache1_ctrl_dc_inv;
  wire cache_ctrl_int0;
  wire cache_ctrl_int1;
  wire cache_ctrl_cache01sel_ctrl_temp;
  wire [70:0] n396_o;
  wire n397_o;
  wire [31:0] n398_o;
  wire n399_o;
  wire n400_o;
  wire [3:0] n401_o;
  wire [31:0] n402_o;
  wire [32:0] n403_o;
  wire n405_o;
  wire [30:0] n406_o;
  wire n407_o;
  wire n408_o;
  wire [30:0] n409_o;
  wire n410_o;
  wire [1:0] n411_o;
  wire [1:0] n413_o;
  wire [1:0] n415_o;
  wire [1:0] n417_o;
  wire [31:0] flash_db_o_d;
  wire flash_db_o_ack;
  wire flash_spi_clk;
  wire [70:0] n421_o;
  wire n422_o;
  wire [31:0] n423_o;
  wire n424_o;
  wire n425_o;
  wire [3:0] n426_o;
  wire [31:0] n427_o;
  wire [32:0] n428_o;
  wire [31:0] gpio_db_o_d;
  wire gpio_db_o_ack;
  wire gpio_irq;
  wire [31:0] gpio_p_o;
  wire [70:0] n433_o;
  wire n434_o;
  wire [31:0] n435_o;
  wire n436_o;
  wire n437_o;
  wire [3:0] n438_o;
  wire [31:0] n439_o;
  wire [32:0] n440_o;
  wire [31:0] uart0_db_o_d;
  wire uart0_db_o_ack;
  wire uart0_int;
  wire [70:0] n444_o;
  wire n445_o;
  wire [31:0] n446_o;
  wire n447_o;
  wire n448_o;
  wire [3:0] n449_o;
  wire [31:0] n450_o;
  wire [32:0] n451_o;
  wire [197:0] n455_o;
  wire [425:0] n456_o;
  wire n457_o;
  wire n458_o;
  wire [2:0] n459_o;
  wire [7:0] n460_o;
  wire [32:0] n461_o;
  wire [32:0] n462_o;
  wire [32:0] n463_o;
  wire [32:0] n464_o;
  wire [32:0] n465_o;
  wire [32:0] n466_o;
  wire [1:0] n467_o;
  reg [32:0] n468_o;
  wire n469_o;
  wire [32:0] n470_o;
  wire n471_o;
  wire [32:0] n472_o;
  assign cache01sel_ctrl_temp = cache_ctrl_cache01sel_ctrl_temp; //(module output)
  assign cpu0_event_i_en = n74_o; //(module output)
  assign cpu0_event_i_cmd = n75_o; //(module output)
  assign cpu0_event_i_vec = n76_o; //(module output)
  assign cpu0_event_i_msk = n77_o; //(module output)
  assign cpu0_event_i_lvl = n78_o; //(module output)
  assign cpu0_periph_dbus_i_d = n81_o; //(module output)
  assign cpu0_periph_dbus_i_ack = n82_o; //(module output)
  assign cpu1_periph_dbus_i_d = n86_o; //(module output)
  assign cpu1_periph_dbus_i_ack = n87_o; //(module output)
  assign dcache0_ctrl_en = n90_o; //(module output)
  assign dcache0_ctrl_inv = n91_o; //(module output)
  assign dcache1_ctrl_en = n93_o; //(module output)
  assign dcache1_ctrl_inv = n94_o; //(module output)
  assign flash_clk = flash_spi_clk; //(module output)
  assign icache0_ctrl_en = n99_o; //(module output)
  assign icache0_ctrl_inv = n100_o; //(module output)
  assign icache1_ctrl_en = n102_o; //(module output)
  assign icache1_ctrl_inv = n103_o; //(module output)
  assign po = gpio_p_o; //(module output)
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:85:31  */
  assign n72_o = {cpu0_ddr_ibus_o_jp, cpu0_ddr_ibus_o_a, cpu0_ddr_ibus_o_en};
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:82:31  */
  assign n74_o = n394_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:81:31  */
  assign n75_o = n394_o[2:1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:79:31  */
  assign n76_o = n394_o[10:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:74:31  */
  assign n77_o = n394_o[11]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:72:31  */
  assign n78_o = n394_o[15:12]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:46:27  */
  assign n79_o = {cpu0_event_o_dbg, cpu0_event_o_slp, cpu0_event_o_lvl, cpu0_event_o_ack};
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:46:12  */
  assign n81_o = n472_o[31:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:46:5  */
  assign n82_o = n472_o[32]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:44:5  */
  assign n83_o = {cpu0_periph_dbus_o_d, cpu0_periph_dbus_o_we, cpu0_periph_dbus_o_wr, cpu0_periph_dbus_o_rd, cpu0_periph_dbus_o_a, cpu0_periph_dbus_o_en};
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:41:5  */
  assign n84_o = {cpu1_ddr_ibus_o_jp, cpu1_ddr_ibus_o_a, cpu1_ddr_ibus_o_en};
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:39:5  */
  assign n86_o = n117_o[31:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:38:5  */
  assign n87_o = n117_o[32]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:35:5  */
  assign n88_o = {cpu1_periph_dbus_o_d, cpu1_periph_dbus_o_we, cpu1_periph_dbus_o_wr, cpu1_periph_dbus_o_rd, cpu1_periph_dbus_o_a, cpu1_periph_dbus_o_en};
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:33:5  */
  assign n90_o = n415_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:32:5  */
  assign n91_o = n415_o[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:22:5  */
  assign n93_o = n417_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:21:5  */
  assign n94_o = n417_o[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:61:60  */
  assign n99_o = n411_o[0]; // extract
  assign n100_o = n411_o[1]; // extract
  assign n102_o = n413_o[0]; // extract
  assign n103_o = n413_o[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:47:12  */
  assign active_dev = n207_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:50:12  */
  assign devs_bus_i = n455_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:51:12  */
  assign devs_bus_o = n456_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:82:12  */
  always @*
    irqs0 = n460_o; // (isignal)
  initial
    irqs0 = 8'b00000000;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/cpu/cpu2j0_pkg.vhd:94:18  */
  assign n113_o = n88_o[0]; // extract
  assign n117_o = {n113_o, 32'b00000000000000000000000000000000};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:56:16  */
  assign n124_o = n83_o[28:11]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:56:31  */
  assign n126_o = n124_o == 18'b101111001101000000;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:57:20  */
  assign n127_o = n83_o[10]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:57:24  */
  assign n128_o = ~n127_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:58:24  */
  assign n129_o = n83_o[9]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:58:28  */
  assign n130_o = ~n129_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:59:28  */
  assign n131_o = n83_o[8]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:59:32  */
  assign n132_o = ~n131_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:60:32  */
  assign n133_o = n83_o[7:5]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:60:45  */
  assign n135_o = n133_o == 3'b000;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:63:35  */
  assign n137_o = n83_o[7:4]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:63:48  */
  assign n139_o = n137_o == 4'b1000;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:63:25  */
  assign n143_o = n139_o ? 1'b0 : 1'b1;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:63:25  */
  assign n147_o = n139_o ? 3'b011 : 3'bX;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:60:25  */
  assign n149_o = n135_o ? 1'b0 : n143_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:60:25  */
  assign n152_o = n135_o ? 3'b100 : n147_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:67:31  */
  assign n153_o = n83_o[8:7]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:67:44  */
  assign n155_o = n153_o == 2'b11;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:67:21  */
  assign n159_o = n155_o ? 1'b0 : 1'b1;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:67:21  */
  assign n163_o = n155_o ? 3'b010 : 3'bX;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:59:21  */
  assign n164_o = n132_o ? n149_o : n159_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:59:21  */
  assign n166_o = n132_o ? n152_o : n163_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:71:27  */
  assign n167_o = n83_o[9:5]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:71:40  */
  assign n169_o = n167_o == 5'b10000;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:71:17  */
  assign n173_o = n169_o ? 1'b0 : 1'b1;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:71:17  */
  assign n177_o = n169_o ? 3'b101 : 3'bX;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:58:17  */
  assign n178_o = n130_o ? n164_o : n173_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:58:17  */
  assign n180_o = n130_o ? n166_o : n177_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:75:23  */
  assign n181_o = n83_o[10:7]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:75:36  */
  assign n183_o = n181_o == 4'b1000;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:75:13  */
  assign n187_o = n183_o ? 1'b0 : 1'b1;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:75:13  */
  assign n191_o = n183_o ? 3'b001 : 3'bX;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:57:13  */
  assign n192_o = n128_o ? n178_o : n187_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:57:13  */
  assign n194_o = n128_o ? n180_o : n191_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:56:9  */
  assign n196_o = n126_o ? n192_o : 1'b1;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:56:9  */
  assign n201_o = n126_o ? n194_o : 3'bX;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:80:9  */
  assign n207_o = n196_o ? 3'b000 : n201_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:88:38  */
  assign n209_o = 3'b101 - active_dev;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:90:71  */
  assign n215_o = 3'b000 == active_dev;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:49:5  */
  assign n222_o = n215_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:93:22  */
  assign n227_o = n83_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:93:16  */
  assign n228_o = n222_o & n227_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:94:22  */
  assign n230_o = n83_o[33]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:94:16  */
  assign n231_o = n222_o & n230_o;
  assign n233_o = n83_o[32:1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:95:22  */
  assign n234_o = n83_o[34]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:95:16  */
  assign n235_o = n222_o & n234_o;
  assign n236_o = n83_o[70:35]; // extract
  assign n237_o = {n236_o, n235_o, n231_o, n233_o, n228_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:90:71  */
  assign n241_o = 3'b001 == active_dev;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:49:5  */
  assign n248_o = n241_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:93:22  */
  assign n253_o = n83_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:93:16  */
  assign n254_o = n248_o & n253_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:94:22  */
  assign n256_o = n83_o[33]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:94:16  */
  assign n257_o = n248_o & n256_o;
  assign n259_o = n83_o[32:1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:95:22  */
  assign n260_o = n83_o[34]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:95:16  */
  assign n261_o = n248_o & n260_o;
  assign n262_o = n83_o[70:35]; // extract
  assign n263_o = {n262_o, n261_o, n257_o, n259_o, n254_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:90:71  */
  assign n267_o = 3'b010 == active_dev;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:49:5  */
  assign n274_o = n267_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:93:22  */
  assign n279_o = n83_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:93:16  */
  assign n280_o = n274_o & n279_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:94:22  */
  assign n282_o = n83_o[33]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:94:16  */
  assign n283_o = n274_o & n282_o;
  assign n285_o = n83_o[32:1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:95:22  */
  assign n286_o = n83_o[34]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:95:16  */
  assign n287_o = n274_o & n286_o;
  assign n288_o = n83_o[70:35]; // extract
  assign n289_o = {n288_o, n287_o, n283_o, n285_o, n280_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:90:71  */
  assign n293_o = 3'b011 == active_dev;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:49:5  */
  assign n300_o = n293_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:93:22  */
  assign n305_o = n83_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:93:16  */
  assign n306_o = n300_o & n305_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:94:22  */
  assign n308_o = n83_o[33]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:94:16  */
  assign n309_o = n300_o & n308_o;
  assign n311_o = n83_o[32:1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:95:22  */
  assign n312_o = n83_o[34]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:95:16  */
  assign n313_o = n300_o & n312_o;
  assign n314_o = n83_o[70:35]; // extract
  assign n315_o = {n314_o, n313_o, n309_o, n311_o, n306_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:90:71  */
  assign n319_o = 3'b100 == active_dev;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:49:5  */
  assign n326_o = n319_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:93:22  */
  assign n331_o = n83_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:93:16  */
  assign n332_o = n326_o & n331_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:94:22  */
  assign n334_o = n83_o[33]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:94:16  */
  assign n335_o = n326_o & n334_o;
  assign n337_o = n83_o[32:1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:95:22  */
  assign n338_o = n83_o[34]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:95:16  */
  assign n339_o = n326_o & n338_o;
  assign n340_o = n83_o[70:35]; // extract
  assign n341_o = {n340_o, n339_o, n335_o, n337_o, n332_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:90:71  */
  assign n345_o = 3'b101 == active_dev;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:49:5  */
  assign n352_o = n345_o ? 1'b1 : 1'b0;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:93:22  */
  assign n357_o = n83_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:93:16  */
  assign n358_o = n352_o & n357_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:94:22  */
  assign n360_o = n83_o[33]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:94:16  */
  assign n361_o = n352_o & n360_o;
  assign n363_o = n83_o[32:1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:95:22  */
  assign n364_o = n83_o[34]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/data_bus_pkg.vhd:95:16  */
  assign n365_o = n352_o & n364_o;
  assign n366_o = n83_o[70:35]; // extract
  assign n367_o = {n366_o, n365_o, n361_o, n363_o, n358_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/components/cpu/cpu2j0_pkg.vhd:94:18  */
  assign n375_o = devs_bus_o[355]; // extract
  assign n379_o = {n375_o, 32'b00000000000000000000000000000000};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:94:5  */
  ref_devices__aic_20_e72b4ff27ee3ed4623c72c79d0e6ca011b4a0698 aic0 (
    .clk_bus(clk_sys),
    .rst_i(reset),
    .db_i_en(n381_o),
    .db_i_a(n382_o),
    .db_i_rd(n383_o),
    .db_i_wr(n384_o),
    .db_i_we(n385_o),
    .db_i_d(n386_o),
    .bstb_i(cpu0_data_master_en),
    .back_i(cpu0_data_master_ack),
    .irq_i(irqs0),
    .enmi_i(n389_o),
    .event_i_ack(n390_o),
    .event_i_lvl(n391_o),
    .event_i_slp(n392_o),
    .event_i_dbg(n393_o),
    .db_o_d(aic0_db_o_d),
    .db_o_ack(aic0_db_o_ack),
    .rtc_sec(),
    .rtc_nsec(),
    .event_o_en(aic0_event_o_en),
    .event_o_cmd(aic0_event_o_cmd),
    .event_o_vec(aic0_event_o_vec),
    .event_o_msk(aic0_event_o_msk),
    .event_o_lvl(aic0_event_o_lvl));
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:103:31  */
  assign n380_o = devs_bus_o[354:284]; // extract
  assign n381_o = n380_o[0]; // extract
  assign n382_o = n380_o[32:1]; // extract
  assign n383_o = n380_o[33]; // extract
  assign n384_o = n380_o[34]; // extract
  assign n385_o = n380_o[38:35]; // extract
  assign n386_o = n380_o[70:39]; // extract
  assign n387_o = {aic0_db_o_ack, aic0_db_o_d};
  assign n390_o = n79_o[0]; // extract
  assign n391_o = n79_o[4:1]; // extract
  assign n392_o = n79_o[5]; // extract
  assign n393_o = n79_o[6]; // extract
  assign n394_o = {aic0_event_o_lvl, aic0_event_o_msk, aic0_event_o_vec, aic0_event_o_cmd, aic0_event_o_en};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:113:5  */
  ref_devices__icache_modereg cache_ctrl (
    .rst(reset),
    .clk(clk_sys),
    .db_i_en(n397_o),
    .db_i_a(n398_o),
    .db_i_rd(n399_o),
    .db_i_wr(n400_o),
    .db_i_we(n401_o),
    .db_i_d(n402_o),
    .cpu0_ddr_ibus_o_en(n405_o),
    .cpu0_ddr_ibus_o_a(n406_o),
    .cpu0_ddr_ibus_o_jp(n407_o),
    .cpu1_ddr_ibus_o_en(n408_o),
    .cpu1_ddr_ibus_o_a(n409_o),
    .cpu1_ddr_ibus_o_jp(n410_o),
    .db_o_d(cache_ctrl_db_o_d),
    .db_o_ack(cache_ctrl_db_o_ack),
    .cache0_ctrl_ic_en(cache_ctrl_cache0_ctrl_ic_en),
    .cache0_ctrl_ic_inv(cache_ctrl_cache0_ctrl_ic_inv),
    .cache1_ctrl_ic_en(cache_ctrl_cache1_ctrl_ic_en),
    .cache1_ctrl_ic_inv(cache_ctrl_cache1_ctrl_ic_inv),
    .cache0_ctrl_dc_en(cache_ctrl_cache0_ctrl_dc_en),
    .cache0_ctrl_dc_inv(cache_ctrl_cache0_ctrl_dc_inv),
    .cache1_ctrl_dc_en(cache_ctrl_cache1_ctrl_dc_en),
    .cache1_ctrl_dc_inv(cache_ctrl_cache1_ctrl_dc_inv),
    .int0(cache_ctrl_int0),
    .int1(),
    .cache01sel_ctrl_temp(cache_ctrl_cache01sel_ctrl_temp));
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:123:31  */
  assign n396_o = devs_bus_o[283:213]; // extract
  assign n397_o = n396_o[0]; // extract
  assign n398_o = n396_o[32:1]; // extract
  assign n399_o = n396_o[33]; // extract
  assign n400_o = n396_o[34]; // extract
  assign n401_o = n396_o[38:35]; // extract
  assign n402_o = n396_o[70:39]; // extract
  assign n403_o = {cache_ctrl_db_o_ack, cache_ctrl_db_o_d};
  assign n405_o = n72_o[0]; // extract
  assign n406_o = n72_o[31:1]; // extract
  assign n407_o = n72_o[32]; // extract
  assign n408_o = n84_o[0]; // extract
  assign n409_o = n84_o[31:1]; // extract
  assign n410_o = n84_o[32]; // extract
  assign n411_o = {cache_ctrl_cache0_ctrl_ic_inv, cache_ctrl_cache0_ctrl_ic_en};
  assign n413_o = {cache_ctrl_cache1_ctrl_ic_inv, cache_ctrl_cache1_ctrl_ic_en};
  assign n415_o = {cache_ctrl_cache0_ctrl_dc_inv, cache_ctrl_cache0_ctrl_dc_en};
  assign n417_o = {cache_ctrl_cache1_ctrl_dc_inv, cache_ctrl_cache1_ctrl_dc_en};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:129:5  */
  ref_devices__spi2_2_89fb3ab272c6c870879ac5ed9b6f8e6cfb09dc2d flash (
    .clk(clk_sys),
    .rst(reset),
    .db_i_en(n422_o),
    .db_i_a(n423_o),
    .db_i_rd(n424_o),
    .db_i_wr(n425_o),
    .db_i_we(n426_o),
    .db_i_d(n427_o),
    .miso(flash_miso),
    .db_o_d(flash_db_o_d),
    .db_o_ack(flash_db_o_ack),
    .spi_clk(flash_spi_clk),
    .cs(flash_cs),
    .mosi(flash_mosi));
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:137:31  */
  assign n421_o = devs_bus_o[212:142]; // extract
  assign n422_o = n421_o[0]; // extract
  assign n423_o = n421_o[32:1]; // extract
  assign n424_o = n421_o[33]; // extract
  assign n425_o = n421_o[34]; // extract
  assign n426_o = n421_o[38:35]; // extract
  assign n427_o = n421_o[70:39]; // extract
  assign n428_o = {flash_db_o_ack, flash_db_o_d};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:144:5  */
  ref_devices__pio_34d7de1b571aa545cf571b84dc4b40d1f42fed39 gpio (
    .clk_bus(clk_sys),
    .reset(reset),
    .db_i_en(n434_o),
    .db_i_a(n435_o),
    .db_i_rd(n436_o),
    .db_i_wr(n437_o),
    .db_i_we(n438_o),
    .db_i_d(n439_o),
    .p_i(pi),
    .db_o_d(gpio_db_o_d),
    .db_o_ack(gpio_db_o_ack),
    .irq(gpio_irq),
    .p_o(gpio_p_o));
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:147:31  */
  assign n433_o = devs_bus_o[141:71]; // extract
  assign n434_o = n433_o[0]; // extract
  assign n435_o = n433_o[32:1]; // extract
  assign n436_o = n433_o[33]; // extract
  assign n437_o = n433_o[34]; // extract
  assign n438_o = n433_o[38:35]; // extract
  assign n439_o = n433_o[70:39]; // extract
  assign n440_o = {gpio_db_o_ack, gpio_db_o_d};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:154:5  */
  ref_devices__uartlitedb_1_eee99cc82b436e2be5204cecddaa56d739e34653 uart0 (
    .rst(reset),
    .clk(clk_sys),
    .db_i_en(n445_o),
    .db_i_a(n446_o),
    .db_i_rd(n447_o),
    .db_i_wr(n448_o),
    .db_i_we(n449_o),
    .db_i_d(n450_o),
    .rx(uart0_rx),
    .db_o_d(uart0_db_o_d),
    .db_o_ack(uart0_db_o_ack),
    .int_i(uart0_int),
    .tx(uart0_tx));
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:162:31  */
  assign n444_o = devs_bus_o[70:0]; // extract
  assign n445_o = n444_o[0]; // extract
  assign n446_o = n444_o[32:1]; // extract
  assign n447_o = n444_o[33]; // extract
  assign n448_o = n444_o[34]; // extract
  assign n449_o = n444_o[38:35]; // extract
  assign n450_o = n444_o[70:39]; // extract
  assign n451_o = {uart0_db_o_ack, uart0_db_o_d};
  assign n455_o = {n379_o, n387_o, n403_o, n428_o, n440_o, n451_o};
  assign n456_o = {n237_o, n263_o, n289_o, n315_o, n341_o, n367_o};
  assign n457_o = n106_o[0]; // extract
  assign n458_o = n106_o[2]; // extract
  assign n459_o = n106_o[7:5]; // extract
  assign n460_o = {n459_o, gpio_irq, cache_ctrl_int0, n458_o, uart0_int, n457_o};
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:167:19  */
  assign n461_o = devs_bus_i[32:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:164:20  */
  assign n462_o = devs_bus_i[65:33]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:163:21  */
  assign n463_o = devs_bus_i[98:66]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:151:20  */
  assign n464_o = devs_bus_i[131:99]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:149:20  */
  assign n465_o = devs_bus_i[164:132]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:148:21  */
  assign n466_o = devs_bus_i[197:165]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:88:37  */
  assign n467_o = n209_o[1:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:88:37  */
  always @*
    case (n467_o)
      2'b00: n468_o = n461_o;
      2'b01: n468_o = n462_o;
      2'b10: n468_o = n463_o;
      2'b11: n468_o = n464_o;
    endcase
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:142:24  */
  assign n469_o = n209_o[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:88:37  */
  assign n470_o = n469_o ? n466_o : n465_o;
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:88:37  */
  assign n471_o = n209_o[2]; // extract
  /* /home/imi415/Documents/Workspaces/J2/reference/soc_top/targets/boards/mimas_v2/ref_devices__devices.vhd:88:37  */
  assign n472_o = n471_o ? n470_o : n468_o;
endmodule

module ref_devices
  (input  clk,
   input  rst,
   input  db_en,
   input  [31:0] db_a,
   input  db_rd,
   input  db_wr,
   input  [3:0] db_we,
   input  [31:0] db_d,
   input  mon_en,
   input  mon_ack,
   input  ev_o_ack,
   input  [3:0] ev_o_lvl,
   input  ev_o_slp,
   input  ev_o_dbg,
   input  uart_rx,
   input  spi_miso,
   input  [31:0] pi,
   output [31:0] db_q,
   output db_ack,
   output ev_i_en,
   output [1:0] ev_i_cmd,
   output [7:0] ev_i_vec,
   output ev_i_msk,
   output [3:0] ev_i_lvl,
   output uart_tx,
   output spi_clk,
   output [1:0] spi_cs,
   output spi_mosi,
   output [31:0] po,
   output ic_en,
   output ic_inv,
   output dc_en,
   output dc_inv);
  wire [70:0] dbus_o;
  wire [32:0] dbus_i;
  wire [6:0] evo;
  wire [15:0] evi;
  wire [1:0] ic0;
  wire [1:0] dc0;
  wire [31:0] n16_o;
  wire n17_o;
  wire n18_o;
  wire [1:0] n19_o;
  wire [7:0] n22_o;
  wire n23_o;
  wire [3:0] n24_o;
  wire n25_o;
  wire n26_o;
  wire n27_o;
  wire n28_o;
  wire u_cache01sel_ctrl_temp;
  wire u_cpu0_event_i_en;
  wire [1:0] u_cpu0_event_i_cmd;
  wire [7:0] u_cpu0_event_i_vec;
  wire u_cpu0_event_i_msk;
  wire [3:0] u_cpu0_event_i_lvl;
  wire [31:0] u_cpu0_periph_dbus_i_d;
  wire u_cpu0_periph_dbus_i_ack;
  wire [31:0] u_cpu1_periph_dbus_i_d;
  wire u_cpu1_periph_dbus_i_ack;
  wire u_dcache0_ctrl_en;
  wire u_dcache0_ctrl_inv;
  wire u_dcache1_ctrl_en;
  wire u_dcache1_ctrl_inv;
  wire u_flash_clk;
  wire [1:0] u_flash_cs;
  wire u_flash_mosi;
  wire u_icache0_ctrl_en;
  wire u_icache0_ctrl_inv;
  wire u_icache1_ctrl_en;
  wire u_icache1_ctrl_inv;
  wire [31:0] u_po;
  wire u_uart0_tx;
  localparam [32:0] n29_o = 33'b000000000000000000000000000000000;
  wire n30_o;
  wire [30:0] n31_o;
  wire n32_o;
  wire [15:0] n33_o;
  wire n35_o;
  wire [3:0] n36_o;
  wire n37_o;
  wire n38_o;
  wire [32:0] n39_o;
  wire n41_o;
  wire [31:0] n42_o;
  wire n43_o;
  wire n44_o;
  wire [3:0] n45_o;
  wire [31:0] n46_o;
  wire n47_o;
  wire [30:0] n48_o;
  wire n49_o;
  localparam [70:0] n51_o = 71'b00000000000000000000000000000000000000000000000000000000000000000000000;
  wire n52_o;
  wire [31:0] n53_o;
  wire n54_o;
  wire n55_o;
  wire [3:0] n56_o;
  wire [31:0] n57_o;
  wire [1:0] n58_o;
  wire [1:0] n64_o;
  wire [70:0] n69_o;
  wire [6:0] n70_o;
  assign db_q = n16_o; //(module output)
  assign db_ack = n17_o; //(module output)
  assign ev_i_en = n18_o; //(module output)
  assign ev_i_cmd = n19_o; //(module output)
  assign ev_i_vec = n22_o; //(module output)
  assign ev_i_msk = n23_o; //(module output)
  assign ev_i_lvl = n24_o; //(module output)
  assign uart_tx = u_uart0_tx; //(module output)
  assign spi_clk = u_flash_clk; //(module output)
  assign spi_cs = u_flash_cs; //(module output)
  assign spi_mosi = u_flash_mosi; //(module output)
  assign po = u_po; //(module output)
  assign ic_en = n25_o; //(module output)
  assign ic_inv = n26_o; //(module output)
  assign dc_en = n27_o; //(module output)
  assign dc_inv = n28_o; //(module output)
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:50:10  */
  assign dbus_o = n69_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:51:10  */
  assign dbus_i = n39_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:52:10  */
  assign evo = n70_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:53:10  */
  assign evi = n33_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:54:10  */
  assign ic0 = n64_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:54:15  */
  assign dc0 = n58_o; // (signal)
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:58:18  */
  assign n16_o = dbus_i[31:0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:58:41  */
  assign n17_o = dbus_i[32]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:60:19  */
  assign n18_o = evi[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:61:68  */
  assign n19_o = evi[2:1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:62:19  */
  assign n22_o = evi[10:3]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:62:41  */
  assign n23_o = evi[11]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:62:63  */
  assign n24_o = evi[15:12]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:63:16  */
  assign n25_o = ic0[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:63:35  */
  assign n26_o = ic0[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:63:54  */
  assign n27_o = dc0[0]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:63:73  */
  assign n28_o = dc0[1]; // extract
  /* /home/imi415/Documents/Workspaces/J2/ref/ref_devices.vhd:65:3  */
  ref_devices__devices u (
    .clk_sys(clk),
    .cpu0_data_master_ack(mon_ack),
    .cpu0_data_master_en(mon_en),
    .cpu0_ddr_ibus_o_en(n30_o),
    .cpu0_ddr_ibus_o_a(n31_o),
    .cpu0_ddr_ibus_o_jp(n32_o),
    .cpu0_event_o_ack(n35_o),
    .cpu0_event_o_lvl(n36_o),
    .cpu0_event_o_slp(n37_o),
    .cpu0_event_o_dbg(n38_o),
    .cpu0_periph_dbus_o_en(n41_o),
    .cpu0_periph_dbus_o_a(n42_o),
    .cpu0_periph_dbus_o_rd(n43_o),
    .cpu0_periph_dbus_o_wr(n44_o),
    .cpu0_periph_dbus_o_we(n45_o),
    .cpu0_periph_dbus_o_d(n46_o),
    .cpu1_ddr_ibus_o_en(n47_o),
    .cpu1_ddr_ibus_o_a(n48_o),
    .cpu1_ddr_ibus_o_jp(n49_o),
    .cpu1_periph_dbus_o_en(n52_o),
    .cpu1_periph_dbus_o_a(n53_o),
    .cpu1_periph_dbus_o_rd(n54_o),
    .cpu1_periph_dbus_o_wr(n55_o),
    .cpu1_periph_dbus_o_we(n56_o),
    .cpu1_periph_dbus_o_d(n57_o),
    .flash_miso(spi_miso),
    .pi(pi),
    .reset(rst),
    .uart0_rx(uart_rx),
    .cache01sel_ctrl_temp(),
    .cpu0_event_i_en(u_cpu0_event_i_en),
    .cpu0_event_i_cmd(u_cpu0_event_i_cmd),
    .cpu0_event_i_vec(u_cpu0_event_i_vec),
    .cpu0_event_i_msk(u_cpu0_event_i_msk),
    .cpu0_event_i_lvl(u_cpu0_event_i_lvl),
    .cpu0_periph_dbus_i_d(u_cpu0_periph_dbus_i_d),
    .cpu0_periph_dbus_i_ack(u_cpu0_periph_dbus_i_ack),
    .cpu1_periph_dbus_i_d(),
    .cpu1_periph_dbus_i_ack(),
    .dcache0_ctrl_en(u_dcache0_ctrl_en),
    .dcache0_ctrl_inv(u_dcache0_ctrl_inv),
    .dcache1_ctrl_en(),
    .dcache1_ctrl_inv(),
    .flash_clk(u_flash_clk),
    .flash_cs(u_flash_cs),
    .flash_mosi(u_flash_mosi),
    .icache0_ctrl_en(u_icache0_ctrl_en),
    .icache0_ctrl_inv(u_icache0_ctrl_inv),
    .icache1_ctrl_en(),
    .icache1_ctrl_inv(),
    .po(u_po),
    .uart0_tx(u_uart0_tx));
  assign n30_o = n29_o[0]; // extract
  assign n31_o = n29_o[31:1]; // extract
  assign n32_o = n29_o[32]; // extract
  assign n33_o = {u_cpu0_event_i_lvl, u_cpu0_event_i_msk, u_cpu0_event_i_vec, u_cpu0_event_i_cmd, u_cpu0_event_i_en};
  assign n35_o = evo[0]; // extract
  assign n36_o = evo[4:1]; // extract
  assign n37_o = evo[5]; // extract
  assign n38_o = evo[6]; // extract
  assign n39_o = {u_cpu0_periph_dbus_i_ack, u_cpu0_periph_dbus_i_d};
  assign n41_o = dbus_o[0]; // extract
  assign n42_o = dbus_o[32:1]; // extract
  assign n43_o = dbus_o[33]; // extract
  assign n44_o = dbus_o[34]; // extract
  assign n45_o = dbus_o[38:35]; // extract
  assign n46_o = dbus_o[70:39]; // extract
  assign n47_o = n29_o[0]; // extract
  assign n48_o = n29_o[31:1]; // extract
  assign n49_o = n29_o[32]; // extract
  assign n52_o = n51_o[0]; // extract
  assign n53_o = n51_o[32:1]; // extract
  assign n54_o = n51_o[33]; // extract
  assign n55_o = n51_o[34]; // extract
  assign n56_o = n51_o[38:35]; // extract
  assign n57_o = n51_o[70:39]; // extract
  assign n58_o = {u_dcache0_ctrl_inv, u_dcache0_ctrl_en};
  assign n64_o = {u_icache0_ctrl_inv, u_icache0_ctrl_en};
  assign n69_o = {db_d, db_we, db_wr, db_rd, db_a, db_en};
  assign n70_o = {ev_o_dbg, ev_o_slp, ev_o_lvl, ev_o_ack};
endmodule

