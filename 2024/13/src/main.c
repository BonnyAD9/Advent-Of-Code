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
bool solve_machine(Machine *m, long long *a, long long *b);
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

bool solve_machine(Machine *m, long long *a, long long *b) {
    if (m->ay != 0) {
        long long n = m->ax;
        m->ax *= m->ay;
        m->bx *= m->ay;
        m->px *= m->ay;
        m->ay = 0;
        m->by = m->by * n - m->bx;
        m->py = m->py * n - m->px;
    }

    *b = m->py / m->by;
    *a = (m->px - *b * m->bx) / m->ax;

    return *a * m->ax + *b * m->bx == m->px
        && *a * m->ay + *b * m->by == m->py
        && *a >= 0 && *b >= 0;
}

void part2(Machine *m) {
    m->px += 10000000000000;
    m->py += 10000000000000;
}