#include <iostream>
#include <vector>
#include <unordered_map>
#include <cstdint>
#include <span>
#include <cmath>

void blink_to(std::vector<std::uint64_t> res, std::uint64_t n);
std::size_t blink(std::span<std::uint64_t> stones, std::size_t c);
size_t dig_cnt(std::uint64_t n);

class BlinkCache {
public:
    std::span<std::uint64_t> blink(std::uint64_t n, std::size_t c) {
        auto cnts = &get_cnts(n);
        auto last = first_lt(*cnts, c);
        if (last == c) {
            return (*cnts)[c];
        }

        std::vector<std::uint64_t> nv;
        for (std::size_t i = 0; i < (*cnts)[last].size(); ++i) {
            auto sp = blink((*cnts)[last][i], c - last);
            cnts = &get_cnts(n);
            auto size = sp.size();
            (void)size;
            nv.insert(nv.end(), sp.begin(), sp.end());
        }

        (*cnts)[c] = std::move(nv);

        return (*cnts)[c];
    }

private:
    std::vector<std::vector<std::uint64_t>> &get_cnts(std::uint64_t n) {
        auto &cnts = cache[n];
        if (cnts.size() < 2) {
            cnts.clear();
            std::vector<std::uint64_t> v;
            v.push_back(n);
            cnts.push_back(std::move(v));
            v = {};
            blink_to(v, n);
            cnts.push_back(std::move(v));
        }
        return cnts;
    }

    static std::size_t first_lt(std::vector<std::vector<std::uint64_t>> &v, std::size_t c) {
        if (v.size() <= c) {
            v.resize(c + 1);
        }
        for (std::size_t i = c; i <= c; --i) {
            if (!v[i].empty()) {
                return i;
            }
        }
        return 0;
    }

    std::unordered_map<std::uint64_t, std::vector<std::vector<std::uint64_t>>>
        cache;
};

int main(void) {
    std::vector<std::uint64_t> input{2, 72, 8949, 0, 981038, 86311, 246, 7636740};
    //std::vector<std::uint64_t> input{125, 17};
    auto res = blink(input, 75);
    std::cout << res << std::endl;
}

void blink_to(std::vector<std::uint64_t> res, std::uint64_t n) {
    std::vector<std::uint64_t> res;
    if (n == 0) {
        res.push_back(1);
        return;
    }

    auto dc = dig_cnt(n);
    if ((dc & 1) == 1) {
        res.push_back(n * 2024);
        return;
    }

    auto p = std::uint64_t(std::pow(10, dc / 2));
    res.push_back(n / p);
    res.push_back(n % p);
    return;
}

std::size_t blink(std::span<std::uint64_t> stones, std::size_t c) {
    BlinkCache cache;
    std::size_t res = 0;

    for (auto s : stones) {
        res += cache.blink(s, c).size();
    }

    return res;
}

size_t dig_cnt(std::uint64_t n) {
    return std::uint64_t(std::log10(n)) + 1;
}
