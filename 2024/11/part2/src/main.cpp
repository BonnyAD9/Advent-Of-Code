#include <iostream>
#include <vector>
#include <unordered_map>
#include <cstdint>
#include <span>
#include <cmath>
#include <algorithm>

std::vector<std::uint64_t> blink(std::uint64_t n);
std::size_t blink(std::span<std::uint64_t> stones, std::size_t c);
size_t dig_cnt(std::uint64_t n);

int main(void) {
    std::vector<std::uint64_t> input{
        2, 72, 8949, 0, 981038, 86311, 246, 7636740
    };
    auto res = blink(input, 75);
    std::cout << res << std::endl;
}

class BlinkCache {
public:
    std::size_t blink(std::uint64_t n, std::size_t c) {
        auto &cnts = get_cnts(n);
        if (cnts.size() <= c) {
            cnts.resize(c + 1, 0);
        }
        if (cnts[c] != 0) {
            return cnts[c];
        }

        auto v = ::blink(n);
        auto res = blink(v, c - 1);
        return get_cnts(n)[c] = res;
    }

    std::size_t blink(std::span<std::uint64_t> v, std::size_t c) {
        std::size_t res = 0;
        for (auto n : v) {
            res += blink(n, c);
        }
        return res;
    }

private:
    std::vector<std::uint64_t> &get_cnts(std::uint64_t n) {
        auto &cnts = cache[n];
        if (cnts.size() < 2) {
            cnts.clear();
            cnts.push_back(n);
            cnts.push_back(::blink(n).size());
        }
        return cnts;
    }

    std::unordered_map<std::uint64_t, std::vector<std::size_t>> cache;
};

std::vector<std::uint64_t> blink(std::uint64_t n) {
    std::vector<std::uint64_t> res;
    if (n == 0) {
        res.push_back(1);
        return res;
    }

    auto dc = dig_cnt(n);
    if ((dc & 1) == 1) {
        res.push_back(n * 2024);
        return res;
    }

    auto p = std::uint64_t(std::pow(10, dc / 2));
    res.push_back(n / p);
    res.push_back(n % p);
    return res;
}

std::size_t blink(std::span<std::uint64_t> stones, std::size_t c) {
    BlinkCache cache;
    return cache.blink(stones, c);
}

size_t dig_cnt(std::uint64_t n) {
    return std::uint64_t(std::log10(n)) + 1;
}
