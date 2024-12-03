#include <stdio.h>
#include <stdlib.h>
#include <string.h>

constexpr size_t WIDTH = 1000;
constexpr size_t HEIGHT = 1000;

typedef struct {
    size_t x;
    size_t y;
} Vec2;

typedef struct {
    const char *pat;
    unsigned (*op)(unsigned);
} Action;

// part1
// unsigned on(unsigned) { return 1; }
// unsigned off(unsigned) { return 0; }
// unsigned toggle(unsigned v) { return !v; }

// part2
unsigned on(unsigned v) { return v + 1; }
unsigned off(unsigned v) { return v == 0 ? 0 : v - 1; }
unsigned toggle(unsigned v) { return v + 2; }

void operate(
    unsigned *data, size_t w, Vec2 s, Vec2 e, unsigned (*op)(unsigned)
);
size_t count(unsigned *data, size_t len);

int main(void) {
    constexpr auto DATA_LEN = WIDTH * HEIGHT;
    unsigned *data = malloc(sizeof(*data) * DATA_LEN);
    memset(data, 0, sizeof(*data) * DATA_LEN);

    const Action actions[] = {
        // this is stupid, but it works :)
        { " turn on %zu,%zu through %zu,%zu", on },
        { "oggle %zu,%zu through %zu,%zu", toggle },
        { "ff %zu,%zu through %zu,%zu", off },
    };
    constexpr size_t ACTIONS_LEN = (sizeof(actions) / sizeof(*actions));

    int res = 4;
    while (res == 4) {
        for (size_t i = 0; i < ACTIONS_LEN; ++i) {
            Vec2 s, e;
            res = scanf(actions[i].pat, &s.x, &s.y, &e.x, &e.y);
            if (res != 4) {
                continue;
            }

            operate(data, WIDTH, s, e, actions[i].op);
            break;
        }
    }

    printf("%zu\n", count(data, DATA_LEN));
    free(data);
}

void operate(
    unsigned *data, size_t w, Vec2 s, Vec2 e, unsigned (*op)(unsigned)
) {
    for (size_t y = s.y; y <= e.y; ++y) {
        for (size_t x = s.x; x <= e.x; ++x) {
            data[y * w + x] = op(data[y * w + x]);
        }
    }
}

size_t count(unsigned *data, size_t len) {
    size_t res = 0;
    while (--len) {
        res += *data++;
    }
    return res;
}
