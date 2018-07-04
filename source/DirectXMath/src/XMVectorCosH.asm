
include DirectXMath.inc

    .data
    ;;
    ;; 1.0f / ln(2.0f)
    ;;
    Scale XMVECTORF32 { { { 1.442695040888963, 1.442695040888963, 1.442695040888963, 1.442695040888963 } } }

    .code

XMVectorCosH proc XM_CALLCONV V:FXMVECTOR

    _mm_mul_ps(xmm0, Scale)
    _mm_store_ps(xmm1, xmm0)
    _mm_store_ps(xmm3, g_XMNegativeOne)
    _mm_add_ps(xmm0, xmm3)
    _mm_sub_ps(xmm3, xmm1)
    _mm_store_ps(V, xmm0)
    XMVectorExp(xmm3)
    _mm_store_ps(V[16], xmm0)
    XMVectorExp(V)
    _mm_add_ps(xmm0, V[16])
    ret

XMVectorCosH endp

    end
