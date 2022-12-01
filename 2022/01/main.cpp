#include <iostream> // std::cin, std::cout, std::endl
#include <array> // std::array
#include <numeric> // std::accumulate
#include <algorithm> // std::min_element

void Part1();
void Part2();

int main()
{
    //Part1();
    Part2();
}

void Part2()
{
    int chr;
    int currentElfSum = 0;
    std::array<int, 3> maxElfSums{ 0, 0, 0 };

    while ((chr = std::cin.peek()) != EOF)
    {
        if (chr == '\n')
        {
            std::cin.get();
            chr = std::cin.peek();

            if (chr == EOF)
                break;

            if (chr == '\n')
            {
                auto min = std::min_element(maxElfSums.begin(), maxElfSums.end());
                if (currentElfSum > *min)
                    *min = currentElfSum;

                currentElfSum = 0;
                continue;
            }
        }

        int num;
        std::cin >> num;
        currentElfSum += num;
    }

    auto min = std::min_element(maxElfSums.begin(), maxElfSums.end());
    if (currentElfSum > *min)
        *min = currentElfSum;

    std::cout << std::accumulate(maxElfSums.begin(), maxElfSums.end(), 0) << std::endl;
}

void Part1()
{
    int chr;
    int currentElfSum = 0;
    int maxElfSum = 0;

    while ((chr = std::cin.peek()) != EOF)
    {
        if (chr == '\n')
        {
            std::cin.get();
            chr = std::cin.peek();

            if (chr == EOF)
                break;

            if (chr == '\n')
            {
                if (currentElfSum > maxElfSum)
                    maxElfSum = currentElfSum;

                currentElfSum = 0;
                continue;
            }
        }

        int num;
        std::cin >> num;
        currentElfSum += num;
    }

    if (currentElfSum > maxElfSum)
        maxElfSum = currentElfSum;

    std::cout << maxElfSum << std::endl;
}
