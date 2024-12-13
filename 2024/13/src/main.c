#include <stdio.h>
#include <stdbool.h>
#include <tgmath.h>

typedef struct {
    long long ax;
    long long ay;
    long long bx;
    long long by;
    long long px;
    long long py;
} Machine;

bool read_machine(Machine *m);
bool solve_machine(const Machine *m, long long *a, long long *b);
void part2(Machine *m);

int main(void) {
    long long r = 0;
    Machine m;
    while (read_machine(&m)) {
        //part2(&m);
        long long a, b;
        if (solve_machine(&m, &a, &b)) {
            r += a * 3 + b;
        }
    }

    printf("%lld\n", r);
}

bool read_machine(Machine *m) {
    int r = scanf(" Button A: X%lld, Y%lld", &m->ax, &m->ay);
    r += scanf(" Button B: X%lld, Y%lld", &m->bx, &m->by);
    r += scanf(" Prize: X=%lld, Y=%lld", &m->px, &m->py);
    return r == 6;
}

bool solve_machine(const Machine *m, long long *a, long long *b) {
    long long ax = m->ax;
    long long bx = m->bx;
    long long px = m->px;

    long long ay = m->ay;
    long long by = m->by;
    long long py = m->py;

    if (ay != 0) {
        long long m = ax;
        ax *= ay;
        bx *= ay;
        px *= ay;
        ay = 0;
        by = by * m - bx;
        py = py * m - px;
    }

    *b = py / by;
    *a = (px - *b * bx) / ax;

    return *a * m->ax + *b * m->bx == m->px
        && *a * m->ay + *b * m->by == m->py
        && *a >= 0 && *b >= 0;
}

void part2(Machine *m) {
    m->px += 10000000000000;
    m->py += 10000000000000;
}
