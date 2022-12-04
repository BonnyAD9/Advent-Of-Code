#include <iostream>

void Part2();
void Part1();

int main()
{
    //Part1();
    Part2();
}

void Part2()
{
    int overlapSectionCount = 0;
    while (!std::cin.eof())
    {
        int start1, end1, start2, end2;
        char c;

        std::cin >> start1 >> c >> end1 >> c >> start2 >> c >> end2;

        if (start1 <= end2 && end1 >= start2)
            ++overlapSectionCount;
    }

    std::cout << overlapSectionCount << std::endl;
}

void Part1()
{
    int fullyOverlapSectionCount = 0;
    while (!std::cin.eof())
    {
        int start1, end1, start2, end2;
        char c;

        std::cin >> start1 >> c >> end1 >> c >> start2 >> c >> end2;

        if (   (start1 >= start2 && end1 <= end2)
            || (start2 >= start1 && end2 <= end1))
            ++fullyOverlapSectionCount;
    }

    std::cout << fullyOverlapSectionCount << std::endl;
}
