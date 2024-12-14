#include <stdio.h>
#include <inttypes.h>

size_t get_quad(int64_t w, int64_t h, int64_t x, int64_t y);
void resolve_robot(
    int64_t w,
    int64_t h,
    int64_t *px,
    int64_t *py,
    int64_t vx,
    int64_t vy,
    int64_t t
);
int64_t pmod(int64_t v, int64_t n);

int main(void) {
    constexpr int64_t WIDTH = 101;
    constexpr int64_t HEIGHT = 103;
    constexpr int64_t END = 100;

    int64_t px, py, vx, vy;
    int64_t quads[5] = { 0 };

    while (scanf(" p=%ld,%ld v=%ld,%ld", &px, &py, &vx, &vy) == 4) {
        resolve_robot(WIDTH, HEIGHT, &px, &py, vx, vy, END);
        ++quads[get_quad(WIDTH, HEIGHT, px, py)];
    }

    int64_t res = 1;
    for (size_t i = 0; i < 4; ++i) {
        res *= quads[i];
    }

    printf("%ld\n", res);
}

void resolve_robot(
    int64_t w,
    int64_t h,
    int64_t *px,
    int64_t *py,
    int64_t vx,
    int64_t vy,
    int64_t t
) {
    *px = pmod(*px + vx * t, w);
    *py = pmod(*py + vy * t, h);
}

int64_t pmod(int64_t v, int64_t n) {
    int64_t r = v % n;
    return r < 0 ? r + n : r;
}

size_t get_quad(int64_t w, int64_t h, int64_t x, int64_t y) {
    int64_t xh = w / 2, yh = h / 2;

    if (((w & 1) && x == xh) || ((h & 1) && y == yh)) {
        return 4;
    }

    return (size_t)(x >= xh) << 1 | (y >= yh);
}
