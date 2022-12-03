#include <iostream>
#include <string>

void Part1();
void Part2();

int main()
{
    //Part1();
    Part2();
}

void Part2()
{
    std::string line1;
    std::string line2;
    std::string line3;
    int totalPriority = 0;

    while (!std::cin.eof())
    {
        std::cin >> line1;
        std::cin >> line2;
        std::cin >> line3;

        char duplicate = *std::find_if(line1.begin(), line1.end(), [&](char item)
        {
            return std::find(line2.begin(), line2.end(), item) != line2.end()
                && std::find(line3.begin(), line3.end(), item) != line3.end();
        });

        totalPriority += duplicate >= 'a' && duplicate <= 'z'
            ? duplicate - 'a' + 1
            : duplicate - 'A' + 27;
    }

    std::cout << totalPriority;
}

void Part1()
{
    std::string line;
    int totalPriority = 0;

    while (!std::cin.eof())
    {
        std::cin >> line;

        auto pivot = line.begin() + line.size() / 2;

        char duplicate = *std::find_if(line.begin(), pivot, [&](char item)
        {
            return std::find(pivot, line.end(), item) != line.end();
        });

        totalPriority += duplicate >= 'a' && duplicate <= 'z'
            ? duplicate - 'a' + 1
            : duplicate - 'A' + 27;
    }

    std::cout << totalPriority;
}
