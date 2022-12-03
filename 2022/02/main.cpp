#include <iostream>

enum
{
    ROCK = 0,
    PAPER = 1,
    SCISSORS = 2,
};

void Part2();
void Part1();

int main()
{
    Part2();
}

void Part2()
{
    int otherTurn;
    int myTurn;
    int score = 0;

    do
    {
        otherTurn = std::cin.get() - 'A';
        std::cin.get();
        myTurn = std::cin.get() - 'X' - 1 + otherTurn;
        myTurn = (myTurn + 3) % 3;
        score += myTurn + 1;

        if (
            (myTurn == ROCK && otherTurn == PAPER) ||
            (myTurn == PAPER && otherTurn == SCISSORS) ||
            (myTurn == SCISSORS && otherTurn == ROCK))
            continue;

        score += 3 + 3 * (otherTurn != myTurn);
    } while (std::cin.get() != EOF);

    std::cout << score << std::endl;
}

void Part1()
{
    int otherTurn;
    int myTurn;
    int score = 0;

    do
    {
        otherTurn = std::cin.get() - 'A';
        std::cin.get();
        myTurn = std::cin.get() - 'X';
        score += myTurn + 1;

        if (
            (myTurn == ROCK && otherTurn == PAPER) ||
            (myTurn == PAPER && otherTurn == SCISSORS) ||
            (myTurn == SCISSORS && otherTurn == ROCK))
            continue;

        score += 3 + 3 * (otherTurn != myTurn);
    } while (std::cin.get() != EOF);

    std::cout << score << std::endl;
}
